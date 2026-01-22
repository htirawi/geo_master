import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/error/failures.dart';

/// Reusable error state widget for displaying errors in screens
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.title,
    this.onRetry,
    this.retryText,
    this.onBack,
    this.backText,
    this.showBackButton = false,
    this.compact = false,
  });

  /// Create from a Failure object
  factory ErrorStateWidget.fromFailure({
    Key? key,
    required Failure failure,
    required bool isArabic,
    VoidCallback? onRetry,
    VoidCallback? onBack,
    bool showBackButton = false,
    bool compact = false,
  }) {
    return ErrorStateWidget(
      key: key,
      message: _getLocalizedMessage(failure, isArabic),
      title: _getLocalizedTitle(failure, isArabic),
      icon: _getIconForFailure(failure),
      iconColor: _getColorForFailure(failure),
      onRetry: onRetry,
      retryText: isArabic ? 'إعادة المحاولة' : 'Retry',
      onBack: onBack,
      backText: isArabic ? 'رجوع' : 'Back',
      showBackButton: showBackButton,
      compact: compact,
    );
  }

  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;
  final VoidCallback? onBack;
  final String? backText;
  final bool showBackButton;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIcon = icon ?? Icons.error_outline;
    final effectiveColor = iconColor ?? AppColors.error;

    if (compact) {
      return _buildCompact(theme, effectiveIcon, effectiveColor);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              effectiveIcon,
              size: 64,
              color: effectiveColor,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLG),
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(ThemeData theme, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMD),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(retryText ?? 'Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBackButton && onBack != null)
          OutlinedButton(
            onPressed: onBack,
            child: Text(backText ?? 'Back'),
          ),
        if (showBackButton && onBack != null && onRetry != null)
          const SizedBox(width: AppDimensions.spacingSM),
        if (onRetry != null)
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryText ?? 'Retry'),
          ),
      ],
    );
  }

  static String _getLocalizedTitle(Failure failure, bool isArabic) {
    return switch (failure) {
      NetworkFailure() => isArabic ? 'خطأ في الشبكة' : 'Network Error',
      ServerFailure() => isArabic ? 'خطأ في الخادم' : 'Server Error',
      AuthFailure() => isArabic ? 'خطأ في المصادقة' : 'Authentication Error',
      CacheFailure() => isArabic ? 'خطأ في التخزين' : 'Cache Error',
      QuizFailure() => isArabic ? 'خطأ في الاختبار' : 'Quiz Error',
      CountryFailure() => isArabic ? 'خطأ في البيانات' : 'Data Error',
      AiTutorFailure() => isArabic ? 'خطأ في المعلم الذكي' : 'AI Tutor Error',
      PurchaseFailure() => isArabic ? 'خطأ في الشراء' : 'Purchase Error',
      SubscriptionFailure() => isArabic ? 'خطأ في الاشتراك' : 'Subscription Error',
      GamificationFailure() =>
        isArabic ? 'خطأ في النظام' : 'System Error',
      ValidationFailure() => isArabic ? 'خطأ في البيانات' : 'Validation Error',
      _ => isArabic ? 'حدث خطأ' : 'Error',
    };
  }

  static String _getLocalizedMessage(Failure failure, bool isArabic) {
    return switch (failure) {
      NetworkFailure(code: 'noConnection') =>
        isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection',
      NetworkFailure(code: 'timeout') =>
        isArabic ? 'انتهت مهلة الاتصال' : 'Connection timed out',
      NetworkFailure() =>
        isArabic ? 'فشل الاتصال بالشبكة' : 'Network connection failed',
      ServerFailure(code: 'serviceUnavailable') =>
        isArabic ? 'الخدمة غير متاحة حالياً' : 'Service is temporarily unavailable',
      ServerFailure() =>
        isArabic ? 'حدث خطأ في الخادم' : 'Server error occurred',
      AuthFailure(code: 'invalidCredentials') =>
        isArabic ? 'بيانات الدخول غير صحيحة' : 'Invalid email or password',
      AuthFailure(code: 'userNotFound') =>
        isArabic ? 'المستخدم غير موجود' : 'User not found',
      AuthFailure(code: 'emailAlreadyInUse') =>
        isArabic ? 'البريد الإلكتروني مستخدم بالفعل' : 'Email is already in use',
      AuthFailure(code: 'weakPassword') =>
        isArabic ? 'كلمة المرور ضعيفة جداً' : 'Password is too weak',
      AuthFailure(code: 'userDisabled') =>
        isArabic ? 'تم تعطيل هذا الحساب' : 'This account has been disabled',
      AuthFailure(code: 'tooManyRequests') =>
        isArabic ? 'محاولات كثيرة. حاول لاحقاً' : 'Too many attempts. Try again later',
      AuthFailure(code: 'sessionExpired') =>
        isArabic ? 'انتهت الجلسة. سجل الدخول مجدداً' : 'Session expired. Please sign in again',
      AuthFailure() =>
        isArabic ? 'فشل في المصادقة' : 'Authentication failed',
      CacheFailure(code: 'notFound') =>
        isArabic ? 'البيانات غير متوفرة' : 'Data not available',
      CacheFailure(code: 'expired') =>
        isArabic ? 'انتهت صلاحية البيانات' : 'Cached data has expired',
      CacheFailure() =>
        isArabic ? 'فشل في التخزين المؤقت' : 'Cache operation failed',
      QuizFailure(code: 'noQuestionsAvailable') =>
        isArabic ? 'لا توجد أسئلة متاحة' : 'No questions available',
      QuizFailure(code: 'quizAlreadyCompleted') =>
        isArabic ? 'تم إكمال هذا الاختبار' : 'Quiz already completed',
      QuizFailure(code: 'timeExpired') =>
        isArabic ? 'انتهى الوقت' : 'Time has expired',
      QuizFailure() =>
        isArabic ? 'حدث خطأ في الاختبار' : 'Quiz error occurred',
      CountryFailure(code: 'notFound') =>
        isArabic ? 'الدولة غير موجودة' : 'Country not found',
      CountryFailure() =>
        isArabic ? 'فشل في تحميل بيانات الدولة' : 'Failed to load country data',
      AiTutorFailure(code: 'rateLimited') =>
        isArabic ? 'تم الوصول للحد الأقصى' : 'Rate limit reached',
      AiTutorFailure(code: 'messageLimitReached') =>
        isArabic ? 'وصلت للحد اليومي من الرسائل' : 'Daily message limit reached',
      AiTutorFailure(code: 'apiKeyInvalid') =>
        isArabic ? 'خطأ في الإعدادات' : 'Configuration error',
      AiTutorFailure() =>
        isArabic ? 'فشل في الاتصال بالمعلم' : 'Failed to connect to AI tutor',
      PurchaseFailure(code: 'cancelled') =>
        isArabic ? 'تم إلغاء الشراء' : 'Purchase was cancelled',
      PurchaseFailure(code: 'paymentDeclined') =>
        isArabic ? 'تم رفض الدفع' : 'Payment was declined',
      PurchaseFailure(code: 'alreadyPurchased') =>
        isArabic ? 'تم شراء هذا المنتج مسبقاً' : 'Already purchased',
      PurchaseFailure() =>
        isArabic ? 'فشل في إتمام الشراء' : 'Purchase failed',
      SubscriptionFailure(code: 'notSubscribed') =>
        isArabic ? 'غير مشترك' : 'No active subscription',
      SubscriptionFailure(code: 'featureNotAvailable') =>
        isArabic ? 'هذه الميزة غير متوفرة في خطتك' : 'Feature not available in your plan',
      SubscriptionFailure() =>
        isArabic ? 'خطأ في الاشتراك' : 'Subscription error',
      ValidationFailure(code: 'invalidEmail') =>
        isArabic ? 'البريد الإلكتروني غير صالح' : 'Invalid email address',
      ValidationFailure(code: 'invalidPassword') =>
        isArabic ? 'كلمة المرور غير صالحة' : 'Invalid password',
      ValidationFailure() =>
        isArabic ? 'البيانات المدخلة غير صالحة' : 'Invalid input',
      // Security: Use generic message to avoid exposing internal error details
      _ => isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred',
    };
  }

  static IconData _getIconForFailure(Failure failure) {
    return switch (failure) {
      NetworkFailure() => Icons.wifi_off_rounded,
      ServerFailure() => Icons.cloud_off_rounded,
      AuthFailure() => Icons.lock_outline_rounded,
      CacheFailure() => Icons.storage_rounded,
      QuizFailure() => Icons.quiz_rounded,
      CountryFailure() => Icons.public_off_rounded,
      AiTutorFailure() => Icons.smart_toy_outlined,
      PurchaseFailure() => Icons.payment_rounded,
      SubscriptionFailure() => Icons.card_membership_rounded,
      ValidationFailure() => Icons.warning_amber_rounded,
      _ => Icons.error_outline_rounded,
    };
  }

  static Color _getColorForFailure(Failure failure) {
    return switch (failure) {
      NetworkFailure() => AppColors.warning,
      ServerFailure() => AppColors.error,
      AuthFailure() => AppColors.error,
      PurchaseFailure(code: 'cancelled') => AppColors.warning,
      PurchaseFailure() => AppColors.error,
      _ => AppColors.error,
    };
  }
}

/// Empty state widget for when there's no data
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_rounded,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSM),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingLG),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error banner for inline error display
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
    this.icon,
  });

  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: onRetry,
              color: AppColors.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: AppColors.error,
              padding: const EdgeInsetsDirectional.only(start: 8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Loading widget with optional message
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.compact = false,
  });

  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (message != null) ...[
            const SizedBox(width: AppDimensions.spacingSM),
            Text(
              message!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
