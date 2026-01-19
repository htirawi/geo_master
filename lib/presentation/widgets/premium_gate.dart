import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';

/// Widget that gates premium content
/// Shows the child if user has access, otherwise shows a premium prompt
class PremiumGate extends ConsumerWidget {
  const PremiumGate({
    super.key,
    required this.child,
    required this.feature,
    this.fallback,
    this.showLockedOverlay = true,
    this.requiredTier = SubscriptionTier.pro,
  });

  /// The premium content to show if user has access
  final Widget child;

  /// The feature this gate protects
  final SubscriptionFeature feature;

  /// Optional fallback widget when user doesn't have access
  /// If not provided, shows default locked content UI
  final Widget? fallback;

  /// Whether to show a locked overlay on the child
  final bool showLockedOverlay;

  /// Minimum required tier for this feature
  final SubscriptionTier requiredTier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionTierProvider);
    final hasAccess = _hasAccess(tier);

    if (hasAccess) {
      return child;
    }

    if (fallback != null) {
      return fallback!;
    }

    if (showLockedOverlay) {
      return _LockedOverlay(
        feature: feature,
        child: child,
      );
    }

    return _LockedPlaceholder(feature: feature);
  }

  bool _hasAccess(SubscriptionTier userTier) {
    return userTier.index >= requiredTier.index;
  }
}

/// Overlay shown on locked premium content
class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({
    required this.child,
    required this.feature,
  });

  final Widget child;
  final SubscriptionFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Stack(
      children: [
        // Blurred/dimmed content
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.grey.withValues(alpha: 0.3),
            BlendMode.saturation,
          ),
          child: IgnorePointer(child: child),
        ),

        // Lock overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.premiumGold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: AppColors.premiumGold,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isArabic ? 'ميزة مميزة' : 'Premium Feature',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => context.push(Routes.paywall),
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(isArabic ? 'ترقية' : 'Upgrade'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.premiumGold,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Placeholder shown for locked content
class _LockedPlaceholder extends StatelessWidget {
  const _LockedPlaceholder({required this.feature});

  final SubscriptionFeature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.premiumGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: AppColors.premiumGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getFeatureTitle(feature, isArabic),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getFeatureDescription(feature, isArabic),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push(Routes.paywall),
            icon: const Icon(Icons.star, size: 18),
            label: Text(isArabic ? 'فتح الميزة' : 'Unlock Feature'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.premiumGold,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getFeatureTitle(SubscriptionFeature feature, bool isArabic) {
    return isArabic ? feature.displayNameArabic : feature.displayName;
  }

  String _getFeatureDescription(SubscriptionFeature feature, bool isArabic) {
    switch (feature) {
      case SubscriptionFeature.unlimitedQuizzes:
        return isArabic
            ? 'أجب على عدد غير محدود من الاختبارات'
            : 'Take unlimited quizzes without daily limits';
      case SubscriptionFeature.unlimitedAiChat:
        return isArabic
            ? 'تحدث مع المعلم الذكي بدون حدود'
            : 'Chat with AI tutor without message limits';
      case SubscriptionFeature.offlineMode:
      case SubscriptionFeature.offlineAccess:
        return isArabic
            ? 'تعلم بدون اتصال بالإنترنت'
            : 'Learn anywhere without internet connection';
      case SubscriptionFeature.noAds:
        return isArabic
            ? 'استمتع بتجربة خالية من الإعلانات'
            : 'Enjoy an uninterrupted ad-free experience';
      case SubscriptionFeature.advancedStats:
        return isArabic
            ? 'احصل على رؤى تفصيلية حول تقدمك'
            : 'Get detailed insights about your progress';
      case SubscriptionFeature.customThemes:
        return isArabic
            ? 'خصص مظهر التطبيق حسب ذوقك'
            : 'Personalize the app appearance';
      case SubscriptionFeature.prioritySupport:
        return isArabic
            ? 'احصل على دعم سريع ومميز'
            : 'Get fast and dedicated support';
      case SubscriptionFeature.terrain3D:
        return isArabic
            ? 'استكشف العالم بتضاريس ثلاثية الأبعاد'
            : 'Explore the world with 3D terrain';
      case SubscriptionFeature.advancedLearning:
        return isArabic
            ? 'وحدات تعليمية متقدمة ومتعمقة'
            : 'Access advanced learning modules';
      case SubscriptionFeature.limitedQuizzes:
        return isArabic
            ? 'اختبارات محدودة يومياً'
            : 'Limited quizzes per day';
      case SubscriptionFeature.limitedAiChat:
        return isArabic
            ? 'رسائل محدودة يومياً'
            : 'Limited AI messages per day';
      case SubscriptionFeature.adsEnabled:
        return isArabic
            ? 'يحتوي على إعلانات'
            : 'Contains advertisements';
      case SubscriptionFeature.streakFreeze:
        return isArabic
            ? 'حافظ على سلسلة إنجازاتك'
            : 'Protect your learning streak';
      case SubscriptionFeature.exclusiveAchievements:
        return isArabic
            ? 'إنجازات حصرية للأعضاء'
            : 'Exclusive member achievements';
    }
  }
}

/// Premium badge widget
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({
    super.key,
    this.size = PremiumBadgeSize.small,
  });

  final PremiumBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final double iconSize;
    final double padding;

    switch (size) {
      case PremiumBadgeSize.small:
        iconSize = 12;
        padding = 4;
      case PremiumBadgeSize.medium:
        iconSize = 16;
        padding = 6;
      case PremiumBadgeSize.large:
        iconSize = 20;
        padding = 8;
    }

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.star_rounded,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}

enum PremiumBadgeSize { small, medium, large }

/// Extension to check if a tier has access to a feature
extension SubscriptionTierAccess on SubscriptionTier {
  bool hasFeature(SubscriptionFeature feature) {
    switch (feature) {
      case SubscriptionFeature.limitedQuizzes:
      case SubscriptionFeature.limitedAiChat:
      case SubscriptionFeature.adsEnabled:
        return true; // Free tier features
      case SubscriptionFeature.unlimitedQuizzes:
      case SubscriptionFeature.noAds:
        return this != SubscriptionTier.free;
      case SubscriptionFeature.unlimitedAiChat:
      case SubscriptionFeature.offlineMode:
      case SubscriptionFeature.offlineAccess:
      case SubscriptionFeature.terrain3D:
        return this == SubscriptionTier.pro || this == SubscriptionTier.premium;
      case SubscriptionFeature.advancedStats:
      case SubscriptionFeature.customThemes:
      case SubscriptionFeature.prioritySupport:
      case SubscriptionFeature.streakFreeze:
      case SubscriptionFeature.exclusiveAchievements:
      case SubscriptionFeature.advancedLearning:
        return this == SubscriptionTier.premium;
    }
  }
}
