import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';
import 'region_chip.dart';

/// Region filter section with horizontal scrolling chips
class RegionFilterSection extends ConsumerWidget {
  const RegionFilterSection({
    super.key,
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  final String? selectedRegion;
  final ValueChanged<String?> onRegionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final regions = ref.watch(regionsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // All filter
            RegionChip(
              label: l10n.all,
              icon: Icons.public,
              color: AppColors.primary,
              isSelected: selectedRegion == null,
              onTap: () => onRegionSelected(null),
            ),
            const SizedBox(width: 8),
            // Region filters
            ...regions.map((region) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: RegionChip(
                    label: _getLocalizedRegion(l10n, region),
                    icon: _getRegionIcon(region),
                    color: _getRegionColor(region),
                    isSelected: selectedRegion == region,
                    onTap: () =>
                        onRegionSelected(selectedRegion == region ? null : region),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getLocalizedRegion(AppLocalizations l10n, String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return l10n.africa;
      case 'americas':
        return l10n.americas;
      case 'asia':
        return l10n.asia;
      case 'europe':
        return l10n.europe;
      case 'oceania':
        return l10n.oceania;
      default:
        return region;
    }
  }

  IconData _getRegionIcon(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return Icons.wb_sunny;
      case 'americas':
        return Icons.landscape;
      case 'asia':
        return Icons.temple_buddhist;
      case 'europe':
        return Icons.castle;
      case 'oceania':
        return Icons.waves;
      default:
        return Icons.public;
    }
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'africa':
        return AppColors.regionAfrica;
      case 'americas':
        return AppColors.regionAmericas;
      case 'asia':
        return AppColors.regionAsia;
      case 'europe':
        return AppColors.regionEurope;
      case 'oceania':
        return AppColors.regionOceania;
      default:
        return AppColors.primary;
    }
  }
}
