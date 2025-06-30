import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:flutter/material.dart';

class EmotionIntensitySlider extends StatefulWidget {
  final String emotion;
  final double intensity;
  final Function(double) onIntensityChanged;
  final bool showLabels;

  const EmotionIntensitySlider({
    super.key,
    required this.emotion,
    required this.intensity,
    required this.onIntensityChanged,
    this.showLabels = true,
  });

  @override
  State<EmotionIntensitySlider> createState() => _EmotionIntensitySliderState();
}

class _EmotionIntensitySliderState extends State<EmotionIntensitySlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onIntensityChanged(double value) {
    widget.onIntensityChanged(value);
    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(widget.emotion);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            emotion['color'].withValues(alpha: 0.1),
            emotion['color'].withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(
          color: emotion['color'].withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(emotion),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildIntensityVisualizer(emotion),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildSlider(emotion),
          if (widget.showLabels) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildLabels(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> emotion) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                emotion['emoji'],
                style: const TextStyle(fontSize: 32),
              ),
            );
          },
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How intense is this ${emotion['name'].toLowerCase()}?',
                style: const TextStyle(
                  fontSize: AppDimensions.textLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getIntensityDescription(widget.intensity),
                style: TextStyle(
                  fontSize: AppDimensions.textMedium,
                  color: emotion['color'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityVisualizer(Map<String, dynamic> emotion) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Stack(
        children: [
          // Background bars
          ...List.generate(10, (index) {
            final barIntensity = (index + 1) / 10;
            final isActive = barIntensity <= widget.intensity;

            return Positioned(
              left: (index * 28) + 10,
              top: 10,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? emotion['color'].withValues(
                          alpha: 0.3 + (barIntensity * 0.7),
                        )
                      : AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: isActive
                      ? Border.all(color: emotion['color'], width: 1)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlider(Map<String, dynamic> emotion) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: emotion['color'],
        inactiveTrackColor: emotion['color'].withValues(alpha: 0.3),
        thumbColor: emotion['color'],
        overlayColor: emotion['color'].withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        trackHeight: 6,
        valueIndicatorColor: emotion['color'],
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: Slider(
        value: widget.intensity,
        onChanged: _onIntensityChanged,
        min: 0.1,
        max: 1.0,
        divisions: 9,
        label: '${(widget.intensity * 100).round()}%',
      ),
    );
  }

  Widget _buildLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mild',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppDimensions.textSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Moderate',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppDimensions.textSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          'Intense',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppDimensions.textSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getIntensityDescription(double intensity) {
    if (intensity < 0.3) return 'Mild feeling';
    if (intensity < 0.6) return 'Moderate feeling';
    if (intensity < 0.8) return 'Strong feeling';
    return 'Very intense feeling';
  }
}
