import 'dart:math' as math;

import 'package:emora_mobile_app/features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/earth_widget.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/orbit_paths.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/solar_system.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/space_background.dart';
import 'package:flutter/material.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/enhanced_atlas_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emora_mobile_app/app/di/injection_container.dart' as di;
import 'package:emora_mobile_app/features/emotion/domain/use_case/log_emotion.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_emotion_feed.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_stats.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_heatmap.dart';
import 'package:emora_mobile_app/features/emotion/domain/repository/emotion_repository.dart';
import 'package:emora_mobile_app/features/emotion/services/insights_service.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/ai_insights_widget.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

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

  // AI Insights
  EmotionInsight? _globalInsight;
  bool _isLoadingInsights = false;
  String? _insightsErrorMessage;
  InsightsService? _insightsService;

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
    _initializeInsightsService();
    _loadGlobalInsights();
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

  void _initializeInsightsService() {
    try {
      _insightsService = InsightsService(di.sl<ApiService>());
      print('✅ InsightsService initialized successfully in MoodAtlasView');
    } catch (e) {
      print('❌ Failed to initialize InsightsService in MoodAtlasView: $e');
      _insightsService = null;
    }
  }

  Future<void> _loadGlobalInsights() async {
    if (_insightsService == null) {
      print('⚠️ InsightsService not initialized');
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Insights service not available';
      });
      return;
    }

    setState(() {
      _isLoadingInsights = true;
      _insightsErrorMessage = null;
    });

    try {
      final insight = await _insightsService!.getGlobalInsights(
        timeRange: '7d',
      );
      
      setState(() {
        _globalInsight = insight;
        _isLoadingInsights = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Failed to load AI insights: $e';
      });
      print('Error loading global insights: $e');
    }
  }

  void _showAIInsightsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'AI Emotional Intelligence',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Global Insights
                        if (_globalInsight != null) ...[
                          Text(
                            'Global Insights',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AIInsightsWidget(
                            insight: _globalInsight,
                            onRefresh: _loadGlobalInsights,
                          ),
                        ] else if (_insightsService == null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'AI Insights service not available. Please check your connection.',
                                    style: TextStyle(
                                      color: Colors.orange.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Loading state
                        if (_isLoadingInsights)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        
                        // Error state
                        if (_insightsErrorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _insightsErrorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
      if (!mounted) return;

      // Get the EmotionBloc from current context before navigation
      EmotionBloc? emotionBloc;
      try {
        emotionBloc = context.read<EmotionBloc>();
        print('✅ Found EmotionBloc in MoodAtlasView context');
      } catch (e) {
        print('⚠️ EmotionBloc not found in MoodAtlasView: $e');
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) {
            // Pass the EmotionBloc to the new route
            if (emotionBloc != null) {
              return BlocProvider.value(
                value: emotionBloc,
                child:  EnhancedAtlasView(),
              );
            } else {
              // Fallback: create a new EmotionBloc instance using DI
              return BlocProvider(
                create: (context) => EmotionBloc(
                  logEmotion: di.sl<LogEmotion>(),
                  getEmotionFeed: di.sl<GetEmotionFeed>(),
                  getGlobalEmotionStats: di.sl<GetGlobalEmotionStats>(),
                  getGlobalHeatmap: di.sl<GetGlobalEmotionHeatmap>(),
                  emotionRepository: di.sl<EmotionRepository>(),
                ),
                child:  EnhancedAtlasView(),
              );
            }
          },
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn),
              ),
              child: child,
            );
          },
        ),
      ).then((_) {
        if (mounted) _resetAfterTransition();
      }).catchError((error) {
        print('❌ Navigation error: $error');
        if (mounted) _resetAfterTransition();
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
                
                // AI Insights Button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        const Color(0xFF6366F1).withValues(alpha: 0.2),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _showAIInsightsModal,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
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
                  print('�� INSTRUCTION CARD TAPPED as backup!');
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
