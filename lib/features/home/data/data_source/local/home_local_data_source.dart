// lib/features/home/data/data_source/local/home_local_data_source.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/home_data_model.dart';
import '../../model/user_stats_model.dart';

abstract class HomeLocalDataSource {
  Future<HomeDataModel> getLastHomeData();
  Future<void> cacheHomeData(HomeDataModel homeData);
  Future<HomeDataModel> markFirstTimeLoginComplete();
  Future<UserStatsModel> getUserStats();
  Future<void> cacheUserStats(UserStatsModel userStats);
  Future<void> clearHomeData();
  Future<bool> hasHomeData();
  Future<DateTime?> getLastCacheTime();

  // Enhanced emotion-related methods
  Future<void> cacheEmotionFeed(List<Map<String, dynamic>> emotionFeed);
  Future<List<Map<String, dynamic>>> getCachedEmotionFeed();
  Future<void> cacheGlobalStats(Map<String, dynamic> globalStats);
  Future<Map<String, dynamic>?> getCachedGlobalStats();
  Future<void> cacheHeatmapData(Map<String, dynamic> heatmapData);
  Future<Map<String, dynamic>?> getCachedHeatmapData();
  Future<void> updateLastEmotionLog(Map<String, dynamic> emotion);
  Future<Map<String, dynamic>?> getLastEmotionLog();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const String _homeDataKey = 'CACHED_HOME_DATA';
  static const String _userStatsKey = 'CACHED_USER_STATS';
  static const String _cacheTimestampKey = 'HOME_CACHE_TIMESTAMP';
  static const String _firstTimeLoginKey = 'IS_FIRST_TIME_LOGIN';

  // New emotion-related cache keys
  static const String _emotionFeedKey = 'CACHED_EMOTION_FEED';
  static const String _globalStatsKey = 'CACHED_GLOBAL_STATS';
  static const String _heatmapDataKey = 'CACHED_HEATMAP_DATA';
  static const String _lastEmotionKey = 'LAST_EMOTION_LOG';
  static const String _emotionCacheTimestampKey = 'EMOTION_CACHE_TIMESTAMP';

  @override
  Future<HomeDataModel> getLastHomeData() async {
    try {
      Logger.info('📱 Retrieving cached home data...');

      final prefs = await SharedPreferences.getInstance();
      final homeDataJson = prefs.getString(_homeDataKey);

      if (homeDataJson != null) {
        final Map<String, dynamic> homeDataMap = json.decode(homeDataJson);
        final homeData = HomeDataModel.fromJson(homeDataMap);

        Logger.info(
          '. Cached home data retrieved for user: ${homeData.username}',
        );
        return homeData;
      } else {
        Logger.warning('. No cached home data found');
        throw CacheException(message: 'No cached home data found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;

      Logger.error('. Error retrieving cached home data', e);
      throw CacheException(
        message: 'Failed to retrieve cached home data: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheHomeData(HomeDataModel homeData) async {
    try {
      Logger.info('📱 Caching home data for user: ${homeData.username}');

      final prefs = await SharedPreferences.getInstance();
      final homeDataJson = json.encode(homeData.toJson());

      // Cache the home data
      await prefs.setString(_homeDataKey, homeDataJson);

      // Cache the user stats separately for quick access
      final userStatsJson = json.encode((homeData.userStats).toJson());
      await prefs.setString(_userStatsKey, userStatsJson);

      // Update cache timestamp
      await prefs.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      // Cache first-time login status
      await prefs.setBool(_firstTimeLoginKey, homeData.isFirstTimeLogin);

      Logger.info('. Home data cached successfully');
    } catch (e) {
      Logger.error('. Error caching home data', e);
      throw CacheException(
        message: 'Failed to cache home data: ${e.toString()}',
      );
    }
  }

  @override
  Future<HomeDataModel> markFirstTimeLoginComplete() async {
    try {
      Logger.info('📱 Marking first-time login as complete locally...');

      // Get current cached data
      final cachedHomeData = await getLastHomeData();

      // Update first-time login status
      final updatedHomeData = cachedHomeData.copyWith(isFirstTimeLogin: false);

      // Cache the updated data
      await cacheHomeData(updatedHomeData);

      Logger.info('. First-time login marked complete locally');
      return updatedHomeData;
    } catch (e) {
      Logger.error('. Error updating first-time login status locally', e);
      throw CacheException(
        message: 'Failed to update first-time login status: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserStatsModel> getUserStats() async {
    try {
      Logger.info('📱 Retrieving cached user stats...');

      final prefs = await SharedPreferences.getInstance();
      final userStatsJson = prefs.getString(_userStatsKey);

      if (userStatsJson != null) {
        final Map<String, dynamic> userStatsMap = json.decode(userStatsJson);
        final userStats = UserStatsModel.fromJson(userStatsMap);

        Logger.info(
          '. Cached user stats retrieved: ${userStats.totalMoodEntries} entries',
        );
        return userStats;
      } else {
        Logger.warning('. No cached user stats found');
        throw CacheException(message: 'No cached user stats found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;

      Logger.error('. Error retrieving cached user stats', e);
      throw CacheException(
        message: 'Failed to retrieve cached user stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserStats(UserStatsModel userStats) async {
    try {
      Logger.info('📱 Caching user stats...');

      final prefs = await SharedPreferences.getInstance();
      final userStatsJson = json.encode(userStats.toJson());

      await prefs.setString(_userStatsKey, userStatsJson);

      // Also update the cache timestamp
      await prefs.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. User stats cached successfully');
    } catch (e) {
      Logger.error('. Error caching user stats', e);
      throw CacheException(
        message: 'Failed to cache user stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearHomeData() async {
    try {
      Logger.info('📱 Clearing all cached home data...');

      final prefs = await SharedPreferences.getInstance();

      // Remove all home-related cache keys
      final keysToRemove = [
        _homeDataKey,
        _userStatsKey,
        _cacheTimestampKey,
        _firstTimeLoginKey,
        _emotionFeedKey,
        _globalStatsKey,
        _heatmapDataKey,
        _lastEmotionKey,
        _emotionCacheTimestampKey,
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      Logger.info('. All cached home data cleared');
    } catch (e) {
      Logger.error('. Error clearing cached home data', e);
      throw CacheException(
        message: 'Failed to clear cached home data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> hasHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasData = prefs.containsKey(_homeDataKey);

      Logger.info(
        '📱 Home data cache check: ${hasData ? 'exists' : 'not found'}',
      );
      return hasData;
    } catch (e) {
      Logger.error('. Error checking for cached home data', e);
      return false;
    }
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_cacheTimestampKey);

      if (timestampString != null) {
        final timestamp = DateTime.parse(timestampString);
        Logger.info('📱 Last cache time: $timestamp');
        return timestamp;
      } else {
        Logger.info('📱 No cache timestamp found');
        return null;
      }
    } catch (e) {
      Logger.error('. Error retrieving cache timestamp', e);
      return null;
    }
  }

  // ========================================
  // Enhanced Emotion-Related Methods
  // ========================================

  @override
  Future<void> cacheEmotionFeed(List<Map<String, dynamic>> emotionFeed) async {
    try {
      Logger.info(
        '🎭 Caching emotion feed with ${emotionFeed.length} entries...',
      );

      final prefs = await SharedPreferences.getInstance();
      final emotionFeedJson = json.encode(emotionFeed);

      await prefs.setString(_emotionFeedKey, emotionFeedJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Emotion feed cached successfully');
    } catch (e) {
      Logger.error('. Error caching emotion feed', e);
      throw CacheException(
        message: 'Failed to cache emotion feed: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCachedEmotionFeed() async {
    try {
      Logger.info('🎭 Retrieving cached emotion feed...');

      final prefs = await SharedPreferences.getInstance();
      final emotionFeedJson = prefs.getString(_emotionFeedKey);

      if (emotionFeedJson != null) {
        final List<dynamic> emotionFeedList = json.decode(emotionFeedJson);
        final emotionFeed = emotionFeedList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        Logger.info(
          '. Cached emotion feed retrieved: ${emotionFeed.length} entries',
        );
        return emotionFeed;
      } else {
        Logger.warning('. No cached emotion feed found');
        return [];
      }
    } catch (e) {
      Logger.error('. Error retrieving cached emotion feed', e);
      return [];
    }
  }

  @override
  Future<void> cacheGlobalStats(Map<String, dynamic> globalStats) async {
    try {
      Logger.info('🌍 Caching global emotion stats...');

      final prefs = await SharedPreferences.getInstance();
      final globalStatsJson = json.encode(globalStats);

      await prefs.setString(_globalStatsKey, globalStatsJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Global stats cached successfully');
    } catch (e) {
      Logger.error('. Error caching global stats', e);
      throw CacheException(
        message: 'Failed to cache global stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedGlobalStats() async {
    try {
      Logger.info('🌍 Retrieving cached global stats...');

      final prefs = await SharedPreferences.getInstance();
      final globalStatsJson = prefs.getString(_globalStatsKey);

      if (globalStatsJson != null) {
        final globalStats = Map<String, dynamic>.from(
          json.decode(globalStatsJson),
        );
        Logger.info('. Cached global stats retrieved');
        return globalStats;
      } else {
        Logger.warning('. No cached global stats found');
        return null;
      }
    } catch (e) {
      Logger.error('. Error retrieving cached global stats', e);
      return null;
    }
  }

  @override
  Future<void> cacheHeatmapData(Map<String, dynamic> heatmapData) async {
    try {
      Logger.info('🗺️ Caching heatmap data...');

      final prefs = await SharedPreferences.getInstance();
      final heatmapJson = json.encode(heatmapData);

      await prefs.setString(_heatmapDataKey, heatmapJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Heatmap data cached successfully');
    } catch (e) {
      Logger.error('. Error caching heatmap data', e);
      throw CacheException(
        message: 'Failed to cache heatmap data: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getCachedHeatmapData() async {
    try {
      Logger.info('🗺️ Retrieving cached heatmap data...');

      final prefs = await SharedPreferences.getInstance();
      final heatmapJson = prefs.getString(_heatmapDataKey);

      if (heatmapJson != null) {
        final heatmapData = Map<String, dynamic>.from(json.decode(heatmapJson));
        Logger.info('. Cached heatmap data retrieved');
        return heatmapData;
      } else {
        Logger.warning('. No cached heatmap data found');
        return null;
      }
    } catch (e) {
      Logger.error('. Error retrieving cached heatmap data', e);
      return null;
    }
  }

  @override
  Future<void> updateLastEmotionLog(Map<String, dynamic> emotion) async {
    try {
      Logger.info('🎭 Updating last emotion log: ${emotion['emotion']}');

      final prefs = await SharedPreferences.getInstance();
      final emotionJson = json.encode(emotion);

      await prefs.setString(_lastEmotionKey, emotionJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Last emotion log updated successfully');
    } catch (e) {
      Logger.error('. Error updating last emotion log', e);
      throw CacheException(
        message: 'Failed to update last emotion log: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getLastEmotionLog() async {
    try {
      Logger.info('🎭 Retrieving last emotion log...');

      final prefs = await SharedPreferences.getInstance();
      final emotionJson = prefs.getString(_lastEmotionKey);

      if (emotionJson != null) {
        final emotion = Map<String, dynamic>.from(json.decode(emotionJson));
        Logger.info('. Last emotion log retrieved: ${emotion['emotion']}');
        return emotion;
      } else {
        Logger.info('📱 No last emotion log found');
        return null;
      }
    } catch (e) {
      Logger.error('. Error retrieving last emotion log', e);
      return null;
    }
  }

  // ========================================
  // Enhanced Helper Methods
  // ========================================

  /// Check if cached data is stale (older than specified duration)
  Future<bool> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final lastCacheTime = await getLastCacheTime();

      if (lastCacheTime == null) {
        return true; // No cache = stale
      }

      final age = DateTime.now().difference(lastCacheTime);
      final isStale = age > maxAge;

      Logger.info('📱 Cache age: ${age.inMinutes} minutes, stale: $isStale');
      return isStale;
    } catch (e) {
      Logger.error('. Error checking cache staleness', e);
      return true; // Assume stale on error
    }
  }

  /// Check if emotion cache is stale
  Future<bool> isEmotionCacheStale({
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_emotionCacheTimestampKey);

      if (timestampString == null) {
        return true; // No cache = stale
      }

      final lastCacheTime = DateTime.parse(timestampString);
      final age = DateTime.now().difference(lastCacheTime);
      final isStale = age > maxAge;

      Logger.info(
        '🎭 Emotion cache age: ${age.inMinutes} minutes, stale: $isStale',
      );
      return isStale;
    } catch (e) {
      Logger.error('. Error checking emotion cache staleness', e);
      return true; // Assume stale on error
    }
  }

  /// Get first-time login status from cache
  Future<bool> getFirstTimeLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool(_firstTimeLoginKey) ?? true;

      Logger.info('📱 First-time login status from cache: $isFirstTime');
      return isFirstTime;
    } catch (e) {
      Logger.error('. Error getting first-time login status', e);
      return true; // Default to first-time on error
    }
  }

  /// Update only the first-time login status
  Future<void> setFirstTimeLoginStatus(bool isFirstTime) async {
    try {
      Logger.info('📱 Setting first-time login status: $isFirstTime');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_firstTimeLoginKey, isFirstTime);

      Logger.info('. First-time login status updated');
    } catch (e) {
      Logger.error('. Error setting first-time login status', e);
      throw CacheException(
        message: 'Failed to update first-time login status: ${e.toString()}',
      );
    }
  }

  /// Get cache size information for debugging
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final info = <String, dynamic>{};

      // Check which keys exist
      info['has_home_data'] = prefs.containsKey(_homeDataKey);
      info['has_user_stats'] = prefs.containsKey(_userStatsKey);
      info['has_timestamp'] = prefs.containsKey(_cacheTimestampKey);
      info['has_first_time_status'] = prefs.containsKey(_firstTimeLoginKey);
      info['has_emotion_feed'] = prefs.containsKey(_emotionFeedKey);
      info['has_global_stats'] = prefs.containsKey(_globalStatsKey);
      info['has_heatmap_data'] = prefs.containsKey(_heatmapDataKey);
      info['has_last_emotion'] = prefs.containsKey(_lastEmotionKey);

      // Get cache timestamps
      final timestampString = prefs.getString(_cacheTimestampKey);
      if (timestampString != null) {
        info['last_cache_time'] = timestampString;
        info['cache_age_minutes'] = DateTime.now()
            .difference(DateTime.parse(timestampString))
            .inMinutes;
      }

      final emotionTimestampString = prefs.getString(_emotionCacheTimestampKey);
      if (emotionTimestampString != null) {
        info['emotion_cache_time'] = emotionTimestampString;
        info['emotion_cache_age_minutes'] = DateTime.now()
            .difference(DateTime.parse(emotionTimestampString))
            .inMinutes;
      }

      // Get first-time status
      info['is_first_time_login'] = prefs.getBool(_firstTimeLoginKey);

      Logger.info('📱 Cache info: $info');
      return info;
    } catch (e) {
      Logger.error('. Error getting cache info', e);
      return {'error': e.toString()};
    }
  }

  /// Clear only emotion-related cache
  Future<void> clearEmotionCache() async {
    try {
      Logger.info('🎭 Clearing emotion cache...');

      final prefs = await SharedPreferences.getInstance();

      final emotionKeys = [
        _emotionFeedKey,
        _globalStatsKey,
        _heatmapDataKey,
        _lastEmotionKey,
        _emotionCacheTimestampKey,
      ];

      for (final key in emotionKeys) {
        await prefs.remove(key);
      }

      Logger.info('. Emotion cache cleared successfully');
    } catch (e) {
      Logger.error('. Error clearing emotion cache', e);
      throw CacheException(
        message: 'Failed to clear emotion cache: ${e.toString()}',
      );
    }
  }

  /// Get emotion cache statistics
  Future<Map<String, dynamic>> getEmotionCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = <String, dynamic>{};

      // Check emotion feed
      final emotionFeedJson = prefs.getString(_emotionFeedKey);
      if (emotionFeedJson != null) {
        final List<dynamic> emotionFeed = json.decode(emotionFeedJson);
        stats['emotion_feed_count'] = emotionFeed.length;
      } else {
        stats['emotion_feed_count'] = 0;
      }

      // Check global stats
      stats['has_global_stats'] = prefs.containsKey(_globalStatsKey);

      // Check heatmap data
      final heatmapJson = prefs.getString(_heatmapDataKey);
      if (heatmapJson != null) {
        final Map<String, dynamic> heatmapData = json.decode(heatmapJson);
        final locations = heatmapData['locations'] as List?;
        stats['heatmap_locations_count'] = locations?.length ?? 0;
      } else {
        stats['heatmap_locations_count'] = 0;
      }

      // Check last emotion
      stats['has_last_emotion'] = prefs.containsKey(_lastEmotionKey);

      // Get emotion cache age
      final emotionTimestampString = prefs.getString(_emotionCacheTimestampKey);
      if (emotionTimestampString != null) {
        stats['emotion_cache_age_minutes'] = DateTime.now()
            .difference(DateTime.parse(emotionTimestampString))
            .inMinutes;
      }

      Logger.info('🎭 Emotion cache stats: $stats');
      return stats;
    } catch (e) {
      Logger.error('. Error getting emotion cache stats', e);
      return {'error': e.toString()};
    }
  }
}
