import 'package:flutter/material.dart';
import 'dashboard_modals.dart';

class MoodCapsuleTimeline extends StatelessWidget {
  final Function(MoodCapsule) onCapsuleTapped;

  const MoodCapsuleTimeline({
    super.key,
    required this.onCapsuleTapped,
  });

  List<MoodCapsule> get _moodCapsules => [
    MoodCapsule(
      emotion: 'reflective',
      color: const Color(0xFF8B5CF6),
      intensity: 0.7,
      time: '2h ago',
      note: 'Feeling contemplative about the day ahead',
    ),
    MoodCapsule(
      emotion: 'peaceful',
      color: const Color(0xFF4CAF50),
      intensity: 0.8,
      time: '5h ago',
      note: 'Morning meditation brought such clarity',
    ),
    MoodCapsule(
      emotion: 'restless',
      color: const Color(0xFFFF6B6B),
      intensity: 0.4,
      time: '8h ago',
      note: 'Couldn\'t sleep well, mind racing',
    ),
    MoodCapsule(
      emotion: 'hopeful',
      color: const Color(0xFFFFD700),
      intensity: 0.9,
      time: '1d ago',
      note: 'Something beautiful is coming',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your Emotional Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _moodCapsules.length,
            itemBuilder: (context, index) {
              final capsule = _moodCapsules[index];
              return GestureDetector(
                onTap: () => onCapsuleTapped(capsule),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      // Capsule Circle
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              capsule.color.withOpacity(0.6),
                              capsule.color.withOpacity(0.2),
                              capsule.color.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: capsule.color.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: capsule.color,
                              boxShadow: [
                                BoxShadow(
                                  color: capsule.color.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Emotion Label
                      Text(
                        capsule.emotion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Time
                      Text(
                        capsule.time,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}