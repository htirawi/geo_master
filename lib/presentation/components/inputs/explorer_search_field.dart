import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';

/// Explorer Search Field - Specialized search input for the Atlas
///
/// Features:
/// - Search icon with animation
/// - Clear button when text present
/// - Debounced search callbacks
/// - Glass morphism variant
/// - Voice search support (optional)
class ExplorerSearchField extends StatefulWidget {
  const ExplorerSearchField({
    super.key,
    this.controller,
    this.hint = 'Search countries...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.variant = SearchFieldVariant.standard,
    this.autofocus = false,
    this.enabled = true,
    this.showVoiceButton = false,
    this.onVoiceTap,
    this.focusNode,
  });

  /// Glass morphism variant
  const ExplorerSearchField.glass({
    super.key,
    this.controller,
    this.hint = 'Search countries...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
    this.showVoiceButton = false,
    this.onVoiceTap,
    this.focusNode,
  }) : variant = SearchFieldVariant.glass;

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final SearchFieldVariant variant;
  final bool autofocus;
  final bool enabled;
  final bool showVoiceButton;
  final VoidCallback? onVoiceTap;
  final FocusNode? focusNode;

  @override
  State<ExplorerSearchField> createState() => _ExplorerSearchFieldState();
}

class _ExplorerSearchFieldState extends State<ExplorerSearchField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  bool _hasText = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppDimensions.inputHeight,
      decoration: _buildDecoration(isDark),
      child: Row(
        children: [
          const SizedBox(width: AppDimensions.sm),
          // Search icon
          AnimatedBuilder(
            animation: _iconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconAnimation.value,
                child: Icon(
                  Icons.search_rounded,
                  color: _isFocused
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  size: AppDimensions.iconMD,
                ),
              );
            },
          ),
          const SizedBox(width: AppDimensions.xs),
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          // Clear button
          if (_hasText)
            _buildIconButton(
              icon: Icons.close_rounded,
              onTap: _handleClear,
              isDark: isDark,
            ),
          // Voice button
          if (widget.showVoiceButton && !_hasText)
            _buildIconButton(
              icon: Icons.mic_rounded,
              onTap: widget.onVoiceTap,
              isDark: isDark,
            ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isDark) {
    switch (widget.variant) {
      case SearchFieldVariant.standard:
        return BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.mountainSnow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: _isFocused
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: _isFocused ? 2 : 1,
          ),
        );
      case SearchFieldVariant.glass:
        return BoxDecoration(
          color: isDark
              ? AppColors.glassDark
              : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: AppColors.glassStroke,
            width: 1,
          ),
        );
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xs),
        child: Icon(
          icon,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          size: AppDimensions.iconSM,
        ),
      ),
    );
  }
}

enum SearchFieldVariant {
  standard,
  glass,
}
