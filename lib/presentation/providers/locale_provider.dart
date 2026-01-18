import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_provider.dart';

/// Locale provider that wraps the onboarding language state
final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(selectedLanguageProvider);
  return Locale(language);
});

/// Locale notifier for changing locale
class LocaleNotifier {
  LocaleNotifier(this._ref);

  final Ref _ref;

  void setLocale(Locale locale) {
    _ref.read(onboardingStateProvider.notifier).setLanguage(locale.languageCode);
  }
}

/// Locale notifier provider
final localeNotifierProvider = Provider(LocaleNotifier.new);

/// Extension to make locale changing easier
extension LocaleProviderExtension on Ref {
  LocaleNotifier get localeNotifier => read(localeNotifierProvider);
}
