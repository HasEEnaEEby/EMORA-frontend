import 'package:flutter/material.dart';

class EmotionAnalyticsCard extends StatelessWidget {
  const EmotionAnalyticsCard({super.key});

  List<Map<String, dynamic>> get _weeklyMoodData => [
    {'day': 'Mon', 'intensity': 0.3, 'color': const Color(0xFF87CEEB)},
    {'day': 'Tue', 'intensity': 0.7, 'color': const Color(0xFF4CAF50)},
    {'day': 'Wed', 'intensity': 0.5, 'color': const Color(0xFFFFD700)},
    {'day': 'Thu', 'intensity': 0.8, 'color': const Color(0xFF8B5CF6)},
    {'day': 'Fri', 'intensity': 0.4, 'color': const Color(0xFFFF6B6B)},
    {'day': 'Sat', 'intensity': 0.9, 'color': const Color(0xFF4CAF50)},
    {'day': 'Sun', 'intensity': 0.6, 'color': const Color(0xFF8B5CF6)},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week\'s Emotional Flow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Weekly Chart
            SizedBox(
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _weeklyMoodData.map((data) {
                  final intensity = data['intensity'] as double;
                  final color = data['color'] as Color;
                  final day = data['day'] as String;
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 8,
                        height: intensity * 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.5)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Music Recommendation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your soundtrack this week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reflective indie with hopeful undertones',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}