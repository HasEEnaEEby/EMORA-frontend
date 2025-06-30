import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class EmotionJourneyTimeline extends StatelessWidget {
  const EmotionJourneyTimeline({super.key});

  // Mock data - replace with actual data from backend
  static const List<Map<String, dynamic>> _emotionJourney = [
    {'day': 'Mon', 'emotion': 'joy', 'intensity': 0.8, 'time': '9:30 AM'},
    {'day': 'Tue', 'emotion': 'calm', 'intensity': 0.9, 'time': '11:15 AM'},
    {'day': 'Wed', 'emotion': 'fear', 'intensity': 0.6, 'time': '2:45 PM'},
    {'day': 'Thu', 'emotion': 'joy', 'intensity': 0.7, 'time': '10:00 AM'},
    {'day': 'Fri', 'emotion': 'anger', 'intensity': 0.5, 'time': '4:20 PM'},
    {'day': 'Sat', 'emotion': 'calm', 'intensity': 0.8, 'time': '7:30 AM'},
    {'day': 'Today', 'emotion': 'joy', 'intensity': 0.9, 'time': 'Now'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: AppDimensions.paddingMedium),
        _buildTimelineList(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Icon(
              Icons.auto_stories,
              color: AppColors.white,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          const Text(
            'Your Emotion Journey',
            style: TextStyle(
              fontSize: AppDimensions.textXLarge,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return SizedBox(
      height: AppDimensions.cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
        ),
        itemCount: _emotionJourney.length,
        itemBuilder: (context, index) {
          final journey = _emotionJourney[index];
          return _buildTimelineItem(journey, index);
        },
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> journey, int index) {
    final emotion = EmotionConstants.getEmotion(journey['emotion']);
    final isToday = journey['day'] == 'Today';

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppDimensions.paddingMedium),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: emotion['bgGradient']),
              border: Border.all(
                color: isToday ? AppColors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: emotion['color'].withValues(alpha: 0.5),
                  blurRadius: isToday ? 15 : 8,
                  spreadRadius: isToday ? 2 : 0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                emotion['emoji'],
                style: const TextStyle(fontSize: AppDimensions.iconLarge),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            journey['day'],
            style: TextStyle(
              fontSize: AppDimensions.textMedium,
              color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            journey['time'],
            style: const TextStyle(
              fontSize: AppDimensions.textSmall,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
