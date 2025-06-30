import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class GlobalEmotionMap extends StatefulWidget {
  final String selectedMood;

  const GlobalEmotionMap({super.key, required this.selectedMood});

  @override
  State<GlobalEmotionMap> createState() => _GlobalEmotionMapState();
}

class _GlobalEmotionMapState extends State<GlobalEmotionMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      height: AppDimensions.mapHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          _buildMapBackground(),
          _buildMapHeader(),
          _buildEmotionDots(),
          _buildMapStats(),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildMapHeader() {
    return Positioned(
      top: AppDimensions.paddingMedium,
      left: AppDimensions.paddingLarge,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: const Icon(
              Icons.public,
              color: AppColors.white,
              size: AppDimensions.iconSmall,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          const Text(
            'Global Emotions',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppDimensions.textLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDots() {
    final selectedEmotionColor = EmotionConstants.getEmotion(
      widget.selectedMood,
    )['color'];

    return Stack(
      children: [
        // Other users' emotions
        Positioned(
          top: 60,
          left: 50,
          child: _buildEmotionDot(
            EmotionConstants.emotions['joy']!['color'],
            'Joy',
          ),
        ),
        Positioned(
          top: 80,
          right: 60,
          child: _buildEmotionDot(
            EmotionConstants.emotions['calm']!['color'],
            'Calm',
          ),
        ),
        Positioned(
          bottom: 60,
          left: 80,
          child: _buildEmotionDot(
            EmotionConstants.emotions['fear']!['color'],
            'Fear',
          ),
        ),
        // User's emotion (highlighted)
        Positioned(
          bottom: 80,
          right: 40,
          child: _buildEmotionDot(selectedEmotionColor, 'You', isYou: true),
        ),
      ],
    );
  }

  Widget _buildEmotionDot(Color color, String label, {bool isYou = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isYou ? 16 * _pulseAnimation.value : 12,
              height: isYou ? 16 * _pulseAnimation.value : 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: isYou ? 12 : 6,
                    spreadRadius: isYou ? 2 : 1,
                  ),
                ],
              ),
            ),
            if (isYou) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMapStats() {
    return Positioned(
      bottom: AppDimensions.paddingMedium,
      left: AppDimensions.paddingLarge,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: const Text(
          '2.3M emotions shared today',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
