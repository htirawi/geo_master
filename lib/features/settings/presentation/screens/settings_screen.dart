import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../domain/entities/user.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/providers/onboarding_provider.dart';
import '../../../../presentation/providers/theme_provider.dart';
import '../../../../presentation/providers/user_preferences_provider.dart';
import '../../../../presentation/providers/user_provider.dart';

/// Settings screen with all app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = ref.watch(userDataProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final localPrefs = ref.watch(localLearningPreferencesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final spacingMD = responsive.sp(AppDimensions.spacingMD);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final spacingXL = responsive.sp(AppDimensions.spacingXL);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ResponsiveCenter(
        child: ListView(
          children: [
          // Account Section
          _buildSectionHeader(context, theme, l10n.account),
          _AccountTile(user: user),
          const Divider(height: 1),

          // Appearance Section
          _buildSectionHeader(context, theme, l10n.appearance),
          _buildThemeTile(context, theme, l10n, themeMode),
          const Divider(height: 1),
          _buildLanguageTile(context, theme, l10n, selectedLanguage, isArabic),
          const Divider(height: 1),

          // Preferences Section
          _buildSectionHeader(context, theme, l10n.preferences),
          _buildSwitchTile(
            theme: theme,
            icon: Icons.volume_up,
            title: l10n.soundEffects,
            value: preferences.soundEnabled,
            onChanged: (value) => _updatePreference(
              preferences.copyWith(soundEnabled: value),
            ),
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            theme: theme,
            icon: Icons.vibration,
            title: l10n.haptics,
            value: preferences.hapticsEnabled,
            onChanged: (value) => _updatePreference(
              preferences.copyWith(hapticsEnabled: value),
            ),
          ),
          const Divider(height: 1),

          // Learning Preferences Section
          _buildSectionHeader(context, theme, l10n.learningPreferences),
          _buildInterestsTile(theme, l10n, preferences, localPrefs),
          const Divider(height: 1),
          _buildDifficultySettingsTile(theme, l10n, preferences, localPrefs),
          const Divider(height: 1),
          _buildLearningDailyGoalTile(theme, l10n, preferences, localPrefs),
          const Divider(height: 1),

          // Notifications Section
          _buildSectionHeader(context, theme, l10n.notifications),
          _buildSwitchTile(
            theme: theme,
            icon: Icons.notifications,
            title: l10n.notifications,
            value: preferences.notificationsEnabled,
            onChanged: (value) => _updatePreference(
              preferences.copyWith(notificationsEnabled: value),
            ),
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            theme: theme,
            icon: Icons.alarm,
            title: l10n.dailyReminder,
            value: preferences.dailyReminderEnabled,
            onChanged: preferences.notificationsEnabled
                ? (value) => _updatePreference(
                      preferences.copyWith(dailyReminderEnabled: value),
                    )
                : null,
          ),
          const Divider(height: 1),

          // Premium Section
          if (!(user?.isPremium ?? false)) ...[
            _buildSectionHeader(context, theme, l10n.premium),
            _buildPremiumTile(context, theme, l10n),
            const Divider(height: 1),
          ],

          // About Section
          _buildSectionHeader(context, theme, l10n.about),
          _buildNavigationTile(
            theme: theme,
            icon: Icons.privacy_tip,
            title: l10n.privacyPolicy,
            onTap: () => _showInfoDialog(l10n.privacyPolicy),
          ),
          const Divider(height: 1),
          _buildNavigationTile(
            theme: theme,
            icon: Icons.description,
            title: l10n.termsOfService,
            onTap: () => _showInfoDialog(l10n.termsOfService),
          ),
          const Divider(height: 1),
          _buildNavigationTile(
            theme: theme,
            icon: Icons.star_rate,
            title: l10n.rateApp,
            onTap: _rateApp,
          ),
          const Divider(height: 1),
          _buildNavigationTile(
            theme: theme,
            icon: Icons.share,
            title: l10n.shareApp,
            onTap: _shareApp,
          ),
          const Divider(height: 1),
          _buildVersionTile(theme, l10n),
          const Divider(height: 1),

          // Sign Out
          SizedBox(height: spacingMD),
          _buildSignOutTile(context, theme, l10n),

          // Delete Account
          if (!(user?.isAnonymous ?? true)) ...[
            SizedBox(height: spacingSM),
            _buildDeleteAccountTile(context, theme, l10n),
          ],

          SizedBox(height: spacingXL),
        ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, String title) {
    final responsive = ResponsiveUtils.of(context);
    return Padding(
      padding: responsive.insetsOnly(
        left: AppDimensions.paddingMD,
        top: AppDimensions.paddingLG,
        right: AppDimensions.paddingMD,
        bottom: AppDimensions.paddingSM,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    ThemeMode themeMode,
  ) {
    return ListTile(
      leading: Icon(
        themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
        color: theme.colorScheme.primary,
      ),
      title: Text(l10n.theme),
      subtitle: Text(_getThemeName(l10n, themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(l10n, themeMode),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String selectedLanguage,
    bool isArabic,
  ) {
    return ListTile(
      leading: Icon(Icons.language, color: theme.colorScheme.primary),
      title: Text(l10n.language),
      subtitle: Text(isArabic ? 'العربية' : 'English'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(l10n, selectedLanguage),
    );
  }

  Widget _buildSwitchTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: onChanged != null
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: onChanged != null
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInterestsTile(
    ThemeData theme,
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    final interestNames = localPrefs.interests
        .map((id) => _getInterestLabel(l10n, id))
        .toList();
    final subtitle = interestNames.isEmpty
        ? l10n.noInterestsSelected
        : interestNames.join(', ');

    return ListTile(
      leading: Icon(Icons.interests, color: theme.colorScheme.primary),
      title: Text(l10n.yourInterests),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showInterestsDialog(l10n, cloudPrefs, localPrefs),
    );
  }

  Widget _buildDifficultySettingsTile(
    ThemeData theme,
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    return ListTile(
      leading: Icon(Icons.speed, color: theme.colorScheme.primary),
      title: Text(l10n.quizDifficulty),
      subtitle: Text(_getDifficultyLabel(l10n, localPrefs.difficulty)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDifficultyDialog(l10n, cloudPrefs, localPrefs),
    );
  }

  Widget _buildLearningDailyGoalTile(
    ThemeData theme,
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    return ListTile(
      leading: Icon(Icons.flag, color: theme.colorScheme.primary),
      title: Text(l10n.dailyLearningGoal),
      subtitle: Text(_getDailyGoalLabel(l10n, localPrefs.dailyGoal)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLearningDailyGoalDialog(l10n, cloudPrefs, localPrefs),
    );
  }

  String _getInterestLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case 'flags':
        return l10n.interestFlags;
      case 'capitals':
        return l10n.interestCapitals;
      case 'culture':
        return l10n.interestCulture;
      case 'geography':
        return l10n.interestGeography;
      case 'languages':
        return l10n.interestLanguages;
      case 'history':
        return l10n.interestHistory;
      default:
        return id;
    }
  }

  String _getDifficultyLabel(AppLocalizations l10n, String difficulty) {
    switch (difficulty) {
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

  String _getDailyGoalLabel(AppLocalizations l10n, String goal) {
    switch (goal) {
      case 'casual':
        return l10n.goalCasual;
      case 'regular':
        return l10n.goalRegular;
      case 'serious':
        return l10n.goalSerious;
      case 'intense':
        return l10n.goalIntense;
      default:
        return l10n.goalCasual;
    }
  }

  void _showInterestsDialog(
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    final interests = ['flags', 'capitals', 'culture', 'geography', 'languages', 'history'];
    final selected = Set<String>.from(localPrefs.interests);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.selectYourInterests),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) => FilterChip(
              label: Text(_getInterestLabel(l10n, interest)),
              selected: selected.contains(interest),
              onSelected: (isSelected) => setState(() {
                if (isSelected) {
                  selected.add(interest);
                } else {
                  selected.remove(interest);
                }
              }),
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                // Update local preferences
                await ref.read(localLearningPreferencesProvider.notifier).savePreferences(
                  interests: selected,
                  difficulty: localPrefs.difficulty,
                  dailyGoal: localPrefs.dailyGoal,
                );

                // Sync to cloud
                final updatedCloudPrefs = cloudPrefs.copyWith(
                  interests: selected.toList(),
                );
                _updatePreference(updatedCloudPrefs);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  _showPreferencesUpdatedSnackBar();
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog(
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    final difficulties = ['easy', 'medium', 'hard'];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.quizDifficulty),
        content: RadioGroup<String>(
          groupValue: localPrefs.difficulty,
          onChanged: (value) async {
            if (value != null) {
              // Update local preferences
              await ref.read(localLearningPreferencesProvider.notifier).setDifficulty(value);

              // Sync to cloud
              final updatedCloudPrefs = cloudPrefs.copyWith(
                difficultyLevel: value,
              );
              _updatePreference(updatedCloudPrefs);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                _showPreferencesUpdatedSnackBar();
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: difficulties.map((diff) {
              return RadioListTile<String>(
                title: Text(_getDifficultyLabel(l10n, diff)),
                value: diff,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLearningDailyGoalDialog(
    AppLocalizations l10n,
    UserPreferences cloudPrefs,
    LocalLearningPreferences localPrefs,
  ) {
    final goals = ['casual', 'regular', 'serious', 'intense'];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dailyLearningGoal),
        content: RadioGroup<String>(
          groupValue: localPrefs.dailyGoal,
          onChanged: (value) async {
            if (value != null) {
              // Update local preferences
              await ref.read(localLearningPreferencesProvider.notifier).setDailyGoal(value);

              // Get the minutes equivalent for cloud sync
              final updatedLocalPrefs = ref.read(localLearningPreferencesProvider);
              final updatedCloudPrefs = cloudPrefs.copyWith(
                dailyGoalMinutes: updatedLocalPrefs.dailyGoalMinutes,
              );
              _updatePreference(updatedCloudPrefs);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                _showPreferencesUpdatedSnackBar();
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: goals.map((goal) {
              return RadioListTile<String>(
                title: Text(_getDailyGoalLabel(l10n, goal)),
                value: goal,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showPreferencesUpdatedSnackBar() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.preferencesUpdated),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPremiumTile(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final responsive = ResponsiveUtils.of(context);
    final iconPadding = responsive.sp(8);
    final iconRadius = responsive.sp(8);
    final iconSize = responsive.sp(20);
    final badgePaddingH = responsive.sp(12);
    final badgePaddingV = responsive.sp(6);
    final badgeRadius = responsive.sp(AppDimensions.radiusMD);

    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(iconPadding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          borderRadius: BorderRadius.circular(iconRadius),
        ),
        child: Icon(Icons.star, color: Colors.white, size: iconSize),
      ),
      title: Text(
        l10n.upgradeToPremium,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(l10n.unlockAllFeatures),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(badgeRadius),
        ),
        child: Text(
          l10n.upgrade,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () => context.push(Routes.paywall),
    );
  }

  Widget _buildVersionTile(ThemeData theme, AppLocalizations l10n) {
    return ListTile(
      leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
      title: Text(l10n.version),
      subtitle: const Text('1.0.0 (1)'),
    );
  }

  Widget _buildSignOutTile(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final responsive = ResponsiveUtils.of(context);
    final paddingMD = responsive.sp(AppDimensions.paddingMD);
    final spacingSM = responsive.sp(AppDimensions.spacingSM);
    final buttonPadding = responsive.sp(16);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingMD),
      child: OutlinedButton(
        onPressed: () => _showSignOutDialog(l10n),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(color: theme.colorScheme.error),
          padding: EdgeInsets.symmetric(vertical: buttonPadding),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            SizedBox(width: spacingSM),
            Text(l10n.signOut),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountTile(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final responsive = ResponsiveUtils.of(context);
    final paddingMD = responsive.sp(AppDimensions.paddingMD);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingMD),
      child: TextButton(
        onPressed: () => _showDeleteAccountDialog(l10n),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.error.withValues(alpha: 0.7),
        ),
        child: Text(l10n.deleteAccount),
      ),
    );
  }

  String _getThemeName(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemDefault;
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
    }
  }

  void _showThemeDialog(AppLocalizations l10n, ThemeMode currentMode) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: RadioGroup<ThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              ref.read(themeModeProvider.notifier).setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(_getThemeName(l10n, mode)),
                value: mode,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(AppLocalizations l10n, String selectedLanguage) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: RadioGroup<String>(
          groupValue: selectedLanguage,
          onChanged: (value) {
            if (value != null) {
              ref.read(onboardingStateProvider.notifier).setLanguage(value);
              Navigator.pop(context);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('English'),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text('العربية'),
                value: 'ar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'This information will be available soon.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening App Store...')),
    );
  }

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _updatePreference(UserPreferences preferences) {
    ref.read(userProfileProvider.notifier).updatePreferences(preferences);
  }

  void _signOut() async {
    await ref.read(authStateProvider.notifier).signOut();
    if (mounted) {
      context.go(Routes.auth);
    }
  }
}

/// Account tile widget
class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Responsive scaling
    final responsive = ResponsiveUtils.of(context);
    final avatarRadius = responsive.sp(24);
    final badgePaddingH = responsive.sp(8);
    final badgePaddingV = responsive.sp(4);
    final badgeRadius = responsive.sp(AppDimensions.radiusSM);

    return ListTile(
      leading: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: theme.colorScheme.primaryContainer,
        backgroundImage: user?.photoUrl != null
            ? CachedNetworkImageProvider(user!.photoUrl!)
            : null,
        child: user?.photoUrl == null
            ? Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              )
            : null,
      ),
      title: Text(
        user?.displayName ?? l10n.guest,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        user?.email ?? (user?.isAnonymous == true ? 'Guest Account' : ''),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: user?.isPremium == true
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(badgeRadius),
              ),
              child: Text(
                l10n.proBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
