import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routes/app_router.dart';
import 'l10n/generated/app_localizations.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/providers/theme_provider.dart';

/// Main application widget
class GeoMasterApp extends ConsumerWidget {
  const GeoMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isArabic = ref.watch(isArabicProvider);
    final lightTheme = ref.watch(lightThemeProvider(isArabic));
    final darkTheme = ref.watch(darkThemeProvider(isArabic));
    final selectedLanguage = ref.watch(selectedLanguageProvider);

    return MaterialApp.router(
      title: 'GeoMaster',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,

      // Localization
      locale: Locale(selectedLanguage),
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Routing
      routerConfig: router,

      // Builder for global overlay configuration
      builder: (context, child) {
        return MediaQuery(
          // Prevent text scaling for consistent UI
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
