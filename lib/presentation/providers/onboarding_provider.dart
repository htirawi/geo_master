import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/di/repository_providers.dart';

/// Onboarding state
class OnboardingState {
  const OnboardingState({
    this.hasSelectedLanguage = false,
    this.hasCompletedOnboarding = false,
    this.needsPersonalization = true,
    this.selectedLanguage = 'ar', // Arabic as default
  });

  final bool hasSelectedLanguage;
  final bool hasCompletedOnboarding;
  final bool needsPersonalization;
  final String selectedLanguage;

  OnboardingState copyWith({
    bool? hasSelectedLanguage,
    bool? hasCompletedOnboarding,
    bool? needsPersonalization,
    String? selectedLanguage,
  }) {
    return OnboardingState(
      hasSelectedLanguage: hasSelectedLanguage ?? this.hasSelectedLanguage,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      needsPersonalization: needsPersonalization ?? this.needsPersonalization,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

/// Onboarding state notifier
class OnboardingStateNotifier extends StateNotifier<AsyncValue<OnboardingState>> {
  OnboardingStateNotifier(this._prefs)
      : super(const AsyncValue.loading()) {
    _loadState();
  }

  static const _keyLanguageSelected = 'has_selected_language';
  static const _keyOnboardingCompleted = 'has_completed_onboarding';
  static const _keyNeedsPersonalization = 'needs_personalization';
  static const _keySelectedLanguage = 'selected_language';

  final SharedPreferences _prefs;

  void _loadState() {
    final hasSelectedLanguage = _prefs.getBool(_keyLanguageSelected) ?? false;
    final hasCompletedOnboarding =
        _prefs.getBool(_keyOnboardingCompleted) ?? false;
    final needsPersonalization =
        _prefs.getBool(_keyNeedsPersonalization) ?? true;
    final selectedLanguage = _prefs.getString(_keySelectedLanguage) ?? 'ar';

    state = AsyncValue.data(
      OnboardingState(
        hasSelectedLanguage: hasSelectedLanguage,
        hasCompletedOnboarding: hasCompletedOnboarding,
        needsPersonalization: needsPersonalization,
        selectedLanguage: selectedLanguage,
      ),
    );
  }

  /// Set selected language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(_keySelectedLanguage, language);
    await _prefs.setBool(_keyLanguageSelected, true);

    state = AsyncValue.data(
      state.valueOrNull?.copyWith(
            hasSelectedLanguage: true,
            selectedLanguage: language,
          ) ??
          OnboardingState(
            hasSelectedLanguage: true,
            selectedLanguage: language,
          ),
    );
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyOnboardingCompleted, true);

    state = AsyncValue.data(
      state.valueOrNull?.copyWith(hasCompletedOnboarding: true) ??
          const OnboardingState(hasCompletedOnboarding: true),
    );
  }

  /// Complete personalization
  Future<void> completePersonalization() async {
    await _prefs.setBool(_keyNeedsPersonalization, false);

    state = AsyncValue.data(
      state.valueOrNull?.copyWith(needsPersonalization: false) ??
          const OnboardingState(needsPersonalization: false),
    );
  }

  /// Reset onboarding (for testing)
  Future<void> reset() async {
    await _prefs.remove(_keyLanguageSelected);
    await _prefs.remove(_keyOnboardingCompleted);
    await _prefs.remove(_keyNeedsPersonalization);
    await _prefs.remove(_keySelectedLanguage);

    state = const AsyncValue.data(OnboardingState());
  }
}

/// Onboarding state provider
final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, AsyncValue<OnboardingState>>(
        (ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingStateNotifier(prefs);
});

/// Selected language provider
final selectedLanguageProvider = Provider<String>((ref) {
  final onboardingState = ref.watch(onboardingStateProvider);
  return onboardingState.valueOrNull?.selectedLanguage ?? 'ar';
});

/// Is Arabic provider
final isArabicProvider = Provider<bool>((ref) {
  final language = ref.watch(selectedLanguageProvider);
  return language == 'ar';
});
