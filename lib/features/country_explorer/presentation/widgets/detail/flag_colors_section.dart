import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../domain/entities/flag_meaning.dart';
import '../../../../../l10n/generated/app_localizations.dart';

/// Flag Colors Section - Clean, minimal, professional design
class FlagColorsMeaningSection extends StatelessWidget {
  const FlagColorsMeaningSection({
    super.key,
    required this.countryCode,
    required this.accentColor,
  });

  final String countryCode;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final flagMeaning = FlagMeaningsRepository.getMeaning(countryCode);

    if (flagMeaning == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 22,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'ألوان العلم ومعانيها' : 'Flag Colors & Meanings',
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Color Cards
        ...flagMeaning.colors.asMap().entries.map((entry) {
          final index = entry.key;
          final flagColor = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < flagMeaning.colors.length - 1 ? 12 : 0,
            ),
            child: FlagColorCard(
              flagColor: flagColor,
              isArabic: isArabic,
            )
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),
          );
        }),

        // Symbols Section (if available)
        if (flagMeaning.additionalInfo != null) ...[
          const SizedBox(height: 20),
          SymbolsCard(
            flagMeaning: flagMeaning,
            isArabic: isArabic,
            accentColor: accentColor,
          )
              .animate(
                  delay: Duration(milliseconds: 50 * flagMeaning.colors.length))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
        ],
      ],
    );
  }
}

/// Clean, minimal color card
class FlagColorCard extends StatelessWidget {
  const FlagColorCard({
    super.key,
    required this.flagColor,
    required this.isArabic,
  });

  final FlagColor flagColor;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Color swatch (RTL-aware)
          Container(
            width: 56,
            height: 72,
            decoration: ShapeDecoration(
              color: flagColor.color,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(15),
                ),
                side: flagColor.color == const Color(0xFFFFFFFF)
                    ? BorderSide(color: Colors.grey[300]!, width: 1)
                    : BorderSide.none,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color name and hex
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          flagColor.getName(isArabic: isArabic),
                          style:
                              (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyHexCode(context, flagColor.hexCode, l10n),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            flagColor.hexCode,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Meaning
                  Text(
                    flagColor.getMeaning(isArabic: isArabic),
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyHexCode(
      BuildContext context, String hexCode, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: hexCode));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.copiedToClipboard}: $hexCode'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Symbols card for additional flag information
class SymbolsCard extends StatelessWidget {
  const SymbolsCard({
    super.key,
    required this.flagMeaning,
    required this.isArabic,
    required this.accentColor,
  });

  final FlagMeaning flagMeaning;
  final bool isArabic;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'الرموز والمعاني' : 'Symbols & Meanings',
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isArabic
                ? (flagMeaning.additionalInfoAr ?? flagMeaning.additionalInfo!)
                : flagMeaning.additionalInfo!,
            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 13,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
