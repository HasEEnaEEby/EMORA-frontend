import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/logger.dart';

abstract class EmotionLocalDataSource {
  Future<void> cacheEmotionFeed(List<Map<String, dynamic>> emotionFeed);
  Future<List<Map<String, dynamic>>> getCachedEmotionFeed();
  Future<void> cacheGlobalStats(Map<String, dynamic> globalStats);
  Future<Map<String, dynamic>?> getCachedGlobalStats();
  Future<void> cacheHeatmapData(Map<String, dynamic> heatmapData);
  Future<Map<String, dynamic>?> getCachedHeatmapData();
  Future<void> cacheUserEmotion(Map<String, dynamic> emotion);
  Future<List<Map<String, dynamic>>> getUserEmotionHistory();
  Future<void> clearEmotionCache();

  Future<Map<String, dynamic>> getCachedUserStats(String userId);
  Future<void> cacheUserStats(String userId, Map<String, dynamic> stats);

  Future<Map<String, dynamic>> getCachedUserInsights(String userId);
  Future<void> cacheUserInsights(String userId, Map<String, dynamic> insights);

  Future<Map<String, dynamic>> getCachedUserAnalytics(String userId);
  Future<void> cacheUserAnalytics(String userId, Map<String, dynamic> analytics);

  Future isCacheStale({required Duration maxAge}) async {}
}

class EmotionLocalDataSourceImpl implements EmotionLocalDataSource {
  static const String _emotionFeedKey = 'CACHED_EMOTION_FEED';
  static const String _globalStatsKey = 'CACHED_GLOBAL_EMOTION_STATS';
  static const String _heatmapDataKey = 'CACHED_HEATMAP_DATA';
  static const String _userEmotionsKey = 'USER_EMOTION_HISTORY';
  static const String _emotionCacheTimestampKey = 'EMOTION_CACHE_TIMESTAMP';
  static const String _userStatsKey = 'USER_EMOTION_STATS';
  static const String _userInsightsKey = 'USER_EMOTION_INSIGHTS';
  static const String _userAnalyticsKey = 'USER_EMOTION_ANALYTICS';

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

      Logger.info('. Global emotion stats cached successfully');
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
      Logger.info('🌍 Retrieving cached global emotion stats...');

      final prefs = await SharedPreferences.getInstance();
      final globalStatsJson = prefs.getString(_globalStatsKey);

      if (globalStatsJson != null) {
        final globalStats = Map<String, dynamic>.from(
          json.decode(globalStatsJson),
        );
        Logger.info('. Cached global emotion stats retrieved');
        return globalStats;
      } else {
        Logger.warning('. No cached global emotion stats found');
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
      Logger.info('🗺️ Caching emotion heatmap data...');

      final prefs = await SharedPreferences.getInstance();
      final heatmapJson = json.encode(heatmapData);

      await prefs.setString(_heatmapDataKey, heatmapJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Emotion heatmap data cached successfully');
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
      Logger.info('🗺️ Retrieving cached emotion heatmap data...');

      final prefs = await SharedPreferences.getInstance();
      final heatmapJson = prefs.getString(_heatmapDataKey);

      if (heatmapJson != null) {
        final heatmapData = Map<String, dynamic>.from(json.decode(heatmapJson));
        Logger.info('. Cached emotion heatmap data retrieved');
        return heatmapData;
      } else {
        Logger.warning('. No cached emotion heatmap data found');
        return null;
      }
    } catch (e) {
      Logger.error('. Error retrieving cached heatmap data', e);
      return null;
    }
  }

  @override
  Future<void> cacheUserEmotion(Map<String, dynamic> emotion) async {
    try {
      Logger.info('🎭 Caching user emotion: ${emotion['emotion']}');

      final prefs = await SharedPreferences.getInstance();

      final existingEmotions = await getUserEmotionHistory();

      existingEmotions.insert(0, emotion);

      if (existingEmotions.length > 100) {
        existingEmotions.removeRange(100, existingEmotions.length);
      }

      final emotionsJson = json.encode(existingEmotions);
      await prefs.setString(_userEmotionsKey, emotionsJson);

      Logger.info('. User emotion cached successfully');
    } catch (e) {
      Logger.error('. Error caching user emotion', e);
      throw CacheException(
        message: 'Failed to cache user emotion: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserEmotionHistory() async {
    try {
      Logger.info('📱 Retrieving user emotion history...');

      final prefs = await SharedPreferences.getInstance();
      final emotionsJson = prefs.getString(_userEmotionsKey);

      if (emotionsJson != null) {
        final List<dynamic> emotionsList = json.decode(emotionsJson);
        final emotions = emotionsList
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        Logger.info(
          '. User emotion history retrieved: ${emotions.length} entries',
        );
        return emotions;
      } else {
        Logger.info('📱 No user emotion history found');
        return [];
      }
    } catch (e) {
      Logger.error('. Error retrieving user emotion history', e);
      return [];
    }
  }

  @override
  Future<void> clearEmotionCache() async {
    try {
      Logger.info('🧹 Clearing emotion cache...');

      final prefs = await SharedPreferences.getInstance();

      final keysToRemove = [
        _emotionFeedKey,
        _globalStatsKey,
        _heatmapDataKey,
        _userEmotionsKey,
        _emotionCacheTimestampKey,
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      final allKeys = prefs.getKeys();
      final userCacheKeys = allKeys.where((key) => 
        key.startsWith(_userStatsKey) || 
        key.startsWith(_userInsightsKey) || 
        key.startsWith(_userAnalyticsKey)
      ).toList();

      for (final key in userCacheKeys) {
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

  @override
  Future<bool> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastCacheTime = prefs.getString('emotion_cache_timestamp');

      if (lastCacheTime == null) {
        return true;
      }

      final cacheDateTime = DateTime.tryParse(lastCacheTime);
      if (cacheDateTime == null) {
        return true;
      }

      final now = DateTime.now();
      final difference = now.difference(cacheDateTime);

      return difference > maxAge;
    } catch (e) {
      Logger.error('. Failed to check cache staleness', e);
      return true;
    }
  }

  @override
  Future<Map<String, dynamic>> getCachedUserStats(String userId) async {
    try {
      Logger.info('📊 Retrieving cached user stats for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userStatsKey = '${_userStatsKey}_$userId';
      final userStatsJson = prefs.getString(userStatsKey);

      if (userStatsJson != null) {
        final userStats = Map<String, dynamic>.from(json.decode(userStatsJson));
        Logger.info('. Cached user stats retrieved');
        return userStats;
      } else {
        Logger.warning('. No cached user stats found for $userId');
        return {};
      }
    } catch (e) {
      Logger.error('. Error retrieving cached user stats', e);
      return {};
    }
  }

  @override
  Future<void> cacheUserStats(String userId, Map<String, dynamic> stats) async {
    try {
      Logger.info('📊 Caching user stats for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userStatsKey = '${_userStatsKey}_$userId';
      final userStatsJson = json.encode(stats);

      await prefs.setString(userStatsKey, userStatsJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
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
  Future<Map<String, dynamic>> getCachedUserInsights(String userId) async {
    try {
      Logger.info('💡 Retrieving cached user insights for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userInsightsKey = '${_userInsightsKey}_$userId';
      final userInsightsJson = prefs.getString(userInsightsKey);

      if (userInsightsJson != null) {
        final userInsights = Map<String, dynamic>.from(json.decode(userInsightsJson));
        Logger.info('. Cached user insights retrieved');
        return userInsights;
      } else {
        Logger.warning('. No cached user insights found for $userId');
        return {};
      }
    } catch (e) {
      Logger.error('. Error retrieving cached user insights', e);
      return {};
    }
  }

  @override
  Future<void> cacheUserInsights(String userId, Map<String, dynamic> insights) async {
    try {
      Logger.info('💡 Caching user insights for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userInsightsKey = '${_userInsightsKey}_$userId';
      final userInsightsJson = json.encode(insights);

      await prefs.setString(userInsightsKey, userInsightsJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. User insights cached successfully');
    } catch (e) {
      Logger.error('. Error caching user insights', e);
      throw CacheException(
        message: 'Failed to cache user insights: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getCachedUserAnalytics(String userId) async {
    try {
      Logger.info('📈 Retrieving cached user analytics for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userAnalyticsKey = '${_userAnalyticsKey}_$userId';
      final userAnalyticsJson = prefs.getString(userAnalyticsKey);

      if (userAnalyticsJson != null) {
        final userAnalytics = Map<String, dynamic>.from(json.decode(userAnalyticsJson));
        Logger.info('. Cached user analytics retrieved');
        return userAnalytics;
      } else {
        Logger.warning('. No cached user analytics found for $userId');
        return {};
      }
    } catch (e) {
      Logger.error('. Error retrieving cached user analytics', e);
      return {};
    }
  }

  @override
  Future<void> cacheUserAnalytics(String userId, Map<String, dynamic> analytics) async {
    try {
      Logger.info('📈 Caching user analytics for $userId...');

      final prefs = await SharedPreferences.getInstance();
      final userAnalyticsKey = '${_userAnalyticsKey}_$userId';
      final userAnalyticsJson = json.encode(analytics);

      await prefs.setString(userAnalyticsKey, userAnalyticsJson);
      await prefs.setString(
        _emotionCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. User analytics cached successfully');
    } catch (e) {
      Logger.error('. Error caching user analytics', e);
      throw CacheException(
        message: 'Failed to cache user analytics: ${e.toString()}',
      );
    }
  }
}
