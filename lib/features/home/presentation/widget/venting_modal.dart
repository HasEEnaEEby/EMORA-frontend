import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:flutter/material.dart';

class VentingModal extends StatefulWidget {
  const VentingModal({super.key});

  @override
  State<VentingModal> createState() => _VentingModalState();
}

class _VentingModalState extends State<VentingModal> {
  String ventingText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1B69), AppColors.surface],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXLarge),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppDimensions.paddingXLarge,
          left: AppDimensions.paddingXLarge,
          right: AppDimensions.paddingXLarge,
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              AppDimensions.paddingXLarge,
        ),
        child: Column(
          children: [
            _buildHandleBar(),
            const SizedBox(height: AppDimensions.paddingXLarge),
            _buildVentingHeader(),
            const SizedBox(height: AppDimensions.paddingXLarge),
            _buildSafeSpaceMessage(),
            const SizedBox(height: AppDimensions.paddingXLarge),
            _buildVentingTextArea(),
            const SizedBox(height: AppDimensions.paddingXLarge),
            _buildReleaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildVentingHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.navVenting, Color(0xFF9C27B0)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: const Icon(
            Icons.air,
            color: AppColors.white,
            size: AppDimensions.iconLarge,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let It Out',
                style: TextStyle(
                  fontSize: AppDimensions.textTitle,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Release what\'s weighing on your mind',
                style: TextStyle(
                  fontSize: AppDimensions.textMedium,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeSpaceMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.white70,
            size: AppDimensions.iconMedium,
          ),
          SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              'This is your safe space. Nothing you write here will be saved or shared.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentingTextArea() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => ventingText = value),
          maxLines: null,
          expands: true,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: AppDimensions.textLarge,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText:
                'Just let it all out... \n\nType whatever you\'re feeling. Get frustrated, be angry, feel sad - it\'s all okay here. \n\nNo one will judge you. This is your moment.',
            hintStyle: TextStyle(
              color: AppColors.white.withValues(alpha: 0.4),
              fontSize: AppDimensions.textLarge,
              height: 1.5,
            ),
            border: InputBorder.none,
          ),
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildReleaseButton() {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navVenting, Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.navVenting.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: ventingText.isNotEmpty ? _releaseEmotions : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.whatshot,
              color: AppColors.white,
              size: AppDimensions.iconLarge,
            ),
            SizedBox(width: AppDimensions.paddingMedium),
            Text(
              'Release & Let Go 🔥',
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppDimensions.textLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _releaseEmotions() {
    Navigator.pop(context);
    _showReleaseAnimation();
  }

  void _showReleaseAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VentingReleaseAnimation(),
    );

    // Auto dismiss after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        _showReleaseComplete();
      }
    });
  }

  void _showReleaseComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🌸', style: TextStyle(fontSize: 20)),
            SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Text(
                'You\'ve let it go. Take a deep breath. You\'re okay. 💙',
                style: TextStyle(
                  fontSize: AppDimensions.textLarge,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00BCD4),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      ),
    );
  }
}

// lib/features/home/presentation/widget/venting_release_animation.dart
class VentingReleaseAnimation extends StatelessWidget {
  const VentingReleaseAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fire/smoke animation
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 3),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: 1 - value,
                  child: Transform.translate(
                    offset: Offset(0, -value * 100),
                    child: Transform.scale(
                      scale: 1 + value * 0.5,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFFFF5722),
                              AppColors.navVenting,
                              Colors.transparent,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('🔥', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.paddingXLarge),
            const Text(
              'Releasing...',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppDimensions.textLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingSmall),
            const Text(
              'Let it burn away',
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppDimensions.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
