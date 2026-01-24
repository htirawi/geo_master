import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../presentation/providers/country_provider.dart';

/// View toggle header with country count and list/grid toggle
class ViewToggleHeader extends ConsumerWidget {
  const ViewToggleHeader({
    super.key,
    required this.isGridView,
    required this.onViewToggle,
  });

  final bool isGridView;
  final VoidCallback onViewToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filteredCountries = ref.watch(regionFilteredCountriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, color: AppColors.tertiary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${filteredCountries.length} ${l10n.countries}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // View toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _ViewToggleButton(
                  icon: Icons.view_list,
                  isSelected: !isGridView,
                  onTap: isGridView ? onViewToggle : null,
                  isFirst: true,
                ),
                _ViewToggleButton(
                  icon: Icons.grid_view,
                  isSelected: isGridView,
                  onTap: !isGridView ? onViewToggle : null,
                  isFirst: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tertiary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(12) : Radius.zero,
            right: !isFirst ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}
