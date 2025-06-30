import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/logger.dart';

class AuthChoiceView extends StatelessWidget {
  final Map<String, dynamic>? onboardingData;

  const AuthChoiceView({super.key, this.onboardingData});

  @override
  Widget build(BuildContext context) {
    Logger.info('📦 AuthChoice received onboarding data: $onboardingData');

    // Debug log the specific values we care about
    if (onboardingData != null) {
      Logger.info('✅ AuthChoice data breakdown:');
      Logger.info('  pronouns: ${onboardingData!['pronouns']}');
      Logger.info('  ageGroup: ${onboardingData!['ageGroup']}');
      Logger.info('  selectedAvatar: ${onboardingData!['selectedAvatar']}');
    } else {
      Logger.warning('⚠️ AuthChoice received NULL onboarding data');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App branding
              _buildBranding(),

              const SizedBox(height: 40),

              // Welcome message
              _buildWelcomeMessage(onboardingData),

              const SizedBox(height: 60),

              // Auth options
              _buildAuthOptions(context, onboardingData),

              const Spacer(flex: 3),

              // Footer
              _buildFooter(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5FBF), Color(0xFF6B3FA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5FBF).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Emora',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage(Map<String, dynamic>? onboardingData) {
    String welcomeText = 'Welcome to Emora!';
    String subText = 'Create your account to get started';

    // Personalize message if we have onboarding data
    if (onboardingData != null &&
        onboardingData['hasCompletedOnboarding'] == true) {
      welcomeText = 'Great choices!';
      subText = 'Now let\'s create your account';
    }

    return Column(
      children: [
        Text(
          welcomeText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthOptions(
    BuildContext context,
    Map<String, dynamic>? onboardingData,
  ) {
    return Column(
      children: [
        // Create Account Button
        _buildCreateAccountButton(context, onboardingData),

        const SizedBox(height: 16),

        // Sign In Button
        _buildSignInButton(context, onboardingData),

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

        // Continue as Guest
        _buildGuestButton(context),
      ],
    );
  }

  Widget _buildCreateAccountButton(
    BuildContext context,
    Map<String, dynamic>? onboardingData,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5FBF), Color(0xFF6B3FA0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5FBF).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Logger.info('🚀 Navigating to register with onboarding data');
          Logger.info('📦 Data being passed: $onboardingData');

          // Pass the onboarding data to registration
          Navigator.pushNamed(
            context,
            AppRouter.register,
            arguments: onboardingData,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    Map<String, dynamic>? onboardingData,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF8B5FBF).withValues(alpha: 0.5),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: OutlinedButton(
        onPressed: () {
          Logger.info('🔐 Navigating to login');
          Navigator.pushNamed(context, AppRouter.login);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, color: Color(0xFF8B5FBF), size: 20),
            SizedBox(width: 12),
            Text(
              'Sign In',
              style: TextStyle(
                color: Color(0xFF8B5FBF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Logger.info('👤 Continuing as guest');
        Navigator.pushReplacementNamed(context, AppRouter.home);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(
        'Continue as Guest',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
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
              onPressed: () {
                // Navigate to terms
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            TextButton(
              onPressed: () {
                // Navigate to privacy policy
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
