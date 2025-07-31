import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class EarthWidget extends StatelessWidget {
  final AnimationController orbitController;
  final AnimationController pulseController;
  final AnimationController earthRotationController;
  final AnimationController transitionController;
  final Animation<double> zoomAnimation;
  final Animation<Offset> earthPositionAnimation;
  final Animation<double> earthRotationAnimation;
  final bool isTransitioning;
  final VoidCallback onTap;

  const EarthWidget({
    super.key,
    required this.orbitController,
    required this.pulseController,
    required this.earthRotationController,
    required this.transitionController,
    required this.zoomAnimation,
    required this.earthPositionAnimation,
    required this.earthRotationAnimation,
    required this.isTransitioning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          orbitController,
          pulseController,
          zoomAnimation,
          earthPositionAnimation,
          earthRotationController,
          earthRotationAnimation,
        ]),
        builder: (context, child) {
          final orbitAngle = orbitController.value * 2 * math.pi;
          final baseOffset = isTransitioning
              ? earthPositionAnimation.value
              : const Offset(200, 0);

          return Transform.rotate(
            angle: isTransitioning ? 0 : orbitAngle,
            child: Transform.translate(
              offset: isTransitioning ? Offset.zero : baseOffset,
              child: Transform.rotate(
                angle: isTransitioning ? 0 : -orbitAngle,
                child: Transform.scale(
                  scale: zoomAnimation.value,
                  child: GestureDetector(
                    onTap: () {
                      print(
                        '🌍 Earth.glb MODEL TAPPED! Triggering navigation...',
                      );
                      onTap();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
width: 80, 
height: 80, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withValues(
                              alpha: isTransitioning
                                  ? math.min(
                                      0.9,
                                      0.3 + (transitionController.value * 0.6),
                                    )
                                  : 0.3 + (pulseController.value * 0.4),
                            ),
                            blurRadius: isTransitioning
                                ? math.min(
                                    100.0,
                                    25 + (transitionController.value * 75),
                                  )
                                : 25 + (pulseController.value * 15),
                            spreadRadius: isTransitioning
                                ? math.min(
                                    50.0,
                                    8 + (transitionController.value * 42),
                                  )
                                : 8 + (pulseController.value * 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: earthRotationController,
                              builder: (context, child) {
                                final rotationSpeed = isTransitioning
                                    ? earthRotationAnimation.value
                                    : 1.0;
                                return Transform.rotate(
                                  angle:
                                      earthRotationController.value *
                                      2 *
                                      math.pi *
                                      rotationSpeed,
                                  child: ModelViewer(
                                    src: 'assets/images/3d/earth.glb',
                                    alt: "Earth - Emotional Hub",
                                    ar: false,
                                    autoRotate: !isTransitioning,
                                    disableZoom: true,
                                    cameraControls: false,
                                    backgroundColor: Colors.transparent,
                                  ),
                                );
                              },
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
