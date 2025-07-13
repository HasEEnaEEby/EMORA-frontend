// lib/features/home/presentation/widget/profile_achievements_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'profile_dialogs.dart';

class ProfileAchievementsWidget extends StatelessWidget {
  final List<dynamic> achievements;
  final bool isLoading;

  const ProfileAchievementsWidget({
    super.key,
    required this.achievements,
    this.isLoading = false,
  });

  // Static achievements data - this could be moved to a separate service/repository
  static final List<Map<String, dynamic>> _staticAchievements = [
    {
      'id': 'first_steps',
      'title': 'First Steps',
      'description': 'Logged your first emotion',
      'icon': Icons.emoji_emotions,
      'color': Color(0xFF10B981),
      'requirement': 1,
      'type': 'emotion_logs',
    },
    {
      'id': 'week_warrior',
      'title': 'Week Warrior',
      'description': 'Maintained a 7-day streak',
      'icon': Icons.calendar_today,
      'color': Color(0xFF8B5CF6),
      'requirement': 7,
      'type': 'streak',
    },
    {
      'id': 'social_butterfly',
      'title': 'Social Butterfly',
      'description': 'Connected with 10 friends',
      'icon': Icons.people,
      'color': Color(0xFF6366F1),
      'requirement': 10,
      'type': 'friends',
    },
    {
      'id': 'insight_seeker',
      'title': 'Insight Seeker',
      'description': 'Viewed insights 25 times',
      'icon': Icons.insights,
      'color': Color(0xFFFF6B35),
      'requirement': 25,
      'type': 'insights_viewed',
    },
    {
      'id': 'mood_master',
      'title': 'Mood Master',
      'description': 'Logged 100 emotions',
      'icon': Icons.psychology,
      'color': Color(0xFFFFD700),
      'requirement': 100,
      'type': 'emotion_logs',
    },
    {
      'id': 'support_hero',
      'title': 'Support Hero',
      'description': 'Helped 5 friends with support',
      'icon': Icons.favorite,
      'color': Color(0xFFFF69B4),
      'requirement': 5,
      'type': 'friends_helped',
    },
    {
      'id': 'consistency_king',
      'title': 'Consistency King',
      'description': 'Maintained a 30-day streak',
      'icon': Icons.local_fire_department,
      'color': Color(0xFFFF4500),
      'requirement': 30,
      'type': 'streak',
    },
    {
      'id': 'community_leader',
      'title': 'Community Leader',
      'description': 'Help 50 friends',
      'icon': Icons.star,
      'color': Color(0xFFFFD700),
      'requirement': 50,
      'type': 'friends_helped',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingState()
          else
            _buildAchievementsList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final earnedCount = _getEarnedAchievementsCount();

    return Row(
      children: [
        const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ),
          child: Text(
            '$earnedCount/${_staticAchievements.length}',
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ProfileDialogs.showAllAchievements(
              context,
              _getMergedAchievements(),
            );
          },
          child: const Text(
            'View All',
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
            child: _buildLoadingSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    final mergedAchievements = _getMergedAchievements();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mergedAchievements.take(6).length,
        itemBuilder: (context, index) {
          final achievement = mergedAchievements[index];
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
            child: _buildAchievementBadge(context, achievement),
          );
        },
      ),
    );
  }

  Widget _buildAchievementBadge(
    BuildContext context,
    Map<String, dynamic> achievement,
  ) {
    final bool isEarned = achievement['earned'] ?? false;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ProfileDialogs.showAchievementDetail(context, achievement);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isEarned
                  ? LinearGradient(
                      colors: [
                        achievement['color'],
                        achievement['color'].withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: isEarned ? null : Colors.grey[800],
              border: Border.all(
                color: isEarned
                    ? achievement['color'].withValues(alpha: 0.5)
                    : Colors.grey[600]!,
                width: 2,
              ),
              boxShadow: isEarned
                  ? [
                      BoxShadow(
                        color: achievement['color'].withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              achievement['icon'],
              color: isEarned ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement['title'],
            style: TextStyle(
              color: isEarned ? Colors.white : Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<Map<String, dynamic>> _getMergedAchievements() {
    // Create a map of earned achievements by ID for quick lookup
    final earnedAchievementsMap = <String, dynamic>{};

    for (final achievement in achievements) {
      if (achievement is Map<String, dynamic> && achievement['id'] != null) {
        earnedAchievementsMap[achievement['id']] = achievement;
      }
    }

    // Merge static achievements with earned data
    return _staticAchievements.map((staticAchievement) {
      final earnedData = earnedAchievementsMap[staticAchievement['id']];

      return {
        ...staticAchievement,
        'earned': earnedData != null,
        'date': earnedData?['earnedDate'] ?? earnedData?['date'],
        'progress': earnedData?['progress'] ?? 0,
      };
    }).toList();
  }

  int _getEarnedAchievementsCount() {
    return _getMergedAchievements()
        .where((achievement) => achievement['earned'] == true)
        .length;
  }
}

// Extension for additional functionality
extension ProfileAchievementsWidgetExtensions on ProfileAchievementsWidget {
  static List<Map<String, dynamic>> getStaticAchievements() {
    return ProfileAchievementsWidget._staticAchievements;
  }

  static Map<String, dynamic>? findAchievementById(String id) {
    try {
      return ProfileAchievementsWidget._staticAchievements.firstWhere(
        (achievement) => achievement['id'] == id,
      );
    } catch (e) {
      return null;
    }
  }
}
