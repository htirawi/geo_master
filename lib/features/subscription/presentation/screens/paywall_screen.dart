import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/user_provider.dart';

/// Subscription tier enum
enum SubscriptionTier {
  monthly,
  yearly,
}

/// Paywall screen for premium subscription
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionTier _selectedTier = SubscriptionTier.yearly;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final user = ref.watch(userDataProvider);

    // If user is already premium, show management screen
    if (user?.isPremium == true) {
      return _buildPremiumManagementScreen(theme, l10n);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.9),
              theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.3, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: _restorePurchases,
                      child: Text(
                        l10n.restorePurchases,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              // Premium Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLG,
                  vertical: AppDimensions.paddingSM,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: AppDimensions.spacingSM),
                    Text(
                      l10n.goPremium,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXL),

              // Features List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusXL),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.premiumFeatures,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMD),

                        // Feature items
                        _buildFeatureItem(
                          theme,
                          Icons.quiz,
                          l10n.unlimitedQuizzes,
                          isArabic
                              ? 'تدرب بلا حدود مع اختبارات غير محدودة'
                              : 'Practice without limits with unlimited quizzes',
                        ),
                        _buildFeatureItem(
                          theme,
                          Icons.smart_toy,
                          l10n.unlimitedAiChat,
                          isArabic
                              ? 'احصل على مساعدة غير محدودة من المعلم الذكي'
                              : 'Get unlimited help from your AI tutor',
                        ),
                        _buildFeatureItem(
                          theme,
                          Icons.download,
                          l10n.offlineAccess,
                          isArabic
                              ? 'تعلم في أي مكان بدون اتصال بالإنترنت'
                              : 'Learn anywhere without internet connection',
                        ),
                        _buildFeatureItem(
                          theme,
                          Icons.block,
                          l10n.noAds,
                          isArabic
                              ? 'استمتع بتجربة خالية من الإعلانات'
                              : 'Enjoy an ad-free experience',
                        ),
                        _buildFeatureItem(
                          theme,
                          Icons.ac_unit,
                          l10n.streakFreeze,
                          isArabic
                              ? 'حافظ على سلسلتك حتى لو فاتك يوم'
                              : 'Protect your streak even if you miss a day',
                        ),
                        _buildFeatureItem(
                          theme,
                          Icons.emoji_events,
                          l10n.exclusiveAchievements,
                          isArabic
                              ? 'افتح إنجازات حصرية للأعضاء المميزين'
                              : 'Unlock exclusive achievements for premium members',
                        ),

                        const SizedBox(height: AppDimensions.spacingXL),

                        // Subscription Tiers
                        _buildTierSelector(theme, l10n),

                        const SizedBox(height: AppDimensions.spacingLG),

                        // Subscribe Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _subscribe,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMD,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.subscribe,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingMD),

                        // Terms text
                        Text(
                          isArabic
                              ? 'بالاشتراك، أنت توافق على الشروط والأحكام. يتجدد الاشتراك تلقائياً ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة الحالية.'
                              : 'By subscribing, you agree to our Terms of Service. Subscription auto-renews unless cancelled at least 24 hours before the end of the current period.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierSelector(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Yearly (Best Value)
        _buildTierCard(
          theme: theme,
          tier: SubscriptionTier.yearly,
          title: isArabic ? 'سنوي' : 'Yearly',
          price: '\$29.99',
          period: l10n.perYear,
          savings: isArabic ? 'وفر 50%' : 'Save 50%',
          isBestValue: true,
        ),
        const SizedBox(height: AppDimensions.spacingSM),

        // Monthly
        _buildTierCard(
          theme: theme,
          tier: SubscriptionTier.monthly,
          title: isArabic ? 'شهري' : 'Monthly',
          price: '\$4.99',
          period: l10n.perMonth,
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required ThemeData theme,
    required SubscriptionTier tier,
    required String title,
    required String price,
    required String period,
    String? savings,
    bool isBestValue = false,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Radio indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppDimensions.spacingMD),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (savings != null) ...[
                            const SizedBox(width: AppDimensions.spacingSM),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                savings,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Best Value badge
            if (isBestValue)
              Positioned(
                top: -8,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isArabic ? 'الأفضل قيمة' : 'BEST VALUE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get isArabic => Localizations.localeOf(context).languageCode == 'ar';

  Widget _buildPremiumManagementScreen(ThemeData theme, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionManagement),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppDimensions.spacingXL),

            // Premium Badge
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 64),
            ),

            const SizedBox(height: AppDimensions.spacingLG),

            Text(
              isArabic ? 'أنت عضو مميز!' : 'You\'re Premium!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingSM),

            Text(
              isArabic
                  ? 'استمتع بجميع الميزات المميزة'
                  : 'Enjoy all premium features',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXL),

            // Features list
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Column(
                children: [
                  _buildPremiumFeatureRow(theme, Icons.quiz, l10n.unlimitedQuizzes),
                  const Divider(),
                  _buildPremiumFeatureRow(theme, Icons.smart_toy, l10n.unlimitedAiChat),
                  const Divider(),
                  _buildPremiumFeatureRow(theme, Icons.download, l10n.offlineAccess),
                  const Divider(),
                  _buildPremiumFeatureRow(theme, Icons.block, l10n.noAds),
                ],
              ),
            ),

            const Spacer(),

            // Manage subscription button
            OutlinedButton(
              onPressed: _manageSubscription,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                  vertical: AppDimensions.paddingMD,
                ),
              ),
              child: Text(l10n.subscriptionManagement),
            ),

            const SizedBox(height: AppDimensions.spacingLG),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatureRow(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingMD),
          Text(title, style: theme.textTheme.bodyLarge),
          const Spacer(),
          const Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  void _subscribe() async {
    setState(() => _isLoading = true);

    // Simulate subscription process
    await Future<void>.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      // Show success message (in real app, would handle actual purchase)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'سيتم تفعيل الاشتراك قريباً (تجريبي)'
                : 'Subscription will be activated soon (Demo)',
          ),
        ),
      );
    }
  }

  void _restorePurchases() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'جاري استعادة المشتريات...'
              : 'Restoring purchases...',
        ),
      ),
    );
  }

  void _manageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'إدارة الاشتراك في إعدادات المتجر'
              : 'Manage subscription in store settings',
        ),
      ),
    );
  }
}
