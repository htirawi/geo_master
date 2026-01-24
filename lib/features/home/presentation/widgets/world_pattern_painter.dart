import 'package:flutter/material.dart';

/// Custom painter for world pattern background
class WorldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw latitude lines
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw longitude curves
    for (int i = 1; i < 8; i++) {
      final x = size.width * i / 8;
      final path = Path()
        ..moveTo(x - 20, 0)
        ..quadraticBezierTo(x, size.height / 2, x + 20, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
