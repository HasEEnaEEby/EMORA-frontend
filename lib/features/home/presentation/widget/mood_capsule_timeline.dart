import 'package:flutter/material.dart';
import 'dashboard_modals.dart';

class MoodCapsuleTimeline extends StatelessWidget {
  final Function(MoodCapsule) onCapsuleTapped;
  final List<MoodCapsule>? moodCapsules;
  final bool isNewUser;

  const MoodCapsuleTimeline({
    super.key,
    required this.onCapsuleTapped,
    this.moodCapsules,
    this.isNewUser = false,
  });

  List<MoodCapsule> get _effectiveMoodCapsules {
    // Return real data if available, otherwise return empty list for new users
    if (moodCapsules != null) {
      return moodCapsules!;
    }
    
    // For new users, return empty list to show empty state
    if (isNewUser) {
      return [];
    }
    
    // Fallback mock data for development/testing (only if not new user)
    return [
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
  }

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
        _buildTimelineContent(),
      ],
    );
  }

  Widget _buildTimelineContent() {
    final capsules = _effectiveMoodCapsules;
    
    if (capsules.isEmpty) {
      return _buildEmptyState();
    }
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: capsules.length,
        itemBuilder: (context, index) {
          final capsule = capsules[index];
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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_rounded,
            color: const Color(0xFF8B5CF6),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'No emotions logged yet!',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the mood face above to log your first emotion',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}