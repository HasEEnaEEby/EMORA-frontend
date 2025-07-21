


import 'package:flutter/material.dart';

class MoodSelectionWidget extends StatefulWidget {
  final Function(String) onMoodSelected;
  final String? selectedMood;

  const MoodSelectionWidget({
    Key? key,
    required this.onMoodSelected,
    this.selectedMood,
  }) : super(key: key);

  @override
  State<MoodSelectionWidget> createState() => _MoodSelectionWidgetState();
}

class _MoodSelectionWidgetState extends State<MoodSelectionWidget> {
  final List<Map<String, dynamic>> moods = [
    {'name': 'happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.yellow},
    {'name': 'sad', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.blue},
    {'name': 'calm', 'icon': Icons.self_improvement, 'color': Colors.green},
    {'name': 'energetic', 'icon': Icons.flash_on, 'color': Colors.orange},
    {'name': 'romantic', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'focus', 'icon': Icons.center_focus_strong, 'color': Colors.indigo},
    {'name': 'angry', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    {'name': 'excited', 'icon': Icons.celebration, 'color': Colors.amber},
    {'name': 'nostalgic', 'icon': Icons.access_time, 'color': Colors.purple},
    {'name': 'confident', 'icon': Icons.psychology, 'color': Colors.teal},
    {'name': 'anxious', 'icon': Icons.healing, 'color': Colors.cyan},
    {'name': 'grateful', 'icon': Icons.favorite_border, 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a mood to get personalized music recommendations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = widget.selectedMood == mood['name'];
              
              return GestureDetector(
                onTap: () => widget.onMoodSelected(mood['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? mood['color'].withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? mood['color']
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mood['icon'],
                        size: 32,
                        color: isSelected 
                            ? mood['color']
                            : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['name'].toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? mood['color']
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
