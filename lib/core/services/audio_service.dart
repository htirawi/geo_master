import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger_service.dart';

/// Sound effect categories for the app
enum SoundCategory {
  feedback, // correct, incorrect, streak, xp_tick
  ui, // tap, swoosh
  celebration, // achievement, level_up, confetti
}

/// Available sound effects in the app
enum SoundEffect {
  // Feedback sounds
  correct('feedback/correct', SoundCategory.feedback),
  incorrect('feedback/incorrect', SoundCategory.feedback),
  streak('feedback/streak', SoundCategory.feedback),
  xpTick('feedback/xp_tick', SoundCategory.feedback),

  // UI sounds
  tap('ui/tap', SoundCategory.ui),
  swoosh('ui/swoosh', SoundCategory.ui),

  // Celebration sounds
  achievement('celebration/achievement', SoundCategory.celebration),
  levelUp('celebration/level_up', SoundCategory.celebration),
  confetti('celebration/confetti', SoundCategory.celebration);

  const SoundEffect(this.path, this.category);

  /// Path to the sound file (without extension)
  final String path;

  /// Category of the sound
  final SoundCategory category;

  /// Full asset path
  String get assetPath => 'assets/sounds/$path.mp3';
}

/// Audio service status
enum AudioStatus {
  idle,
  playing,
  error,
}

/// Audio service for playing sound effects
/// Follows the TTS service pattern with preloading and accessibility support
class AudioService {
  AudioService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  bool _isInitialized = false;
  bool _soundEnabled = true;
  double _volume = 1.0;

  final _statusController = StreamController<AudioStatus>.broadcast();
  final Map<SoundEffect, AudioPlayer> _players = {};
  final Map<SoundEffect, bool> _preloaded = {};

  /// Stream of audio status changes
  Stream<AudioStatus> get statusStream => _statusController.stream;

  /// Whether sound is currently enabled
  bool get soundEnabled => _soundEnabled;

  /// Current volume (0.0 to 1.0)
  double get volume => _volume;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  static const _keySoundEnabled = 'sound_enabled';
  static const _keyVolume = 'sound_volume';

  /// Initialize the audio service
  Future<bool> initialize({SharedPreferences? prefs}) async {
    if (_isInitialized) return true;

    try {
      _prefs = prefs ?? _prefs;

      // Load user preferences
      if (_prefs != null) {
        _soundEnabled = _prefs!.getBool(_keySoundEnabled) ?? true;
        _volume = _prefs!.getDouble(_keyVolume) ?? 1.0;
      }

      // Configure AudioPlayers for short sound effects
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            audioMode: AndroidAudioMode.normal,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      // Preload common sounds for instant playback
      await _preloadSounds([
        SoundEffect.correct,
        SoundEffect.incorrect,
        SoundEffect.tap,
      ]);

      _isInitialized = true;
      logger.info(
        'Audio service initialized (sound: ${_soundEnabled ? "on" : "off"})',
        tag: 'AudioService',
      );

      return true;
    } catch (e, stackTrace) {
      logger.error(
        'Error initializing audio service',
        tag: 'AudioService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Preload sounds for instant playback
  Future<void> _preloadSounds(List<SoundEffect> sounds) async {
    for (final sound in sounds) {
      try {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        player.setVolume(_volume);

        // Try to preload the asset
        final assetExists = await _assetExists(sound.assetPath);
        if (assetExists) {
          await player.setSource(AssetSource(sound.assetPath.replaceFirst('assets/', '')));
          _players[sound] = player;
          _preloaded[sound] = true;
          logger.debug('Preloaded sound: ${sound.name}', tag: 'AudioService');
        } else {
          logger.warning('Sound asset not found: ${sound.assetPath}', tag: 'AudioService');
          _preloaded[sound] = false;
        }
      } catch (e) {
        logger.warning('Failed to preload ${sound.name}: $e', tag: 'AudioService');
        _preloaded[sound] = false;
      }
    }
  }

  /// Check if an asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Play a sound effect
  Future<void> play(SoundEffect sound, {double? volume}) async {
    if (!_soundEnabled) return;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Check if asset exists
      if (_preloaded[sound] == false) {
        logger.debug('Skipping missing sound: ${sound.name}', tag: 'AudioService');
        return;
      }

      _statusController.add(AudioStatus.playing);

      // Use preloaded player or create new one
      AudioPlayer player;
      if (_players.containsKey(sound)) {
        player = _players[sound]!;
        await player.stop();
        await player.seek(Duration.zero);
      } else {
        // Check if asset exists before creating player
        final assetExists = await _assetExists(sound.assetPath);
        if (!assetExists) {
          _preloaded[sound] = false;
          logger.debug('Sound asset not found: ${sound.assetPath}', tag: 'AudioService');
          return;
        }

        player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(AssetSource(sound.assetPath.replaceFirst('assets/', '')));
        _players[sound] = player;
        _preloaded[sound] = true;
      }

      await player.setVolume(volume ?? _volume);
      await player.resume();

      // Reset status when done
      player.onPlayerComplete.listen((_) {
        _statusController.add(AudioStatus.idle);
      });
    } catch (e, stackTrace) {
      logger.error(
        'Error playing sound: ${sound.name}',
        tag: 'AudioService',
        error: e,
        stackTrace: stackTrace,
      );
      _statusController.add(AudioStatus.error);
    }
  }

  /// Play correct answer sound
  Future<void> playCorrect() => play(SoundEffect.correct);

  /// Play incorrect answer sound
  Future<void> playIncorrect() => play(SoundEffect.incorrect);

  /// Play streak milestone sound
  Future<void> playStreak() => play(SoundEffect.streak);

  /// Play XP tick sound (for animated counters)
  Future<void> playXpTick() => play(SoundEffect.xpTick, volume: 0.3);

  /// Play tap/button press sound
  Future<void> playTap() => play(SoundEffect.tap, volume: 0.5);

  /// Play swoosh/transition sound
  Future<void> playSwoosh() => play(SoundEffect.swoosh);

  /// Play achievement unlock sound
  Future<void> playAchievement() => play(SoundEffect.achievement);

  /// Play level up sound
  Future<void> playLevelUp() => play(SoundEffect.levelUp);

  /// Play confetti burst sound
  Future<void> playConfetti() => play(SoundEffect.confetti);

  /// Set sound enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs?.setBool(_keySoundEnabled, enabled);

    logger.debug('Sound ${enabled ? "enabled" : "disabled"}', tag: 'AudioService');
  }

  /// Toggle sound on/off
  Future<void> toggleSound() => setSoundEnabled(!_soundEnabled);

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _prefs?.setDouble(_keyVolume, _volume);

    // Update all preloaded players
    for (final player in _players.values) {
      await player.setVolume(_volume);
    }

    logger.debug('Volume set to $_volume', tag: 'AudioService');
  }

  /// Trigger haptic feedback based on sound type
  Future<void> playWithHaptic(
    SoundEffect sound, {
    HapticFeedbackType hapticType = HapticFeedbackType.light,
  }) async {
    // Trigger haptic first for immediate feedback
    switch (hapticType) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
      case HapticFeedbackType.vibrate:
        await HapticFeedback.vibrate();
    }

    // Then play sound
    await play(sound);
  }

  /// Stop all playing sounds
  Future<void> stopAll() async {
    for (final player in _players.values) {
      await player.stop();
    }
    _statusController.add(AudioStatus.idle);
  }

  /// Dispose of resources
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _preloaded.clear();
    await _statusController.close();
  }
}

/// Haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}
