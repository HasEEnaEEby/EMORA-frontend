/// EMORA Auth Choice View - Refined Welcome Screen with Emora Logo Emphasis and Background Illustration

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';

class AuthChoiceView extends StatelessWidget {
  final Map<String, dynamic>? onboardingData;

  const AuthChoiceView({super.key, this.onboardingData});

  @override
  Widget build(BuildContext context) {
    Logger.info('📦 AuthChoice received onboarding data: $onboardingData');

    return Scaffold(
      backgroundColor: const Color(0xFF0C031A),
      body: Stack(
        children: [
          _buildAnimatedBackdrop(),
          _buildImageOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogoSVG(),
                  const SizedBox(height: 48),
                  _buildWelcomeMessage(),
                  const SizedBox(height: 48),
                  _buildAuthOptions(context),
                  const Spacer(flex: 3),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackdrop() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: [Color(0xFF2A0F46), Color(0xFF0C031A)],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _buildImageOverlay() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Congrats_user_illus.png'),
          fit: BoxFit.cover,
          opacity: 0.08,
        ),
      ),
    ).animate().fade(duration: 1000.ms);
  }

  Widget _buildLogoSVG() {
    return SvgPicture.asset(
      'assets/images/EmoraLogo.svg',
      height: 160,
      semanticsLabel: 'Emora Logo',
    ).animate().fade(duration: 700.ms).scale();
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        const Text(
          'Welcome to your space',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Feel, reflect, connect — all at your pace.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthOptions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Logger.info('🚀 Navigating to register with onboarding data');
              Navigator.pushNamed(
                context,
                AppRouter.register,
                arguments: onboardingData,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5FBF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: Colors.deepPurple.withOpacity(0.4),
            ),
            child: const Text(
              'Create Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ).animate().fade(duration: 600.ms).slideX(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Logger.info('🔐 Navigating to login');
              Navigator.pushNamed(context, AppRouter.login);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5FBF), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Color(0xFF8B5FBF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fade(duration: 700.ms).slideY(begin: 0.3),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(' and ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
