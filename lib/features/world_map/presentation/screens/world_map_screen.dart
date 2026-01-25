import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/arabic_country_names.dart';
import '../../../../domain/entities/country.dart' hide LatLng;
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../presentation/providers/world_map_provider.dart';
import '../utils/map_style.dart';
import '../widgets/country_info_popup.dart';
import '../widgets/map_controls.dart' hide MapStatsBar;
import '../widgets/map_filter_bar.dart';
import '../widgets/map_legend.dart';
import '../widgets/random_country_fab.dart';
import '../widgets/search_autocomplete.dart';

/// Main World Map screen with interactive country exploration
class WorldMapScreen extends ConsumerStatefulWidget {
  const WorldMapScreen({
    super.key,
    this.initialContinent,
  });

  /// Optional initial continent to filter/zoom to
  final String? initialContinent;

  @override
  ConsumerState<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends ConsumerState<WorldMapScreen> {
  gm.GoogleMapController? _mapController;
  bool _isLegendExpanded = false;
  bool _isSearchFocused = false;
  Country? _selectedCountry;
  double _currentBearing = 0;

  // Initial camera position (world view)
  static const _initialPosition = gm.CameraPosition(
    target: gm.LatLng(20.0, 0.0),
    zoom: 2.0,
  );

  @override
  void initState() {
    super.initState();
    // Handle initial continent filter if provided
    if (widget.initialContinent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedContinentFilterProvider.notifier).state =
            widget.initialContinent;
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final mapStateAsync = ref.watch(worldMapProvider);
    final viewMode = ref.watch(mapViewModeProvider);
    final isPremium = ref.watch(isPremiumProvider);

    // Extract the actual state from AsyncValue
    final mapState = mapStateAsync.valueOrNull ?? const WorldMapInitial();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          gm.GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onTap: _onMapTap,
            markers: _buildMarkers(mapState, isArabic),
            mapType: _getMapType(viewMode),
            style: viewMode == MapViewMode.normal
                ? MapStyle.getStyle(isDark: isDark)
                : null,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
          ),

          // Top bar with search and filters
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: CountrySearchAutocomplete(
                    onCountrySelected: _onCountrySelected,
                    onSearchFocusChanged: (focused) {
                      setState(() => _isSearchFocused = focused);
                    },
                  ),
                ),

                // Filter bar
                if (!_isSearchFocused)
                  MapFilterBar(
                    onContinentSelected: _onContinentSelected,
                  ),
              ],
            ),
          ),

          // Map controls (right side)
          Positioned(
            right: AppDimensions.md,
            top: MediaQuery.of(context).size.height * 0.35,
            child: Column(
              children: [
                // Layer selector
                MapLayerSelector(
                  onLayerChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppDimensions.sm),

                // Zoom and other controls
                MapControls(
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onResetView: _resetView,
                  onMyLocation: _goToMyLocation,
                  onToggle3D: _toggle3D,
                  isPremium: isPremium,
                ),
              ],
            ),
          ),

          // Compass (shows when map is rotated)
          Positioned(
            right: AppDimensions.md,
            top: MediaQuery.of(context).padding.top + 150,
            child: MapCompass(
              bearing: _currentBearing,
              onTap: _resetBearing,
            ),
          ),

          // Legend (bottom left)
          Positioned(
            left: AppDimensions.md,
            bottom: 100,
            child: MapLegend(
              isExpanded: _isLegendExpanded,
              onToggle: () {
                setState(() => _isLegendExpanded = !_isLegendExpanded);
              },
            ),
          ),

          // Stats bar (bottom center)
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: MapStatsBar(),
            ),
          ),

          // Selected country popup
          if (_selectedCountry != null)
            Positioned(
              bottom: 180,
              left: AppDimensions.md,
              right: AppDimensions.md,
              child: Center(
                child: CountryInfoPopup(
                  country: _selectedCountry!,
                  onTap: () => _navigateToCountryDetail(_selectedCountry!),
                  onClose: () => setState(() => _selectedCountry = null),
                ),
              ),
            ),

          // Loading indicator
          if (mapStateAsync.isLoading || mapState is WorldMapLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),

      // Random country FAB
      floatingActionButton: _selectedCountry == null && !_isSearchFocused
          ? RandomCountryFab(
              onCountrySelected: _onRandomCountrySelected,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _onMapCreated(gm.GoogleMapController controller) {
    _mapController = controller;
    // Load map data
    ref.read(worldMapProvider.notifier).loadMap();
  }

  void _onCameraMove(gm.CameraPosition position) {
    if (position.bearing != _currentBearing) {
      setState(() => _currentBearing = position.bearing);
    }
  }

  void _onMapTap(gm.LatLng position) {
    // Close popup if open
    if (_selectedCountry != null) {
      setState(() => _selectedCountry = null);
    }
  }

  Set<gm.Marker> _buildMarkers(WorldMapState state, bool isArabic) {
    if (state is! WorldMapLoaded) return {};

    final markers = <gm.Marker>{};

    for (final marker in state.markers) {
      final progressValue = marker.progressLevel.progressValue;
      final displayName = isArabic
          ? (ArabicCountryNames.getName(marker.countryCode) ?? marker.name)
          : marker.name;
      final exploredText = isArabic
          ? '${(progressValue * 100).toInt()}% مستكشف'
          : '${(progressValue * 100).toInt()}% explored';

      markers.add(gm.Marker(
        markerId: gm.MarkerId(marker.countryCode),
        position: gm.LatLng(marker.latitude, marker.longitude),
        icon: gm.BitmapDescriptor.defaultMarkerWithHue(
          _getHueForProgress(progressValue),
        ),
        onTap: () => _onMarkerTap(marker.countryCode),
        infoWindow: gm.InfoWindow(
          title: displayName,
          snippet: exploredText,
        ),
      ));
    }

    return markers;
  }

  double _getHueForProgress(double progress) {
    if (progress >= 1.0) return gm.BitmapDescriptor.hueGreen;
    if (progress >= 0.5) return gm.BitmapDescriptor.hueYellow;
    if (progress > 0) return gm.BitmapDescriptor.hueOrange;
    return gm.BitmapDescriptor.hueRed;
  }

  gm.MapType _getMapType(MapViewMode mode) {
    switch (mode) {
      case MapViewMode.normal:
        return gm.MapType.normal;
      case MapViewMode.satellite:
        return gm.MapType.satellite;
      case MapViewMode.terrain:
        return gm.MapType.terrain;
      case MapViewMode.hybrid:
        return gm.MapType.hybrid;
    }
  }

  Future<void> _onMarkerTap(String countryCode) async {
    final country = await ref.read(worldMapProvider.notifier).getCountryByCode(countryCode);
    if (country != null) {
      setState(() => _selectedCountry = country);
      // Animate to country
      _animateToCountry(country);
    }
  }

  void _onCountrySelected(Country country) {
    setState(() => _selectedCountry = country);
    _animateToCountry(country);
  }

  void _onRandomCountrySelected(Country country) {
    setState(() => _selectedCountry = country);
    _animateToCountry(country);
  }

  void _onContinentSelected(String? continentId) {
    if (continentId == null) {
      _resetView();
      return;
    }

    final zoomData = ContinentMapData.getZoomData(continentId);
    if (zoomData != null) {
      _mapController?.animateCamera(
        gm.CameraUpdate.newCameraPosition(
          gm.CameraPosition(
            target: gm.LatLng(zoomData.lat, zoomData.lng),
            zoom: zoomData.zoom,
          ),
        ),
      );
    }
  }

  void _animateToCountry(Country country) {
    _mapController?.animateCamera(
      gm.CameraUpdate.newCameraPosition(
        gm.CameraPosition(
          target: gm.LatLng(
            country.coordinates.latitude,
            country.coordinates.longitude,
          ),
          zoom: 5.0,
        ),
      ),
    );
  }

  void _navigateToCountryDetail(Country country) {
    Navigator.of(context).pushNamed(
      '/countries/${country.code}',
      arguments: country,
    );
  }

  void _zoomIn() {
    _mapController?.animateCamera(gm.CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(gm.CameraUpdate.zoomOut());
  }

  void _resetView() {
    _mapController?.animateCamera(
      gm.CameraUpdate.newCameraPosition(_initialPosition),
    );
    ref.read(selectedContinentFilterProvider.notifier).state = null;
  }

  void _resetBearing() {
    _mapController?.animateCamera(
      gm.CameraUpdate.newCameraPosition(
        const gm.CameraPosition(
          target: gm.LatLng(20.0, 0.0),
          zoom: 2.0,
          bearing: 0,
        ),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    // The GoogleMap widget handles location internally when myLocationEnabled is true
    // This would require location permission handling
    // For now, we just show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'جاري تحديد موقعك...'
                : 'Finding your location...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggle3D() {
    // 3D terrain toggle (premium feature)
    // This would require enabling 3D buildings and terrain in Google Maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'ميزة العرض ثلاثي الأبعاد'
              : '3D View Feature',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// World Map screen without shell (full screen mode)
class WorldMapFullScreen extends ConsumerWidget {
  const WorldMapFullScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: WorldMapScreen(),
    );
  }
}
