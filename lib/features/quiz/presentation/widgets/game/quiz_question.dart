import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_dimensions.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Quiz question display widget
class QuizQuestionDisplay extends StatelessWidget {
  const QuizQuestionDisplay({
    super.key,
    required this.question,
    required this.isArabic,
  });

  final QuizQuestion question;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final questionText = question.getDisplayQuestion(isArabic: isArabic);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Generate semantic label for flag
    String? flagSemanticLabel;
    if (question.mode == QuizMode.reverseFlags) {
      // In reverse mode, we're showing the answer as image
      flagSemanticLabel = 'Flag to identify';
    } else if (question.mode == QuizMode.flags) {
      flagSemanticLabel = 'Flag of a country';
    }

    return Column(
      children: [
        // Flag image for flag quiz
        if ((question.mode == QuizMode.flags ||
                question.mode == QuizMode.reverseFlags) &&
            question.imageUrl != null) ...[
          Semantics(
            label: flagSemanticLabel,
            image: true,
            child: Container(
              height: 120,
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: question.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(
                    Icons.flag,
                    size: 48,
                    semanticLabel: 'Flag image failed to load',
                  ),
                ),
                placeholder: (context, url) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
            ),
          )
              .animate(autoPlay: !reduceMotion)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          const SizedBox(height: AppDimensions.spacingLG),
        ],

        // Question text
        Builder(
          builder: (context) {
            final textWidget = Text(
              questionText,
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            );
            if (reduceMotion) {
              return textWidget;
            }
            return textWidget.animate().fadeIn(duration: 300.ms);
          },
        ),

        // Multi-select indicator
        if (question.isMultiSelect) ...[
          const SizedBox(height: AppDimensions.xs),
          Semantics(
            hint: 'This question requires multiple selections',
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs - 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                l10n.selectAnswersCount(question.correctAnswers?.length ?? 0),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
