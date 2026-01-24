import 'package:flutter/material.dart';

/// Atlas pattern painter for explorer header background
class AtlasPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw latitude lines
    for (int i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw meridian curves
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final path = Path()
        ..moveTo(x - 15, 0)
        ..quadraticBezierTo(x, size.height / 2, x + 15, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
