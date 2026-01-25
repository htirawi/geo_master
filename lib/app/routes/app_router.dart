import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/quiz.dart';
import '../../features/ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../features/continent_explorer/presentation/screens/continent_detail_screen.dart';
import '../../features/continent_explorer/presentation/screens/continent_explorer_screen.dart';
import '../../features/country_explorer/presentation/screens/country_detail_screen.dart';
import '../../features/country_explorer/presentation/screens/country_detail_tabbed_screen.dart';
import '../../features/country_explorer/presentation/screens/country_explorer_screen.dart';
import '../../features/gamification/presentation/screens/achievements_screen.dart';
import '../../features/gamification/presentation/screens/leaderboard_screen.dart';
import '../../features/goals/presentation/screens/weekly_goals_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../../features/legal/presentation/screens/terms_of_service_screen.dart';
import '../../features/onboarding/presentation/screens/auth_screen.dart';
import '../../features/onboarding/presentation/screens/email_auth_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/personalization_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/presentation/screens/quiz_game_screen.dart';
import '../../features/quiz/presentation/screens/quiz_results_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/social/presentation/screens/friends_screen.dart';
import '../../features/stats/presentation/screens/stats_dashboard_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/tournament/presentation/screens/tournament_screen.dart';
import '../../features/world_map/presentation/screens/world_map_screen.dart';
import '../../presentation/navigation/main_scaffold.dart';
import '../../presentation/navigation/page_transitions.dart';
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

      // Onboarding routes - Fade transitions for smooth flow
      GoRoute(
        path: Routes.languageSelection,
        name: RouteNames.languageSelection,
        pageBuilder: (context, state) => FadeTransitionPage(
          child: const LanguageSelectionScreen(),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => FadeTransitionPage(
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: Routes.auth,
        name: RouteNames.auth,
        pageBuilder: (context, state) => FadeTransitionPage(
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: Routes.emailAuth,
        name: RouteNames.emailAuth,
        pageBuilder: (context, state) {
          final isSignUp = state.uri.queryParameters['signup'] == 'true';
          return SlideUpTransitionPage(
            child: EmailAuthScreen(isSignUp: isSignUp),
          );
        },
      ),
      GoRoute(
        path: Routes.personalization,
        name: RouteNames.personalization,
        pageBuilder: (context, state) => FadeTransitionPage(
          child: const PersonalizationScreen(),
        ),
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

      // Country detail screen (simple version) - Hero transition for shared element
      GoRoute(
        path: Routes.countryDetail,
        name: RouteNames.countryDetail,
        pageBuilder: (context, state) {
          final code = state.pathParameters['code']!;
          return HeroTransitionPage(
            child: CountryDetailScreen(countryCode: code),
          );
        },
      ),

      // Country detail tabbed screen (enhanced 5-tab version)
      GoRoute(
        path: Routes.countryDetailTabbed,
        name: RouteNames.countryDetailTabbed,
        pageBuilder: (context, state) {
          final code = state.pathParameters['code']!;
          final tabString = state.uri.queryParameters['tab'];
          final initialTab = tabString != null ? int.tryParse(tabString) ?? 0 : 0;
          return SlideUpTransitionPage(
            child: CountryDetailTabbedScreen(
              countryCode: code,
              initialTab: initialTab,
            ),
          );
        },
      ),

      // World map screen (full screen for immersive experience) - Zoom transition
      GoRoute(
        path: Routes.worldMap,
        name: RouteNames.worldMap,
        pageBuilder: (context, state) {
          final continentFilter = state.uri.queryParameters['continent'];
          return ZoomFadeTransitionPage(
            child: WorldMapScreen(initialContinent: continentFilter),
          );
        },
      ),

      // Continent explorer screen
      GoRoute(
        path: Routes.continentExplorer,
        name: RouteNames.continentExplorer,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const ContinentExplorerScreen(),
        ),
      ),

      // Continent detail screen
      GoRoute(
        path: Routes.continentDetail,
        name: RouteNames.continentDetail,
        pageBuilder: (context, state) {
          final continentId = state.pathParameters['id']!;
          return SlideUpTransitionPage(
            child: ContinentDetailScreen(continentId: continentId),
          );
        },
      ),

      // Quiz routes
      GoRoute(
        path: Routes.quizModeSelection,
        name: RouteNames.quizModeSelection,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const QuizScreen(),
        ),
      ),
      GoRoute(
        path: Routes.quizGame,
        name: RouteNames.quizGame,
        pageBuilder: (context, state) {
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

          return ZoomFadeTransitionPage(
            child: QuizGameScreen(
              mode: mode,
              difficulty: difficulty,
              region: region,
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.quizResults,
        name: RouteNames.quizResults,
        pageBuilder: (context, state) => ZoomFadeTransitionPage(
          child: const QuizResultsScreen(),
        ),
      ),

      // AI Tutor chat screen - Slide up for modal-like feel
      GoRoute(
        path: Routes.aiTutor,
        name: RouteNames.aiTutor,
        pageBuilder: (context, state) {
          final countryCode = state.uri.queryParameters['country'];
          return SlideUpTransitionPage(
            child: AiTutorScreen(initialCountryCode: countryCode),
          );
        },
      ),

      // Gamification screens
      GoRoute(
        path: Routes.achievements,
        name: RouteNames.achievements,
        pageBuilder: (context, state) => ZoomFadeTransitionPage(
          child: const AchievementsScreen(),
        ),
      ),
      GoRoute(
        path: Routes.leaderboard,
        name: RouteNames.leaderboard,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const LeaderboardScreen(),
        ),
      ),

      // Tournament screen
      GoRoute(
        path: Routes.tournaments,
        name: RouteNames.tournaments,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const TournamentScreen(),
        ),
      ),

      // Stats dashboard screen
      GoRoute(
        path: Routes.statsDashboard,
        name: RouteNames.statsDashboard,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const StatsDashboardScreen(),
        ),
      ),

      // Friends screen
      GoRoute(
        path: Routes.friends,
        name: RouteNames.friends,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const FriendsScreen(),
        ),
      ),

      // Weekly goals screen
      GoRoute(
        path: Routes.weeklyGoals,
        name: RouteNames.weeklyGoals,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const WeeklyGoalsScreen(),
        ),
      ),

      // Settings screen
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        pageBuilder: (context, state) => SlideHorizontalTransitionPage(
          child: const SettingsScreen(),
        ),
      ),

      // Subscription screen - Modal-style for paywall
      GoRoute(
        path: Routes.paywall,
        name: RouteNames.paywall,
        pageBuilder: (context, state) => ModalTransitionPage(
          child: const PaywallScreen(),
        ),
      ),

      // Legal screens - Slide up for modal-like document view
      GoRoute(
        path: Routes.termsOfService,
        name: RouteNames.termsOfService,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const TermsOfServiceScreen(),
        ),
      ),
      GoRoute(
        path: Routes.privacyPolicy,
        name: RouteNames.privacyPolicy,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          child: const PrivacyPolicyScreen(),
        ),
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
