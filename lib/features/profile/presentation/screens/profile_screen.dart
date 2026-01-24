import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../widgets/app_version_badge.dart';
import '../widgets/dialog_options.dart';
import '../widgets/expedition_upgrade_card.dart';
import '../widgets/passport_header.dart';
import '../widgets/passport_section.dart';
import '../widgets/sign_out_button.dart';
import '../widgets/traveler_stats_card.dart';

/// User profile as Traveler's Passport - Explorer Theme
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isSigningOut = false;

  // URL constants
  static const String _privacyPolicyUrl = 'https://geomaster.app/privacy';
  static const String _termsOfServiceUrl = 'https://geomaster.app/terms';
  static const String _supportEmail = 'support@geomaster.app';
  static const String _appStoreId = '';
  static const String _androidPackageName = 'com.geomaster.app';

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
            child: PassportHeader(
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
                    TravelerStatsCard(
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
                      ExpeditionUpgradeCard(
                        isArabic: isArabic,
                        onTap: () => _showPremiumUpgrade(context),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: AppDimensions.spacingLG),
                    ],
                    // Journey Settings
                    PassportSection(
                      title: l10n.preferences,
                      icon: Icons.compass_calibration,
                      isArabic: isArabic,
                      items: [
                        PassportItem(
                          icon: Icons.language,
                          iconColor: AppColors.ocean,
                          title: l10n.language,
                          subtitle: isArabic ? l10n.arabic : l10n.english,
                          onTap: () => _showLanguageDialog(context, l10n),
                        ),
                        PassportItem(
                          icon: Icons.dark_mode,
                          iconColor: AppColors.mountain,
                          title: l10n.theme,
                          subtitle: _getThemeLabel(themeMode, l10n),
                          onTap: () => _showThemeDialog(context, l10n),
                        ),
                        PassportItem(
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
                    PassportSection(
                      title: l10n.learningPreferences,
                      icon: Icons.explore,
                      isArabic: isArabic,
                      items: [
                        PassportItem(
                          icon: Icons.terrain,
                          iconColor: AppColors.forest,
                          title: l10n.difficulty,
                          subtitle: _getDifficultyLabel(userPrefs.difficultyLevel, l10n),
                          onTap: () => _showDifficultyDialog(context, l10n),
                        ),
                        PassportItem(
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
                    PassportSection(
                      title: l10n.account,
                      icon: Icons.badge,
                      isArabic: isArabic,
                      items: [
                        if (user?.isAnonymous ?? true)
                          PassportItem(
                            icon: Icons.person_add,
                            iconColor: AppColors.tertiary,
                            title: l10n.createAccount,
                            onTap: () => _showCreateAccountDialog(context, l10n),
                          ),
                        PassportItem(
                          icon: Icons.privacy_tip,
                          iconColor: AppColors.info,
                          title: l10n.privacyPolicy,
                          onTap: () => _launchUrl(_privacyPolicyUrl),
                        ),
                        PassportItem(
                          icon: Icons.description,
                          iconColor: AppColors.earth,
                          title: l10n.termsOfService,
                          onTap: () => _launchUrl(_termsOfServiceUrl),
                        ),
                        PassportItem(
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
                    SignOutButton(
                      isSigningOut: _isSigningOut,
                      onPressed: () => _signOut(context),
                      isArabic: isArabic,
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: AppDimensions.spacingMD),
                    // App version
                    AppVersionBadge(isArabic: isArabic)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.ocean.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.language, color: AppColors.ocean),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(l10n.language),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LanguageOption(
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
            const SizedBox(height: AppDimensions.xs),
            LanguageOption(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.xs),
                  decoration: BoxDecoration(
                    color: AppColors.sunset.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(Icons.notifications_active, color: AppColors.sunset),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(l10n.notifications),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchOption(
                  icon: Icons.notifications,
                  title: l10n.pushNotifications,
                  value: userPrefs.notificationsEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(notificationsEnabled: value);
                    dialogRef.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                  },
                ),
                const SizedBox(height: AppDimensions.sm),
                SwitchOption(
                  icon: Icons.volume_up,
                  title: l10n.soundEffects,
                  value: userPrefs.soundEnabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    final updatedPrefs = userPrefs.copyWith(soundEnabled: value);
                    dialogRef.read(userProfileProvider.notifier).updatePreferences(updatedPrefs);
                  },
                ),
                const SizedBox(height: AppDimensions.sm),
                SwitchOption(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.forest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.terrain, color: AppColors.forest),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(l10n.difficulty),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DifficultyOption(
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
            const SizedBox(height: AppDimensions.xs),
            DifficultyOption(
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
            const SizedBox(height: AppDimensions.xs),
            DifficultyOption(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.flag, color: AppColors.secondary),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(l10n.dailyGoal),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in [5, 10, 15, 20, 30])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DailyGoalOption(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.person_add, color: AppColors.tertiary),
            ),
            const SizedBox(width: AppDimensions.sm),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.help_center, color: AppColors.primary),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(l10n.helpAndSupport),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(Icons.email, color: AppColors.info, size: AppDimensions.iconSM),
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
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(Icons.rate_review, color: AppColors.secondary, size: AppDimensions.iconSM),
              ),
              title: Text(l10n.rateApp),
              onTap: () {
                Navigator.pop(dialogContext);
                _requestAppReview(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(Icons.share, color: AppColors.tertiary, size: AppDimensions.iconSM),
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
      await inAppReview.openStoreListing(appStoreId: _appStoreId);
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

    await Share.share(shareText, subject: l10n.appTitle);
  }

  void _showThemeDialog(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.mountain.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.dark_mode, color: AppColors.mountain),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(l10n.theme),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeOption(
              icon: Icons.light_mode,
              title: l10n.lightMode,
              isSelected: ref.read(themeModeProvider) == ThemeMode.light,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: AppDimensions.xs),
            ThemeOption(
              icon: Icons.dark_mode,
              title: l10n.darkMode,
              isSelected: ref.read(themeModeProvider) == ThemeMode.dark,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: AppDimensions.xs),
            ThemeOption(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.xs),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: const Icon(Icons.logout, color: AppColors.error),
            ),
            const SizedBox(width: AppDimensions.sm),
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
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
        margin: const EdgeInsets.all(AppDimensions.md),
      ),
    );
  }
}
