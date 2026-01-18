import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quiz.dart';
import '../../features/country_explorer/presentation/screens/country_explorer_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/auth_screen.dart';
import '../../features/onboarding/presentation/screens/email_auth_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/personalization_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../features/country_explorer/presentation/screens/country_detail_screen.dart';
import '../../features/gamification/presentation/screens/achievements_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/legal/presentation/screens/terms_of_service_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../../features/quiz/presentation/screens/quiz_game_screen.dart';
import '../../features/quiz/presentation/screens/quiz_results_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../presentation/navigation/main_scaffold.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';
import 'routes.dart';

/// GoRouter configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  // Use ref.read instead of ref.watch to prevent router recreation
  // The refreshListenable will trigger redirects when auth state changes

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.read(authStateProvider.notifier).stream,
    ),
    redirect: (context, state) {
      // Read current state inside redirect (called on each navigation/refresh)
      final authState = ref.read(authStateProvider);
      final onboardingState = ref.read(onboardingStateProvider);

      final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
      final currentPath = state.matchedLocation;

      // Allow access to public routes without authentication
      final publicRoutes = [
        Routes.splash,
        Routes.languageSelection,
        Routes.onboarding,
        Routes.auth,
        Routes.emailAuth,
        Routes.termsOfService,
        Routes.privacyPolicy,
      ];

      final isPublicRoute = publicRoutes.contains(currentPath);

      // Splash screen handles its own navigation - don't redirect
      if (currentPath == Routes.splash) {
        return null;
      }

      // If not logged in and not on public route, redirect to auth
      if (!isLoggedIn && !isPublicRoute) {
        return Routes.auth;
      }

      // If logged in and on auth route, redirect to home or personalization
      if (isLoggedIn && currentPath == Routes.auth) {
        final needsPersonalization =
            onboardingState.valueOrNull?.needsPersonalization ?? true;
        if (needsPersonalization) {
          return Routes.personalization;
        }
        return Routes.home;
      }

      return null;
    },
    routes: [
      // Splash route (just for initial redirect)
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding routes
      GoRoute(
        path: Routes.languageSelection,
        name: RouteNames.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.auth,
        name: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: Routes.emailAuth,
        name: RouteNames.emailAuth,
        builder: (context, state) {
          final isSignUp = state.uri.queryParameters['signup'] == 'true';
          return EmailAuthScreen(isSignUp: isSignUp);
        },
      ),
      GoRoute(
        path: Routes.personalization,
        name: RouteNames.personalization,
        builder: (context, state) => const PersonalizationScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.explore,
            name: RouteNames.explore,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CountryExplorerScreen(),
            ),
          ),
          GoRoute(
            path: Routes.quiz,
            name: RouteNames.quiz,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuizScreen(),
            ),
          ),
          GoRoute(
            path: Routes.stats,
            name: RouteNames.stats,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatsScreen(),
            ),
          ),
          GoRoute(
            path: Routes.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Country detail screen
      GoRoute(
        path: Routes.countryDetail,
        name: RouteNames.countryDetail,
        builder: (context, state) {
          final code = state.pathParameters['code']!;
          return CountryDetailScreen(countryCode: code);
        },
      ),

      // Quiz routes
      GoRoute(
        path: Routes.quizModeSelection,
        name: RouteNames.quizModeSelection,
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: Routes.quizGame,
        name: RouteNames.quizGame,
        builder: (context, state) {
          // Parse mode and difficulty from query parameters
          final modeString = state.uri.queryParameters['mode'] ?? 'capitals';
          final difficultyString = state.uri.queryParameters['difficulty'] ?? 'medium';
          final region = state.uri.queryParameters['region'];

          // Convert strings to enums
          final mode = QuizMode.values.firstWhere(
            (m) => m.name == modeString,
            orElse: () => QuizMode.capitals,
          );
          final difficulty = QuizDifficulty.values.firstWhere(
            (d) => d.name == difficultyString,
            orElse: () => QuizDifficulty.medium,
          );

          return QuizGameScreen(
            mode: mode,
            difficulty: difficulty,
            region: region,
          );
        },
      ),
      GoRoute(
        path: Routes.quizResults,
        name: RouteNames.quizResults,
        builder: (context, state) => const QuizResultsScreen(),
      ),

      // AI Tutor chat screen
      GoRoute(
        path: Routes.aiTutor,
        name: RouteNames.aiTutor,
        builder: (context, state) {
          final countryCode = state.uri.queryParameters['country'];
          return AiTutorScreen(initialCountryCode: countryCode);
        },
      ),

      // Gamification screens
      GoRoute(
        path: Routes.achievements,
        name: RouteNames.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: Routes.leaderboard,
        name: RouteNames.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Settings screen
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Subscription screen
      GoRoute(
        path: Routes.paywall,
        name: RouteNames.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),

      // Legal screens
      GoRoute(
        path: Routes.termsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

/// Stream wrapper for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Error screen
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(Routes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
