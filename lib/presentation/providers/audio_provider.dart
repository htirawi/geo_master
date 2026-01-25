import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di/repository_providers.dart';
import '../../core/services/audio_service.dart';

/// Audio service provider - singleton instance
final audioServiceProvider = Provider<AudioService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final service = AudioService(prefs: prefs);

  // Dispose when provider is disposed
  ref.onDispose(service.dispose);

  return service;
});

/// Sound enabled state notifier
class SoundEnabledNotifier extends StateNotifier<bool> {
  SoundEnabledNotifier(this._audioService, SharedPreferences prefs)
      : super(prefs.getBool(_keySoundEnabled) ?? true);

  static const _keySoundEnabled = 'sound_enabled';

  final AudioService _audioService;

  /// Toggle sound on/off
  Future<void> toggle() async {
    state = !state;
    await _audioService.setSoundEnabled(state);
  }

  /// Set sound enabled
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _audioService.setSoundEnabled(enabled);
  }
}

/// Sound enabled provider
final soundEnabledProvider =
    StateNotifierProvider<SoundEnabledNotifier, bool>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return SoundEnabledNotifier(audioService, prefs);
});

/// Volume state notifier
class VolumeNotifier extends StateNotifier<double> {
  VolumeNotifier(this._audioService, SharedPreferences prefs)
      : super(prefs.getDouble(_keyVolume) ?? 1.0);

  static const _keyVolume = 'sound_volume';

  final AudioService _audioService;

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    state = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(state);
  }
}

/// Volume provider
final volumeProvider = StateNotifierProvider<VolumeNotifier, double>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return VolumeNotifier(audioService, prefs);
});

/// Convenience provider for checking if sound effects are available
final canPlaySoundProvider = Provider<bool>((ref) {
  final soundEnabled = ref.watch(soundEnabledProvider);
  return soundEnabled;
});
