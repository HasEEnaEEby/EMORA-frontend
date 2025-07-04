import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';

class EmotionBackendService {
  final DioClient dioClient;

  const EmotionBackendService(this.dioClient);

  /// Log a new emotion to the backend
  Future<Map<String, dynamic>> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    String? context,
    String? memory,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Logger.info('🎭 Logging emotion: $emotion with intensity: $intensity');

      // FIX: Use emotionData parameter that matches DioClient signature
      final emotionData = {
        'emotion': emotion,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
        if (context != null) 'context': {'trigger': context},
        if (memory != null)
          'memory': {'description': memory, 'isPrivate': true},
        if (latitude != null && longitude != null)
          'location': {
            'coordinates': [longitude, latitude],
            'type': 'Point',
          },
        if (additionalData != null) ...additionalData,
      };

      final response = await dioClient.logEmotion(
        userId: userId,
        emotion: emotion,
        intensity: intensity,
        context: context != null
            ? {'trigger': context}
            : null, // FIX: Convert to Map
        memory: memory != null
            ? {'description': memory, 'isPrivate': true}
            : null, // FIX: Convert to Map
        // FIX: Remove individual latitude/longitude, use emotionData instead
        emotionData: emotionData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ Emotion logged successfully');
        return {
          'success': true,
          'data': response.data,
          'emotionId': response.data?['data']?['_id'] ?? response.data?['_id'],
        };
      } else {
        throw Exception('Failed to log emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to log emotion', e);

      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔄 Using fallback emotion logging');
        return _getFallbackEmotionResponse(emotion, intensity);
      }

      rethrow;
    }
  }

  /// Get emotion feed from the backend
  Future<List<Map<String, dynamic>>> getEmotionFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Logger.info('📰 Fetching emotion feed...');

      final response = await dioClient.getEmotionFeed(
        limit: limit,
        offset: offset,
        format: 'unified',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns: { success: true, message: "...", data: emotionsArray, meta: pagination }
        final emotions = data['data'] ?? [];

        return List<Map<String, dynamic>>.from(
          emotions.map((emotion) => _normalizeEmotionData(emotion)),
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

  /// Get global emotion statistics
  Future<Map<String, dynamic>> getGlobalEmotionStats({
    String timeframe = '24h',
  }) async {
    try {
      Logger.info('🌍 Fetching global emotion stats for: $timeframe');

      final response = await dioClient.getGlobalEmotionStats(
        timeframe: timeframe,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'totalUsers': data['data']?['activeUsers'] ?? 0,
          'totalEmotions': data['data']?['totalEmotions'] ?? 0,
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

  /// Get global emotion heatmap data
  Future<Map<String, dynamic>> getGlobalHeatmap() async {
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
            heatmapData.map((location) => _normalizeLocationData(location)),
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

  /// Check backend connectivity
  Future<bool> checkBackendHealth() async {
    try {
      Logger.info('🔍 Checking backend health...');

      final response = await dioClient.healthCheck();
      final isHealthy = response.statusCode == 200;

      Logger.info(
        '${isHealthy ? '✅' : '❌'} Backend health: ${isHealthy ? 'OK' : 'Failed'}',
      );
      return isHealthy;
    } catch (e) {
      Logger.error('❌ Backend health check failed', e);
      return false;
    }
  }

  // Private helper methods
  Map<String, dynamic> _normalizeEmotionData(Map<String, dynamic> emotion) {
    return {
      'id': emotion['_id'] ?? emotion['id'],
      'emotion': emotion['emotion'] ?? emotion['coreEmotion'],
      'intensity': emotion['intensity'] ?? 0.5,
      'timestamp': emotion['timestamp'] ?? DateTime.now().toIso8601String(),
      'context': emotion['context'],
      'memory': emotion['memory'],
      'isAnonymous': emotion['memory']?['isPrivate'] ?? true,
      'location': emotion['location'],
    };
  }

  Map<String, dynamic> _normalizeLocationData(Map<String, dynamic> location) {
    // Safely extract coordinates
    double latitude = 0.0;
    double longitude = 0.0;
    
    try {
      final locationData = location['location'];
      if (locationData is Map) {
        final coordinates = locationData['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          // Handle both string and integer indices
          final lat = coordinates[1];
          final lng = coordinates[0];
          
          if (lat is num) latitude = lat.toDouble();
          if (lng is num) longitude = lng.toDouble();
        }
      }
    } catch (e) {
      Logger.warning('⚠️ Failed to parse location coordinates: $e');
    }

    return {
      'id': location['_id'] ?? location['id'],
      'latitude': latitude,
      'longitude': longitude,
      'emotion': location['emotion'] ?? location['coreEmotion'],
      'intensity': location['intensity'] ?? 0.5,
      'count': location['count'] ?? 1,
      'locationName': location['locationName'] ?? location['location']?['name'],
      'timestamp': location['timestamp'] ?? DateTime.now().toIso8601String(),
    };
  }

  // Fallback data for development mode
  Map<String, dynamic> _getFallbackEmotionResponse(
    String emotion,
    double intensity,
  ) {
    return {
      'success': true,
      'data': {
        '_id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
        'emotion': emotion,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
      },
      'emotionId': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
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
        'memory': {
          'description': 'Perfect start to the day',
          'isPrivate': true,
        },
        'isAnonymous': true,
      },
      {
        'id': 'feed_2',
        'emotion': 'calm',
        'intensity': 0.7,
        'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
        'context': {'trigger': 'Morning meditation'},
        'memory': {
          'description': 'Feeling centered and peaceful',
          'isPrivate': true,
        },
        'isAnonymous': true,
      },
      {
        'id': 'feed_3',
        'emotion': 'excitement',
        'intensity': 0.9,
        'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'context': {'trigger': 'Weekend plans!'},
        'memory': {
          'description': 'Looking forward to adventures',
          'isPrivate': true,
        },
        'isAnonymous': true,
      },
    ];
  }

  Map<String, dynamic> _getFallbackGlobalStats() {
    return {
      'totalUsers': 2300000,
      'totalEmotions': 450000,
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
      ],
      'summary': {
        'totalLocations': 3,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
    };
  }
}
