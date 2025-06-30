import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class EmotionGreetingCard extends StatefulWidget {
  final String? username;
  final bool? hasLoggedMoodToday;
  final String selectedMood;

  const EmotionGreetingCard({
    super.key,
    this.username,
    this.hasLoggedMoodToday,
    required this.selectedMood,
  });

  @override
  State<EmotionGreetingCard> createState() => _EmotionGreetingCardState();
}

class _EmotionGreetingCardState extends State<EmotionGreetingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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
    final emotion = EmotionConstants.getEmotion(widget.selectedMood);
    final hasLoggedToday = widget.hasLoggedMoodToday ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surfaceVariant,
            emotion['color'].withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        border: Border.all(
          color: emotion['color'].withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: emotion['color'].withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGreetingHeader(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildEmotionDisplay(emotion),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildMoodStatus(hasLoggedToday),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildEncouragementMessage(hasLoggedToday),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader() {
    final timeOfDay = _getTimeOfDay();
    final userName = widget.username ?? 'Friend';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$timeOfDay, $userName! 👋',
          style: const TextStyle(
            fontSize: AppDimensions.textXXLarge,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        Text(
          _getPersonalizedGreeting(),
          style: TextStyle(
            fontSize: AppDimensions.textLarge,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionDisplay(Map<String, dynamic> emotion) {
    return Row(
      children: [
        // Animated emotion character
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: List<Color>.from(emotion['bgGradient']),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: emotion['color'].withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    emotion['character'],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: AppDimensions.paddingLarge),
        // Emotion details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You\'re feeling',
                style: TextStyle(
                  fontSize: AppDimensions.textMedium,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                emotion['name'],
                style: TextStyle(
                  fontSize: AppDimensions.textXXLarge,
                  fontWeight: FontWeight.bold,
                  color: emotion['color'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                emotion['description'],
                style: TextStyle(
                  fontSize: AppDimensions.textMedium,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodStatus(bool hasLoggedToday) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: hasLoggedToday
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: hasLoggedToday
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasLoggedToday ? Icons.check_circle : Icons.schedule,
            size: AppDimensions.iconSmall,
            color: hasLoggedToday ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(
            hasLoggedToday ? 'Mood logged today ✨' : 'Ready to log your mood?',
            style: TextStyle(
              fontSize: AppDimensions.textSmall,
              color: hasLoggedToday ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncouragementMessage(bool hasLoggedToday) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.primary,
              size: AppDimensions.iconSmall,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Text(
              hasLoggedToday
                  ? 'Great job staying connected with your emotions! 🌟'
                  : 'Every emotion matters. You\'re doing great by being here. 💙',
              style: TextStyle(
                fontSize: AppDimensions.textMedium,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 20) return 'Good Evening';
    return 'Good Night';
  }

  String _getPersonalizedGreeting() {
    final greetings = [
      'How are you feeling today?',
      'Ready to explore your emotions?',
      'Your emotional journey continues here',
      'What\'s in your heart today?',
      'Let\'s check in with yourself',
    ];

    final hour = DateTime.now().hour;
    final index = hour % greetings.length;
    return greetings[index];
  }
}
