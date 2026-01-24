import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// Weekly progress bar showing streak days
class WeekProgressBar extends StatelessWidget {
  const WeekProgressBar({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun];
    final today = DateTime.now().weekday - 1;
    final daysCompleted = streak.clamp(0, 7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final isCompleted = index < daysCompleted;
        final isToday = index == today;

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.streak
                    : isToday
                        ? AppColors.streak.withValues(alpha: 0.2)
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
                border: isToday && !isCompleted
                    ? Border.all(color: AppColors.streak, width: 2)
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              days[index],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? AppColors.streak
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        );
      }),
    );
  }
}
