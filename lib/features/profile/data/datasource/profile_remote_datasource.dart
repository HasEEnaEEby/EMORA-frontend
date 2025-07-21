// lib/features/profile/data/data_source/remote/profile_remote_data_source.dart - FIXED VERSION
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:emora_mobile_app/features/profile/data/model/achievement_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/profile_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/user_preferences_model.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/network/api_service.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<UserPreferencesModel> getUserPreferences(String userId);
  Future<UserPreferencesModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
  );
  Future<List<AchievementModel>> getAchievements(String userId);
  Future<String> exportUserData(String userId, List<String> dataTypes);
  Future<bool> deleteUserAccount(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl({required this.apiService});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      Logger.info('🔄 Fetching profile from API for user: $userId');

      // Fetch both profile and comprehensive stats
      final profileResponse = await apiService.getUserProfileWithStats();
      
      Logger.info('✅ Profile API response received');
      
      // Try to get comprehensive stats, but don't fail if endpoint doesn't exist
      Map<String, dynamic> statsResponse = {};
      try {
        statsResponse = await apiService.getComprehensiveStats();
        Logger.info('✅ Comprehensive stats API response received');
      } catch (e) {
        Logger.warning('⚠️ Comprehensive stats endpoint not available, using fallback data');
        statsResponse = {
          'totalEntries': 0,
          'currentStreak': 0,
          'longestStreak': 0,
          'totalFriends': 0,
          'helpedFriends': 0,
          'badgesEarned': 0,
          'level': 'New Explorer',
          'favoriteEmotion': '',
        };
      }

      // 🔧 FIX: Handle the correct backend response structure
      // The backend returns: { success: true, message: "...", data: { user: { ... } } }
      final responseData = profileResponse['data'] as Map<String, dynamic>? ?? profileResponse;
      final userData = responseData['user'] as Map<String, dynamic>? ?? responseData;
      
      Logger.info('📊 Full backend response: $profileResponse');
      Logger.info('📊 Response data: $responseData');
      Logger.info('📊 User data: $userData');
      Logger.info('📊 Stats response: $statsResponse');

      // Extract user data and stats
      final profileData = userData['profile'] as Map<String, dynamic>? ?? {};
      final preferencesData = userData['preferences'] as Map<String, dynamic>? ?? {};
      final statsData = userData['stats'] as Map<String, dynamic>? ?? {};

      Logger.info('📊 Backend profileData: $profileData');
      Logger.info('📊 Backend statsData: $statsData');

      // 🔧 FIX 1: Use backend-calculated stats instead of local calculation
      final displayName = profileData['displayName']?.toString() ?? 
                         userData['displayName']?.toString() ?? 
                         userData['name']?.toString() ?? 
                         userData['username']?.toString() ?? 
                         'User';

      // 🔧 FIX 2: Get email from userData
      String email = userData['email']?.toString() ?? '';
      if (email.isEmpty) {
        try {
          final authDataSource = GetIt.instance<AuthLocalDataSource>();
          final localUserData = await authDataSource.getUserData();
          email = localUserData?.email ?? 'No email available';
        } catch (e) {
          Logger.warning('⚠️ Could not fetch email from local storage: $e');
          email = 'No email available';
        }
      }

      // 🔧 FIX 3: Properly extract bio
      final bio = profileData['bio']?.toString();
      final bioText = (bio != null && bio.isNotEmpty) ? bio : null;

      // 🔧 FIX 4: Properly extract avatar with fallbacks
      final selectedAvatar = userData['selectedAvatar']?.toString();
      final avatar = selectedAvatar ?? userData['avatar']?.toString() ?? 'fox';

      // 🔧 FIX 5: Use comprehensive stats from the dedicated stats endpoint
      final comprehensiveStats = statsResponse as Map<String, dynamic>;
      
      final totalEntries = comprehensiveStats['totalEntries'] ?? 
                          statsData['totalEntries'] ?? 
                          userData['totalEntries'] ?? 
                          userData['totalEmotions'] ?? 
                          userData['dashboard']?['totalEmotions'] ?? 0;
      
      final currentStreak = comprehensiveStats['currentStreak'] ?? 
                           statsData['currentStreak'] ?? 
                           userData['currentStreak'] ?? 
                           userData['dashboard']?['currentStreak'] ?? 0;
      
      final longestStreak = comprehensiveStats['longestStreak'] ?? 
                           statsData['longestStreak'] ?? 
                           userData['longestStreak'] ?? 
                           userData['dashboard']?['longestStreak'] ?? 0;
      
      final favoriteEmotion = comprehensiveStats['favoriteEmotion']?.toString() ?? 
                             statsData['favoriteEmotion']?.toString() ?? 
                             userData['favoriteEmotion']?.toString() ?? 
                             userData['dashboard']?['dominantEmotion']?.toString();
      
      final totalFriends = comprehensiveStats['totalFriends'] ?? 
                          statsData['totalFriends'] ?? 
                          userData['totalFriends'] ?? 
                          userData['analytics']?['totalFriends'] ?? 0;
      
      final helpedFriends = comprehensiveStats['helpedFriends'] ?? 
                           statsData['helpedFriends'] ?? 
                           userData['helpedFriends'] ?? 
                           userData['analytics']?['totalComfortReactionsSent'] ?? 0;
      
      final badgesEarned = comprehensiveStats['badgesEarned'] ?? 
                           statsData['badgesEarned'] ?? 
                           userData['badgesEarned'] ?? 
                           userData['achievements']?['earned'] ?? 0;
      
      final userLevel = comprehensiveStats['level']?.toString() ?? 
                       statsData['level']?.toString() ?? 
                       userData['level']?.toString() ?? 
                       'New Explorer';

      Logger.info('📝 Extracted data from backend:');
      Logger.info('   - displayName: $displayName');
      Logger.info('   - username: ${userData['username']}');
      Logger.info('   - email: $email');
      Logger.info('   - bio: $bioText');
      Logger.info('   - avatar: $avatar');
      Logger.info('   - totalEntries: $totalEntries');
      Logger.info('   - currentStreak: $currentStreak');
      Logger.info('   - longestStreak: $longestStreak');
      Logger.info('   - favoriteEmotion: $favoriteEmotion');
      Logger.info('   - totalFriends: $totalFriends');
      Logger.info('   - helpedFriends: $helpedFriends');
      Logger.info('   - badgesEarned: $badgesEarned');
      Logger.info('   - userLevel: $userLevel');

      return UserProfileModel(
        id: userData['id']?.toString() ?? userId,
        name: displayName,
        username: userData['username']?.toString() ?? 'user',
        email: email,
        avatar: avatar,
        bio: bioText,
        pronouns: userData['pronouns']?.toString() ?? 'They / Them',
        ageGroup: userData['ageGroup']?.toString() ?? '18-24',
        themeColor: profileData['themeColor']?.toString() ?? '#8B5CF6',
        joinDate: userData['joinDate'] != null
            ? DateTime.parse(userData['joinDate'])
            : userData['createdAt'] != null
            ? DateTime.parse(userData['createdAt'])
            : DateTime.now(),
        // 🔧 FIX 6: Use comprehensive stats
        totalEntries: totalEntries,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        favoriteEmotion: favoriteEmotion,
        totalFriends: totalFriends,
        helpedFriends: helpedFriends,
        level: userLevel,
        badgesEarned: badgesEarned,
        lastActive: userData['lastActive'] != null
            ? DateTime.parse(userData['lastActive'])
            : userData['lastLoginAt'] != null
            ? DateTime.parse(userData['lastLoginAt'])
            : userData['updatedAt'] != null
            ? DateTime.parse(userData['updatedAt'])
            : null,
        isPrivate: preferencesData['moodPrivacy'] == 'private' ||
            profileData['isPrivate'] == true ||
            userData['isPrivate'] == true,
      );
    } catch (e) {
      Logger.error('❌ Error fetching profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      Logger.info('📝 Updating profile via API');

      // 🔧 FIX 7: Enhanced update data structure to match your API
      final updateData = {
        'pronouns': profile.pronouns ?? 'They / Them',
        'ageGroup': profile.ageGroup ?? '18-24',
        'selectedAvatar': profile.avatar ?? 'fox',
        'profile': {
          'displayName': profile.name,
          'bio': profile.bio ?? '',
          'themeColor': profile.themeColor ?? '#8B5CF6',
        },
      };

      Logger.info('📤 Sending update data: $updateData');

      final response = await apiService.updateUserProfile(updateData);
      Logger.info('✅ Profile updated successfully');
      Logger.info('📥 Update response: $response');
      
      // 🔧 FIX 8: Clear cache and fetch fresh data
      apiService.clearCache();
      
      // Wait a bit for server to process
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Fetch the updated profile to ensure we have the latest data
      final updatedProfile = await getUserProfile(profile.id);
      Logger.info('✅ Fresh profile data fetched after update');
      
      return updatedProfile;
    } catch (e) {
      Logger.error('❌ Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<UserPreferencesModel> getUserPreferences(String userId) async {
    try {
      Logger.info('🔄 Fetching preferences from API');

      final response = await apiService.getUserProfile();
      final userData = response['user'] as Map<String, dynamic>? ?? response;
      final preferences = userData['preferences'] as Map<String, dynamic>? ?? {};
      final notifications = preferences['notifications'] as Map<String, dynamic>? ?? {};

      return UserPreferencesModel(
        notificationsEnabled: notifications['dailyReminder'] ?? true,
        sharingEnabled: preferences['shareEmotions'] ?? false,
        language: 'English',
        theme: userData['profile']?['themeColor'] ?? '#8B5CF6',
        darkModeEnabled: true,
        privacySettings: {
          'shareLocation': preferences['shareLocation'] ?? false,
          'anonymousMode': preferences['anonymousMode'] ?? false,
          'moodPrivacy': preferences['moodPrivacy'] ?? 'private',
          'shareEmotions': preferences['shareEmotions'] ?? false,
        },
        customSettings: {
          'reminderTime': notifications['time'] ?? '20:00',
          'timezone': notifications['timezone'] ?? 'UTC',
          'friendRequests': notifications['friendRequests'] ?? true,
          'comfortReactions': notifications['comfortReactions'] ?? true,
          'friendMoodUpdates': notifications['friendMoodUpdates'] ?? true,
          'allowRecommendations': preferences['allowRecommendations'] ?? true,
        },
      );
    } catch (e) {
      Logger.error('❌ Error fetching preferences: $e');
      return const UserPreferencesModel();
    }
  }

  @override
  Future<UserPreferencesModel> updateUserPreferences(
    String userId,
    UserPreferencesModel preferences,
  ) async {
    try {
      Logger.info('📝 Updating preferences via API');

      final updateData = {
        'preferences': {
          'notifications': {
            'dailyReminder': preferences.notificationsEnabled,
            'time': preferences.customSettings?['reminderTime'] ?? '20:00',
            'timezone': preferences.customSettings?['timezone'] ?? 'UTC',
            'friendRequests': preferences.customSettings?['friendRequests'] ?? true,
            'comfortReactions': preferences.customSettings?['comfortReactions'] ?? true,
            'friendMoodUpdates': preferences.customSettings?['friendMoodUpdates'] ?? true,
          },
          'shareLocation': preferences.privacySettings?['shareLocation'] ?? false,
          'shareEmotions': preferences.privacySettings?['shareEmotions'] ?? false,
          'anonymousMode': preferences.privacySettings?['anonymousMode'] ?? false,
          'allowRecommendations': preferences.customSettings?['allowRecommendations'] ?? true,
          'moodPrivacy': preferences.privacySettings?['moodPrivacy'] ?? 'private',
        }
      };

      final response = await apiService.updateUserPreferences(updateData);
      Logger.info('✅ Preferences updated successfully');
      return preferences;
    } catch (e) {
      Logger.error('❌ Error updating preferences: $e');
      return preferences;
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    try {
      Logger.info('🏆 Fetching achievements from API');

      final achievementsList = await apiService.getUserAchievements();

      if (achievementsList.isEmpty) {
        // Return engaging starter achievements if none exist
        return _createEngagingStarterAchievements(userId);
      }

      return achievementsList.map((achievement) {
        return AchievementModel(
          id: achievement['id'] ?? achievement['_id'] ?? '',
          title: achievement['title'] ?? achievement['name'] ?? '',
          description: achievement['description'] ?? '',
          icon: _mapAchievementIcon(achievement['icon'] ?? achievement['category']),
          category: achievement['category'] ?? 'general',
          earned: achievement['earned'] ?? achievement['isEarned'] ?? false,
          earnedDate: achievement['earnedDate'],
          progress: achievement['progress'] ?? 0,
          requirement: achievement['requirement'] ?? achievement['target'] ?? 1,
          color: achievement['color'] ?? _getColorForCategory(achievement['category']),
          rarity: _mapAchievementRarity(achievement['category']),
        );
      }).toList();
    } catch (e) {
      Logger.error('❌ Error fetching achievements: $e');
      return _createEngagingStarterAchievements(userId);
    }
  }

  @override
  Future<String> exportUserData(String userId, List<String> dataTypes) async {
    try {
      Logger.info('📤 Exporting user data: $dataTypes');

      final response = await apiService.exportUserData(dataTypes);
      return response['message'] ?? 'Data export initiated successfully';
    } catch (e) {
      Logger.error('❌ Error exporting data: $e');
      throw Exception('Failed to export user data: $e');
    }
  }

  @override
  Future<bool> deleteUserAccount(String userId) async {
    try {
      Logger.info('🗑️ Deleting user account');
      // This would be implemented when the endpoint is ready
      return false;
    } catch (e) {
      Logger.error('❌ Error deleting account: $e');
      throw Exception('Failed to delete user account: $e');
    }
  }

  // 🔧 FIX 9: Remove local calculation methods since we're using backend stats
  String _mapAchievementIcon(String? category) {
    final iconMap = {
      'milestone': 'emoji_events',
      'streak': 'local_fire_department',
      'diversity': 'palette',
      'social': 'people',
      'exploration': 'explore',
      'mindfulness': 'psychology',
      'first_steps': 'emoji_emotions',
      'getting_started': 'trending_up',
      'emotion_explorer': 'explore',
      'dedicated_tracker': 'psychology',
      'three_day_streak': 'local_fire_department',
      'week_warrior': 'military_tech',
      'consistent_tracker': 'schedule',
    };
    return iconMap[category] ?? 'star';
  }

  String _getColorForCategory(String? category) {
    final colorMap = {
      'milestone': '#10B981',
      'streak': '#EF4444',
      'diversity': '#8B5CF6',
      'social': '#3B82F6',
      'exploration': '#F59E0B',
      'mindfulness': '#6366F1',
    };
    return colorMap[category] ?? '#6B7280';
  }

  String _mapAchievementRarity(String? category) {
    final rarityMap = {
      'milestone': 'common',
      'streak': 'rare',
      'diversity': 'epic',
      'social': 'rare',
      'exploration': 'common',
      'mindfulness': 'legendary',
    };
    return rarityMap[category] ?? 'common';
  }

  // 🔧 FIX 10: More engaging and comprehensive starter achievements
  List<AchievementModel> _createEngagingStarterAchievements(String userId) {
    return [
      // Welcome & First Steps
      const AchievementModel(
        id: 'welcome_aboard',
        title: 'Welcome Aboard! 🎉',
        description: 'Welcome to your emotional wellness journey',
        icon: 'star',
        category: 'milestone',
        earned: true,
        progress: 1,
        requirement: 1,
        color: '#10B981',
        rarity: 'common',
      ),
      const AchievementModel(
        id: 'first_steps',
        title: 'First Steps',
        description: 'Log your first emotion entry',
        icon: 'emoji_emotions',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#3B82F6',
        rarity: 'common',
      ),
      const AchievementModel(
        id: 'profile_complete',
        title: 'Profile Master',
        description: 'Complete your profile with avatar, bio, and preferences',
        icon: 'account_circle',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#8B5CF6',
        rarity: 'common',
      ),
      
      // Streak Achievements
      const AchievementModel(
        id: 'three_day_streak',
        title: 'Three Day Streak 🔥',
        description: 'Log emotions for 3 consecutive days',
        icon: 'local_fire_department',
        category: 'streak',
        earned: false,
        progress: 0,
        requirement: 3,
        color: '#EF4444',
        rarity: 'rare',
      ),
      const AchievementModel(
        id: 'week_warrior',
        title: 'Week Warrior ⚡',
        description: 'Maintain a 7-day logging streak',
        icon: 'military_tech',
        category: 'streak',
        earned: false,
        progress: 0,
        requirement: 7,
        color: '#F59E0B',
        rarity: 'rare',
      ),
      const AchievementModel(
        id: 'month_master',
        title: 'Month Master 🏆',
        description: 'Complete 30 consecutive days of emotion tracking',
        icon: 'emoji_events',
        category: 'streak',
        earned: false,
        progress: 0,
        requirement: 30,
        color: '#EF4444',
        rarity: 'epic',
      ),
      
      // Progress Milestones
      const AchievementModel(
        id: 'getting_started',
        title: 'Getting Started 📈',
        description: 'Complete 5 emotion entries',
        icon: 'trending_up',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 5,
        color: '#10B981',
        rarity: 'common',
      ),
      const AchievementModel(
        id: 'emotion_explorer',
        title: 'Emotion Explorer 🧭',
        description: 'Log 15 different emotions',
        icon: 'explore',
        category: 'exploration',
        earned: false,
        progress: 0,
        requirement: 15,
        color: '#6366F1',
        rarity: 'rare',
      ),
      const AchievementModel(
        id: 'dedicated_tracker',
        title: 'Dedicated Tracker 🎯',
        description: 'Complete 30 emotion entries',
        icon: 'psychology',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 30,
        color: '#8B5CF6',
        rarity: 'epic',
      ),
      
      // Mindfulness & Growth
      const AchievementModel(
        id: 'mindful_moments',
        title: 'Mindful Moments 🧘',
        description: 'Log emotions with detailed notes 5 times',
        icon: 'psychology',
        category: 'mindfulness',
        earned: false,
        progress: 0,
        requirement: 5,
        color: '#6366F1',
        rarity: 'rare',
      ),
      const AchievementModel(
        id: 'emotion_diversity',
        title: 'Emotion Rainbow 🌈',
        description: 'Experience and log 10 different emotion categories',
        icon: 'palette',
        category: 'diversity',
        earned: false,
        progress: 0,
        requirement: 10,
        color: '#8B5CF6',
        rarity: 'epic',
      ),
      const AchievementModel(
        id: 'growth_mindset',
        title: 'Growth Mindset 🌱',
        description: 'Update your profile and personalize your experience',
        icon: 'trending_up',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#10B981',
        rarity: 'common',
      ),
      
      // Social & Community (for future features)
      const AchievementModel(
        id: 'social_butterfly',
        title: 'Social Butterfly 🦋',
        description: 'Connect with your first friend',
        icon: 'people',
        category: 'social',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#3B82F6',
        rarity: 'rare',
      ),
      const AchievementModel(
        id: 'helpful_heart',
        title: 'Helpful Heart ❤️',
        description: 'Support a friend with comfort reactions',
        icon: 'favorite',
        category: 'social',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#EF4444',
        rarity: 'rare',
      ),
      
      // Special Recognition
      const AchievementModel(
        id: 'early_adopter',
        title: 'Early Adopter 🚀',
        description: 'One of the first to join our community',
        icon: 'rocket_launch',
        category: 'special',
        earned: true,
        progress: 1,
        requirement: 1,
        color: '#F59E0B',
        rarity: 'legendary',
      ),
    ];
  }
}