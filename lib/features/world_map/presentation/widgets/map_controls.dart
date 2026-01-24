import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../presentation/providers/world_map_provider.dart';

/// Map control buttons (zoom, reset, layer selector)
class MapControls extends ConsumerWidget {
  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    this.onMyLocation,
    this.onToggle3D,
    this.is3DEnabled = false,
    this.isPremium = false,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;
  final VoidCallback? onMyLocation;
  final VoidCallback? onToggle3D;
  final bool is3DEnabled;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: AppDimensions.xs,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom in
          _ControlButton(
            icon: Icons.add,
            onTap: onZoomIn,
            tooltip: 'Zoom in',
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
          ),
          _Divider(),

          // Zoom out
          _ControlButton(
            icon: Icons.remove,
            onTap: onZoomOut,
            tooltip: 'Zoom out',
          ),
          _Divider(),

          // Reset view
          _ControlButton(
            icon: Icons.crop_free,
            onTap: onResetView,
            tooltip: 'Reset view',
          ),

          // My location
          if (onMyLocation != null) ...[
            _Divider(),
            _ControlButton(
              icon: Icons.my_location,
              onTap: onMyLocation,
              tooltip: 'My location',
            ),
          ],

          // 3D toggle (premium)
          if (onToggle3D != null && isPremium) ...[
            _Divider(),
            _ControlButton(
              icon: is3DEnabled ? Icons.view_in_ar : Icons.terrain,
              onTap: onToggle3D,
              tooltip: is3DEnabled ? 'Disable 3D' : 'Enable 3D',
              isActive: is3DEnabled,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusMD)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isActive = false,
    this.borderRadius,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;
  final bool isActive;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: SizedBox(
            width: AppDimensions.buttonHeightMD,
            height: AppDimensions.buttonHeightMD,
            child: Icon(
              icon,
              size: AppDimensions.iconMD - 2,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}

/// Map layer selector dropdown
class MapLayerSelector extends ConsumerWidget {
  const MapLayerSelector({
    super.key,
    this.onLayerChanged,
  });

  final void Function(MapViewMode mode)? onLayerChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final currentMode = ref.watch(mapViewModeProvider);

    return PopupMenuButton<MapViewMode>(
      initialValue: currentMode,
      onSelected: (mode) {
        ref.read(mapViewModeProvider.notifier).state = mode;
        onLayerChanged?.call(mode);
      },
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xs + 2),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: AppDimensions.xs,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _getIconForMode(currentMode),
          size: AppDimensions.iconMD - 2,
          color: theme.colorScheme.onSurface,
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          MapViewMode.normal,
          Icons.map,
          isArabic ? 'عادي' : 'Normal',
          currentMode == MapViewMode.normal,
        ),
        _buildMenuItem(
          context,
          MapViewMode.satellite,
          Icons.satellite,
          isArabic ? 'قمر صناعي' : 'Satellite',
          currentMode == MapViewMode.satellite,
        ),
        _buildMenuItem(
          context,
          MapViewMode.terrain,
          Icons.terrain,
          isArabic ? 'تضاريس' : 'Terrain',
          currentMode == MapViewMode.terrain,
        ),
        _buildMenuItem(
          context,
          MapViewMode.hybrid,
          Icons.layers,
          isArabic ? 'هجين' : 'Hybrid',
          currentMode == MapViewMode.hybrid,
        ),
      ],
    );
  }

  IconData _getIconForMode(MapViewMode mode) {
    switch (mode) {
      case MapViewMode.normal:
        return Icons.map;
      case MapViewMode.satellite:
        return Icons.satellite;
      case MapViewMode.terrain:
        return Icons.terrain;
      case MapViewMode.hybrid:
        return Icons.layers;
    }
  }

  PopupMenuItem<MapViewMode> _buildMenuItem(
    BuildContext context,
    MapViewMode mode,
    IconData icon,
    String label,
    bool isSelected,
  ) {
    final theme = Theme.of(context);

    return PopupMenuItem<MapViewMode>(
      value: mode,
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimensions.iconSM,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check,
              size: AppDimensions.iconSM - 2,
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Compass widget showing map rotation
class MapCompass extends StatelessWidget {
  const MapCompass({
    super.key,
    required this.bearing,
    this.onTap,
  });

  final double bearing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Hide compass when north is up
    if (bearing.abs() < 1) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.buttonHeightMD,
        height: AppDimensions.buttonHeightMD,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: AppDimensions.xs,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: -bearing * (3.14159 / 180),
          child: Icon(
            Icons.navigation,
            size: AppDimensions.iconMD,
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

/// Map scale indicator
class MapScaleIndicator extends StatelessWidget {
  const MapScaleIndicator({
    super.key,
    required this.metersPerPixel,
  });

  final double metersPerPixel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (value, unit, width) = _calculateScale();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs, vertical: AppDimensions.xxs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: AppDimensions.xxs,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.onSurface, width: 2),
                left: BorderSide(color: theme.colorScheme.onSurface, width: 2),
                right: BorderSide(color: theme.colorScheme.onSurface, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value $unit',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  (int, String, double) _calculateScale() {
    // Calculate a nice round number for the scale
    const targetWidthPixels = 100.0;
    final targetMeters = metersPerPixel * targetWidthPixels;

    if (targetMeters >= 1000) {
      // Show in km
      final km = (targetMeters / 1000).round();
      final niceKm = _niceNumber(km);
      return (niceKm, 'km', niceKm * 1000 / metersPerPixel);
    } else {
      // Show in meters
      final m = targetMeters.round();
      final niceM = _niceNumber(m);
      return (niceM, 'm', niceM / metersPerPixel);
    }
  }

  int _niceNumber(int value) {
    if (value <= 0) return 1;
    if (value <= 5) return 5;
    if (value <= 10) return 10;
    if (value <= 20) return 20;
    if (value <= 50) return 50;
    if (value <= 100) return 100;
    if (value <= 200) return 200;
    if (value <= 500) return 500;
    if (value <= 1000) return 1000;
    return (value / 1000).round() * 1000;
  }
}

/// Stats bar showing country counts
class MapStatsBar extends ConsumerWidget {
  const MapStatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final stats = ref.watch(mapStatsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: AppDimensions.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG + 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: AppDimensions.xxs + 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatItem(
            value: stats.totalCountries,
            label: isArabic ? 'دولة' : 'Countries',
            icon: Icons.public,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppDimensions.md),
          _StatItem(
            value: stats.explored,
            label: isArabic ? 'مستكشفة' : 'Explored',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: AppDimensions.md),
          _StatItem(
            value: stats.favorites,
            label: isArabic ? 'مفضلة' : 'Favorites',
            icon: Icons.favorite_outline,
            color: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimensions.iconXS, color: color),
        const SizedBox(width: AppDimensions.xxs),
        Text(
          '$value',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: AppDimensions.xxs),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
