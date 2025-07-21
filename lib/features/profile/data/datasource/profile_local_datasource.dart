import 'dart:convert';

import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/model/user_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/achievement_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/profile_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/user_preferences_model.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/data/data_source/local/auth_local_data_source.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> getCachedUserProfile();
  Future<void> cacheUserProfile(UserProfileModel profile);
  Future<UserPreferencesModel?> getCachedUserPreferences();
  Future<void> cacheUserPreferences(UserPreferencesModel preferences);
  Future<List<AchievementModel>?> getCachedAchievements();
  Future<UserModel?> getCurrentUser();
  Future<UserProfileModel?> getLastUserProfile();
  Future<void> cacheAchievements(List<AchievementModel> achievements);
  Future<void> clearCache();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _userProfileKey = 'CACHED_USER_PROFILE';
  static const String _userPreferencesKey = 'CACHED_USER_PREFERENCES';
  static const String _achievementsKey = 'CACHED_ACHIEVEMENTS';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileModel?> getCachedUserProfile() async {
    try {
      final jsonString = sharedPreferences.getString(_userProfileKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(json);
        Logger.info('📱 Retrieved cached user profile: ${profile.username}');
        return profile;
      }
      Logger.info('📱 No cached user profile found');
      return null;
    } catch (e) {
      Logger.error('. Error getting cached profile: $e');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> getLastUserProfile() async {
    try {
      // First try to get cached profile
      final cachedProfile = await getCachedUserProfile();
      if (cachedProfile != null) {
        Logger.info('📱 Found cached profile for: ${cachedProfile.username}');
        return cachedProfile;
      }

      // If no cached profile, try to get current user and create profile from it
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        Logger.info(
          '📱 Creating basic profile from current user: ${currentUser.username}',
        );

        // Convert UserModel to UserProfileModel with minimal data
        // Note: This should only be used as a fallback, real stats should come from API
        final profile = UserProfileModel(
          id: currentUser.id,
          name: currentUser.username,
          username: currentUser.username,
          email: currentUser.email,
          avatar: currentUser.selectedAvatar ?? 'fox',
          joinDate: currentUser.createdAt,
          // 🔧 FIX: Don't set zero stats here - let the API provide real data
          totalEntries: 0, // Will be updated by API call
          currentStreak: 0, // Will be updated by API call
          longestStreak: 0, // Will be updated by API call
          favoriteEmotion: null, // Will be updated by API call
          totalFriends: 0, // Will be updated by API call
          helpedFriends: 0, // Will be updated by API call
          level: 'New Explorer', // Will be updated by API call
          badgesEarned: 0, // Will be updated by API call
          lastActive: currentUser.updatedAt,
          isPrivate: false,
        );

        // Cache this basic profile for future use
        await cacheUserProfile(profile);
        return profile;
      }

      Logger.info('📱 No cached profile or current user found');
      return null;
    } catch (e) {
      Logger.error('. Error getting last user profile: $e');
      throw CacheException(message: 'Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> cacheUserProfile(UserProfileModel profile) async {
    try {
      await sharedPreferences.setString(
        _userProfileKey,
        jsonEncode(profile.toJson()),
      );
      Logger.info('. Cached user profile: ${profile.username}');
    } catch (e) {
      Logger.error('. Error caching profile: $e');
      // Don't throw - cache errors are not critical
    }
  }

  @override
  Future<UserPreferencesModel?> getCachedUserPreferences() async {
    try {
      final jsonString = sharedPreferences.getString(_userPreferencesKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        final preferences = UserPreferencesModel.fromJson(json);
        Logger.info('📱 Retrieved cached user preferences');
        return preferences;
      }
      Logger.info('📱 No cached user preferences found');
      return null;
    } catch (e) {
      Logger.error('. Error getting cached preferences: $e');
      return null;
    }
  }

  @override
  Future<void> cacheUserPreferences(UserPreferencesModel preferences) async {
    try {
      await sharedPreferences.setString(
        _userPreferencesKey,
        jsonEncode(preferences.toJson()),
      );
      Logger.info('. Cached user preferences');
    } catch (e) {
      Logger.error('. Error caching preferences: $e');
      // Don't throw - cache errors are not critical
    }
  }

  @override
  Future<List<AchievementModel>?> getCachedAchievements() async {
    try {
      final jsonString = sharedPreferences.getString(_achievementsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final achievements = jsonList
            .map((json) => AchievementModel.fromJson(json))
            .toList();
        Logger.info('📱 Retrieved ${achievements.length} cached achievements');
        return achievements;
      }
      Logger.info('📱 No cached achievements found');
      return null;
    } catch (e) {
      Logger.error('. Error getting cached achievements: $e');
      return null;
    }
  }

  @override
  Future<void> cacheAchievements(List<AchievementModel> achievements) async {
    try {
      final jsonList = achievements
          .map((achievement) => achievement.toJson())
          .toList();
      await sharedPreferences.setString(
        _achievementsKey,
        json.encode(jsonList),
      );
      Logger.info('. Cached ${achievements.length} achievements');
    } catch (e) {
      Logger.error('. Error caching achievements: $e');
      // Don't throw - cache errors are not critical
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_userProfileKey),
        sharedPreferences.remove(_userPreferencesKey),
        sharedPreferences.remove(_achievementsKey),
      ]);
      Logger.info('🗑️ Profile cache cleared successfully');
    } catch (e) {
      Logger.error('. Error clearing cache: $e');
      // Don't throw - cache errors are not critical
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Get the current user from the auth data source
      final authDataSource = GetIt.instance<AuthLocalDataSource>();
      final currentUser = await authDataSource.getCurrentUser();

      if (currentUser != null) {
        Logger.info(
          '. Retrieved current user from auth: ${currentUser.username}',
        );
        return currentUser;
      }

      Logger.info('. No current user found in auth storage');
      return null;
    } catch (e) {
      Logger.error('. Error getting current user: $e');
      return null;
    }
  }
}
