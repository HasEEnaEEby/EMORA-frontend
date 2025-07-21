// lib/features/home/presentation/widget/profile_achievements_widget.dart - COMPLETE ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/achievement_entity.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

import 'profile_dialogs.dart';

class ProfileAchievementsWidget extends StatelessWidget {
  final List<dynamic> achievements;
  final bool isLoading;
  final dynamic profile; // Add profile for dynamic achievement calculation

  const ProfileAchievementsWidget({
    super.key,
    required this.achievements,
    this.isLoading = false,
    this.profile,
  });

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
    final mergedAchievements = _getMergedAchievements();
    final earnedCount = mergedAchievements.where((a) => a['earned'] == true).length;
    final totalCount = mergedAchievements.length;
    final progressPercentage = totalCount > 0 ? (earnedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withValues(alpha: 0.8),
            const Color(0xFF312E81).withValues(alpha: 0.6),
            const Color(0xFF4C1D95).withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      const Color(0xFF6366F1).withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your journey milestones',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAllAchievements(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                        const Color(0xFF6366F1).withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View All',
                        style: TextStyle(
                          color: Color(0xFF8B5CF6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: const Color(0xFF8B5CF6),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress section
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$earnedCount of $totalCount earned',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$progressPercentage%',
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.grey[700]!.withValues(alpha: 0.5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressPercentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 110,
            margin: EdgeInsets.only(right: index < 5 ? 12 : 0),
            child: _buildLoadingSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[800]!.withValues(alpha: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[700],
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
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    final mergedAchievements = _getMergedAchievements();
    final displayAchievements = mergedAchievements.take(6).toList();

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayAchievements.length,
        itemBuilder: (context, index) {
          final achievement = displayAchievements[index];
          return Container(
            width: 110,
            margin: EdgeInsets.only(right: index < displayAchievements.length - 1 ? 12 : 0),
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
    final String rarity = achievement['rarity'] ?? 'common';
    final Color achievementColor = _getAchievementColor(achievement);
    final Color rarityColor = _getRarityColor(rarity);
    final int progress = achievement['progress'] ?? 0;
    final int requirement = achievement['requirement'] ?? 1;
    final double progressPercent = requirement > 0 ? (progress / requirement).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAchievementDetail(context, achievement);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEarned
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    achievementColor.withValues(alpha: 0.8),
                    achievementColor.withValues(alpha: 0.6),
                    achievementColor.withValues(alpha: 0.4),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E1B4B).withValues(alpha: 0.8),
                    const Color(0xFF312E81).withValues(alpha: 0.6),
                  ],
                ),
          border: Border.all(
            color: isEarned
                ? achievementColor.withValues(alpha: 0.6)
                : Colors.grey[700]!.withValues(alpha: 0.5),
            width: isEarned ? 2 : 1,
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: achievementColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: achievementColor.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Icon container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEarned
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey[700]!.withValues(alpha: 0.3),
                    border: Border.all(
                      color: isEarned
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.grey[600]!.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIconData(achievement['icon']),
                    color: isEarned ? Colors.white : Colors.grey[500],
                    size: 24,
                  ),
                ),
                
                const Spacer(),
                
                // Title
                Text(
                  achievement['title'] ?? 'Achievement',
                  style: TextStyle(
                    color: isEarned ? Colors.white : Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Progress or completion indicator
                if (!isEarned && requirement > 1) ...[
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.5),
                      color: Colors.grey[700]!.withValues(alpha: 0.5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressPercent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.5),
                          color: achievementColor,
                        ),
                      ),
                    ),
                  ),
                ] else if (isEarned) ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 14,
                  ),
                ],
              ],
            ),
            
            // Rarity indicator
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rarityColor,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            
            // Lock overlay for unearned achievements
            if (!isEarned)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.grey[400],
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods for achievement data
  List<Map<String, dynamic>> _getMergedAchievements() {
    try {
      // Convert AchievementEntity objects to maps if needed
      final processedAchievements = achievements.map((achievement) {
        if (achievement is AchievementEntity) {
          return _achievementEntityToMap(achievement);
        } else if (achievement is Map<String, dynamic>) {
          return achievement;
        } else {
          Logger.warning('⚠️ Unknown achievement type: ${achievement.runtimeType}');
          return <String, dynamic>{};
        }
      }).where((map) => map.isNotEmpty).toList();

      // Merge with static achievements if we have profile data
      if (profile != null) {
        final staticAchievements = _getStaticAchievements();
        final processedIds = processedAchievements.map((a) => a['id']).toSet();
        
        // Add static achievements that aren't in the processed list
        final missingStatic = staticAchievements
            .where((staticAch) => !processedIds.contains(staticAch['id']))
            .toList();
        
        processedAchievements.addAll(missingStatic);
      }

      // Sort by earned status and then by rarity
      processedAchievements.sort((a, b) {
        final aEarned = a['earned'] ?? false;
        final bEarned = b['earned'] ?? false;
        
        if (aEarned && !bEarned) return -1;
        if (!aEarned && bEarned) return 1;
        
        // If both earned or both not earned, sort by rarity
        final rarityOrder = {'legendary': 0, 'epic': 1, 'rare': 2, 'common': 3};
        final aRarity = rarityOrder[a['rarity']] ?? 3;
        final bRarity = rarityOrder[b['rarity']] ?? 3;
        
        return aRarity.compareTo(bRarity);
      });

      return processedAchievements;
    } catch (e) {
      Logger.error('💥 Error merging achievements: $e');
      return _getStaticAchievements();
    }
  }

  Map<String, dynamic> _achievementEntityToMap(AchievementEntity achievement) {
    return {
      'id': achievement.id,
      'title': achievement.title,
      'description': achievement.description,
      'icon': _mapCategoryToIcon(achievement.category),
      'color': _mapCategoryToColor(achievement.category),
      'category': achievement.category,
      'earned': achievement.earned,
      'progress': achievement.progress,
      'requirement': achievement.requirement,
      'rarity': achievement.rarity,
      'earnedDate': achievement.earnedDate,
    };
  }

  List<Map<String, dynamic>> _getStaticAchievements() {
    // Calculate dynamic values based on profile if available
    final totalEntries = profile?.totalEntries ?? 0;
    final currentStreak = profile?.currentStreak ?? 0;
    final isProfileComplete = _isProfileComplete();

    return [
      // Welcome & First Steps
      {
        'id': 'welcome_aboard',
        'title': 'Welcome! 🎉',
        'description': 'Welcome to your emotional wellness journey',
        'icon': 'star',
        'color': '#10B981',
        'category': 'milestone',
        'earned': true,
        'progress': 1,
        'requirement': 1,
        'rarity': 'common',
        'earnedDate': DateTime.now().toIso8601String(),
      },
      {
        'id': 'first_steps',
        'title': 'First Steps',
        'description': 'Log your first emotion entry',
        'icon': 'emoji_emotions',
        'color': '#3B82F6',
        'category': 'milestone',
        'earned': totalEntries > 0,
        'progress': totalEntries > 0 ? 1 : 0,
        'requirement': 1,
        'rarity': 'common',
        'earnedDate': totalEntries > 0 ? DateTime.now().toIso8601String() : null,
      },
      {
        'id': 'profile_complete',
        'title': 'Profile Master',
        'description': 'Complete your profile setup',
        'icon': 'account_circle',
        'color': '#8B5CF6',
        'category': 'milestone',
        'earned': isProfileComplete,
        'progress': isProfileComplete ? 1 : 0,
        'requirement': 1,
        'rarity': 'common',
        'earnedDate': isProfileComplete ? DateTime.now().toIso8601String() : null,
      },
      
      // Streak Achievements
      {
        'id': 'three_day_streak',
        'title': 'Three Day Fire 🔥',
        'description': 'Log emotions for 3 consecutive days',
        'icon': 'local_fire_department',
        'color': '#EF4444',
        'category': 'streak',
        'earned': currentStreak >= 3,
        'progress': currentStreak,
        'requirement': 3,
        'rarity': 'rare',
        'earnedDate': currentStreak >= 3 ? DateTime.now().toIso8601String() : null,
      },
      {
        'id': 'week_warrior',
        'title': 'Week Warrior ⚡',
        'description': 'Maintain a 7-day logging streak',
        'icon': 'military_tech',
        'color': '#F59E0B',
        'category': 'streak',
        'earned': currentStreak >= 7,
        'progress': currentStreak,
        'requirement': 7,
        'rarity': 'rare',
        'earnedDate': currentStreak >= 7 ? DateTime.now().toIso8601String() : null,
      },
      {
        'id': 'month_master',
        'title': 'Month Master 🏆',
        'description': 'Complete 30 consecutive days',
        'icon': 'emoji_events',
        'color': '#EF4444',
        'category': 'streak',
        'earned': currentStreak >= 30,
        'progress': currentStreak,
        'requirement': 30,
        'rarity': 'epic',
        'earnedDate': currentStreak >= 30 ? DateTime.now().toIso8601String() : null,
      },
      
      // Progress Milestones
      {
        'id': 'getting_started',
        'title': 'Getting Started 📈',
        'description': 'Complete 5 emotion entries',
        'icon': 'trending_up',
        'color': '#10B981',
        'category': 'milestone',
        'earned': totalEntries >= 5,
        'progress': totalEntries,
        'requirement': 5,
        'rarity': 'common',
        'earnedDate': totalEntries >= 5 ? DateTime.now().toIso8601String() : null,
      },
      {
        'id': 'emotion_explorer',
        'title': 'Emotion Explorer 🧭',
        'description': 'Log 15 different emotions',
        'icon': 'explore',
        'color': '#6366F1',
        'category': 'exploration',
        'earned': totalEntries >= 15,
        'progress': totalEntries,
        'requirement': 15,
        'rarity': 'rare',
        'earnedDate': totalEntries >= 15 ? DateTime.now().toIso8601String() : null,
      },
      {
        'id': 'dedicated_tracker',
        'title': 'Dedicated Tracker 🎯',
        'description': 'Complete 30 emotion entries',
        'icon': 'psychology',
        'color': '#8B5CF6',
        'category': 'milestone',
        'earned': totalEntries >= 30,
        'progress': totalEntries,
        'requirement': 30,
        'rarity': 'epic',
        'earnedDate': totalEntries >= 30 ? DateTime.now().toIso8601String() : null,
      },
      
      // Special Achievements
      {
        'id': 'early_adopter',
        'title': 'Early Adopter 🚀',
        'description': 'One of the first to join our community',
        'icon': 'rocket_launch',
        'color': '#F59E0B',
        'category': 'special',
        'earned': true,
        'progress': 1,
        'requirement': 1,
        'rarity': 'legendary',
        'earnedDate': DateTime.now().toIso8601String(),
      },
    ];
  }

  bool _isProfileComplete() {
    if (profile == null) return false;
    return profile.name?.isNotEmpty == true && 
           profile.email?.isNotEmpty == true && 
           profile.avatar?.isNotEmpty == true;
  }

  Color _getAchievementColor(Map<String, dynamic> achievement) {
    try {
      final colorStr = achievement['color'] ?? '#6B7280';
      return Color(int.parse(colorStr.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6B7280);
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9CA3AF);
      case 'rare':
        return const Color(0xFF3B82F6);
      case 'epic':
        return const Color(0xFF8B5CF6);
      case 'legendary':
        return const Color(0xFFF59E0B);
      case 'mythic':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getIconData(dynamic iconName) {
    final iconMap = {
      'star': Icons.star,
      'emoji_events': Icons.emoji_events,
      'local_fire_department': Icons.local_fire_department,
      'trending_up': Icons.trending_up,
      'explore': Icons.explore,
      'psychology': Icons.psychology,
      'people': Icons.people,
      'palette': Icons.palette,
      'emoji_emotions': Icons.emoji_emotions,
      'military_tech': Icons.military_tech,
      'schedule': Icons.schedule,
      'account_circle': Icons.account_circle,
      'favorite': Icons.favorite,
      'rocket_launch': Icons.rocket_launch,
      'check_circle': Icons.check_circle,
      'sentiment_satisfied': Icons.sentiment_satisfied,
      'insights': Icons.insights,
    };
    
    if (iconName is IconData) return iconName;
    return iconMap[iconName.toString()] ?? Icons.star;
  }

  String _mapCategoryToIcon(String category) {
    final categoryIconMap = {
      'milestone': 'emoji_events',
      'streak': 'local_fire_department',
      'exploration': 'explore',
      'social': 'people',
      'mindfulness': 'psychology',
      'special': 'star',
    };
    return categoryIconMap[category] ?? 'star';
  }

  String _mapCategoryToColor(String category) {
    final categoryColorMap = {
      'milestone': '#10B981',
      'streak': '#EF4444',
      'exploration': '#6366F1',
      'social': '#3B82F6',
      'mindfulness': '#8B5CF6',
      'special': '#F59E0B',
    };
    return categoryColorMap[category] ?? '#6B7280';
  }

  // Dialog methods
  void _showAllAchievements(BuildContext context) {
    try {
      ProfileDialogs.showAllAchievements(context, _getMergedAchievements());
    } catch (e) {
      Logger.error('💥 Error showing all achievements: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load achievements'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAchievementDetail(BuildContext context, Map<String, dynamic> achievement) {
    try {
      ProfileDialogs.showAchievementDetail(context, achievement);
    } catch (e) {
      Logger.error('💥 Error showing achievement detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load achievement details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Extension for additional functionality
extension ProfileAchievementsWidgetExtensions on ProfileAchievementsWidget {
  static List<Map<String, dynamic>> getStaticAchievements() {
    return const ProfileAchievementsWidget(achievements: [])._getStaticAchievements();
  }

  static Map<String, dynamic>? findAchievementById(String id) {
    try {
      final achievements = const ProfileAchievementsWidget(achievements: [])._getStaticAchievements();
      return achievements.firstWhere(
        (achievement) => achievement['id'] == id,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }
}