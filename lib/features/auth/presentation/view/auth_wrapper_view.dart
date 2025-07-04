import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/utils/logger.dart';
import '../view_model/bloc/auth_bloc.dart';
import '../view_model/bloc/auth_event.dart';
import '../view_model/bloc/auth_state.dart';

class AuthWrapperView extends StatefulWidget {
  const AuthWrapperView({super.key});

  @override
  State<AuthWrapperView> createState() => _AuthWrapperViewState();
}

class _AuthWrapperViewState extends State<AuthWrapperView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _hasShownSessionExpired = false;
  bool _hasNavigated = false; // Prevent multiple navigation attempts

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    // Check auth status when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const CheckAuthStatus());
      }
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleNavigation(AuthState state) {
    if (_hasNavigated || !mounted) return;

    if (state is AuthAuthenticated) {
      _hasNavigated = true;
      Logger.info('🏠 User authenticated: ${state.user.username}');
      Logger.info('📊 Onboarding completed: ${state.user.isOnboardingCompleted}');
      
      // Add a small delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // FIXED: Go directly to home instead of checking onboarding
          NavigationService.safeNavigate(
            AppRouter.home,
            clearStack: true,
            arguments: {
              'isAuthenticated': true,
              'user': state.user,
              'isFirstTime': false,
            },
          );
        }
      });
    } else if (state is AuthUnauthenticated || state is AuthSessionExpired) {
      // User is not authenticated, stay on auth wrapper (show auth choice)
      Logger.info('🔐 User not authenticated, showing auth options');
      
      if (state is AuthSessionExpired && !_hasShownSessionExpired) {
        _hasShownSessionExpired = true;
        NavigationService.showWarningSnackBar(state.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _handleNavigation(state);
          
          if (state is AuthError) {
            NavigationService.showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return _buildLoadingView();
            } else {
              return _buildAuthChoiceView();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Color(0xFF8B5FBF),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Checking authentication...',
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthChoiceView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              _buildWelcomeSection(),
              const SizedBox(height: 60),
              _buildAuthButtons(),
              const Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                const Color(0xFF6B3FA0).withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5FBF).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 60,
            color: Color(0xFF8B5FBF),
          ),
        ),

        const SizedBox(height: 32),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5FBF), Color(0xFFD8A5FF)],
          ).createShader(bounds),
          child: const Text(
            'Welcome to Emora',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Your emotional wellness journey starts here.\nConnect with your feelings, express yourself.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAuthButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => NavigationService.safeNavigate(AppRouter.register),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5FBF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF8B5FBF).withValues(alpha: 0.3),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => NavigationService.safeNavigate(AppRouter.login),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF8B5FBF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: Color(0xFF8B5FBF), width: 2),
            ),
            child: const Text(
              'I already have an account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        Text(
          'Version 1.0.0',
          style: TextStyle(color: Colors.grey[700], fontSize: 10),
        ),
      ],
    );
  }
}