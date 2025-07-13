import 'package:flutter/material.dart';

class OrbitPaths extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const OrbitPaths({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Center(
            child: CustomPaint(
              painter: OrbitPathsPainter(),
              size: const Size(800, 800),
            ),
          ),
        );
      },
    );
  }
}

// Orbital paths painter
class OrbitPathsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw orbital paths
    canvas.drawCircle(center, 120, paint); // Venus
    canvas.drawCircle(center, 200, paint); // Earth
    canvas.drawCircle(center, 280, paint); // Mars
    canvas.drawCircle(center, 360, paint); // Jupiter
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
