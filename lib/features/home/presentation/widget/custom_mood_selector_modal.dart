import 'package:emora_mobile_app/features/home/presentation/widget/custom_mood_face.dart';
import 'package:flutter/material.dart';

class CustomMoodSelectorModal extends StatefulWidget {
  final MoodType currentMood;
  final Function(MoodType) onMoodSelected;

  const CustomMoodSelectorModal({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  State<CustomMoodSelectorModal> createState() =>
      _CustomMoodSelectorModalState();
}

class _CustomMoodSelectorModalState extends State<CustomMoodSelectorModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ).createShader(bounds),
                  child: const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Mood Options
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: MoodUtils.getAllMoods().map((mood) {
                    final isSelected = mood == widget.currentMood;
                    return _buildMoodOption(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () => _selectMood(mood),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption({
    required MoodType mood,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: CustomMoodFace(mood: mood, size: 60),
          ),
          const SizedBox(height: 8),
          Text(
            MoodUtils.getMoodLabel(mood),
            style: TextStyle(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _selectMood(MoodType mood) {
    widget.onMoodSelected(mood);
    Navigator.of(context).pop();
  }
}
