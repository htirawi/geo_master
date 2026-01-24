import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswer == option;
        final isCorrect = question.correctAnswer == option;

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
              onTap: showFeedback ? null : () => onAnswerSelected(option),
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
                  children: [
                    // Option letter
                    Container(
                      width: 32,
                      height: 32,
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
                    const SizedBox(width: 12),
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
                      ),
                    ),
                    if (showFeedback && isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.quizCorrect,
                      )
                    else if (showFeedback && isSelected && !isCorrect)
                      const Icon(
                        Icons.cancel,
                        color: AppColors.quizIncorrect,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
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

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedAnswers.contains(option);
        final isCorrect = question.correctAnswers?.contains(option) ?? false;

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
              onTap: showFeedback ? null : () => onToggleAnswer(option),
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
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (borderColor ?? theme.colorScheme.primary)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: borderColor ??
                              theme.colorScheme.outline.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
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
                      ),
                    ),
                    if (showFeedback && isCorrect)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.quizCorrect,
                      )
                    else if (showFeedback && isSelected && !isCorrect)
                      const Icon(
                        Icons.cancel,
                        color: AppColors.quizIncorrect,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }
}
