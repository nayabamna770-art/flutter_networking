// lib/ui/app_styles.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppStyles {
  // Brand Colors
  static const Color primaryColor = Colors.deepPurple;
  static const Color accentColor = Colors.purpleAccent;
  static const Color backgroundColor = Color(0xFFA592EB);

  // Modern Theme Configuration
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  // Frosted Glass Effect (BackdropFilter)
  static Widget buildGlassContainer({
    required Widget child,
    double borderRadius = 16.0,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // Gradient Text (ShaderMask)
  static Widget buildShaderText(
    String text, {
    TextStyle? style,
    List<Color>? colors,
  }) {
    final defaultColors = colors ?? [Colors.amber, Colors.orangeAccent];
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: defaultColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: (style ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
            .copyWith(color: Colors.white),
      ),
    );
  }
}

// Custom Background ClipPath Painter
class WavesBackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  WavesBackgroundPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final path1 = Path();
    paint.color = primaryColor.withValues(alpha: 0.5);
    path1.moveTo(0, size.height * 0.25);
    path1.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.18,
      size.width * 0.5,
      size.height * 0.22,
    );
    path1.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.26,
      size.width,
      size.height * 0.20,
    );
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    canvas.drawPath(path1, paint);

    final path2 = Path();
    paint.color = secondaryColor.withValues(alpha: 0.3);
    path2.moveTo(0, size.height * 0.22);
    path2.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.28,
      size.width * 0.65,
      size.height * 0.20,
    );
    path2.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.15,
      size.width,
      size.height * 0.18,
    );
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}