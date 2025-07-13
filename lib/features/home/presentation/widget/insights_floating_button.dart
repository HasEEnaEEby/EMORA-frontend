import 'package:flutter/material.dart';

class InsightsFloatingButton extends StatelessWidget {
  final AnimationController animationController;

  const InsightsFloatingButton({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final floatingAnimation = Tween<double>(begin: -3, end: 3).animate(
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
        );

        return Transform.translate(
          offset: Offset(0, floatingAnimation.value),
          child: FloatingActionButton(
            onPressed: () => _showGoalSetting(context),
            backgroundColor: const Color(0xFF8B5CF6),
            child: const Icon(Icons.flag, color: Colors.white, size: 24),
          ),
        );
      },
    );
  }

  void _showGoalSetting(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Color(0xFF8B5CF6), size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Set Mood Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Set goals to track your emotional wellness journey:',
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildGoalOption(
                    'Daily Check-ins',
                    'Track your mood every day',
                    Icons.today,
                  ),
                  _buildGoalOption(
                    'Mood Consistency',
                    'Maintain stable mood patterns',
                    Icons.show_chart,
                  ),
                  _buildGoalOption(
                    'Positive Trend',
                    'Increase average mood score',
                    Icons.trending_up,
                  ),
                  _buildGoalOption(
                    'Sleep Quality',
                    'Improve sleep to boost mood',
                    Icons.bedtime,
                  ),
                  _buildGoalOption(
                    'Exercise Routine',
                    'Regular physical activity',
                    Icons.fitness_center,
                  ),
                  _buildGoalOption(
                    'Mindfulness Practice',
                    'Daily meditation or reflection',
                    Icons.self_improvement,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
