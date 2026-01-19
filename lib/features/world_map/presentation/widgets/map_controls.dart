import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
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
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _getIconForMode(currentMode),
          size: 22,
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
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
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
              size: 18,
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Transform.rotate(
          angle: -bearing * (3.14159 / 180),
          child: Icon(
            Icons.navigation,
            size: 24,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: 4,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
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
          const SizedBox(width: 16),
          _StatItem(
            value: stats.explored,
            label: isArabic ? 'مستكشفة' : 'Explored',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 16),
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
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
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
