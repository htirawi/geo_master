import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/continent.dart';
import '../../../../presentation/providers/world_map_provider.dart';
import '../utils/map_style.dart';

/// Filter bar for the world map
class MapFilterBar extends ConsumerWidget {
  const MapFilterBar({
    super.key,
    this.onContinentSelected,
  });

  final void Function(String? continentId)? onContinentSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final selectedContinent = ref.watch(selectedContinentFilterProvider);
    final progressFilter = ref.watch(progressFilterProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All continents chip
          _FilterChip(
            label: isArabic ? 'الكل' : 'All',
            isSelected: selectedContinent == null,
            onTap: () {
              ref.read(selectedContinentFilterProvider.notifier).state = null;
              onContinentSelected?.call(null);
            },
          ),
          const SizedBox(width: 8),

          // Continent chips
          ...ContinentIds.all.map((id) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: _FilterChip(
                  label: _getContinentName(id, isArabic),
                  isSelected: selectedContinent == id,
                  onTap: () {
                    ref.read(selectedContinentFilterProvider.notifier).state = id;
                    onContinentSelected?.call(id);
                  },
                ),
              )),

          const SizedBox(width: 8),
          // Divider
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(width: 8),

          // Progress filters
          _FilterChip(
            icon: Icons.check_circle,
            iconColor: const Color(ProgressColors.completed),
            label: isArabic ? 'مكتمل' : 'Complete',
            isSelected: progressFilter == MapProgressFilter.completed,
            onTap: () {
              final notifier = ref.read(progressFilterProvider.notifier);
              notifier.state = progressFilter == MapProgressFilter.completed
                  ? MapProgressFilter.all
                  : MapProgressFilter.completed;
            },
          ),
          const SizedBox(width: 8),

          _FilterChip(
            icon: Icons.pending,
            iconColor: const Color(ProgressColors.inProgress),
            label: isArabic ? 'قيد التقدم' : 'In Progress',
            isSelected: progressFilter == MapProgressFilter.inProgress,
            onTap: () {
              final notifier = ref.read(progressFilterProvider.notifier);
              notifier.state = progressFilter == MapProgressFilter.inProgress
                  ? MapProgressFilter.all
                  : MapProgressFilter.inProgress;
            },
          ),
          const SizedBox(width: 8),

          _FilterChip(
            icon: Icons.circle_outlined,
            iconColor: const Color(ProgressColors.notStarted),
            label: isArabic ? 'لم يبدأ' : 'Not Started',
            isSelected: progressFilter == MapProgressFilter.notStarted,
            onTap: () {
              final notifier = ref.read(progressFilterProvider.notifier);
              notifier.state = progressFilter == MapProgressFilter.notStarted
                  ? MapProgressFilter.all
                  : MapProgressFilter.notStarted;
            },
          ),
          const SizedBox(width: 8),

          // Favorites filter
          _FilterChip(
            icon: showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
            iconColor: const Color(ProgressColors.favorite),
            label: isArabic ? 'المفضلة' : 'Favorites',
            isSelected: showFavoritesOnly,
            onTap: () {
              ref.read(showFavoritesOnlyProvider.notifier).state = !showFavoritesOnly;
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  String _getContinentName(String id, bool isArabic) {
    const names = {
      'africa': ('Africa', 'أفريقيا'),
      'asia': ('Asia', 'آسيا'),
      'europe': ('Europe', 'أوروبا'),
      'north_america': ('N. America', 'أمريكا الشمالية'),
      'south_america': ('S. America', 'أمريكا الجنوبية'),
      'oceania': ('Oceania', 'أوقيانوسيا'),
      'antarctica': ('Antarctica', 'أنتاركتيكا'),
    };

    final name = names[id];
    return isArabic ? (name?.$2 ?? id) : (name?.$1 ?? id);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (iconColor ?? theme.colorScheme.onSurface),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable filter panel for more options
class MapFilterPanel extends ConsumerStatefulWidget {
  const MapFilterPanel({
    super.key,
    this.onClose,
  });

  final VoidCallback? onClose;

  @override
  ConsumerState<MapFilterPanel> createState() => _MapFilterPanelState();
}

class _MapFilterPanelState extends ConsumerState<MapFilterPanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final progressFilter = ref.watch(progressFilterProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedContinent = ref.watch(selectedContinentFilterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'تصفية' : 'Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(isArabic ? 'إعادة تعيين' : 'Reset'),
                  ),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Continent section
          Text(
            isArabic ? 'القارة' : 'Continent',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SelectableChip(
                label: isArabic ? 'الكل' : 'All',
                isSelected: selectedContinent == null,
                onTap: () {
                  ref.read(selectedContinentFilterProvider.notifier).state = null;
                },
              ),
              ...ContinentIds.all.map((id) => _SelectableChip(
                    label: _getContinentFullName(id, isArabic),
                    isSelected: selectedContinent == id,
                    onTap: () {
                      ref.read(selectedContinentFilterProvider.notifier).state = id;
                    },
                  )),
            ],
          ),
          const SizedBox(height: 16),

          // Progress section
          Text(
            isArabic ? 'حالة التقدم' : 'Progress Status',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MapProgressFilter.values.map((filter) {
              return _SelectableChip(
                label: _getFilterName(filter, isArabic),
                icon: _getFilterIcon(filter),
                iconColor: _getFilterColor(filter),
                isSelected: progressFilter == filter,
                onTap: () {
                  ref.read(progressFilterProvider.notifier).state = filter;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Favorites toggle
          SwitchListTile(
            value: showFavoritesOnly,
            onChanged: (value) {
              ref.read(showFavoritesOnlyProvider.notifier).state = value;
            },
            title: Text(
              isArabic ? 'إظهار المفضلة فقط' : 'Show Favorites Only',
              style: theme.textTheme.bodyMedium,
            ),
            secondary: const Icon(
              Icons.favorite,
              color: Color(ProgressColors.favorite),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    ref.read(selectedContinentFilterProvider.notifier).state = null;
    ref.read(progressFilterProvider.notifier).state = MapProgressFilter.all;
    ref.read(showFavoritesOnlyProvider.notifier).state = false;
  }

  String _getContinentFullName(String id, bool isArabic) {
    const names = {
      'africa': ('Africa', 'أفريقيا'),
      'asia': ('Asia', 'آسيا'),
      'europe': ('Europe', 'أوروبا'),
      'north_america': ('North America', 'أمريكا الشمالية'),
      'south_america': ('South America', 'أمريكا الجنوبية'),
      'oceania': ('Oceania', 'أوقيانوسيا'),
      'antarctica': ('Antarctica', 'أنتاركتيكا'),
    };

    final name = names[id];
    return isArabic ? (name?.$2 ?? id) : (name?.$1 ?? id);
  }

  String _getFilterName(MapProgressFilter filter, bool isArabic) {
    switch (filter) {
      case MapProgressFilter.all:
        return isArabic ? 'الكل' : 'All';
      case MapProgressFilter.completed:
        return isArabic ? 'مكتمل' : 'Completed';
      case MapProgressFilter.inProgress:
        return isArabic ? 'قيد التقدم' : 'In Progress';
      case MapProgressFilter.notStarted:
        return isArabic ? 'لم يبدأ' : 'Not Started';
    }
  }

  IconData _getFilterIcon(MapProgressFilter filter) {
    switch (filter) {
      case MapProgressFilter.all:
        return Icons.select_all;
      case MapProgressFilter.completed:
        return Icons.check_circle;
      case MapProgressFilter.inProgress:
        return Icons.pending;
      case MapProgressFilter.notStarted:
        return Icons.circle_outlined;
    }
  }

  Color _getFilterColor(MapProgressFilter filter) {
    switch (filter) {
      case MapProgressFilter.all:
        return Colors.grey;
      case MapProgressFilter.completed:
        return const Color(ProgressColors.completed);
      case MapProgressFilter.inProgress:
        return const Color(ProgressColors.inProgress);
      case MapProgressFilter.notStarted:
        return const Color(ProgressColors.notStarted);
    }
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}
