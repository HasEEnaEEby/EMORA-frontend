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
Color(0xFF1a0033), 
Color(0xFF0a0015), 
Color(0xFF000000), 
                    ],
                  ),
                ),
              ),
            );
          },
        ),

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

class RealisticStarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final stars = <Map<String, dynamic>>[];

    for (int i = 0; i < 150; i++) {
      stars.add({
        'x': (i * 37.5) % size.width,
        'y': (i * 73.2) % size.height,
        'size': 0.5 + (i % 3) * 0.3,
        'color': Colors.white,
        'opacity': 0.3 + ((i * 11) % 70) / 100.0,
      });
    }

    for (int i = 0; i < 20; i++) {
      stars.add({
        'x': (i * 127.3) % size.width,
        'y': (i * 191.7) % size.height,
        'size': 1.2 + (i % 2) * 0.5,
        'color': const Color(0xFFFFB6C1),
        'opacity': 0.4 + (i % 5) / 10.0,
      });
    }

    for (int i = 0; i < 15; i++) {
      stars.add({
        'x': (i * 97.1) % size.width,
        'y': (i * 157.3) % size.height,
        'size': 1.0 + (i % 3) * 0.3,
        'color': const Color(0xFF87CEEB),
        'opacity': 0.5 + (i % 4) / 8.0,
      });
    }

    for (final star in stars) {
      paint.color = (star['color'] as Color).withValues(
        alpha: star['opacity'] as double,
      );

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

class NebulaePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50.0);

    paint.color = const Color(0xFF8A2BE2).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 100, paint);

    paint.color = const Color(0xFF4169E1).withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, paint);

    paint.color = const Color(0xFFFF1493).withValues(alpha: 0.06);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 60, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
