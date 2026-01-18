// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

/// Professional Geography App Icon Generator
/// Creates a stylized globe with continents and gradient background
void main() async {
  print('Generating professional app icon...');

  // Generate 1024x1024 icon (highest resolution needed)
  final icon = generateAppIcon(1024);
  final foreground = generateForegroundIcon(1024);

  // Save icons
  final iconPath = 'assets/app_icon/app_icon.png';
  final foregroundPath = 'assets/app_icon/app_icon_foreground.png';

  await File(iconPath).writeAsBytes(img.encodePng(icon));
  await File(foregroundPath).writeAsBytes(img.encodePng(foreground));

  print('App icon saved to: $iconPath');
  print('Foreground icon saved to: $foregroundPath');
  print('Done! Now run: dart run flutter_launcher_icons');
}

/// Generate the main app icon with background
img.Image generateAppIcon(int size) {
  final image = img.Image(width: size, height: size);
  final center = size / 2;
  final globeRadius = size * 0.38;

  // Fill with deep blue gradient background
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      // Diagonal gradient from top-left to bottom-right
      final progress = (x + y) / (size * 2);
      final r = _lerp(13, 27, progress).round(); // 0D -> 1B
      final g = _lerp(27, 38, progress).round(); // 1B -> 26
      final b = _lerp(42, 59, progress).round(); // 2A -> 3B
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw outer glow
  _drawGlow(image, center, center, globeRadius * 1.15,
    img.ColorRgba8(64, 165, 255, 40)); // Light blue glow

  // Draw globe base (ocean blue)
  _drawFilledCircle(image, center, center, globeRadius,
    img.ColorRgba8(30, 90, 150, 255)); // Deep ocean blue

  // Draw globe highlight gradient (makes it look 3D)
  _drawGlobeHighlight(image, center, center, globeRadius);

  // Draw stylized continents
  _drawContinents(image, center, center, globeRadius);

  // Draw latitude/longitude grid lines
  _drawGridLines(image, center, center, globeRadius);

  // Draw globe rim (metallic ring)
  _drawGlobeRim(image, center, center, globeRadius);

  // Draw small compass rose at bottom right
  _drawCompassRose(image, size * 0.78, size * 0.78, size * 0.12);

  return image;
}

/// Generate foreground-only icon for Android adaptive icons
img.Image generateForegroundIcon(int size) {
  // Adaptive icon foreground should be 108dp with 72dp safe zone
  // Scale factor: the icon content should be 66% of the image
  final image = img.Image(width: size, height: size);
  final center = size / 2;
  final globeRadius = size * 0.28; // Smaller for adaptive safe zone

  // Transparent background
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }

  // Draw outer glow
  _drawGlow(image, center, center, globeRadius * 1.15,
    img.ColorRgba8(64, 165, 255, 30));

  // Draw globe base
  _drawFilledCircle(image, center, center, globeRadius,
    img.ColorRgba8(30, 90, 150, 255));

  // Draw highlight
  _drawGlobeHighlight(image, center, center, globeRadius);

  // Draw continents
  _drawContinents(image, center, center, globeRadius);

  // Draw grid lines
  _drawGridLines(image, center, center, globeRadius);

  // Draw rim
  _drawGlobeRim(image, center, center, globeRadius);

  return image;
}

/// Linear interpolation
double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Draw a soft glow effect
void _drawGlow(img.Image image, double cx, double cy, double radius, img.Color color) {
  final glowColor = color as img.ColorRgba8;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist < radius * 1.3 && dist > radius * 0.7) {
        final intensity = 1.0 - ((dist - radius * 0.7) / (radius * 0.6)).abs();
        if (intensity > 0) {
          final current = image.getPixel(x, y);
          final alpha = (glowColor.a * intensity).round().clamp(0, 255);
          final newR = ((current.r.toInt() * (255 - alpha) + glowColor.r * alpha) ~/ 255);
          final newG = ((current.g.toInt() * (255 - alpha) + glowColor.g * alpha) ~/ 255);
          final newB = ((current.b.toInt() * (255 - alpha) + glowColor.b * alpha) ~/ 255);
          image.setPixelRgba(x, y, newR, newG, newB, 255);
        }
      }
    }
  }
}

/// Draw a filled circle
void _drawFilledCircle(img.Image image, double cx, double cy, double radius, img.Color color) {
  final c = color as img.ColorRgba8;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist <= radius) {
        // Anti-aliasing at edges
        if (dist > radius - 1) {
          final alpha = ((radius - dist) * c.a).round().clamp(0, 255);
          final current = image.getPixel(x, y);
          final newR = ((current.r.toInt() * (255 - alpha) + c.r * alpha) ~/ 255);
          final newG = ((current.g.toInt() * (255 - alpha) + c.g * alpha) ~/ 255);
          final newB = ((current.b.toInt() * (255 - alpha) + c.b * alpha) ~/ 255);
          image.setPixelRgba(x, y, newR, newG, newB, 255);
        } else {
          image.setPixelRgba(x, y, c.r, c.g, c.b, c.a);
        }
      }
    }
  }
}

/// Draw 3D highlight effect on globe
void _drawGlobeHighlight(img.Image image, double cx, double cy, double radius) {
  // Highlight offset (light from top-left)
  final highlightX = cx - radius * 0.3;
  final highlightY = cy - radius * 0.3;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist <= radius) {
        // Calculate highlight intensity
        final hdx = x - highlightX;
        final hdy = y - highlightY;
        final hDist = math.sqrt(hdx * hdx + hdy * hdy);
        final highlightIntensity = (1.0 - (hDist / (radius * 1.5))).clamp(0.0, 0.4);

        // Calculate shadow intensity (bottom right)
        final shadowIntensity = ((dist / radius) * 0.3).clamp(0.0, 0.3);

        final current = image.getPixel(x, y);
        var r = current.r.toInt();
        var g = current.g.toInt();
        var b = current.b.toInt();

        // Apply highlight
        r = (r + highlightIntensity * 180).round().clamp(0, 255);
        g = (g + highlightIntensity * 200).round().clamp(0, 255);
        b = (b + highlightIntensity * 255).round().clamp(0, 255);

        // Apply shadow
        r = (r * (1 - shadowIntensity)).round().clamp(0, 255);
        g = (g * (1 - shadowIntensity)).round().clamp(0, 255);
        b = (b * (1 - shadowIntensity)).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }
}

/// Draw stylized continents on the globe
void _drawContinents(img.Image image, double cx, double cy, double radius) {
  // Land colors
  final landColor = img.ColorRgba8(76, 175, 80, 255); // Green
  final sandColor = img.ColorRgba8(194, 178, 128, 255); // Desert tan

  // Simplified continent shapes using parametric equations
  // These create recognizable landmass patterns

  // Europe/Africa mass (right side)
  _drawLandmass(image, cx, cy, radius,
    offsetAngle: -0.2,
    offsetDist: 0.15,
    scaleX: 0.35,
    scaleY: 0.7,
    rotation: 0.1,
    color: landColor);

  // Americas mass (left side)
  _drawLandmass(image, cx, cy, radius,
    offsetAngle: math.pi - 0.3,
    offsetDist: 0.2,
    scaleX: 0.3,
    scaleY: 0.8,
    rotation: -0.15,
    color: landColor);

  // Asia mass (top right)
  _drawLandmass(image, cx, cy, radius,
    offsetAngle: -0.6,
    offsetDist: 0.3,
    scaleX: 0.5,
    scaleY: 0.35,
    rotation: 0.2,
    color: landColor);

  // Australia (bottom right)
  _drawLandmass(image, cx, cy, radius,
    offsetAngle: 0.5,
    offsetDist: 0.45,
    scaleX: 0.2,
    scaleY: 0.15,
    rotation: 0.1,
    color: sandColor);

  // Sahara desert overlay
  _drawDesertOverlay(image, cx, cy, radius);
}

/// Draw a stylized landmass shape
void _drawLandmass(
  img.Image image,
  double cx,
  double cy,
  double radius, {
  required double offsetAngle,
  required double offsetDist,
  required double scaleX,
  required double scaleY,
  required double rotation,
  required img.Color color,
}) {
  final c = color as img.ColorRgba8;
  final landCx = cx + math.cos(offsetAngle) * radius * offsetDist;
  final landCy = cy + math.sin(offsetAngle) * radius * offsetDist;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      // Check if inside globe first
      final gdx = x - cx;
      final gdy = y - cy;
      final globeDist = math.sqrt(gdx * gdx + gdy * gdy);
      if (globeDist > radius - 2) continue;

      // Transform to landmass coordinates
      var dx = (x - landCx) / (radius * scaleX);
      var dy = (y - landCy) / (radius * scaleY);

      // Apply rotation
      final rotDx = dx * math.cos(rotation) - dy * math.sin(rotation);
      final rotDy = dx * math.sin(rotation) + dy * math.cos(rotation);

      // Organic blob shape using perlin-like noise
      final angle = math.atan2(rotDy, rotDx);
      final baseDist = math.sqrt(rotDx * rotDx + rotDy * rotDy);

      // Add organic edges
      final noise = 0.15 * math.sin(angle * 3) +
                   0.1 * math.sin(angle * 5 + 1) +
                   0.05 * math.sin(angle * 8 + 2);

      if (baseDist < 1.0 + noise) {
        // Apply 3D shading to land
        final shadeAmount = (globeDist / radius * 0.2).clamp(0.0, 0.2);
        final r = (c.r * (1 - shadeAmount)).round().clamp(0, 255);
        final g = (c.g * (1 - shadeAmount)).round().clamp(0, 255);
        final b = (c.b * (1 - shadeAmount)).round().clamp(0, 255);

        // Anti-alias edges
        if (baseDist > 0.9 + noise) {
          final edgeDist = baseDist - (0.9 + noise);
          final alpha = ((1.0 - edgeDist / 0.1) * 255).round().clamp(0, 255);
          final current = image.getPixel(x, y);
          final newR = ((current.r.toInt() * (255 - alpha) + r * alpha) ~/ 255);
          final newG = ((current.g.toInt() * (255 - alpha) + g * alpha) ~/ 255);
          final newB = ((current.b.toInt() * (255 - alpha) + b * alpha) ~/ 255);
          image.setPixelRgba(x, y, newR, newG, newB, 255);
        } else {
          image.setPixelRgba(x, y, r, g, b, 255);
        }
      }
    }
  }
}

/// Add desert coloring to Africa region
void _drawDesertOverlay(img.Image image, double cx, double cy, double radius) {
  final desertColor = img.ColorRgba8(210, 180, 120, 255);

  final desertCx = cx + radius * 0.15;
  final desertCy = cy - radius * 0.1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      // Only affect green land areas
      final current = image.getPixel(x, y);
      if (current.g.toInt() < 150 || current.g.toInt() > 200) continue;
      if (current.r.toInt() > 100) continue; // Already desert

      final dx = (x - desertCx) / (radius * 0.2);
      final dy = (y - desertCy) / (radius * 0.12);
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist < 1.0) {
        final blend = (1.0 - dist).clamp(0.0, 0.7);
        final r = _lerp(current.r.toDouble(), desertColor.r.toDouble(), blend).round();
        final g = _lerp(current.g.toDouble(), desertColor.g.toDouble(), blend).round();
        final b = _lerp(current.b.toDouble(), desertColor.b.toDouble(), blend).round();
        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }
}

/// Draw latitude/longitude grid lines
void _drawGridLines(img.Image image, double cx, double cy, double radius) {
  final gridColor = img.ColorRgba8(255, 255, 255, 30);

  // Draw latitude lines (horizontal curves)
  for (var lat = -60; lat <= 60; lat += 30) {
    final latRad = lat * math.pi / 180;
    final y = cy - math.sin(latRad) * radius * 0.9;
    final halfWidth = math.cos(latRad) * radius * 0.9;

    for (var xi = -halfWidth.round(); xi <= halfWidth.round(); xi++) {
      final x = cx + xi;
      if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
        _blendPixel(image, x.round(), y.round(), gridColor);
      }
    }
  }

  // Draw longitude lines (vertical curves)
  for (var lon = -60; lon <= 60; lon += 30) {
    final lonRad = lon * math.pi / 180;

    for (var latDeg = -90.0; latDeg <= 90.0; latDeg += 2.0) {
      final latRad = latDeg * math.pi / 180;
      final projectedX = math.sin(lonRad) * math.cos(latRad);
      final projectedY = -math.sin(latRad);

      // Only draw front hemisphere
      if (math.cos(lonRad) > 0) {
        final x = (cx + projectedX * radius * 0.9).round();
        final y = (cy + projectedY * radius * 0.9).round();

        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          _blendPixel(image, x, y, gridColor);
        }
      }
    }
  }
}

/// Draw metallic rim around the globe
void _drawGlobeRim(img.Image image, double cx, double cy, double radius) {
  final rimColorLight = img.ColorRgba8(200, 200, 220, 255);
  final rimColorDark = img.ColorRgba8(80, 85, 100, 255);

  final rimInner = radius;
  final rimOuter = radius + radius * 0.03;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);

      if (dist >= rimInner && dist <= rimOuter) {
        // Calculate rim shading (light from top-left)
        final angle = math.atan2(dy, dx);
        final shade = (math.cos(angle + math.pi * 0.75) + 1) / 2;

        final r = _lerp(rimColorDark.r.toDouble(), rimColorLight.r.toDouble(), shade).round();
        final g = _lerp(rimColorDark.g.toDouble(), rimColorLight.g.toDouble(), shade).round();
        final b = _lerp(rimColorDark.b.toDouble(), rimColorLight.b.toDouble(), shade).round();

        // Anti-alias edges
        var alpha = 255;
        if (dist < rimInner + 1) {
          alpha = ((dist - rimInner) * 255).round();
        } else if (dist > rimOuter - 1) {
          alpha = ((rimOuter - dist) * 255).round();
        }

        final current = image.getPixel(x, y);
        final newR = ((current.r.toInt() * (255 - alpha) + r * alpha) ~/ 255);
        final newG = ((current.g.toInt() * (255 - alpha) + g * alpha) ~/ 255);
        final newB = ((current.b.toInt() * (255 - alpha) + b * alpha) ~/ 255);
        image.setPixelRgba(x, y, newR, newG, newB, 255);
      }
    }
  }
}

/// Draw a compass rose
void _drawCompassRose(img.Image image, double cx, double cy, double size) {
  // Draw compass circle background
  _drawFilledCircle(image, cx, cy, size * 0.8,
    img.ColorRgba8(30, 35, 50, 200));

  // Draw compass directions
  final pointerColor = img.ColorRgba8(255, 215, 0, 255); // Gold
  final northColor = img.ColorRgba8(220, 50, 50, 255); // Red for North

  // North pointer (red)
  _drawTriangle(image, cx, cy, size * 0.7, 0, northColor);

  // South pointer (gold)
  _drawTriangle(image, cx, cy, size * 0.5, math.pi, pointerColor);

  // East pointer (gold)
  _drawTriangle(image, cx, cy, size * 0.5, math.pi / 2, pointerColor);

  // West pointer (gold)
  _drawTriangle(image, cx, cy, size * 0.5, -math.pi / 2, pointerColor);

  // Center dot
  _drawFilledCircle(image, cx, cy, size * 0.12,
    img.ColorRgba8(255, 255, 255, 255));
}

/// Draw a directional triangle
void _drawTriangle(img.Image image, double cx, double cy, double length, double angle, img.Color color) {
  final c = color as img.ColorRgba8;
  final tipX = cx + math.sin(angle) * length;
  final tipY = cy - math.cos(angle) * length;
  final baseWidth = length * 0.25;

  final leftX = cx + math.sin(angle + math.pi / 2) * baseWidth;
  final leftY = cy - math.cos(angle + math.pi / 2) * baseWidth;
  final rightX = cx + math.sin(angle - math.pi / 2) * baseWidth;
  final rightY = cy - math.cos(angle - math.pi / 2) * baseWidth;

  // Fill triangle using scanline
  final minY = [tipY, leftY, rightY].reduce(math.min).floor();
  final maxY = [tipY, leftY, rightY].reduce(math.max).ceil();

  for (var y = minY; y <= maxY; y++) {
    final intersections = <double>[];

    // Check all three edges
    _addIntersection(intersections, tipX, tipY, leftX, leftY, y.toDouble());
    _addIntersection(intersections, leftX, leftY, rightX, rightY, y.toDouble());
    _addIntersection(intersections, rightX, rightY, tipX, tipY, y.toDouble());

    if (intersections.length >= 2) {
      intersections.sort();
      final startX = intersections.first.floor();
      final endX = intersections.last.ceil();

      for (var x = startX; x <= endX; x++) {
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixelRgba(x, y, c.r, c.g, c.b, c.a);
        }
      }
    }
  }
}

/// Add edge intersection point
void _addIntersection(List<double> intersections, double x1, double y1, double x2, double y2, double y) {
  if ((y1 <= y && y2 > y) || (y2 <= y && y1 > y)) {
    final t = (y - y1) / (y2 - y1);
    intersections.add(x1 + t * (x2 - x1));
  }
}

/// Blend a pixel with alpha
void _blendPixel(img.Image image, int x, int y, img.Color color) {
  if (x < 0 || x >= image.width || y < 0 || y >= image.height) return;

  final c = color as img.ColorRgba8;
  final current = image.getPixel(x, y);
  final alpha = c.a;

  final newR = ((current.r.toInt() * (255 - alpha) + c.r * alpha) ~/ 255);
  final newG = ((current.g.toInt() * (255 - alpha) + c.g * alpha) ~/ 255);
  final newB = ((current.b.toInt() * (255 - alpha) + c.b * alpha) ~/ 255);

  image.setPixelRgba(x, y, newR, newG, newB, 255);
}
