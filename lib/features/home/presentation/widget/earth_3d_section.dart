import 'dart:math' as math;
import 'dart:ui';

import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class Earth3DSection extends StatefulWidget {
  final String selectedMood;

  const Earth3DSection({super.key, required this.selectedMood});

  @override
  State<Earth3DSection> createState() => _Earth3DSectionState();
}

class _Earth3DSectionState extends State<Earth3DSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _earthController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _earthRotation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _earthController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _earthRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _earthController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    _earthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow effect
          _buildBackgroundGlow(),
          // Enhanced 3D-looking Earth
          _buildEnhanced3DEarth(),
          // Floating emotion particles
          ..._buildFloatingParticles(),
          // Emotion indicators on earth
          _buildEmotionIndicators(),
          // Instructions overlay
          _buildInstructionsOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    final emotion = EmotionConstants.getEmotion(widget.selectedMood);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 300 * _pulseAnimation.value,
          height: 300 * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (emotion['color'] as Color).withValues(alpha: 0.3),
                (emotion['color'] as Color).withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhanced3DEarth() {
    return AnimatedBuilder(
      animation: _earthRotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _earthRotation.value * 2 * math.pi,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                colors: [
                  Color(0xFF4FC3F7), // Light blue (water)
                  Color(0xFF29B6F6), // Medium blue
                  Color(0xFF0288D1), // Dark blue
                  Color(0xFF01579B), // Deepest blue
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Realistic continents
                _buildRealisticContinents(),
                // Atmospheric glow
                _buildAtmosphere(),
                // City lights (subtle)
                _buildCityLights(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealisticContinents() {
    return Stack(
      children: [
        // North America
        Positioned(
          top: 40,
          left: 30,
          child: Container(
            width: 45,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        // South America
        Positioned(
          top: 90,
          left: 50,
          child: Container(
            width: 25,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF388E3C),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                  blurRadius: 3,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        // Europe/Africa
        Positioned(
          top: 45,
          left: 90,
          child: Container(
            width: 35,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047),
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF388E3C).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        // Asia
        Positioned(
          top: 25,
          left: 125,
          child: Container(
            width: 55,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF43A047).withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        // Australia
        Positioned(
          bottom: 40,
          right: 30,
          child: Container(
            width: 22,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAtmosphere() {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.2),
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildCityLights() {
    return Stack(
      children: List.generate(12, (index) {
        final random = math.Random(
          index + 42,
        ); // Fixed seed for consistent positions
        return Positioned(
          top: 40 + random.nextDouble() * 140,
          left: 40 + random.nextDouble() * 140,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 1.5,
                height: 1.5,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(
                    alpha: 0.4 + (0.3 * _pulseAnimation.value),
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.6),
                      blurRadius: 3,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmotionIndicators() {
    final emotion = EmotionConstants.getEmotion(widget.selectedMood);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Your location indicator (center-right, representing your region)
            Positioned(
              top: 90,
              right: 50,
              child: _buildEmotionDot(
                emotion['color'] as Color,
                isYou: true,
                scale: _pulseAnimation.value,
              ),
            ),
            // Other global emotions with realistic positioning
            Positioned(
              top: 70,
              left: 60,
              child: _buildEmotionDot(
                EmotionConstants.emotions['calm']!['color'] as Color,
                isYou: false,
              ),
            ),
            Positioned(
              bottom: 80,
              right: 70,
              child: _buildEmotionDot(
                EmotionConstants.emotions['happy']!['color'] as Color,
                isYou: false,
              ),
            ),
            Positioned(
              bottom: 100,
              left: 80,
              child: _buildEmotionDot(
                EmotionConstants.emotions['grateful']!['color'] as Color,
                isYou: false,
              ),
            ),
            Positioned(
              top: 50,
              left: 140,
              child: _buildEmotionDot(
                EmotionConstants.emotions['excited']!['color'] as Color,
                isYou: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmotionDot(
    Color color, {
    bool isYou = false,
    double scale = 1.0,
  }) {
    return Container(
      width: (isYou ? 16 : 12) * scale,
      height: (isYou ? 16 : 12) * scale,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isYou
            ? Border.all(color: Colors.white, width: 2.5)
            : Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.8),
            blurRadius: isYou ? 15 : 8,
            spreadRadius: isYou ? 4 : 2,
          ),
          if (isYou)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: isYou
          ? Icon(Icons.person, size: 10 * scale, color: Colors.white)
          : Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    final emotion = EmotionConstants.getEmotion(widget.selectedMood);

    return List.generate(16, (index) {
      return AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          final angle =
              (_particleAnimation.value + index * 0.0625) * 2 * math.pi;
          final radius = 140.0 + (index % 4) * 15;
          final x = math.cos(angle) * radius;
          final y = math.sin(angle) * radius;
          final opacity =
              0.2 +
              (math.sin(_particleAnimation.value * 2 * math.pi + index) * 0.4);

          return Transform.translate(
            offset: Offset(x, y),
            child: Container(
              width: 3 + (index % 4),
              height: 3 + (index % 4),
              decoration: BoxDecoration(
                color: (emotion['color'] as Color).withValues(
                  alpha: opacity.clamp(0.0, 1.0),
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (emotion['color'] as Color).withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildInstructionsOverlay() {
    return Positioned(
      bottom: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: EmotionConstants.getEmotionColor(
                      widget.selectedMood,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: EmotionConstants.getEmotionColor(
                          widget.selectedMood,
                        ).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your emotions connect you to the world 🌍',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
