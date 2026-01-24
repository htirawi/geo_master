import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/headers/explorer_hero_header.dart';
import 'atlas_pattern_painter.dart';

/// Explorer Header with search
///
/// Uses the design system's HeaderGradients.atlas for consistent styling.
class ExplorerHeader extends StatelessWidget {
  const ExplorerHeader({
    super.key,
    required this.isArabic,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.onClearSearch,
  });

  final bool isArabic;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchQuery;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: HeaderGradients.atlas,
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(
              painter: AtlasPatternPainter(),
            ),
          ),
          // Decorative globe
          Positioned(
            right: isArabic ? null : -40,
            left: isArabic ? -40 : null,
            top: 40,
            child: Icon(
              Icons.public,
              size: 180,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.xs),
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm - 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMD + 2),
                        ),
                        child: const Icon(Icons.explore,
                            color: Colors.white, size: AppDimensions.iconMD),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.worldAtlas,
                            style: (isArabic
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.discoverCountries,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: AppDimensions.durationSlow),
                  const SizedBox(height: AppDimensions.lg),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppDimensions.borderRadiusLG,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: AppDimensions.blurLight + 2,
                          offset: const Offset(0, AppDimensions.xxs),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: GoogleFonts.poppins(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: l10n.searchCountries,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[400]),
                                onPressed: onClearSearch,
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.lg,
                          vertical: AppDimensions.md,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: AppDimensions.durationSlow),
                  const SizedBox(height: AppDimensions.xs),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
