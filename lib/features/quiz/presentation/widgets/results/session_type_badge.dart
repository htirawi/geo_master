import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/quiz.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Session type info badge with continent
class SessionTypeBadge extends StatelessWidget {
  const SessionTypeBadge({
    super.key,
    required this.sessionType,
    this.continent,
  });

  final QuizSessionType sessionType;
  final String? continent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionName = _getSessionTypeName(sessionType, l10n);
    final color = _getSessionTypeColor(sessionType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSessionTypeIcon(sessionType),
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            sessionName,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (continent != null) ...[
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 16,
              color: color.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 8),
            Text(
              continent!,
              style: GoogleFonts.poppins(
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSessionTypeName(QuizSessionType sessionType, AppLocalizations l10n) {
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return l10n.sessionTypeQuickQuiz;
      case QuizSessionType.continentChallenge:
        return l10n.sessionTypeContinentChallenge;
      case QuizSessionType.timedBlitz:
        return l10n.sessionTypeTimedBlitz;
      case QuizSessionType.dailyChallenge:
        return l10n.sessionTypeDailyChallenge;
      case QuizSessionType.marathon:
        return l10n.sessionTypeMarathon;
      case QuizSessionType.studyMode:
        return l10n.sessionTypeStudyMode;
      case QuizSessionType.standard:
        return l10n.sessionTypeStandard;
    }
  }

  Color _getSessionTypeColor(QuizSessionType sessionType) {
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return const Color(0xFF2196F3);
      case QuizSessionType.continentChallenge:
        return const Color(0xFF4CAF50);
      case QuizSessionType.timedBlitz:
        return const Color(0xFFF44336);
      case QuizSessionType.dailyChallenge:
        return const Color(0xFFFF6D00);
      case QuizSessionType.marathon:
        return const Color(0xFF9C27B0);
      case QuizSessionType.studyMode:
        return const Color(0xFF607D8B);
      case QuizSessionType.standard:
        return AppColors.primary;
    }
  }

  IconData _getSessionTypeIcon(QuizSessionType sessionType) {
    switch (sessionType) {
      case QuizSessionType.quickQuiz:
        return Icons.bolt;
      case QuizSessionType.continentChallenge:
        return Icons.public;
      case QuizSessionType.timedBlitz:
        return Icons.timer;
      case QuizSessionType.dailyChallenge:
        return Icons.today;
      case QuizSessionType.marathon:
        return Icons.sports_score;
      case QuizSessionType.studyMode:
        return Icons.school;
      case QuizSessionType.standard:
        return Icons.quiz;
    }
  }
}
