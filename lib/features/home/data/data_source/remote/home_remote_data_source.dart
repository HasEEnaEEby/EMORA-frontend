import '../../../../../core/config/app_config.dart';
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

  const HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      Logger.info('🏠 Fetching home data from EMORA backend...');

      // Check backend health first
      final healthResponse = await dioClient.healthCheck();
      if (healthResponse.statusCode != 200) {
        throw Exception('Backend health check failed');
      }

      // Get global emotion stats for the home screen
      final globalStats = await getGlobalEmotionStats();

      // Get emotion feed for recent activity
      final emotionFeed = await getEmotionFeed();

      // Get global heatmap data
      final heatmapData = await getGlobalEmotionHeatmap();

      // Combine all data for home screen
      final homeData = {
        'currentMood': 'joy', // Default mood
        'moodEmoji': '😊',
        'todayMoodLogged': false,
        'streak': 0,
        'globalStats': globalStats,
        'emotionFeed': emotionFeed,
        'heatmapData': heatmapData,
        'lastUpdated': DateTime.now().toIso8601String(),
        'backendConnected': true,
      };

      Logger.info('✅ Home data fetched successfully');
      return homeData;
    } catch (e) {
      Logger.error('❌ Failed to fetch home data', e);

      // Return fallback data in development mode
      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔄 Using fallback home data in development mode');
        return _getFallbackHomeData();
      }

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      Logger.info('📊 Fetching user stats for: $userId');

      final response = await dioClient.getUserEmotionInsights(
        userId: userId,
        timeframe: '30d',
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

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalEmotionStats() async {
    try {
      Logger.info('🌍 Fetching global emotion stats...');

      final response = await dioClient.getGlobalEmotionStats(timeframe: '24h');

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

      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEmotionFeed() async {
    try {
      Logger.info('📰 Fetching emotion feed...');

      final response = await dioClient.getEmotionFeed(
        limit: 20,
        offset: 0,
        format: 'unified',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final emotions = data['data']?['emotions'] ?? data['emotions'] ?? [];

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

      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalEmotionHeatmap() async {
    try {
      Logger.info('🗺️ Fetching global emotion heatmap...');

      final response = await dioClient.getGlobalEmotionHeatmap(
        format: 'unified',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final heatmapData =
            data['data']?['heatmapData'] ?? data['locations'] ?? [];

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

      rethrow;
    }
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
      ],
      'summary': {
        'totalLocations': 5,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    };
  }
}
