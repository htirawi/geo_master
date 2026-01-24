import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Toast - Notification messages
///
/// Features:
/// - Multiple variants (info, success, warning, error)
/// - Custom icons
/// - Action button support
/// - Auto-dismiss
/// - Swipe to dismiss
class ExplorerToast extends StatelessWidget {
  const ExplorerToast({
    super.key,
    required this.message,
    this.title,
    this.variant = ToastVariant.info,
    this.icon,
    this.action,
    this.actionLabel,
    this.onDismiss,
  });

  /// Success toast
  const ExplorerToast.success({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.actionLabel,
    this.onDismiss,
  }) : variant = ToastVariant.success;

  /// Error toast
  const ExplorerToast.error({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.actionLabel,
    this.onDismiss,
  }) : variant = ToastVariant.error;

  /// Warning toast
  const ExplorerToast.warning({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.action,
    this.actionLabel,
    this.onDismiss,
  }) : variant = ToastVariant.warning;

  final String message;
  final String? title;
  final ToastVariant variant;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;
  final VoidCallback? onDismiss;

  Color get _backgroundColor {
    switch (variant) {
      case ToastVariant.info:
        return AppColors.info;
      case ToastVariant.success:
        return AppColors.success;
      case ToastVariant.warning:
        return AppColors.warning;
      case ToastVariant.error:
        return AppColors.error;
    }
  }

  IconData get _icon {
    if (icon != null) return icon!;
    switch (variant) {
      case ToastVariant.info:
        return Icons.info_outline_rounded;
      case ToastVariant.success:
        return Icons.check_circle_outline_rounded;
      case ToastVariant.warning:
        return Icons.warning_amber_rounded;
      case ToastVariant.error:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _icon,
            color: Colors.white,
            size: AppDimensions.iconMD,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxs),
                ],
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (action != null && actionLabel != null) ...[
            const SizedBox(width: AppDimensions.sm),
            TextButton(
              onPressed: action,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: AppDimensions.xs),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: AppDimensions.iconSM,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show toast as overlay
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    ToastVariant variant = ToastVariant.info,
    IconData? icon,
    VoidCallback? action,
    String? actionLabel,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _AnimatedToast(
        toast: ExplorerToast(
          message: message,
          title: title,
          variant: variant,
          icon: icon,
          action: action,
          actionLabel: actionLabel,
          onDismiss: () => entry.remove(),
        ),
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.toast,
    required this.duration,
    required this.onDismiss,
  });

  final ExplorerToast toast;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppDimensions.md,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: widget.toast,
          ),
        ),
      ),
    );
  }
}

enum ToastVariant {
  info,
  success,
  warning,
  error,
}

/// Toast service for showing toasts from anywhere
class ToastService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSuccess(String message, {String? title}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ExplorerToast.show(
        context,
        message: message,
        title: title,
        variant: ToastVariant.success,
      );
    }
  }

  static void showError(String message, {String? title}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ExplorerToast.show(
        context,
        message: message,
        title: title,
        variant: ToastVariant.error,
      );
    }
  }

  static void showWarning(String message, {String? title}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ExplorerToast.show(
        context,
        message: message,
        title: title,
        variant: ToastVariant.warning,
      );
    }
  }

  static void showInfo(String message, {String? title}) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ExplorerToast.show(
        context,
        message: message,
        title: title,
        variant: ToastVariant.info,
      );
    }
  }
}
