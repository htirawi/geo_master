/// Google Maps styling utilities for World Map feature
class MapStyle {
  MapStyle._();

  /// Default map style - clean, minimal look
  static const String defaultStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#bdbdbd"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#9e9e9e"}, {"weight": 1}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#dadada"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [{"color": "#e5e5e5"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#eeeeee"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9c9c9"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  }
]
''';

  /// Dark mode map style
  static const String darkStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b4b4b"}, {"weight": 1}]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#bdbdbd"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1b1b1b"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#373737"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#3c3c3c"}]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [{"color": "#4e4e4e"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3d3d3d"}]
  }
]
''';

  /// Satellite hybrid style (minimal labels)
  static const String satelliteStyle = '''
[
  {
    "featureType": "all",
    "elementType": "labels",
    "stylers": [{"visibility": "simplified"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels",
    "stylers": [{"visibility": "on"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels",
    "stylers": [{"visibility": "off"}]
  }
]
''';

  /// Get style based on theme mode
  static String getStyle({required bool isDark}) {
    return isDark ? darkStyle : defaultStyle;
  }
}

/// Progress level colors for country markers
class ProgressColors {
  ProgressColors._();

  /// Completed (100%) - Green
  static const int completed = 0xFF4CAF50;

  /// In progress (50-99%) - Yellow/Gold
  static const int inProgress = 0xFFFFC107;

  /// Started (1-49%) - Orange
  static const int started = 0xFFFF9800;

  /// Not started (0%) - Gray
  static const int notStarted = 0xFF9E9E9E;

  /// Favorite marker - Red heart overlay
  static const int favorite = 0xFFE91E63;

  /// Currently viewing - Blue highlight
  static const int selected = 0xFF2196F3;

  /// Get color for progress percentage
  static int getColorForProgress(double progress) {
    if (progress >= 1.0) return completed;
    if (progress >= 0.5) return inProgress;
    if (progress > 0) return started;
    return notStarted;
  }

  /// Get color name for accessibility
  static String getColorName(double progress, {bool isArabic = false}) {
    if (progress >= 1.0) {
      return isArabic ? 'مكتمل' : 'Completed';
    }
    if (progress >= 0.5) {
      return isArabic ? 'قيد التقدم' : 'In Progress';
    }
    if (progress > 0) {
      return isArabic ? 'بدأت' : 'Started';
    }
    return isArabic ? 'لم يبدأ' : 'Not Started';
  }
}

/// Continent zoom levels and centers
class ContinentMapData {
  ContinentMapData._();

  /// Continent center coordinates and zoom levels
  static const Map<String, ({double lat, double lng, double zoom})> continents = {
    'africa': (lat: 0.0, lng: 20.0, zoom: 3.0),
    'asia': (lat: 34.0, lng: 100.0, zoom: 3.0),
    'europe': (lat: 54.0, lng: 15.0, zoom: 4.0),
    'north_america': (lat: 45.0, lng: -100.0, zoom: 3.0),
    'south_america': (lat: -15.0, lng: -60.0, zoom: 3.0),
    'oceania': (lat: -25.0, lng: 140.0, zoom: 3.5),
    'antarctica': (lat: -82.0, lng: 0.0, zoom: 2.5),
  };

  /// Get zoom data for continent
  static ({double lat, double lng, double zoom})? getZoomData(String continentId) {
    return continents[continentId.toLowerCase()];
  }

  /// World view zoom data
  static const worldView = (lat: 20.0, lng: 0.0, zoom: 2.0);
}

/// Map marker icon generator utilities
class MarkerIconUtils {
  MarkerIconUtils._();

  /// Create a circle marker icon data
  static String createCircleMarkerSvg({
    required int color,
    required double progress,
    bool isFavorite = false,
  }) {
    final colorHex = '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    final progressAngle = progress * 360;

    return '''
<svg width="40" height="40" xmlns="http://www.w3.org/2000/svg">
  <!-- Background circle -->
  <circle cx="20" cy="20" r="18" fill="#ffffff" stroke="$colorHex" stroke-width="3"/>

  <!-- Progress arc -->
  ${progress > 0 ? _createProgressArc(progressAngle, colorHex) : ''}

  <!-- Favorite heart -->
  ${isFavorite ? _createHeartIcon() : ''}
</svg>
''';
  }

  static String _createProgressArc(double angle, String color) {
    if (angle >= 360) {
      return '<circle cx="20" cy="20" r="15" fill="$color" opacity="0.3"/>';
    }
    // Simplified arc for partial progress
    return '<circle cx="20" cy="20" r="15" fill="$color" opacity="0.2"/>';
  }

  static String _createHeartIcon() {
    return '''
<path d="M20 30 L12 22 C8 18 8 12 12 10 C16 8 20 12 20 12 C20 12 24 8 28 10 C32 12 32 18 28 22 Z"
      fill="#E91E63" transform="scale(0.4) translate(25, 20)"/>
''';
  }
}
