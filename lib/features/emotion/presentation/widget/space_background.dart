import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpaceBackground extends StatelessWidget {
  final AnimationController rotationController;
  final Animation<double> fadeAnimation;

  const SpaceBackground({
    super.key,
    required this.rotationController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep space background with nebula
        AnimatedBuilder(
          animation: fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.3, -0.5),
                    radius: 2.0,
                    colors: [
                      Color(0xFF1a0033), // Deep purple nebula
                      Color(0xFF0a0015), // Dark purple
                      Color(0xFF000000), // Pure black
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Rotating starfield
        AnimatedBuilder(
          animation: Listenable.merge([rotationController, fadeAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Transform.rotate(
                angle: rotationController.value * 2 * math.pi,
                child: CustomPaint(
                  painter: RealisticStarFieldPainter(),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),

        // Distant galaxies and nebulae
        AnimatedBuilder(
          animation: fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: CustomPaint(painter: NebulaePainter()),
            );
          },
        ),
      ],
    );
  }
}

// Realistic starfield painter
class RealisticStarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Create different star types
    final stars = <Map<String, dynamic>>[];

    // Generate main sequence stars (white/blue)
    for (int i = 0; i < 150; i++) {
      stars.add({
        'x': (i * 37.5) % size.width,
        'y': (i * 73.2) % size.height,
        'size': 0.5 + (i % 3) * 0.3,
        'color': Colors.white,
        'opacity': 0.3 + ((i * 11) % 70) / 100.0,
      });
    }

    // Add some red giants
    for (int i = 0; i < 20; i++) {
      stars.add({
        'x': (i * 127.3) % size.width,
        'y': (i * 191.7) % size.height,
        'size': 1.2 + (i % 2) * 0.5,
        'color': const Color(0xFFFFB6C1),
        'opacity': 0.4 + (i % 5) / 10.0,
      });
    }

    // Add blue giants
    for (int i = 0; i < 15; i++) {
      stars.add({
        'x': (i * 97.1) % size.width,
        'y': (i * 157.3) % size.height,
        'size': 1.0 + (i % 3) * 0.3,
        'color': const Color(0xFF87CEEB),
        'opacity': 0.5 + (i % 4) / 8.0,
      });
    }

    // Draw all stars
    for (final star in stars) {
      paint.color = (star['color'] as Color).withValues(
        alpha: star['opacity'] as double,
      );

      // Add subtle glow for larger stars
      if (star['size'] > 1.0) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
      } else {
        paint.maskFilter = null;
      }

      canvas.drawCircle(
        Offset(star['x'] as double, star['y'] as double),
        star['size'] as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Nebulae painter for distant background
class NebulaePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50.0);

    // Purple nebula
    paint.color = const Color(0xFF8A2BE2).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 100, paint);

    // Blue nebula
    paint.color = const Color(0xFF4169E1).withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    // Pink nebula
    paint.color = const Color(0xFFFF1493).withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
