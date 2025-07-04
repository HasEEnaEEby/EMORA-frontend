import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final Animation<double> breathingAnimation;
  final String currentMood;
  final bool isBackendConnected;
  final VoidCallback onMoodUpdate;

  const DashboardHeader({
    super.key,
    required this.breathingAnimation,
    required this.currentMood,
    required this.isBackendConnected,
    required this.onMoodUpdate,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Breathing Avatar
          AnimatedBuilder(
            animation: breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: breathingAnimation.value,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.8),
                        const Color(0xFF6B3FA0).withOpacity(0.4),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Haseena',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today feels like a $currentMood',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Status & Action
          Row(
            children: [
              // Connection Status
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isBackendConnected 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              
              // Update Mood Button
              GestureDetector(
                onTap: onMoodUpdate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}