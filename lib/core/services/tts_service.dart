import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';

import 'logger_service.dart';

/// Text-to-speech service for reading AI responses aloud
class TTSService {
  TTSService();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _currentLanguage = 'en-US';

  final _statusController = StreamController<TTSStatus>.broadcast();
  final _progressController = StreamController<TTSProgress>.broadcast();

  /// Stream of TTS status changes
  Stream<TTSStatus> get statusStream => _statusController.stream;

  /// Stream of TTS progress updates
  Stream<TTSProgress> get progressStream => _progressController.stream;

  /// Whether TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Whether TTS is paused
  bool get isPaused => _isPaused;

  /// Current language
  String get currentLanguage => _currentLanguage;

  /// Available languages
  List<String> _languages = [];
  List<String> get availableLanguages => _languages;

  /// Available voices
  List<dynamic> _voices = [];
  List<dynamic> get availableVoices => _voices;

  /// Initialize the TTS service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Set up handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        _statusController.add(TTSStatus.speaking);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _statusController.add(TTSStatus.stopped);
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _statusController.add(TTSStatus.stopped);
      });

      _flutterTts.setPauseHandler(() {
        _isPaused = true;
        _statusController.add(TTSStatus.paused);
      });

      _flutterTts.setContinueHandler(() {
        _isPaused = false;
        _statusController.add(TTSStatus.speaking);
      });

      _flutterTts.setErrorHandler((error) {
        logger.error('TTS error: $error', tag: 'TTSService');
        _isSpeaking = false;
        _isPaused = false;
        _statusController.add(TTSStatus.error);
      });

      _flutterTts.setProgressHandler((
        String text,
        int start,
        int end,
        String word,
      ) {
        _progressController.add(TTSProgress(
          text: text,
          start: start,
          end: end,
          word: word,
        ));
      });

      // Get available languages and voices
      _languages = List<String>.from(await _flutterTts.getLanguages as List);
      _voices = await _flutterTts.getVoices as List;

      // Set default configuration
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // iOS specific
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      // Android specific
      if (Platform.isAndroid) {
        await _flutterTts.setQueueMode(1); // Queue mode
      }

      _isInitialized = true;
      logger.info(
        'TTS service initialized with ${_languages.length} languages',
        tag: 'TTSService',
      );

      return true;
    } catch (e, stackTrace) {
      logger.error(
        'Error initializing TTS service',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Speak the given text
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _statusController.add(TTSStatus.error);
        return;
      }
    }

    try {
      // Set language if specified
      if (language != null && language != _currentLanguage) {
        await setLanguage(language);
      }

      // Stop any current speech
      if (_isSpeaking) {
        await stop();
      }

      await _flutterTts.speak(text);
    } catch (e, stackTrace) {
      logger.error(
        'Error speaking text',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
      _statusController.add(TTSStatus.error);
    }
  }

  /// Pause the current speech
  Future<void> pause() async {
    if (!_isSpeaking || _isPaused) return;

    try {
      await _flutterTts.pause();
    } catch (e, stackTrace) {
      logger.error(
        'Error pausing TTS',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Resume paused speech
  Future<void> resume() async {
    if (!_isPaused) return;

    try {
      // Note: resume is not supported on all platforms
      // On unsupported platforms, we'll need to re-speak from the beginning
      _isPaused = false;
      _statusController.add(TTSStatus.speaking);
    } catch (e, stackTrace) {
      logger.error(
        'Error resuming TTS',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Stop the current speech
  Future<void> stop() async {
    if (!_isSpeaking && !_isPaused) return;

    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _isPaused = false;
      _statusController.add(TTSStatus.stopped);
    } catch (e, stackTrace) {
      logger.error(
        'Error stopping TTS',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set the speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e, stackTrace) {
      logger.error(
        'Error setting speech rate',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set the pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e, stackTrace) {
      logger.error(
        'Error setting pitch',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e, stackTrace) {
      logger.error(
        'Error setting volume',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set the language
  Future<void> setLanguage(String language) async {
    try {
      final result = await _flutterTts.setLanguage(language);
      if (result == 1) {
        _currentLanguage = language;
        logger.debug('TTS language set to: $language', tag: 'TTSService');
      } else {
        logger.warning(
          'Failed to set TTS language: $language',
          tag: 'TTSService',
        );
      }
    } catch (e, stackTrace) {
      logger.error(
        'Error setting language',
        tag: 'TTSService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set language based on preferred language code
  Future<void> setLanguageFromCode(String languageCode) async {
    String language;
    if (languageCode == 'ar') {
      // Try Arabic variants
      if (_languages.contains('ar-SA')) {
        language = 'ar-SA';
      } else if (_languages.any((l) => l.startsWith('ar'))) {
        language = _languages.firstWhere((l) => l.startsWith('ar'));
      } else {
        language = 'en-US';
      }
    } else {
      // Default to English
      if (_languages.contains('en-US')) {
        language = 'en-US';
      } else if (_languages.contains('en-GB')) {
        language = 'en-GB';
      } else if (_languages.any((l) => l.startsWith('en'))) {
        language = _languages.firstWhere((l) => l.startsWith('en'));
      } else {
        language = _languages.isNotEmpty ? _languages.first : 'en-US';
      }
    }
    await setLanguage(language);
  }

  /// Check if a specific language is available
  bool isLanguageAvailable(String language) {
    return _languages.contains(language);
  }

  /// Dispose of resources
  void dispose() {
    _flutterTts.stop();
    _statusController.close();
    _progressController.close();
  }
}

/// TTS status
enum TTSStatus {
  speaking,
  paused,
  stopped,
  error,
}

/// TTS progress information
class TTSProgress {
  const TTSProgress({
    required this.text,
    required this.start,
    required this.end,
    required this.word,
  });

  final String text;
  final int start;
  final int end;
  final String word;
}
