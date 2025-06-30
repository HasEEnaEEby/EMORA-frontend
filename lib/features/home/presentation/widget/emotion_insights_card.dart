import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class EmotionInsightsCard extends StatelessWidget {
  final String selectedMood;

  const EmotionInsightsCard({super.key, required this.selectedMood});

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(selectedMood);
    final percentage = EmotionConstants.getGlobalPercentage(selectedMood);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightsHeader(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildInsightsContent(emotion, percentage),
        ],
      ),
    );
  }

  Widget _buildInsightsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: const Icon(
            Icons.insights,
            color: AppColors.white,
            size: AppDimensions.iconMedium,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        const Text(
          'Quick Insights',
          style: TextStyle(
            fontSize: AppDimensions.textLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsContent(Map<String, dynamic> emotion, int percentage) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$percentage% of people feel ${emotion['name']} today',
                style: const TextStyle(
                  fontSize: AppDimensions.textLarge,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              const Text(
                'You\'re connected to a global community',
                style: TextStyle(
                  fontSize: AppDimensions.textMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: emotion['color'].withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: emotion['color'].withValues(alpha: 0.3)),
          ),
          child: Text(
            emotion['character'],
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ],
    );
  }
}
