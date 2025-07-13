import 'dart:math' as math;

import 'package:flutter/material.dart';

class SolarSystem extends StatelessWidget {
  final AnimationController orbitController;
  final Animation<double> fadeAnimation;

  const SolarSystem({
    super.key,
    required this.orbitController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solar system center (Sun)
        AnimatedBuilder(
          animation: fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFD700), // Gold center
                        Color(0xFFFF8C00), // Orange
                        Color(0xFFFF4500), // Red-orange edge
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF8C00).withValues(alpha: 0.4),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Orbiting planets (except Earth)
        AnimatedBuilder(
          animation: Listenable.merge([orbitController, fadeAnimation]),
          builder: (context, child) {
            return Opacity(
              opacity: fadeAnimation.value,
              child: Center(
                child: Stack(
                  children: [
                    // Venus orbit
                    _buildPlanet(
                      angle: orbitController.value * 2 * math.pi * 1.6,
                      distance: 120,
                      size: 15,
                      colors: const [Color(0xFFFFC649), Color(0xFFFF8C00)],
                      glowColor: const Color(0xFFFFC649),
                    ),

                    // Mars orbit
                    _buildPlanet(
                      angle: orbitController.value * 2 * math.pi * 0.5,
                      distance: 280,
                      size: 20,
                      colors: const [Color(0xFFCD5C5C), Color(0xFF8B0000)],
                      glowColor: const Color(0xFFCD5C5C),
                    ),

                    // Jupiter orbit (distant)
                    _buildPlanet(
                      angle: orbitController.value * 2 * math.pi * 0.3,
                      distance: 360,
                      size: 35,
                      colors: const [Color(0xFFD2691E), Color(0xFF8B4513)],
                      glowColor: const Color(0xFFD2691E),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlanet({
    required double angle,
    required double distance,
    required double size,
    required List<Color> colors,
    required Color glowColor,
  }) {
    return Transform.rotate(
      angle: angle,
      child: Transform.translate(
        offset: Offset(distance, 0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.4),
                blurRadius: size * 0.8,
                spreadRadius: size * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
