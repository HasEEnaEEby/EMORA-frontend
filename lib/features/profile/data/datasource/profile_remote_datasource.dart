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
      Logger.info('🔍 Fetching profile from API for user: $userId');

      // First, try to get the current user from auth storage
      final authDataSource = GetIt.instance<AuthLocalDataSource>();
      final currentUser = await authDataSource.getCurrentUser();

      if (currentUser != null) {
        Logger.info('✅ Found logged-in user data: ${currentUser.username}');

        // Convert UserModel to UserProfileModel
        return UserProfileModel(
          id: currentUser.id,
          name: currentUser.username, // Use username as display name
          username: currentUser.username,
          email: currentUser.email,
          avatar: currentUser.selectedAvatar ?? 'fox',
          joinDate: currentUser.createdAt,
          totalEntries: 0, // Will be updated from analytics if available
          currentStreak: 0,
          longestStreak: 0,
          favoriteEmotion: null,
          totalFriends: 0,
          helpedFriends: 0,
          level: 'New Explorer',
          badgesEarned: 0,
          lastActive: currentUser.updatedAt,
          isPrivate: false,
        );
      }

      // Fallback: try API call
      final response = await apiService.getUserProfile();

      Logger.info('✅ Profile API response received');

      return UserProfileModel(
        id: response['id']?.toString() ?? userId,
        name: response['username'] ?? 'User',
        username: response['username'] ?? 'user',
        email: response['email'] ?? 'user@example.com',
        avatar: response['selectedAvatar'] ?? 'fox',
        joinDate: response['createdAt'] != null
            ? DateTime.parse(response['createdAt'])
            : DateTime.now(),
        totalEntries: _calculateTotalEntries(response),
        currentStreak: _calculateCurrentStreak(response),
        longestStreak: _calculateLongestStreak(response),
        favoriteEmotion: _getFavoriteEmotion(response),
        totalFriends: _getTotalFriends(response),
        helpedFriends: _getHelpedFriends(response),
        level: _calculateUserLevel(response),
        badgesEarned: _getBadgesEarned(response),
        lastActive: response['lastLoginAt'] != null
            ? DateTime.parse(response['lastLoginAt'])
            : response['updatedAt'] != null
            ? DateTime.parse(response['updatedAt'])
            : null,
        isPrivate:
            response['preferences']?['privacy']?['moodPrivacy'] == 'private' ||
            response['isPrivate'] == true,
      );
    } catch (e) {
      Logger.error('❌ Error fetching profile: $e');
      return _createFallbackProfile(userId);
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    try {
      Logger.info('📝 Updating profile via API');

      final updateData = {
        'username': profile.username,
        'email': profile.email,
        'selectedAvatar': profile.avatar,
        'profile': {
          'displayName': profile.name,
          'bio': '', // Add bio if available in your model
        },
        'preferences': {
          'privacy': {'moodPrivacy': profile.isPrivate ? 'private' : 'public'},
        },
      };

      final response = await apiService.updateUserProfile(updateData);
      Logger.info('✅ Profile updated successfully');
      return await getUserProfile(profile.id);
    } catch (e) {
      Logger.error('❌ Error updating profile: $e');
      return profile;
    }
  }

  @override
  Future<UserPreferencesModel> getUserPreferences(String userId) async {
    try {
      Logger.info('🔍 Fetching preferences from API');

      final response = await apiService.getUserProfile();

      final preferences = response['preferences'] ?? {};

      return UserPreferencesModel(
        notificationsEnabled:
            preferences['notifications']?['dailyReminder'] ?? true,
        sharingEnabled: preferences['privacy']?['shareEmotions'] ?? false,
        language: preferences['app']?['language'] ?? 'English',
        theme: preferences['app']?['theme'] ?? 'Cosmic Purple',
        darkModeEnabled: preferences['app']?['darkMode'] ?? true,
        privacySettings: {
          'shareLocation': preferences['privacy']?['shareLocation'] ?? false,
          'anonymousMode': preferences['privacy']?['anonymousMode'] ?? false,
          'moodPrivacy': preferences['privacy']?['moodPrivacy'] ?? 'private',
        },
        customSettings: {
          'reminderTime':
              preferences['notifications']?['reminderTime'] ?? '20:00',
          'autoBackup': preferences['app']?['autoBackup'] ?? true,
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
        'notificationsEnabled': preferences.notificationsEnabled,
        'dataSharingEnabled': preferences.sharingEnabled,
        'language': preferences.language,
        'theme': preferences.theme,
        'darkModeEnabled': preferences.darkModeEnabled,
        'privacySettings': preferences.privacySettings,
        'customSettings': preferences.customSettings,
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

      return achievementsList.map((achievement) {
        return AchievementModel(
          id: achievement['id'] ?? achievement['_id'] ?? '',
          title: achievement['title'] ?? achievement['name'] ?? '',
          description: achievement['description'] ?? '',
          icon: _mapAchievementIcon(
            achievement['icon'] ?? achievement['category'],
          ),
          category: achievement['category'] ?? 'general',
          earned: achievement['earned'] ?? achievement['isEarned'] ?? false,
          earnedDate: achievement['earnedDate'],
          progress: achievement['progress'] ?? 0,
          requirement: achievement['requirement'] ?? achievement['target'] ?? 1,
          color: achievement['color'] ?? '#6B7280',
          rarity: _mapAchievementRarity(achievement['category']),
        );
      }).toList();
    } catch (e) {
      Logger.error('❌ Error fetching achievements: $e');
      return _createStarterAchievements(userId);
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

  // Helper methods
  int _calculateTotalEntries(Map<String, dynamic> userData) {
    final analytics = userData['analytics'] as Map<String, dynamic>?;
    return analytics?['totalEntries'] ?? 0;
  }

  int _calculateCurrentStreak(Map<String, dynamic> userData) {
    final analytics = userData['analytics'] as Map<String, dynamic>?;
    return analytics?['currentStreak'] ?? 0;
  }

  int _calculateLongestStreak(Map<String, dynamic> userData) {
    final analytics = userData['analytics'] as Map<String, dynamic>?;
    return analytics?['longestStreak'] ?? 0;
  }

  String? _getFavoriteEmotion(Map<String, dynamic> userData) {
    final analytics = userData['analytics'] as Map<String, dynamic>?;
    return analytics?['favoriteEmotion'];
  }

  int _getTotalFriends(Map<String, dynamic> userData) {
    return 0; // Implement based on your social features
  }

  int _getHelpedFriends(Map<String, dynamic> userData) {
    return 0; // Implement based on your social features
  }

  String _calculateUserLevel(Map<String, dynamic> userData) {
    final totalEntries = _calculateTotalEntries(userData);
    final currentStreak = _calculateCurrentStreak(userData);

    if (totalEntries >= 365 && currentStreak >= 100) {
      return 'Emotion Master';
    } else if (totalEntries >= 180 && currentStreak >= 50) {
      return 'Mindful Sage';
    } else if (totalEntries >= 90 && currentStreak >= 30) {
      return 'Feeling Guide';
    } else if (totalEntries >= 30 && currentStreak >= 10) {
      return 'Emotion Seeker';
    } else if (totalEntries >= 10) {
      return 'Mindful Beginner';
    } else {
      return 'New Explorer';
    }
  }

  int _getBadgesEarned(Map<String, dynamic> userData) {
    final analytics = userData['analytics'] as Map<String, dynamic>?;
    return analytics?['badgesEarned'] ?? 0;
  }

  String _mapAchievementIcon(String? category) {
    final iconMap = {
      'milestone': 'emoji_events',
      'streak': 'local_fire_department',
      'diversity': 'palette',
      'social': 'people',
      'exploration': 'explore',
      'mindfulness': 'psychology',
    };
    return iconMap[category] ?? 'star';
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

  UserProfileModel _createFallbackProfile(String userId) {
    return UserProfileModel(
      id: userId,
      name: 'User',
      username: 'user',
      email: 'user@example.com',
      avatar: 'fox',
      joinDate: DateTime.now(),
      totalEntries: 0,
      currentStreak: 0,
      longestStreak: 0,
      favoriteEmotion: null,
      totalFriends: 0,
      helpedFriends: 0,
      level: 'New Explorer',
      badgesEarned: 0,
      lastActive: DateTime.now(),
      isPrivate: false,
    );
  }

  List<AchievementModel> _createStarterAchievements(String userId) {
    return [
      const AchievementModel(
        id: 'starter_001',
        title: 'Welcome!',
        description: 'Welcome to your emotional journey',
        icon: 'star',
        category: 'milestone',
        earned: true,
        progress: 1,
        requirement: 1,
        color: '#10B981',
        rarity: 'common',
      ),
      const AchievementModel(
        id: 'starter_002',
        title: 'First Entry',
        description: 'Complete your first mood entry',
        icon: 'sentiment_satisfied',
        category: 'milestone',
        earned: false,
        progress: 0,
        requirement: 1,
        color: '#3B82F6',
        rarity: 'common',
      ),
      const AchievementModel(
        id: 'starter_003',
        title: 'Week Warrior',
        description: 'Log your mood for 7 consecutive days',
        icon: 'local_fire_department',
        category: 'streak',
        earned: false,
        progress: 0,
        requirement: 7,
        color: '#EF4444',
        rarity: 'rare',
      ),
    ];
  }
}
