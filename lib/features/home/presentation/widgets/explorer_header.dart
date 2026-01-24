import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'world_pattern_painter.dart';

/// Immersive explorer header with greeting and world visual
class ExplorerHeader extends StatelessWidget {
  const ExplorerHeader({
    super.key,
    this.userName,
    this.isAnonymous = false,
    required this.isArabic,
  });

  final String? userName;
  final bool isAnonymous;
  final bool isArabic;

  /// Extract first name from full display name
  String _getFirstName(String? fullName, AppLocalizations l10n) {
    if (fullName == null || fullName.isEmpty || isAnonymous) {
      return l10n.guest;
    }
    // Split by space and take first part
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  /// Get a random motivational message with user's name
  String _getMotivationalMessage(String firstName, AppLocalizations l10n) {
    final messages = [
      l10n.motivationalProgress(firstName),
      l10n.motivationalLearning(firstName),
      l10n.motivationalWelcome(firstName),
    ];
    final index = DateTime.now().day % messages.length;
    return messages[index];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    final firstName = _getFirstName(userName, l10n);

    String greeting;
    IconData timeIcon;
    if (hour < 12) {
      greeting = l10n.goodMorning;
      timeIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = l10n.goodAfternoon;
      timeIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = l10n.goodEvening;
      timeIcon = Icons.nightlight_round;
    }

    final motivationalMessage = _getMotivationalMessage(firstName, l10n);

    return Container(
      height: 270,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF002171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative world pattern
          Positioned.fill(
            child: CustomPaint(
              painter: WorldPatternPainter(),
            ),
          ),
          // Decorative floating elements
          ..._buildFloatingElements(),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(timeIcon, color: AppColors.sunrise, size: 24),
                      ),
                      const Spacer(),
                      // Notification bell
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$greeting,',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 4),
                  Text(
                    firstName,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sunrise.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sunrise.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore, color: AppColors.sunrise, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            motivationalMessage,
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                              fontSize: 12,
                              color: AppColors.sunrise,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return [
      Positioned(
        right: -30,
        top: 60,
        child: Icon(
          Icons.public,
          size: 150,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
      Positioned(
        left: 20,
        bottom: 20,
        child: Icon(
          Icons.flight_takeoff,
          size: 30,
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
    ];
  }
}
