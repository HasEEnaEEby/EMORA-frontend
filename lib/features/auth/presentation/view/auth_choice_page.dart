// lib/features/auth/presentation/view/auth_choice_page.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/utils/logger.dart';

class AuthChoiceView extends StatefulWidget {
  final Map<String, dynamic>? onboardingData;

  const AuthChoiceView({super.key, this.onboardingData});

  @override
  State<AuthChoiceView> createState() => _AuthChoiceViewState();
}

class _AuthChoiceViewState extends State<AuthChoiceView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _backgroundController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;

  bool _hasOnboardingData = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingData();
    _initializeAnimations();
    _startAnimations();
  }

  void _checkOnboardingData() {
    _hasOnboardingData =
        widget.onboardingData != null &&
        widget.onboardingData!.isNotEmpty &&
        (widget.onboardingData!['pronouns'] != null ||
            widget.onboardingData!['ageGroup'] != null ||
            widget.onboardingData!['selectedAvatar'] != null);

    Logger.info('🔍 Auth Choice - Has onboarding data: $_hasOnboardingData');
    Logger.info('📊 Onboarding data: ${widget.onboardingData}');
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _backgroundController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _navigateToRegister() {
    Logger.info('📝 Navigating to registration with onboarding data');
    NavigationService.safeNavigate(
      AppRouter.register,
      arguments: widget.onboardingData,
    );
  }

  void _navigateToLogin() {
    Logger.info('🔐 Navigating to login');
    NavigationService.safeNavigate(AppRouter.login);
  }

  void _continueAsGuest() {
    Logger.info('👤 Continuing as guest');
    NavigationService.safeNavigate(
      AppRouter.home,
      clearStack: true,
      arguments: {'isGuest': true, 'isAuthenticated': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: Stack(
          children: [_buildAnimatedBackground(), _buildMainContent()],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_backgroundAnimation.value * 2 * math.pi) * 0.1,
                -0.3 + math.cos(_backgroundAnimation.value * 2 * math.pi) * 0.1,
              ),
              radius: 1.2 + _backgroundAnimation.value * 0.3,
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                const Color(0xFF6366F1).withValues(alpha: 0.08),
                const Color(0xFF090110),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildOnboardingDataPreview(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                          const SizedBox(height: 32),
                          _buildFooter(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 35),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
          ).createShader(bounds),
          child: const Text(
            'EMORA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Welcome to your emotional journey',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOnboardingDataPreview() {
    if (!_hasOnboardingData) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF134E4A).withValues(alpha: 0.6),
            const Color(0xFF065F46).withValues(alpha: 0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Preferences Saved!',
                style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.onboardingData!['pronouns'] != null)
            _buildPreviewItem(
              'Pronouns',
              widget.onboardingData!['pronouns'],
              Icons.person,
            ),
          if (widget.onboardingData!['ageGroup'] != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem(
              'Age Group',
              widget.onboardingData!['ageGroup'],
              Icons.cake,
            ),
          ],
          if (widget.onboardingData!['selectedAvatar'] != null) ...[
            const SizedBox(height: 8),
            _buildPreviewItem(
              'Avatar',
              widget.onboardingData!['selectedAvatar'],
              Icons.emoji_emotions,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 16),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Register Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _navigateToRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 20),
                const SizedBox(width: 12),
                Text(
                  _hasOnboardingData ? 'Create Account' : 'Get Started',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Login Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: OutlinedButton(
            onPressed: _navigateToLogin,
            style: OutlinedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              foregroundColor: const Color(0xFF8B5CF6),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 20),
                SizedBox(width: 12),
                Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Guest Button
        TextButton(
          onPressed: _continueAsGuest,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                'Continue as Guest',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.05),
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
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your emotional journey awaits',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        if (_hasOnboardingData) ...[
          const SizedBox(height: 12),
          Text(
            'We\'ve saved your preferences!',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
