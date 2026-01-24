import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/components/cards/explorer_card.dart';
import 'region_progress_item.dart';

/// World Progress Preview - Mini world map with region progress
///
/// Uses the ExplorerCard component for consistent card styling.
class WorldProgressPreview extends ConsumerWidget {
  const WorldProgressPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final regions = [
      RegionData(l10n.europe, 32, 44, AppColors.regionEurope, Icons.castle),
      RegionData(l10n.asia, 18, 48, AppColors.regionAsia, Icons.temple_buddhist),
      RegionData(l10n.africa, 12, 54, AppColors.regionAfrica, Icons.wb_sunny),
      RegionData(l10n.americas, 15, 35, AppColors.regionAmericas, Icons.landscape),
      RegionData(l10n.oceania, 5, 14, AppColors.regionOceania, Icons.waves),
    ];

    return ExplorerCard.elevated(
      padding: const EdgeInsets.all(AppDimensions.lg),
      borderRadius: AppDimensions.borderRadiusXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm - 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD + 2),
                ),
                child: const Icon(Icons.public, color: AppColors.primary, size: AppDimensions.iconMD),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  l10n.worldProgress,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(Routes.stats),
                child: Text(
                  l10n.viewAll,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          // Region progress bars
          ...regions.map((region) => RegionProgressItem(region: region)),
        ],
      ),
    );
  }
}
