import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/di/service_locator.dart';
import 'core/constants/arabic_country_names.dart';
import 'core/services/translation_service.dart';
import 'firebase_options.dart';

/// Bootstrap the application
Future<void> bootstrap() async {
  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (!kDebugMode) {
      // Log to Crashlytics in production
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

  // Initialize Firebase
  await _initFirebase();

  // Initialize service locator
  await initServiceLocator();

  // Load Arabic translations from bundled JSON asset
  await ArabicCountryNames.loadFromAsset();

  // Initialize translation service (Firebase Remote Config layer)
  await sl<TranslationService>().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

/// Initialize Firebase
Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
}
