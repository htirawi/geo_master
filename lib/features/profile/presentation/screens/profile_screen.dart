import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/routes.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/locale_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../presentation/providers/user_provider.dart';

/// User profile as Traveler's Passport - Explorer Theme
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final userProgress = ref.watch(userProgressProvider);
    final userPrefs = ref.watch(userPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Passport Header
          SliverToBoxAdapter(
            child: _PassportHeader(
              displayName: user?.displayName ?? l10n.guest,
              email: user?.email,
              photoUrl: user?.photoUrl,
              isPremium: user?.isPremium ?? false,
              isArabic: isArabic,
            ),
          ),
          // Content
          SliverPadding(
            padding: EdgeInsets.all(context.responsivePadding),
            sliver: SliverToBoxAdapter(
              child: ResponsiveCenter(
                maxWidth: 600,
                child: Column(
                  children: [
                    // Traveler Stats Card
                    _TravelerStatsCard(
                      isArabic: isArabic,
                      countriesLearned: userProgress.countriesLearned,
                      achievementsCount: userProgress.unlockedAchievements.length,
                      currentStreak: userProgress.currentStreak,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingLG),
                    // Premium banner (if not premium)
                    if (!(user?.isPremium ?? false)) ...[
                      _ExpeditionUpgradeCard(
                        isArabic: isArabic,
                        onTap: () => _showPremiumUpgrade(context),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: AppDimensions.spacingLG),
                    ],
                    // Journey Settings
                    _PassportSection(
                      title: l10n.preferences,
                      icon: Icons.compass_calibration,
                      isArabic: isArabic,
                      items: [
                        _PassportItem(
                          icon: Icons.language,
                          iconColor: AppColors.ocean,
                          title: l10n.language,
                          subtitle: isArabic ? l10n.arabic : l10n.english,
                          onTap: () => _showLanguageDialog(context, l10n),
                        ),
                        _PassportItem(
                          icon: Icons.dark_mode,
                          iconColor: AppColors.mountain,
                          title: l10n.theme,
                          subtitle: _getThemeLabel(themeMode, l10n),
                          onTap: () => _showThemeDialog(context, l10n),
                        ),
                        _PassportItem(
                          icon: Icons.notifications_active,
                          iconColor: AppColors.sunset,
                          title: l10n.notifications,
                          subtitle: userPrefs.notificationsEnabled
                              ? l10n.enabled
                              : l10n.disabled,
                          onTap: () => _showNotificationsDialog(context, l10n),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingLG),
                    // Expedition Settings
                    _PassportSection(
                      title: l10n.learningPreferences,
                      icon: Icons.explore,
                      isArabic: isArabic,
                      items: [
                        _PassportItem(
                          icon: Icons.terrain,
                          iconColor: AppColors.forest,
                          title: l10n.difficulty,
                          subtitle: _getDifficultyLabel(userPrefs.difficultyLevel, l10n),
                          onTap: () => _showDifficultyDialog(context, l10n),
                        ),
                        _PassportItem(
                          icon: Icons.flag,
                          iconColor: AppColors.secondary,
                          title: l10n.dailyGoal,
                          subtitle: '${userPrefs.dailyGoalMinutes} ${l10n.minutesPerDay}',
                          onTap: () => _showDailyGoalDialog(context, l10n),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingLG),
                    // Account Section
                    _PassportSection(
                      title: l10n.account,
                      icon: Icons.badge,
                      isArabic: isArabic,
                      items: [
                        if (user?.isAnonymous ?? true)
                          _PassportItem(
                            icon: Icons.person_add,
                            iconColor: AppColors.tertiary,
                            title: l10n.createAccount,
                            onTap: () => _showCreateAccountDialog(context, l10n),
                          ),
                        _PassportItem(
                          icon: Icons.privacy_tip,
                          iconColor: AppColors.info,
                          title: l10n.privacyPolicy,
                          onTap: () => _launchUrl(_privacyPolicyUrl),
                        ),
                        _PassportItem(
                          icon: Icons.description,
                          iconColor: AppColors.earth,
                          title: l10n.termsOfService,
                          onTap: () => _launchUrl(_termsOfServiceUrl),
                        ),
                        _PassportItem(
                          icon: Icons.help_center,
                          iconColor: AppColors.primary,
                          title: l10n.helpAndSupport,
                          onTap: () => _showHelpDialog(context, l10n),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingXL),
                    // Sign Out Button
                    _SignOutButton(
                      isSigningOut: _isSigningOut,
                      onPressed: () => _signOut(context),
                      isArabic: isArabic,
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingMD),
                    // App version
                    _AppVersionBadge(isArabic: isArabic)
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 500.ms),
                    const SizedBox(height: AppDimensions.spacingLG),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // URL constants
  static const String _privacyPolicyUrl = 'https://geomaster.app/privacy';
  static const String _termsOfServiceUrl = 'https://geomaster.app/terms';
  static const String _supportEmail = 'support@geomaster.app';

  String _getThemeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _getDifficultyLabel(String difficultyLevel, AppLocalizations l10n) {
    switch (difficultyLevel) {
      case 'easy':
        return l10n.difficultyEasy;
      case 'medium':
        return l10n.difficultyMedium;
      case 'hard':
        return l10n.difficultyHard;
      default:
        return l10n.difficultyMedium;
    }
  }

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final currentLocale = ref.read(localeProvider);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ocean.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: AppColors.ocean),
            ),
            const SizedBox(width: 12),
            Text(l10n.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              icon: Icons.translate,
              title: l10n.english,
              subtitle: 'English',
              isSelected: currentLocale.languageCode == 'en',
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(localeNotifierProvider).setLocale(const Locale('en'));
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              icon: Icons.translate,
              title: l10n.arabic,
              subtitle: 'العربية',
              isSelected: currentLocale.languageCode == 'ar',
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(localeNotifierProvider).setLocale(const Locale('ar'));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, dialogRef, _) {
          final userPrefs = dialogRef.watch(userPreferencesProvider);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sunset.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_active, color: AppColors.sunset),
                ),
                const SizedBox(width: 12),
                Text(l10n.notifications),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SwitchOption(
                  icon: Icons.notifications,
                  title: l10n.pushNotifications,
                  value: userPrefs.notificationsEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(notificationsEnabled: value);
                    dialogRef.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                  },
                ),
                const SizedBox(height: 12),
                _SwitchOption(
                  icon: Icons.volume_up,
                  title: l10n.soundEffects,
                  value: userPrefs.soundEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(soundEnabled: value);
                    dialogRef.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                  },
                ),
                const SizedBox(height: 12),
                _SwitchOption(
                  icon: Icons.vibration,
                  title: l10n.hapticFeedback,
                  value: userPrefs.hapticsEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(hapticsEnabled: value);
                    dialogRef.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.done),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final userPrefs = ref.read(userPreferencesProvider);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.forest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.terrain, color: AppColors.forest),
            ),
            const SizedBox(width: 12),
            Text(l10n.difficulty),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DifficultyOption(
              icon: Icons.sentiment_satisfied,
              title: l10n.difficultyEasy,
              subtitle: l10n.difficultyEasyDesc,
              color: AppColors.difficultyEasy,
              isSelected: userPrefs.difficultyLevel == 'easy',
              onTap: () {
                HapticFeedback.selectionClick();
                final updatedPrefs = userPrefs.copyWith(difficultyLevel: 'easy');
                ref.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _DifficultyOption(
              icon: Icons.sentiment_neutral,
              title: l10n.difficultyMedium,
              subtitle: l10n.difficultyMediumDesc,
              color: AppColors.difficultyMedium,
              isSelected: userPrefs.difficultyLevel == 'medium',
              onTap: () {
                HapticFeedback.selectionClick();
                final updatedPrefs = userPrefs.copyWith(difficultyLevel: 'medium');
                ref.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _DifficultyOption(
              icon: Icons.sentiment_very_dissatisfied,
              title: l10n.difficultyHard,
              subtitle: l10n.difficultyHardDesc,
              color: AppColors.difficultyHard,
              isSelected: userPrefs.difficultyLevel == 'hard',
              onTap: () {
                HapticFeedback.selectionClick();
                final updatedPrefs = userPrefs.copyWith(difficultyLevel: 'hard');
                ref.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    final userPrefs = ref.read(userPreferencesProvider);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.flag, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Text(l10n.dailyGoal),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [5, 10, 15, 20, 30])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DailyGoalOption(
                  minutes: minutes,
                  label: '$minutes ${l10n.minutesPerDay}',
                  isSelected: userPrefs.dailyGoalMinutes == minutes,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(dailyGoalMinutes: minutes);
                    ref.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateAccountDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add, color: AppColors.tertiary),
            ),
            const SizedBox(width: 12),
            Text(l10n.createAccount),
          ],
        ),
        content: Text(l10n.createAccountDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push(Routes.auth);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
            ),
            child: Text(l10n.signUp),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help_center, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(l10n.helpAndSupport),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email, color: AppColors.info, size: 20),
              ),
              title: Text(l10n.contactUs),
              subtitle: const Text(_supportEmail),
              onTap: () {
                Navigator.pop(dialogContext);
                _launchUrl('mailto:$_supportEmail');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rate_review, color: AppColors.secondary, size: 20),
              ),
              title: Text(l10n.rateApp),
              onTap: () {
                Navigator.pop(dialogContext);
                _requestAppReview(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.share, color: AppColors.tertiary, size: 20),
              ),
              title: Text(l10n.shareApp),
              onTap: () {
                Navigator.pop(dialogContext);
                _shareApp(context, l10n);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgrade(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.push(Routes.subscription);
  }

  Future<void> _requestAppReview(BuildContext context) async {
    HapticFeedback.lightImpact();
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      // Fallback to opening store listing
      await inAppReview.openStoreListing(
        appStoreId: _appStoreId,
      );
    }
  }

  Future<void> _shareApp(BuildContext context, AppLocalizations l10n) async {
    HapticFeedback.lightImpact();

    final String shareText = '''
${l10n.appTitle} - ${l10n.appTagline}

Download now:
iOS: https://apps.apple.com/app/id$_appStoreId
Android: https://play.google.com/store/apps/details?id=$_androidPackageName
''';

    await Share.share(
      shareText,
      subject: l10n.appTitle,
    );
  }

  // App Store IDs
  static const String _appStoreId = ''; // Add your App Store ID when available
  static const String _androidPackageName = 'com.geomaster.app';

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mountain.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dark_mode, color: AppColors.mountain),
            ),
            const SizedBox(width: 12),
            Text(l10n.theme),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.light_mode,
              title: l10n.lightMode,
              isSelected: ref.read(themeModeProvider) == ThemeMode.light,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: l10n.darkMode,
              isSelected: ref.read(themeModeProvider) == ThemeMode.dark,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              icon: Icons.settings_suggest,
              title: l10n.systemDefault,
              isSelected: ref.read(themeModeProvider) == ThemeMode.system,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    HapticFeedback.mediumImpact();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            Text(l10n.signOut),
          ],
        ),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isSigningOut = true);

      try {
        await ref.read(authStateProvider.notifier).signOut();
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, l10n.errorUnknown);
        }
      } finally {
        if (mounted) {
          setState(() => _isSigningOut = false);
        }
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Passport Header with stamps pattern
class _PassportHeader extends StatelessWidget {
  const _PassportHeader({
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.isPremium,
    required this.isArabic,
  });

  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool isPremium;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.oceanDeep, // Explorer theme - deep ocean
            AppColors.ocean,
            AppColors.primary,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Passport stamps pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PassportStampsPainter(),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: Column(
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.badge,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.passportTitle,
                              style: (isArabic
                                      ? GoogleFonts.cairo(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ))
                                  .copyWith(color: Colors.white),
                            ),
                            Text(
                              l10n.travelerIdSubtitle,
                              style: (isArabic
                                      ? GoogleFonts.cairo(fontSize: 12)
                                      : GoogleFonts.poppins(fontSize: 12))
                                  .copyWith(
                                      color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Passport Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Photo
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.dividerLight,
                                  width: 2,
                                ),
                                image: photoUrl != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(photoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.textTertiaryLight,
                                    )
                                  : null,
                            ),
                            if (isPremium)
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.premiumGradient,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.travelerName.toUpperCase(),
                                style: GoogleFonts.robotoMono(
                                  fontSize: 10,
                                  color: AppColors.textTertiaryLight,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayName,
                                style: (isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          )
                                        : GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ))
                                    .copyWith(color: AppColors.textPrimaryLight),
                              ),
                              const SizedBox(height: 8),
                              if (email != null) ...[
                                Text(
                                  l10n.contactEmail.toUpperCase(),
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 10,
                                    color: AppColors.textTertiaryLight,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email!,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              if (isPremium)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.premiumGradient,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.premiumExplorer.toUpperCase(),
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.robotoMono)(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: isArabic ? 0 : 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for passport stamps pattern
class _PassportStampsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final random = math.Random(42);

    // Draw circular stamps
    for (var i = 0; i < 8; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 30;

      canvas.drawCircle(Offset(x, y), radius, paint);
      canvas.drawCircle(Offset(x, y), radius - 5, paint);
    }

    // Draw some rectangular stamps
    for (var i = 0; i < 5; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final w = 40 + random.nextDouble() * 40;
      final h = 25 + random.nextDouble() * 20;
      final rotation = random.nextDouble() * 0.5 - 0.25;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(4),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Traveler stats card showing exploration progress
class _TravelerStatsCard extends StatelessWidget {
  const _TravelerStatsCard({
    required this.isArabic,
    required this.countriesLearned,
    required this.achievementsCount,
    required this.currentStreak,
  });

  final bool isArabic;
  final int countriesLearned;
  final int achievementsCount;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiary,
            AppColors.tertiaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.journeyStats,
                style: (isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ))
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.public,
                  value: '$countriesLearned',
                  label: l10n.countriesVisited,
                  isArabic: isArabic,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.emoji_events,
                  value: '$achievementsCount',
                  label: l10n.achievements,
                  isArabic: isArabic,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.local_fire_department,
                  value: '$currentStreak',
                  label: l10n.dayStreakLabel,
                  isArabic: isArabic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isArabic,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: (isArabic
                  ? GoogleFonts.cairo(fontSize: 11)
                  : GoogleFonts.poppins(fontSize: 11))
              .copyWith(color: Colors.white.withValues(alpha: 0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Expedition upgrade card
class _ExpeditionUpgradeCard extends StatelessWidget {
  const _ExpeditionUpgradeCard({
    required this.isArabic,
    required this.onTap,
  });

  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.premium.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.upgradeToPremium,
                      style: (isArabic
                              ? GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
                              : GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ))
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.unlockAllFeatures,
                      style: (isArabic
                              ? GoogleFonts.cairo(fontSize: 12)
                              : GoogleFonts.poppins(fontSize: 12))
                          .copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.upgrade,
                  style: (isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )
                          : GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ))
                      .copyWith(color: AppColors.premium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Passport section with items
class _PassportSection extends StatelessWidget {
  const _PassportSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.isArabic,
  });

  final String title;
  final IconData icon;
  final List<_PassportItem> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: (isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ))
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingSM),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((entry) => Column(
                      children: [
                        entry.value,
                        if (entry.key < items.length - 1)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: theme.dividerColor.withValues(alpha: 0.5),
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

/// Passport item with icon and action
class _PassportItem extends StatelessWidget {
  const _PassportItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )
                            : GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ))
                        .copyWith(color: theme.colorScheme.onSurface),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: (isArabic
                              ? GoogleFonts.cairo(fontSize: 13)
                              : GoogleFonts.poppins(fontSize: 13))
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            Icon(
              isArabic ? Icons.chevron_left : Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme option in dialog
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

/// Sign out button
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({
    required this.isSigningOut,
    required this.onPressed,
    required this.isArabic,
  });

  final bool isSigningOut;
  final VoidCallback onPressed;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isSigningOut ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSigningOut)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.error,
                ),
              )
            else
              const Icon(Icons.logout, size: 20),
            const SizedBox(width: 10),
            Text(
              isSigningOut ? l10n.signingOut : l10n.signOut,
              style: (isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ))
                  .copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

/// App version badge
class _AppVersionBadge extends StatelessWidget {
  const _AppVersionBadge({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.explore,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '${l10n.appTitle} v1.0.0',
            style: (isArabic
                    ? GoogleFonts.cairo(fontSize: 12)
                    : GoogleFonts.poppins(fontSize: 12))
                .copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Language option in dialog - professional design without flags
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ocean.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.ocean, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.ocean.withValues(alpha: 0.2)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.ocean : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isArabic
                            ? GoogleFonts.cairo(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 15,
                              )
                            : GoogleFonts.poppins(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 15,
                              ))
                        .copyWith(
                      color: isSelected ? AppColors.ocean : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: (isArabic
                            ? GoogleFonts.cairo(fontSize: 12)
                            : GoogleFonts.poppins(fontSize: 12))
                        .copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.ocean),
          ],
        ),
      ),
    );
  }
}

/// Switch option for settings
class _SwitchOption extends StatelessWidget {
  const _SwitchOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.sunset, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: (isArabic
                      ? GoogleFonts.cairo(fontSize: 14)
                      : GoogleFonts.poppins(fontSize: 14))
                  .copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.sunset.withValues(alpha: 0.6),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.sunset;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

/// Difficulty option in dialog
class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isArabic
                            ? GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                              )
                            : GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ))
                        .copyWith(
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: (isArabic
                            ? GoogleFonts.cairo(fontSize: 12)
                            : GoogleFonts.poppins(fontSize: 12))
                        .copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}

/// Daily goal option in dialog
class _DailyGoalOption extends StatelessWidget {
  const _DailyGoalOption({
    required this.minutes,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final int minutes;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Calculate intensity based on minutes
    final intensity = (minutes / 30).clamp(0.3, 1.0);
    final color = Color.lerp(AppColors.success, AppColors.secondary, intensity)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$minutes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: (isArabic
                        ? GoogleFonts.cairo(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          )
                        : GoogleFonts.poppins(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ))
                    .copyWith(
                  color: isSelected ? color : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
