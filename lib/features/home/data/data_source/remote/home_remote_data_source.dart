// lib/features/home/data/data_source/remote/home_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logger.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHomeData();
  Future<Map<String, dynamic>> getUserStats(String userId);
  Future<Map<String, dynamic>> getGlobalEmotionStats();
  Future<List<Map<String, dynamic>>> getEmotionFeed();
  Future<Map<String, dynamic>> getGlobalEmotionHeatmap();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;
  final ApiService _apiService = ApiService();

  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      Logger.info('🏠 Fetching home data from EMORA backend...');

      // Use ApiService for health check with caching
      final healthResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/health',
        cacheDuration: Duration(minutes: 1),
      );

      // Fetch global emotion stats with caching
      final globalStatsResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-stats',
        queryParameters: {'timeframe': '24h'},
        cacheDuration: Duration(minutes: 5),
      );

      // Fetch emotion feed with caching
      final emotionFeedResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/feed',
        queryParameters: {'limit': 20, 'offset': 0, 'format': 'unified'},
        cacheDuration: Duration(minutes: 3),
      );

      // Fetch global heatmap with caching
      final heatmapResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-heatmap',
        queryParameters: {'format': 'unified'},
        cacheDuration: Duration(minutes: 10),
      );

      Logger.info('✅ Home data fetched successfully');

      // Process and return home data
      return _processHomeDataResponse(
        healthResponse,
        globalStatsResponse,
        emotionFeedResponse,
        heatmapResponse,
      );
    } catch (e) {
      Logger.error('❌ Error fetching home data from backend', e);

      // Return fallback data in development mode
      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔄 Using fallback home data in development mode');
        return _getFallbackHomeData();
      }

      throw ServerException(message: 'Failed to fetch home data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      Logger.info('📊 Fetching user stats for: $userId');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/users/$userId/insights',
        queryParameters: {'timeframe': '30d'},
        cacheDuration: Duration(minutes: 5),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'journalEntries': data['data']?['totalEntries'] ?? 0,
          'moodCheckins': data['data']?['totalMoods'] ?? 0,
          'achievements': 0, // Not implemented in backend yet
          'streakDays': data['data']?['currentStreak'] ?? 0,
          'totalActiveDays': data['data']?['activeDays'] ?? 0,
          'lastActivityDate':
              data['data']?['lastActivity'] ?? DateTime.now().toIso8601String(),
          'weeklyGoal': 5,
          'weeklyProgress': data['data']?['weeklyProgress'] ?? 0,
          'longestStreak': data['data']?['longestStreak'] ?? 0,
          'favoriteEmotions': data['data']?['topEmotions'] ?? [],
        };
      } else {
        throw Exception('Failed to get user stats: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch user stats', e);

      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔄 Using fallback user stats');
        return _getFallbackUserStats();
      }

      throw ServerException(message: 'Failed to fetch user stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalEmotionStats() async {
    try {
      Logger.info('🌍 Fetching global emotion stats...');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-stats',
        queryParameters: {'timeframe': '24h'},
        cacheDuration: Duration(minutes: 5),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'totalUsers': data['data']?['activeUsers'] ?? 0,
          'todayEntries': data['data']?['totalEmotions'] ?? 0,
          'emotionDistribution': data['data']?['emotionDistribution'] ?? {},
          'topEmotions': data['data']?['topEmotions'] ?? {},
          'mostCommonEmotion': data['data']?['mostCommonEmotion'] ?? 'joy',
          'averageIntensity': data['data']?['averageIntensity'] ?? 0.5,
          'lastUpdated':
              data['data']?['lastUpdated'] ?? DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Failed to get global stats: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch global emotion stats', e);

      if (AppConfig.isDevelopmentMode) {
        return _getFallbackGlobalStats();
      }

      throw ServerException(
        message: 'Failed to fetch global emotion stats: $e',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEmotionFeed() async {
    try {
      Logger.info('📰 Fetching emotion feed...');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/feed',
        queryParameters: {'limit': 20, 'offset': 0, 'format': 'unified'},
        cacheDuration: Duration(minutes: 3),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns: { success: true, message: "...", data: emotionsArray, meta: pagination }
        final emotions = data['data'] ?? [];

        return List<Map<String, dynamic>>.from(
          emotions.map(
            (emotion) => {
              'id': emotion['_id'] ?? emotion['id'],
              'emotion': emotion['emotion'] ?? emotion['coreEmotion'],
              'intensity': emotion['intensity'] ?? 0.5,
              'timestamp':
                  emotion['timestamp'] ?? DateTime.now().toIso8601String(),
              'context': emotion['context'],
              'memory': emotion['memory'],
              'isAnonymous': emotion['memory']?['isPrivate'] ?? true,
            },
          ),
        );
      } else {
        throw Exception('Failed to get emotion feed: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch emotion feed', e);

      if (AppConfig.isDevelopmentMode) {
        return _getFallbackEmotionFeed();
      }

      throw ServerException(message: 'Failed to fetch emotion feed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalEmotionHeatmap() async {
    try {
      Logger.info('🗺️ Fetching global emotion heatmap...');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-heatmap',
        queryParameters: {'format': 'unified'},
        cacheDuration: Duration(minutes: 10),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final heatmapData = data['data']?['data'] ?? data['locations'] ?? [];

        return {
          'locations': List<Map<String, dynamic>>.from(
            heatmapData.map(
              (location) => {
                'id': location['_id'] ?? location['id'],
                'latitude':
                    location['location']?['coordinates']?[1] ??
                    location['latitude'] ??
                    0.0,
                'longitude':
                    location['location']?['coordinates']?[0] ??
                    location['longitude'] ??
                    0.0,
                'emotion': location['emotion'] ?? location['coreEmotion'],
                'intensity': location['intensity'] ?? 0.5,
                'count': location['count'] ?? 1,
                'locationName':
                    location['locationName'] ?? location['location']?['name'],
                'timestamp':
                    location['timestamp'] ?? DateTime.now().toIso8601String(),
              },
            ),
          ),
          'summary': {
            'totalLocations': heatmapData.length,
            'lastUpdated': DateTime.now().toIso8601String(),
          },
        };
      } else {
        throw Exception('Failed to get heatmap data: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch global emotion heatmap', e);

      if (AppConfig.isDevelopmentMode) {
        return _getFallbackHeatmapData();
      }

      throw ServerException(
        message: 'Failed to fetch global emotion heatmap: $e',
      );
    }
  }

  Map<String, dynamic> _processHomeDataResponse(
    Response healthResponse,
    Response globalStatsResponse,
    Response emotionFeedResponse,
    Response heatmapResponse,
  ) {
    // Combine all data for home screen
    return {
      'currentMood': 'joy', // Default mood
      'moodEmoji': '😊',
      'todayMoodLogged': false,
      'streak': 0,
      'globalStats': globalStatsResponse.data['data'] ?? {},
      'emotionFeed': emotionFeedResponse.data['data'] ?? [],
      'heatmapData': heatmapResponse.data['data'] ?? {},
      'lastUpdated': DateTime.now().toIso8601String(),
      'backendConnected': true,
    };
  }

  // Fallback data for development mode
  Map<String, dynamic> _getFallbackHomeData() {
    return {
      'currentMood': 'joy',
      'moodEmoji': '😊',
      'todayMoodLogged': false,
      'streak': 7,
      'totalSessions': 25,
      'weekMoods': ['😊', '😌', '😊', '😰', '😊', '😑', '😊'],
      'globalStats': _getFallbackGlobalStats(),
      'emotionFeed': _getFallbackEmotionFeed(),
      'heatmapData': _getFallbackHeatmapData(),
      'recommendations': [
        {
          'title': 'Happy Vibes\nPlaylist',
          'type': 'music',
          'image': 'mood_1.jpg',
        },
        {
          'title': 'Calm Mind\nMeditation',
          'type': 'meditation',
          'image': 'meditation_1.jpg',
        },
        {
          'title': 'Energy Boost\nWorkout',
          'type': 'exercise',
          'image': 'energy_1.jpg',
        },
      ],
      'backendConnected': false,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getFallbackGlobalStats() {
    return {
      'totalUsers': 2300000,
      'todayEntries': 450000,
      'emotionDistribution': {
        'joy': 0.42,
        'calm': 0.28,
        'sadness': 0.18,
        'fear': 0.15,
        'anger': 0.12,
      },
      'topEmotions': {
        'joy': 189000,
        'calm': 126000,
        'excitement': 98000,
        'anxiety': 67500,
        'sadness': 81000,
      },
      'mostCommonEmotion': 'joy',
      'averageIntensity': 0.65,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getFallbackUserStats() {
    return {
      'journalEntries': 0,
      'moodCheckins': 0,
      'achievements': 0,
      'streakDays': 0,
      'totalActiveDays': 1,
      'lastActivityDate': DateTime.now().toIso8601String(),
      'weeklyGoal': 5,
      'weeklyProgress': 1,
      'longestStreak': 0,
      'favoriteEmotions': ['joy', 'calm', 'excitement'],
    };
  }

  List<Map<String, dynamic>> _getFallbackEmotionFeed() {
    final now = DateTime.now();
    return [
      {
        'id': 'feed_1',
        'emotion': 'joy',
        'intensity': 0.8,
        'timestamp': now
            .subtract(const Duration(minutes: 15))
            .toIso8601String(),
        'context': {'trigger': 'Great coffee this morning!'},
        'memory': {'description': 'Perfect start to the day'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_2',
        'emotion': 'calm',
        'intensity': 0.7,
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'context': {'trigger': 'Morning meditation'},
        'memory': {'description': 'Feeling centered and peaceful'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_3',
        'emotion': 'excitement',
        'intensity': 0.9,
        'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'context': {'trigger': 'Weekend plans!'},
        'memory': {'description': 'Looking forward to adventures'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_4',
        'emotion': 'gratitude',
        'intensity': 0.8,
        'timestamp': now.subtract(const Duration(hours: 3)).toIso8601String(),
        'context': {'trigger': 'Family time'},
        'memory': {'description': 'Grateful for loved ones'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_5',
        'emotion': 'peaceful',
        'intensity': 0.9,
        'timestamp': now.subtract(const Duration(hours: 4)).toIso8601String(),
        'context': {'trigger': 'Nature walk'},
        'memory': {'description': 'Beautiful sunset by the lake'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_6',
        'emotion': 'inspired',
        'intensity': 0.7,
        'timestamp': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'context': {'trigger': 'Reading a good book'},
        'memory': {'description': 'Amazing insights from the chapter'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_7',
        'emotion': 'content',
        'intensity': 0.6,
        'timestamp': now.subtract(const Duration(hours: 6)).toIso8601String(),
        'context': {'trigger': 'Finished a project'},
        'memory': {'description': 'Satisfied with the result'},
        'isAnonymous': true,
      },
      {
        'id': 'feed_8',
        'emotion': 'hopeful',
        'intensity': 0.8,
        'timestamp': now.subtract(const Duration(hours: 8)).toIso8601String(),
        'context': {'trigger': 'Planning future goals'},
        'memory': {'description': 'Excited about new opportunities'},
        'isAnonymous': true,
      },
    ];
  }

  Map<String, dynamic> _getFallbackHeatmapData() {
    return {
      'locations': [
        {
          'id': 'loc_1',
          'latitude': 27.7172,
          'longitude': 85.3240,
          'emotion': 'joy',
          'intensity': 0.8,
          'count': 150,
          'locationName': 'Kathmandu',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_2',
          'latitude': 40.7128,
          'longitude': -74.0060,
          'emotion': 'excitement',
          'intensity': 0.7,
          'count': 230,
          'locationName': 'New York',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_3',
          'latitude': 35.6762,
          'longitude': 139.6503,
          'emotion': 'calm',
          'intensity': 0.6,
          'count': 180,
          'locationName': 'Tokyo',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_4',
          'latitude': 51.5074,
          'longitude': -0.1278,
          'emotion': 'anxiety',
          'intensity': 0.5,
          'count': 95,
          'locationName': 'London',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_5',
          'latitude': -33.8688,
          'longitude': 151.2093,
          'emotion': 'happiness',
          'intensity': 0.9,
          'count': 200,
          'locationName': 'Sydney',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_6',
          'latitude': 37.7749,
          'longitude': -122.4194,
          'emotion': 'inspired',
          'intensity': 0.8,
          'count': 175,
          'locationName': 'San Francisco',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_7',
          'latitude': 48.8566,
          'longitude': 2.3522,
          'emotion': 'romantic',
          'intensity': 0.7,
          'count': 160,
          'locationName': 'Paris',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_8',
          'latitude': 55.7558,
          'longitude': 37.6176,
          'emotion': 'contemplative',
          'intensity': 0.6,
          'count': 110,
          'locationName': 'Moscow',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_9',
          'latitude': -22.9068,
          'longitude': -43.1729,
          'emotion': 'energetic',
          'intensity': 0.9,
          'count': 190,
          'locationName': 'Rio de Janeiro',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_10',
          'latitude': 1.3521,
          'longitude': 103.8198,
          'emotion': 'focused',
          'intensity': 0.7,
          'count': 140,
          'locationName': 'Singapore',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_11',
          'latitude': 19.4326,
          'longitude': -99.1332,
          'emotion': 'vibrant',
          'intensity': 0.8,
          'count': 165,
          'locationName': 'Mexico City',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'id': 'loc_12',
          'latitude': 41.9028,
          'longitude': 12.4964,
          'emotion': 'nostalgic',
          'intensity': 0.6,
          'count': 125,
          'locationName': 'Rome',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ],
      'summary': {
        'totalLocations': 12,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    };
  }

  // Additional helper methods for testing and debugging

  /// Clear all cached data (useful for testing)
  void clearCache() {
    _apiService.clearCache();
    Logger.info('🗑️ HomeRemoteDataSource cache cleared');
  }

  /// Get cache statistics for debugging
  Map<String, int> getCacheStats() {
    return _apiService.getCacheStats();
  }

  /// Force refresh all data (bypasses cache)
  Future<Map<String, dynamic>> getHomeDataForceRefresh() async {
    try {
      Logger.info('🔄 Force refreshing all home data...');

      // Force refresh all endpoints
      final healthResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/health',
        forceRefresh: true,
      );

      final globalStatsResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-stats',
        queryParameters: {'timeframe': '24h'},
        forceRefresh: true,
      );

      final emotionFeedResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/feed',
        queryParameters: {'limit': 20, 'offset': 0, 'format': 'unified'},
        forceRefresh: true,
      );

      final heatmapResponse = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/emotions/global-heatmap',
        queryParameters: {'format': 'unified'},
        forceRefresh: true,
      );

      Logger.info('✅ All home data force refreshed successfully');

      return _processHomeDataResponse(
        healthResponse,
        globalStatsResponse,
        emotionFeedResponse,
        heatmapResponse,
      );
    } catch (e) {
      Logger.error('❌ Error force refreshing home data', e);

      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔄 Using fallback data for force refresh');
        return _getFallbackHomeData();
      }

      throw ServerException(message: 'Failed to force refresh home data: $e');
    }
  }

  /// Check backend connectivity
  Future<bool> checkBackendConnectivity() async {
    try {
      Logger.info('🔍 Checking backend connectivity...');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/health',
        cacheDuration: Duration(
          seconds: 10,
        ), // Short cache for connectivity check
      );

      final isConnected = response.statusCode == 200;
      Logger.info(
        isConnected
            ? '✅ Backend is connected and healthy'
            : '❌ Backend connectivity issue',
      );

      return isConnected;
    } catch (e) {
      Logger.error('❌ Backend connectivity check failed', e);
      return false;
    }
  }

  /// Get detailed backend status
  Future<Map<String, dynamic>> getBackendStatus() async {
    try {
      Logger.info('📊 Getting detailed backend status...');

      final response = await _apiService.makeRequest(
        dioClient.dio,
        'GET',
        '/api/health',
        forceRefresh: true, // Always get fresh status
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'connected': true,
          'status': data['data']?['status'] ?? 'unknown',
          'environment': data['data']?['environment'] ?? 'unknown',
          'version': data['data']?['version'] ?? 'unknown',
          'uptime': data['data']?['uptime'] ?? 0,
          'services': data['data']?['services'] ?? {},
          'features': data['data']?['features'] ?? {},
          'lastChecked': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Health check returned ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to get backend status', e);
      return {
        'connected': false,
        'error': e.toString(),
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }
}
