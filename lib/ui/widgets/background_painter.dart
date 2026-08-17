import 'package:flutter/material.dart';

class HeaderBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  HeaderBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // --- Paint Setup for Top Wave ---
    final topWavePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    final topWavePath = Path()
      ..lineTo(0, height * 0.75)
      ..cubicTo(
        width * 0.25, height * 0.95, // Control point 1
        width * 0.75, height * 0.55, // Control point 2
        width, height * 0.80,       // End point
      )
      ..lineTo(width, 0)
      ..close();

    canvas.drawPath(topWavePath, topWavePaint);

    // --- Paint Setup for Subtle Accent Bubble ---
    final accentPaint = Paint()
      ..color = primaryColor.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(width * 0.85, height * 0.25),
      80,
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}