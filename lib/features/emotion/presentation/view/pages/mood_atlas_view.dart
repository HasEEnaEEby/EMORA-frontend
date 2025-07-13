import 'dart:math' as math;

import 'package:emora_mobile_app/features/emotion/presentation/view/pages/earth_emotional_map_view.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/earth_widget.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/orbit_paths.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/solar_system.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/space_background.dart';
import 'package:flutter/material.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/enhanced_atlas_view.dart';

class MoodAtlasView extends StatefulWidget {
  const MoodAtlasView({super.key});

  @override
  State<MoodAtlasView> createState() => _MoodAtlasViewState();
}

class _MoodAtlasViewState extends State<MoodAtlasView>
    with TickerProviderStateMixin {
  bool _isTapped = false;
  bool _isTransitioning = false;
  late AnimationController _rotationController;
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late AnimationController _transitionController;
  late AnimationController _earthRotationController;
  late AnimationController _uiPulseController;
  late AnimationController _floatingController;

  // Cinematic transition animations
  late Animation<double> _zoomAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _earthPositionAnimation;
  late Animation<double> _earthRotationAnimation;
  late Animation<double> _uiPulseAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Slow rotation for the background
    _rotationController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat();

    // Planet orbits
    _orbitController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();

    // Earth glow pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // UI element pulse
    _uiPulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Floating animation for UI elements
    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Earth rotation (faster for effect)
    _earthRotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Cinematic transition controller
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Setup transition animations
    _setupTransitionAnimations();
  }

  void _setupTransitionAnimations() {
    // Epic zoom animation (starts normal, goes massive)
    _zoomAnimation = Tween<double>(begin: 1.0, end: 80.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeInExpo),
      ),
    );

    // Fade out space background
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    // Earth moves to center during transition
    _earthPositionAnimation =
        Tween<Offset>(begin: const Offset(200, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _transitionController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
          ),
        );

    // Earth rotation speeds up during transition
    _earthRotationAnimation = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // UI pulse animation
    _uiPulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _uiPulseController, curve: Curves.easeInOut),
    );

    // Floating animation
    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _transitionController.dispose();
    _earthRotationController.dispose();
    _uiPulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _onEarthTap() {
    print('🚀 EARTH TAPPED! Starting cinematic transition...');

    if (_isTransitioning) {
      print('⚠️ Already transitioning, ignoring tap');
      return;
    }

    setState(() {
      _isTapped = true;
      _isTransitioning = true;
    });

    // Stop other animations for cinematic effect
    _rotationController.stop();
    _orbitController.stop();
    _pulseController.stop();
    _uiPulseController.stop();
    _floatingController.stop();

    print('🎬 Starting epic zoom transition...');
    // Start the epic transition
    _transitionController.forward().then((_) {
      print('✅ Transition complete! Navigating to map...');

      // Navigate to enhanced atlas after transition
      Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const EnhancedAtlasView(),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeIn),
                  ),
                  child: child,
                );
              },
            ),
          )
          .then((_) {
            print('🔙 Returned from map, resetting...');
            _resetAfterTransition();
          })
          .catchError((error) {
            print('❌ Navigation error: $error');
            _resetAfterTransition();
          });
    });
  }

  void _resetAfterTransition() {
    setState(() {
      _isTapped = false;
      _isTransitioning = false;
    });
    _transitionController.reset();
    _rotationController.repeat();
    _orbitController.repeat();
    _pulseController.repeat(reverse: true);
    _uiPulseController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          return Stack(
            children: [
              // Space background with stars and nebulae
              SpaceBackground(
                rotationController: _rotationController,
                fadeAnimation: _fadeAnimation,
              ),

              // Solar system (sun and planets except Earth)
              SolarSystem(
                orbitController: _orbitController,
                fadeAnimation: _fadeAnimation,
              ),

              // Earth widget with cinematic transition
              EarthWidget(
                orbitController: _orbitController,
                pulseController: _pulseController,
                earthRotationController: _earthRotationController,
                zoomAnimation: _zoomAnimation,
                earthPositionAnimation: _earthPositionAnimation,
                earthRotationAnimation: _earthRotationAnimation,
                isTransitioning: _isTransitioning,
                transitionController: _transitionController,
                onTap: _onEarthTap,
              ),

              // Orbital paths
              OrbitPaths(fadeAnimation: _fadeAnimation),

              // Cinematic transition overlay effect (tunnel vision)
              if (_isTransitioning) _buildTransitionOverlay(),

              // Enhanced UI Elements
              if (!_isTransitioning) _buildEnhancedUI(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransitionOverlay() {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: math.max(0.1, 1.2 - (_transitionController.value * 1.0)),
              colors: [
                Colors.transparent,
                Colors.black.withValues(
                  alpha: _transitionController.value * 0.9,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedUI() {
    return SafeArea(
      child: Column(
        children: [
          _buildEnhancedHeader(),
          const Spacer(),
          _buildEnhancedInstructions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced back button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedInstructions() {
    return AnimatedBuilder(
      animation: Listenable.merge([_uiPulseAnimation, _floatingAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value * 0.5),
          child: Column(
            children: [
              // Main instruction card - make it tappable as backup
              GestureDetector(
                onTap: () {
                  print('📝 INSTRUCTION CARD TAPPED as backup!');
                  _onEarthTap();
                },
                behavior: HitTestBehavior.opaque,
                child: Transform.scale(
                  scale: _uiPulseAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF4A90E2).withValues(alpha: 0.15),
                          const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                          const Color(0xFF00CEC9).withValues(alpha: 0.15),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A90E2).withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.withValues(alpha: 0.3),
                                Colors.purple.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.public,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tap Earth to explore emotions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.6,
                            // Removed shadows to make it simpler
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle with floating animation
              Transform.translate(
                offset: Offset(0, _floatingAnimation.value * -0.3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '🌍 Discover global emotional patterns in real-time',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
