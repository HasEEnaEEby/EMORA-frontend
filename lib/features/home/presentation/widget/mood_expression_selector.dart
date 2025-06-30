import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:flutter/material.dart';

class MoodExpressionSelector extends StatefulWidget {
  final String selectedMood;
  final Function(String) onMoodSelected;
  final bool isCompact;

  const MoodExpressionSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.isCompact = false,
  });

  @override
  State<MoodExpressionSelector> createState() => _MoodExpressionSelectorState();
}

class _MoodExpressionSelectorState extends State<MoodExpressionSelector>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  String? _hoveredMood;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isCompact) _buildSectionHeader(),
        if (!widget.isCompact)
          const SizedBox(height: AppDimensions.paddingMedium),
        _buildMoodGrid(),
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
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: const Icon(
              Icons.mood,
              color: AppColors.white,
              size: AppDimensions.iconMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          const Text(
            'Express Yourself',
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

  Widget _buildMoodGrid() {
    final primaryMoods = [
      'joy',
      'calm',
      'sad',
      'angry',
      'anxious',
      'excited',
      'overwhelmed',
      'grateful',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCompact
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingLarge,
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: widget.isCompact ? 4 : 4,
        childAspectRatio: widget.isCompact ? 1.0 : 1.1,
        crossAxisSpacing: AppDimensions.paddingMedium,
        mainAxisSpacing: AppDimensions.paddingMedium,
        children: primaryMoods.map((mood) => _buildMoodCard(mood)).toList(),
      ),
    );
  }

  Widget _buildMoodCard(String moodKey) {
    final emotion = EmotionConstants.getEmotion(moodKey);
    final isSelected = widget.selectedMood.toLowerCase() == moodKey;
    final isHovered = _hoveredMood == moodKey;

    return GestureDetector(
      onTap: () => widget.onMoodSelected(moodKey),
      onTapDown: (_) {
        setState(() => _hoveredMood = moodKey);
        _scaleController.forward();
      },
      onTapUp: (_) {
        setState(() => _hoveredMood = null);
        _scaleController.reverse();
      },
      onTapCancel: () {
        setState(() => _hoveredMood = null);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isHovered ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? List<Color>.from(emotion['bgGradient'])
                      : [
                          emotion['color'].withValues(alpha: 0.15),
                          emotion['color'].withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                ),
                borderRadius: BorderRadius.circular(
                  widget.isCompact
                      ? AppDimensions.radiusMedium
                      : AppDimensions.radiusLarge,
                ),
                border: Border.all(
                  color: isSelected
                      ? emotion['color']
                      : emotion['color'].withValues(alpha: 0.3),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: emotion['color'].withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: emotion['color'].withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emotion['emoji'],
                    style: TextStyle(fontSize: widget.isCompact ? 28 : 36),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    emotion['name'],
                    style: TextStyle(
                      fontSize: widget.isCompact
                          ? AppDimensions.textSmall
                          : AppDimensions.textMedium,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? AppColors.white : emotion['color'],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
