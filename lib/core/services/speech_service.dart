import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'logger_service.dart';

/// Speech-to-text service for voice input
class SpeechService {
  SpeechService();

  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  final _statusController = StreamController<SpeechStatus>.broadcast();
  final _resultController = StreamController<SpeechResult>.broadcast();

  /// Stream of speech recognition status changes
  Stream<SpeechStatus> get statusStream => _statusController.stream;

  /// Stream of speech recognition results
  Stream<SpeechResult> get resultStream => _resultController.stream;

  /// Whether the service is currently listening
  bool get isListening => _isListening;

  /// Whether speech recognition is available on this device
  bool get isAvailable => _isInitialized;

  /// List of available locales for speech recognition
  List<LocaleName> _locales = [];

  /// Get available locales
  List<LocaleName> get availableLocales => _locales;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
        debugLogging: false,
      );

      if (_isInitialized) {
        _locales = await _speechToText.locales();
        logger.info(
          'Speech service initialized with ${_locales.length} locales',
          tag: 'SpeechService',
        );
      } else {
        logger.warning(
          'Speech service failed to initialize',
          tag: 'SpeechService',
        );
      }

      return _isInitialized;
    } catch (e, stackTrace) {
      logger.error(
        'Error initializing speech service',
        tag: 'SpeechService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    String? localeId,
    Duration? listenFor,
    Duration? pauseFor,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _statusController.add(SpeechStatus.unavailable);
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    try {
      _isListening = true;
      _statusController.add(SpeechStatus.listening);

      await _speechToText.listen(
        onResult: _onResult,
        localeId: localeId,
        listenFor: listenFor ?? const Duration(seconds: 30),
        pauseFor: pauseFor ?? const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Error starting speech recognition',
        tag: 'SpeechService',
        error: e,
        stackTrace: stackTrace,
      );
      _isListening = false;
      _statusController.add(SpeechStatus.error);
    }
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      _statusController.add(SpeechStatus.notListening);
    } catch (e, stackTrace) {
      logger.error(
        'Error stopping speech recognition',
        tag: 'SpeechService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel the current speech recognition session
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _statusController.add(SpeechStatus.notListening);
    } catch (e, stackTrace) {
      logger.error(
        'Error cancelling speech recognition',
        tag: 'SpeechService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    _resultController.add(SpeechResult(
      recognizedWords: result.recognizedWords,
      finalResult: result.finalResult,
      confidence: result.confidence,
    ));
  }

  void _onStatus(String status) {
    logger.debug('Speech status: $status', tag: 'SpeechService');

    switch (status) {
      case 'listening':
        _statusController.add(SpeechStatus.listening);
        break;
      case 'notListening':
        _isListening = false;
        _statusController.add(SpeechStatus.notListening);
        break;
      case 'done':
        _isListening = false;
        _statusController.add(SpeechStatus.done);
        break;
      default:
        break;
    }
  }

  void _onError(dynamic error) {
    logger.error(
      'Speech recognition error: $error',
      tag: 'SpeechService',
    );
    _isListening = false;
    _statusController.add(SpeechStatus.error);
  }

  /// Dispose of resources
  void dispose() {
    _speechToText.stop();
    _statusController.close();
    _resultController.close();
  }

  /// Check if a specific locale is supported
  bool isLocaleSupported(String localeId) {
    return _locales.any((locale) => locale.localeId == localeId);
  }

  /// Get the locale ID for Arabic
  String? get arabicLocaleId {
    final arabicLocale = _locales.firstWhere(
      (locale) =>
          locale.localeId.startsWith('ar') ||
          locale.localeId.contains('Arab'),
      orElse: () => LocaleName('', ''),
    );
    return arabicLocale.localeId.isNotEmpty ? arabicLocale.localeId : null;
  }

  /// Get the locale ID for English
  String? get englishLocaleId {
    final englishLocale = _locales.firstWhere(
      (locale) => locale.localeId.startsWith('en'),
      orElse: () => LocaleName('', ''),
    );
    return englishLocale.localeId.isNotEmpty ? englishLocale.localeId : null;
  }
}

/// Speech recognition status
enum SpeechStatus {
  listening,
  notListening,
  done,
  error,
  unavailable,
}

/// Speech recognition result
class SpeechResult {
  const SpeechResult({
    required this.recognizedWords,
    required this.finalResult,
    required this.confidence,
  });

  final String recognizedWords;
  final bool finalResult;
  final double confidence;
}
