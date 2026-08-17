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

    // 1. Top Wave Header Gradient
    final topWavePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height * 0.35));

    final topWavePath = Path()
      ..lineTo(0, height * 0.22)
      ..cubicTo(
        width * 0.3, height * 0.30,
        width * 0.7, height * 0.15,
        width, height * 0.25,
      )
      ..lineTo(width, 0)
      ..close();

    canvas.drawPath(topWavePath, topWavePaint);

    // 2. Bottom Wave Footer Accent
    final bottomWavePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          secondaryColor.withValues(alpha: 0.3),
          primaryColor.withValues(alpha: 0.5),
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ).createShader(Rect.fromLTWH(0, height * 0.8, width, height * 0.2));

    final bottomWavePath = Path()
      ..moveTo(0, height * 0.9)
      ..cubicTo(
        width * 0.35, height * 0.82,
        width * 0.65, height * 0.98,
        width, height * 0.88,
      )
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    canvas.drawPath(bottomWavePath, bottomWavePaint);

    // 3. Subtle Decorative Background Bubbles
    final bubblePaint1 = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final bubblePaint2 = Paint()
      ..color = secondaryColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(width * 0.85, height * 0.12),
      70,
      bubblePaint1,
    );

    canvas.drawCircle(
      Offset(width * 0.1, height * 0.6),
      110,
      bubblePaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}