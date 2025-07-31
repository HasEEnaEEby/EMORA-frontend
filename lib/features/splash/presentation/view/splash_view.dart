import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/utils/logger.dart';
import '../view_model/cubit/splash_cubit.dart';
import '../view_model/cubit/splash_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _breatheController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _logoSlideAnimation;

  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textScaleAnimation;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _gradientAnimation;

  late Animation<double> _particleAnimation;
  late Animation<double> _particleRotationAnimation;

  late Animation<double> _pulseAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutCubic),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -math.pi / 4, end: 0.0)
        .animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
          ),
        );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _textSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutExpo),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutQuart),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: Curves.easeInOutSine,
      ),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCirc),
      ),
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _particleRotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi)
        .animate(
          CurvedAnimation(parent: _particleController, curve: Curves.linear),
        );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _breatheAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOutSine),
    );
  }

  void _startAnimations() {
    _backgroundController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _particleController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _breatheController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          Logger.info('🎯 SplashView received state: ${state.runtimeType}');
          _handleNavigationState(state);
        },
        child: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            return Stack(
              children: [
                _buildEnhancedBackground(),

                _buildEnhancedParticles(),

                _buildEnhancedMainContent(state),

                _buildGlowEffects(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleNavigationState(SplashState state) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      if (state is SplashNavigateToAuth) {
        Logger.info('🔄 Navigating to auth choice...');
        _showNavigationFeedback('Taking you to sign in options...');
        NavigationService.pushReplacementNamed(AppRouter.authChoice);
      } else if (state is SplashNavigateToAuthWithMessage) {
        Logger.info(
          '🔄 Navigating to auth choice with message: ${state.message}',
        );

        if (state.message.isNotEmpty) {
          if (state.isReturningUser) {
            NavigationService.showWarningSnackBar(state.message);
          } else {
            NavigationService.showInfoSnackBar(state.message);
          }
        }

        _showNavigationFeedback('Redirecting to sign in...');
        NavigationService.pushReplacementNamed(AppRouter.authChoice);
      } else if (state is SplashNavigateToOnboarding) {
        Logger.info(
          '🔄 Navigating to onboarding (first time: ${state.isFirstTime})...',
        );
        if (state.isFirstTime) {
          _showNavigationFeedback('Welcome! Let\'s set up your profile...');
        } else {
          _showNavigationFeedback('Completing your setup...');
        }
        NavigationService.pushReplacementNamed(AppRouter.onboarding);
      } else if (state is SplashNavigateToHome) {
        Logger.info('🔄 Navigating to home with user data...');
        _showNavigationFeedback('Welcome back! Loading your dashboard...');
        NavigationService.pushReplacementNamed(
          AppRouter.home,
          arguments: state.userData,
        );
      } else if (state is SplashError) {
        Logger.error('. Splash error: ${state.message}', state.message);
        NavigationService.showErrorSnackBar('Error: ${state.message}');

        if (state.canRetry) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Logger.info(
                '🔄 Error with retry capability - staying on splash for user action',
              );
            }
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Logger.info('🔄 Error fallback - navigating to onboarding');
              _showNavigationFeedback('Redirecting to setup...');
              NavigationService.pushReplacementNamed(AppRouter.onboarding);
            }
          });
        }
      }
    });
  }

  void _showNavigationFeedback(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF8B5CF6),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildEnhancedBackground() {
    return AnimatedBuilder(
      animation: Listenable.merge([_backgroundAnimation, _gradientAnimation]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.0 + math.sin(_backgroundAnimation.value * 2 * math.pi) * 0.1,
                -0.3 + math.cos(_backgroundAnimation.value * 2 * math.pi) * 0.1,
              ),
              radius: 1.5 + _gradientAnimation.value * 0.3,
              colors: [
                Color.lerp(
                  const Color(0xFF8B5FBF).withValues(alpha: 0.1),
                  const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                  _gradientAnimation.value,
                )!,
                Color.lerp(
                  const Color(0xFF6B3FA0).withValues(alpha: 0.05),
                  const Color(0xFF6B3FA0).withValues(alpha: 0.2),
                  _gradientAnimation.value,
                )!,
                const Color(0xFF090110),
              ],
              stops: [0.0, 0.4 + _backgroundAnimation.value * 0.2, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedParticles() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _particleAnimation,
        _particleRotationAnimation,
      ]),
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final progress = (_particleAnimation.value + index * 0.1) % 1.0;
            final angle =
                index * (2 * math.pi / 20) + _particleRotationAnimation.value;
            final radius = 50.0 + index * 15.0;

            final centerX = MediaQuery.of(context).size.width / 2;
            final centerY = MediaQuery.of(context).size.height / 2;

            final x =
                centerX + math.cos(angle) * radius * (0.5 + progress * 0.5);
            final y =
                centerY +
                math.sin(angle) * radius * (0.5 + progress * 0.5) +
                progress * MediaQuery.of(context).size.height;

            final size =
                3.0 + (index % 4) + math.sin(progress * 2 * math.pi) * 2;
            final opacity = (1.0 - progress) * (0.3 + (index % 3) * 0.1);

            return Positioned(
              left: x - size / 2,
              top: y - size / 2,
              child: Transform.rotate(
                angle: _particleRotationAnimation.value + index,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      const Color(0xFF8B5FBF),
                      const Color(0xFFD8A5FF),
                      index / 20,
                    )!.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF8B5FBF,
                        ).withValues(alpha: opacity * 0.5),
                        blurRadius: size * 2,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildEnhancedMainContent(SplashState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEnhancedLogo(),

          const SizedBox(height: 40),

          _buildEnhancedTagline(),

          const SizedBox(height: 60),

          _buildEnhancedStatusContent(state),

          const SizedBox(height: 40),

          _buildEnhancedBottomBranding(),
        ],
      ),
    );
  }

  Widget _buildEnhancedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _pulseController,
        _breatheController,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlideAnimation,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value,
            child: Transform.scale(
              scale:
                  _logoScaleAnimation.value *
                  _pulseAnimation.value *
                  _breatheAnimation.value,
              child: Opacity(
                opacity: _logoOpacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF8B5FBF,
                        ).withValues(alpha: _logoOpacityAnimation.value * 0.3),
                        blurRadius: 30 * _pulseAnimation.value,
                        spreadRadius: 5 * _breatheAnimation.value,
                      ),
                    ],
                  ),
                  child: _buildLogoContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoContent() {
    try {
      return SvgPicture.asset(
        'assets/images/EmoraLogo.svg',
        width: 320,
        height: 140,
        placeholderBuilder: (context) => _buildTextLogo(),
      );
    } catch (e) {
      Logger.warning('. SVG logo not found, using text logo');
      return _buildTextLogo();
    }
  }

  Widget _buildTextLogo() {
    return Container(
      width: 300,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5FBF), Color(0xFFD8A5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EMORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Express Yourself',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedTagline() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Transform.scale(
            scale: _textScaleAnimation.value,
            child: Opacity(
              opacity: _textOpacityAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(
                      0xFF8B5FBF,
                    ).withValues(alpha: _textOpacityAnimation.value * 0.4),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(
                        0xFF8B5FBF,
                      ).withValues(alpha: _textOpacityAnimation.value * 0.15),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF8B5FBF,
                      ).withValues(alpha: _textOpacityAnimation.value * 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF8B5FBF), Color(0xFFD8A5FF)],
                  ).createShader(bounds),
                  child: const Text(
                    'Your Daily Space to Feel Out Loud',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedStatusContent(SplashState state) {
    if (state is SplashLoading) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                        blurRadius: 20 * _pulseAnimation.value,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    color: const Color(0xFF8B5FBF),
                    strokeWidth: 3,
                    backgroundColor: const Color(
                      0xFF8B5FBF,
                    ).withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.message ?? 'Initializing your experience...',
                  style: TextStyle(
                    color: const Color(0xFFB0B0B0),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF8B5FBF).withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (state is SplashError) {
      return _buildEnhancedErrorState(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildEnhancedErrorState(SplashError state) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade400.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.red.shade400.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade400.withValues(alpha: 0.2),
                    blurRadius: 15 * _pulseAnimation.value,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.error_outline,
                size: 35,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.red.shade400.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (state
.canRetry) 
              Transform.scale(
                scale: _pulseAnimation.value,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<SplashCubit>().retryInitialization(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5FBF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF8B5FBF).withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedBottomBranding() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacityAnimation.value * 0.7,
          child: Transform.scale(
            scale: _textScaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF666666).withValues(alpha: 0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF666666).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5FBF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF8B5FBF), Color(0xFF666666)],
                    ).createShader(bounds),
                    child: const Text(
                      'Powered by Emora',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5FBF).withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlowEffects() {
    return AnimatedBuilder(
      animation: _breatheController,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.8 * _breatheAnimation.value,
                  colors: [
                    const Color(0xFF8B5FBF).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
