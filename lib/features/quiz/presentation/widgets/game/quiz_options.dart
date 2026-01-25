import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../domain/entities/quiz.dart';

/// Single-select quiz options widget
class QuizOptionsSingle extends StatelessWidget {
  const QuizOptionsSingle({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.isArabic,
  });

  final QuizQuestion question;
  final bool showFeedback;
  final String? selectedAnswer;
  final ValueChanged<String> onAnswerSelected;
  final bool isArabic;

  /// Check if options should be displayed as images
  bool get _isImageOptions =>
      question.metadata?['isImageOptions'] == true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get localized options and correct answer
    // For image options (reverse flags), don't localize - use original URLs
    final displayOptions = _isImageOptions
        ? question.options
        : question.getDisplayOptions(isArabic: isArabic);
    final displayCorrectAnswer = _isImageOptions
        ? question.correctAnswer
        : question.getDisplayCorrectAnswer(isArabic: isArabic);

    // Use image grid layout for flag options
    if (_isImageOptions) {
      return _buildImageOptionsGrid(
        context: context,
        theme: theme,
        options: displayOptions,
        correctAnswer: displayCorrectAnswer,
      );
    }

    // Build text option widgets
    final optionWidgets = displayOptions.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return _buildOptionCard(
        context: context,
        theme: theme,
        option: option,
        index: index,
        isSelected: selectedAnswer == option,
        isCorrect: displayCorrectAnswer == option,
        showFeedback: showFeedback,
        onTap: showFeedback ? null : () => onAnswerSelected(option),
      );
    }).toList();

    // Use responsive layout: 2 columns on tablets, 1 column on phones
    return ResponsiveBuilder(
      mobile: Column(children: optionWidgets),
      tablet: _buildGridLayout(optionWidgets),
      desktop: _buildGridLayout(optionWidgets),
    );
  }

  /// Build a 2x2 grid layout for image options (flags)
  Widget _buildImageOptionsGrid({
    required BuildContext context,
    required ThemeData theme,
    required List<String> options,
    required String correctAnswer,
  }) {
    // Use Column + Row layout instead of GridView to avoid scroll conflicts
    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += 2) {
      final hasSecond = i + 1 < options.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
          child: Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.4,
                  child: _buildImageOptionCard(
                    context: context,
                    theme: theme,
                    imageUrl: options[i],
                    index: i,
                    isSelected: selectedAnswer == options[i],
                    isCorrect: correctAnswer == options[i],
                    showFeedback: showFeedback,
                    onTap: showFeedback ? null : () => onAnswerSelected(options[i]),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
              if (hasSecond)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.4,
                    child: _buildImageOptionCard(
                      context: context,
                      theme: theme,
                      imageUrl: options[i + 1],
                      index: i + 1,
                      isSelected: selectedAnswer == options[i + 1],
                      isCorrect: correctAnswer == options[i + 1],
                      showFeedback: showFeedback,
                      onTap: showFeedback ? null : () => onAnswerSelected(options[i + 1]),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  /// Build a single image option card (for flag selection)
  Widget _buildImageOptionCard({
    required BuildContext context,
    required ThemeData theme,
    required String imageUrl,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool showFeedback,
    required VoidCallback? onTap,
  }) {
    Color? backgroundColor;
    Color borderColor;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.quizCorrect.withValues(alpha: 0.15);
        borderColor = AppColors.quizCorrect;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.quizIncorrect.withValues(alpha: 0.15);
        borderColor = AppColors.quizIncorrect;
      } else {
        borderColor = theme.colorScheme.outline.withValues(alpha: 0.3);
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.primary;
    } else {
      borderColor = theme.colorScheme.outline.withValues(alpha: 0.3);
    }

    return Material(
      color: backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isSelected || (showFeedback && isCorrect) ? 3 : 1.5,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Stack(
            children: [
              // Flag image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD - 2),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: Icon(Icons.flag, size: 40),
                    ),
                  ),
                ),
              ),
              // Option letter badge
              Positioned(
                top: 8,
                right: isArabic ? null : 8,
                left: isArabic ? 8 : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (showFeedback && isCorrect)
                        ? AppColors.quizCorrect
                        : (showFeedback && isSelected && !isCorrect)
                            ? AppColors.quizIncorrect
                            : theme.colorScheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: (showFeedback && (isCorrect || (isSelected && !isCorrect)))
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              // Feedback icon overlay
              if (showFeedback && isCorrect)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.quizCorrect,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                )
              else if (showFeedback && isSelected && !isCorrect)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.quizIncorrect,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridLayout(List<Widget> options) {
    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += 2) {
      final hasSecond = i + 1 < options.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: options[i]),
              if (hasSecond) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                Expanded(child: options[i + 1]),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required ThemeData theme,
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool showFeedback,
    required VoidCallback? onTap,
  }) {
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.quizCorrect.withValues(alpha: 0.1);
        borderColor = AppColors.quizCorrect;
        textColor = AppColors.quizCorrect;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.quizIncorrect.withValues(alpha: 0.1);
        borderColor = AppColors.quizIncorrect;
        textColor = AppColors.quizIncorrect;
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ??
                    theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected || (showFeedback && isCorrect) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Option letter (leading in LTR, trailing in RTL)
                Container(
                  width: AppDimensions.iconXL,
                  height: AppDimensions.iconXL,
                  decoration: BoxDecoration(
                    color: (borderColor ?? theme.colorScheme.outline)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: borderColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    option,
                    style:
                        (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                if (showFeedback && isCorrect)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: AppDimensions.sm),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.quizCorrect,
                    ),
                  )
                else if (showFeedback && isSelected && !isCorrect)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: AppDimensions.sm),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.quizIncorrect,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Multi-select quiz options widget
class QuizOptionsMulti extends StatelessWidget {
  const QuizOptionsMulti({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.selectedAnswers,
    required this.onToggleAnswer,
    required this.isArabic,
  });

  final QuizQuestion question;
  final bool showFeedback;
  final List<String> selectedAnswers;
  final ValueChanged<String> onToggleAnswer;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get localized options and correct answers
    final displayOptions = question.getDisplayOptions(isArabic: isArabic);
    final displayCorrectAnswers = question.getDisplayCorrectAnswers(isArabic: isArabic);

    // Build option widgets
    final optionWidgets = displayOptions.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return _buildOptionCard(
        context: context,
        theme: theme,
        option: option,
        index: index,
        isSelected: selectedAnswers.contains(option),
        isCorrect: displayCorrectAnswers?.contains(option) ?? false,
        showFeedback: showFeedback,
        onTap: showFeedback ? null : () => onToggleAnswer(option),
      );
    }).toList();

    // Use responsive layout: 2 columns on tablets, 1 column on phones
    return ResponsiveBuilder(
      mobile: Column(children: optionWidgets),
      tablet: _buildGridLayout(optionWidgets),
      desktop: _buildGridLayout(optionWidgets),
    );
  }

  Widget _buildGridLayout(List<Widget> options) {
    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += 2) {
      final hasSecond = i + 1 < options.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: options[i]),
              if (hasSecond) ...[
                const SizedBox(width: AppDimensions.spacingSM),
                Expanded(child: options[i + 1]),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required ThemeData theme,
    required String option,
    required int index,
    required bool isSelected,
    required bool isCorrect,
    required bool showFeedback,
    required VoidCallback? onTap,
  }) {
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = AppColors.quizCorrect.withValues(alpha: 0.1);
        borderColor = AppColors.quizCorrect;
        textColor = AppColors.quizCorrect;
      } else if (isSelected && !isCorrect) {
        backgroundColor = AppColors.quizIncorrect.withValues(alpha: 0.1);
        borderColor = AppColors.quizIncorrect;
        textColor = AppColors.quizIncorrect;
      }
    } else if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSM),
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ??
                    theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected || (showFeedback && isCorrect) ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // Checkbox (leading in LTR, trailing in RTL)
                AnimatedContainer(
                  duration: AppDimensions.durationFast,
                  width: AppDimensions.iconMD,
                  height: AppDimensions.iconMD,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (borderColor ?? theme.colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.xxs + 2),
                    border: Border.all(
                      color: borderColor ??
                          theme.colorScheme.outline.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: AppDimensions.iconXS,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    option,
                    style:
                        (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: textColor,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                if (showFeedback && isCorrect)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: AppDimensions.sm),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.quizCorrect,
                    ),
                  )
                else if (showFeedback && isSelected && !isCorrect)
                  const Padding(
                    padding: EdgeInsetsDirectional.only(start: AppDimensions.sm),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.quizIncorrect,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
