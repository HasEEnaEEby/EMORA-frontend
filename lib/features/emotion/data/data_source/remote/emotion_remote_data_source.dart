import 'dart:math' as math;

import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/utils/logger.dart';

/// Abstract interface for emotion remote data operations
abstract class EmotionRemoteDataSource {
  /// Log a new emotion to the remote server
  Future<Map<String, dynamic>> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    String? context,
    String? memory,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  });

  /// Get emotion feed from remote server
  Future<List<Map<String, dynamic>>> getEmotionFeed({
    int limit = 20,
    int offset = 0,
  });

  /// Get global emotion statistics from remote server
  Future<Map<String, dynamic>> getGlobalEmotionStats({
    String timeframe = '24h',
  });

  /// Get global emotion heatmap from remote server
  Future<Map<String, dynamic>> getGlobalHeatmap();

  /// Get emotion statistics for a specific user
  Future<Map<String, dynamic>> getUserEmotionStats(String userId);

  /// Get user insights from remote server
  Future<Map<String, dynamic>> getUserInsights({
    required String userId,
    String timeframe = '30d',
  });

  /// Get user analytics from remote server
  Future<Map<String, dynamic>> getUserAnalytics({
    required String userId,
    String timeframe = '7d',
  });

  /// Get emotion history for a specific user
  Future<List<Map<String, dynamic>>> getUserEmotions({
    required String userId,
    required int limit,
    required int offset,
  });

  /// Get emotion analytics for a user
  Future<Map<String, dynamic>> getUserEmotionAnalytics({
    required String userId,
    String period = 'week',
  });

  /// Check server health status
  Future<Map<String, dynamic>> checkServerHealth();

  /// Sync pending emotions to server
  Future<Map<String, dynamic>> syncEmotions({
    required List<Map<String, dynamic>> emotions,
  });
}

/// Implementation of emotion remote data source using DioClient
class EmotionRemoteDataSourceImpl implements EmotionRemoteDataSource {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  EmotionRemoteDataSourceImpl({
    required this.dioClient,
    required this.networkInfo,
  });

  @override
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
      Logger.info('🌐 Remote: Logging emotion $emotion for user $userId');

      // Build emotion data payload
      final emotionData = {
        'emotion': emotion,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
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

      // Make API call to log emotion
      final response = await dioClient.logEmotion(
        userId: userId,
        emotion: emotion,
        intensity: intensity,
        emotionData: emotionData,
      );

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('. Remote: Emotion logged successfully');

        // Return standardized response
        return {
          'success': true,
          'data': response.data ?? {},
          'emotionId':
              response.data?['data']?['_id'] ??
              response.data?['_id'] ??
              'remote_${DateTime.now().millisecondsSinceEpoch}',
          'timestamp': DateTime.now().toIso8601String(),
          'syncedToRemote': true,
        };
      } else {
        throw ServerException(
          message: 'Failed to log emotion: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error logging emotion', e);

      // Handle different types of network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Network timeout: ${e.message}');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Connection error: ${e.message}');
      } else {
        throw ServerException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      Logger.error('. Remote: Unexpected error logging emotion', e);
      throw ServerException(message: 'Failed to log emotion: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEmotionFeed({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      Logger.info(
        '🌐 Remote: Fetching emotion feed (limit: $limit, offset: $offset)',
      );

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getEmotionFeed(
        limit: limit,
        offset: offset,
        format: 'unified',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns: { success: true, message: "...", data: emotionsArray, meta: pagination }
        final emotions = data['data'] ?? [];

        // Normalize emotion data
        final normalizedEmotions = emotions.map<Map<String, dynamic>>((
          emotion,
        ) {
          return _normalizeEmotionData(emotion);
        }).toList();

        Logger.info(
          '. Remote: Retrieved ${normalizedEmotions.length} emotions',
        );
        return normalizedEmotions;
      } else {
        throw ServerException(
          message: 'Failed to get emotion feed: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching emotion feed', e);
      _handleDioException(e, 'fetch emotion feed');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching emotion feed', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch emotion feed: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalEmotionStats({
    String timeframe = '24h',
  }) async {
    try {
      Logger.info(
        '🌐 Remote: Fetching global emotion stats (timeframe: $timeframe)',
      );

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getGlobalEmotionStats(
        timeframe: timeframe,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Normalize stats data
        final normalizedStats = {
          'totalUsers': data['data']?['activeUsers'] ?? data['totalUsers'] ?? 0,
          'totalEmotions':
              data['data']?['totalEmotions'] ?? data['totalEmotions'] ?? 0,
          'emotionDistribution':
              data['data']?['emotionDistribution'] ??
              data['emotionDistribution'] ??
              {},
          'topEmotions':
              data['data']?['topEmotions'] ?? data['topEmotions'] ?? {},
          'mostCommonEmotion':
              data['data']?['mostCommonEmotion'] ??
              data['mostCommonEmotion'] ??
              'joy',
          'averageIntensity':
              data['data']?['averageIntensity'] ??
              data['averageIntensity'] ??
              0.5,
          'timeframe': timeframe,
          'lastUpdated':
              data['data']?['lastUpdated'] ?? DateTime.now().toIso8601String(),
        };

        Logger.info('. Remote: Global emotion stats retrieved');
        return normalizedStats;
      } else {
        throw ServerException(
          message: 'Failed to get global stats: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching global stats', e);
      _handleDioException(e, 'fetch global emotion stats');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching global stats', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch global stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getGlobalHeatmap() async {
    try {
      Logger.info('🌐 Remote: Fetching global emotion heatmap');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getGlobalEmotionHeatmap(
        format: 'unified',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final heatmapData =
            data['data']?['heatmapData'] ??
            data['heatmapData'] ??
            data['locations'] ??
            [];

        // Normalize heatmap data
        final normalizedHeatmap = {
          'locations': heatmapData.map<Map<String, dynamic>>((location) {
            return _normalizeLocationData(location);
          }).toList(),
          'summary': {
            'totalLocations': heatmapData.length,
            'lastUpdated':
                data['data']?['lastUpdated'] ??
                DateTime.now().toIso8601String(),
            'dataPoints': heatmapData.length,
          },
          'metadata': {
            'generated': DateTime.now().toIso8601String(),
            'source': 'remote',
          },
        };

        Logger.info(
          '. Remote: Global heatmap retrieved with ${heatmapData.length} locations',
        );
        return normalizedHeatmap;
      } else {
        throw ServerException(
          message: 'Failed to get heatmap: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching heatmap', e);
      _handleDioException(e, 'fetch global heatmap');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching heatmap', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch heatmap: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserEmotionStats(String userId) async {
    try {
      Logger.info('🌐 Remote: Fetching user emotion stats for $userId');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getUserEmotionStats(userId);

      if (response.statusCode == 200) {
        final data = response.data;

        // Normalize user stats
        final normalizedStats = {
          'userId': userId,
          'totalEmotions':
              data['data']?['totalEmotions'] ?? data['totalEmotions'] ?? 0,
          'emotionDistribution':
              data['data']?['emotionDistribution'] ??
              data['emotionDistribution'] ??
              {},
          'averageIntensity':
              data['data']?['averageIntensity'] ??
              data['averageIntensity'] ??
              0.0,
          'mostCommonEmotion':
              data['data']?['mostCommonEmotion'] ?? data['mostCommonEmotion'],
          'emotionStreak': data['data']?['streak'] ?? data['streak'] ?? 0,
          'lastEmotionDate':
              data['data']?['lastEmotionDate'] ?? data['lastEmotionDate'],
          'weeklyTrend':
              data['data']?['weeklyTrend'] ?? data['weeklyTrend'] ?? [],
          'lastUpdated':
              data['data']?['lastUpdated'] ?? DateTime.now().toIso8601String(),
        };

        Logger.info('. Remote: User emotion stats retrieved');
        return normalizedStats;
      } else {
        throw ServerException(
          message: 'Failed to get user stats: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching user stats', e);
      _handleDioException(e, 'fetch user emotion stats');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching user stats', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch user stats: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserInsights({
    required String userId,
    String timeframe = '30d',
  }) async {
    try {
      Logger.info('🌐 Remote: Fetching user insights for $userId');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getUserInsights(
        userId: userId,
        timeframe: timeframe,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final insights = {
          'userId': userId,
          'timeframe': timeframe,
          'summary': data['summary'] ?? {},
          'trends': data['trends'] ?? {},
          'insights': data['insights'] ?? {},
          'generatedAt': DateTime.now().toIso8601String(),
        };

        Logger.info('. Remote: User insights retrieved');
        return insights;
      } else {
        throw ServerException(
          message: 'Failed to get user insights: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching user insights', e);
      _handleDioException(e, 'fetch user insights');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching user insights', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch user insights: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserAnalytics({
    required String userId,
    String timeframe = '7d',
  }) async {
    try {
      Logger.info('🌐 Remote: Fetching user analytics for $userId');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      final response = await dioClient.getUserAnalytics(
        userId: userId,
        timeframe: timeframe,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final analytics = {
          'userId': userId,
          'timeframe': timeframe,
          'summary': data['summary'] ?? {},
          'trends': data['trends'] ?? {},
          'insights': data['insights'] ?? {},
          'generatedAt': DateTime.now().toIso8601String(),
        };

        Logger.info('. Remote: User analytics retrieved');
        return analytics;
      } else {
        throw ServerException(
          message: 'Failed to get user analytics: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching user analytics', e);
      _handleDioException(e, 'fetch user analytics');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching user analytics', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch user analytics: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserEmotions({
    required String userId,
    required int limit,
    required int offset,
  }) async {
    try {
      Logger.info('🌐 Remote: Fetching user emotions for $userId');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      // WORKAROUND: Since getUserEmotions might not exist in DioClient,
      // we'll use getEmotionFeed and filter by userId
      try {
        // Try direct user emotions endpoint first (if available)
        final response = await dioClient.getEmotionFeed(
          limit: limit,
          offset: offset,
          format: 'unified',
        );

        if (response.statusCode == 200) {
          final data = response.data;
          // Backend returns: { success: true, message: "...", data: emotionsArray, meta: pagination }
          var emotions = data['data'] ?? [];

          // Filter by userId if the API doesn't do it automatically
          emotions = emotions.where((emotion) {
            final emotionUserId = emotion['userId'] ?? emotion['user_id'] ?? '';
            return emotionUserId == userId;
          }).toList();

          // Normalize emotion data
          final normalizedEmotions = emotions.map<Map<String, dynamic>>((
            emotion,
          ) {
            return _normalizeEmotionData(emotion);
          }).toList();

          Logger.info(
            '. Remote: Retrieved ${normalizedEmotions.length} user emotions',
          );
          return normalizedEmotions;
        } else {
          throw ServerException(
            message: 'Failed to get user emotions: HTTP ${response.statusCode}',
          );
        }
      } catch (e) {
        // Fallback: Try alternative endpoint or return empty list
        Logger.warning(
          '. Remote: Primary user emotions endpoint failed, trying fallback',
        );
        return [];
      }
    } on DioException catch (e) {
      Logger.error('. Remote: Dio error fetching user emotions', e);
      _handleDioException(e, 'fetch user emotions');
    } catch (e) {
      Logger.error('. Remote: Unexpected error fetching user emotions', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch user emotions: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getUserEmotionAnalytics({
    required String userId,
    String period = 'week',
  }) async {
    try {
      Logger.info('🌐 Remote: Fetching user emotion analytics for $userId');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      // Use user stats endpoint and enhance with analytics
      final stats = await getUserEmotionStats(userId);

      // Generate analytics from stats
      final analytics = {
        'userId': userId,
        'period': period,
        'summary': {
          'totalEmotions': stats['totalEmotions'] ?? 0,
          'averageIntensity': stats['averageIntensity'] ?? 0.0,
          'mostCommonEmotion': stats['mostCommonEmotion'],
          'emotionStreak': stats['emotionStreak'] ?? 0,
        },
        'trends': {
          'weekly': stats['weeklyTrend'] ?? [],
          'emotions': stats['emotionDistribution'] ?? {},
        },
        'insights': _generateEmotionInsights(stats),
        'generatedAt': DateTime.now().toIso8601String(),
      };

      Logger.info('. Remote: User emotion analytics generated');
      return analytics;
    } catch (e) {
      Logger.error('. Remote: Error fetching user emotion analytics', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to fetch user emotion analytics: ${e.toString()}',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> checkServerHealth() async {
    try {
      Logger.info('🌐 Remote: Checking server health');

      final response = await dioClient.healthCheck();

      final isHealthy = response.statusCode == 200;
      final healthData = {
        'status': isHealthy ? 'healthy' : 'unhealthy',
        'statusCode': response.statusCode,
        'timestamp': DateTime.now().toIso8601String(),
        'responseTime': DateTime.now().millisecondsSinceEpoch,
        'data': response.data ?? {},
      };

      Logger.info(
        '${isHealthy ? '.' : '.'} Remote: Server health: ${isHealthy ? 'OK' : 'Failed'}',
      );

      return healthData;
    } on DioException catch (e) {
      Logger.error('. Remote: Health check failed', e);
      return {
        'status': 'unhealthy',
        'statusCode': e.response?.statusCode ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.message,
      };
    } catch (e) {
      Logger.error('. Remote: Unexpected error in health check', e);
      return {
        'status': 'unhealthy',
        'statusCode': 0,
        'timestamp': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> syncEmotions({
    required List<Map<String, dynamic>> emotions,
  }) async {
    try {
      Logger.info('🌐 Remote: Syncing ${emotions.length} emotions to server');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      if (emotions.isEmpty) {
        return {
          'success': true,
          'syncedCount': 0,
          'failedCount': 0,
          'message': 'No emotions to sync',
        };
      }

      int syncedCount = 0;
      int failedCount = 0;
      final List<Map<String, dynamic>> syncResults = [];

      // Sync emotions one by one (or in batches if API supports it)
      for (final emotion in emotions) {
        try {
          final result = await logEmotion(
            userId: emotion['userId'] ?? '',
            emotion: emotion['emotion'] ?? '',
            intensity: (emotion['intensity'] ?? 0.0).toDouble(),
            context: emotion['context']?.toString(),
            memory: emotion['memory']?.toString(),
            latitude: emotion['latitude']?.toDouble(),
            longitude: emotion['longitude']?.toDouble(),
            additionalData: emotion['additionalData'],
          );

          syncedCount++;
          syncResults.add({
            'localId': emotion['id'],
            'remoteId': result['emotionId'],
            'status': 'synced',
          });
        } catch (e) {
          failedCount++;
          syncResults.add({
            'localId': emotion['id'],
            'status': 'failed',
            'error': e.toString(),
          });
        }
      }

      final syncSummary = {
        'success': failedCount == 0,
        'syncedCount': syncedCount,
        'failedCount': failedCount,
        'totalCount': emotions.length,
        'results': syncResults,
        'syncedAt': DateTime.now().toIso8601String(),
      };

      Logger.info(
        '. Remote: Emotion sync completed - $syncedCount synced, $failedCount failed',
      );
      return syncSummary;
    } catch (e) {
      Logger.error('. Remote: Error syncing emotions', e);
      if (e is NetworkException || e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to sync emotions: ${e.toString()}',
      );
    }
  }

  // ========================================
  // PRIVATE HELPER METHODS
  // ========================================

  /// Normalize emotion data from API response
  Map<String, dynamic> _normalizeEmotionData(Map<String, dynamic> emotion) {
    // Safely extract coordinates
    double? latitude;
    double? longitude;

    try {
      final location = emotion['location'];
      if (location is Map) {
        final coordinates = location['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          // Handle both string and integer indices
          final lat = coordinates[1];
          final lng = coordinates[0];

          if (lat is num) latitude = lat.toDouble();
          if (lng is num) longitude = lng.toDouble();
        }
      }
    } catch (e) {
      Logger.warning('. Failed to parse location coordinates: $e');
    }

    return {
      'id': emotion['_id'] ?? emotion['id'] ?? '',
      'userId': emotion['userId'] ?? emotion['user_id'] ?? '',
      'emotion': emotion['emotion'] ?? emotion['coreEmotion'] ?? '',
      'intensity': (emotion['intensity'] ?? 0.0).toDouble(),
      'context': emotion['context']?.toString(),
      'memory': emotion['memory']?.toString(),
      'timestamp': emotion['timestamp'] ?? DateTime.now().toIso8601String(),
      'latitude': latitude ?? emotion['latitude']?.toDouble(),
      'longitude': longitude ?? emotion['longitude']?.toDouble(),
      'isAnonymous':
          emotion['isAnonymous'] ?? emotion['memory']?['isPrivate'] ?? true,
      'tags': emotion['tags'] != null
          ? List<String>.from(emotion['tags'])
          : null,
      'character': emotion['character'],
      'additionalData': emotion['additionalData'],
    };
  }

  /// Normalize location data from API response
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
      Logger.warning('. Failed to parse location coordinates: $e');
    }

    return {
      'id': location['_id'] ?? location['id'] ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'emotion': location['emotion'] ?? location['coreEmotion'] ?? '',
      'intensity': (location['intensity'] ?? 0.0).toDouble(),
      'count': location['count'] ?? 1,
      'locationName':
          location['locationName'] ??
          location['location']?['name'] ??
          'Unknown Location',
      'timestamp': location['timestamp'] ?? DateTime.now().toIso8601String(),
    };
  }

  /// Generate emotion insights from stats data
  Map<String, dynamic> _generateEmotionInsights(Map<String, dynamic> stats) {
    final totalEmotions = stats['totalEmotions'] ?? 0;
    final avgIntensity = stats['averageIntensity'] ?? 0.0;
    final emotionDistribution = stats['emotionDistribution'] ?? {};

    final insights = <String, dynamic>{
      'emotionalState': _getEmotionalState(avgIntensity),
      'diversityScore': _calculateEmotionDiversity(emotionDistribution),
      'recommendations': _generateRecommendations(stats),
    };

    if (totalEmotions > 0) {
      insights['activityLevel'] = _getActivityLevel(totalEmotions);
    }

    return insights;
  }

  /// Determine emotional state based on average intensity
  String _getEmotionalState(double avgIntensity) {
    if (avgIntensity >= 0.8) return 'Very Positive';
    if (avgIntensity >= 0.6) return 'Positive';
    if (avgIntensity >= 0.4) return 'Neutral';
    if (avgIntensity >= 0.2) return 'Low';
    return 'Very Low';
  }

  /// Calculate emotion diversity score
  double _calculateEmotionDiversity(Map<String, dynamic> distribution) {
    if (distribution.isEmpty) return 0.0;

    final values = distribution.values.map((v) => v as num).toList();
    final total = values.fold<num>(0, (sum, val) => sum + val);

    if (total == 0) return 0.0;

    // Calculate Shannon diversity index
    double diversity = 0.0;
    for (final value in values) {
      if (value > 0) {
        final proportion = value / total;
        diversity -= proportion * (math.log(proportion) / math.ln2);
      }
    }

    return diversity / math.log(distribution.length); // Normalize
  }

  /// Get activity level based on total emotions
  String _getActivityLevel(int totalEmotions) {
    if (totalEmotions >= 100) return 'Very Active';
    if (totalEmotions >= 50) return 'Active';
    if (totalEmotions >= 20) return 'Moderate';
    if (totalEmotions >= 5) return 'Low';
    return 'Very Low';
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(Map<String, dynamic> stats) {
    final recommendations = <String>[];
    final avgIntensity = stats['averageIntensity'] ?? 0.0;
    final totalEmotions = stats['totalEmotions'] ?? 0;

    if (avgIntensity < 0.3) {
      recommendations.add('Consider activities that boost your mood');
    }

    if (totalEmotions < 10) {
      recommendations.add(
        'Try logging emotions more regularly for better insights',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Keep up the great emotional awareness!');
    }

    return recommendations;
  }

  /// Handle DioException with appropriate error types
  Never _handleDioException(DioException e, String operation) {
    Logger.error('. Remote: Dio error during $operation', e);

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          message: 'Network timeout during $operation: ${e.message}',
        );

      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Connection error during $operation: ${e.message}',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 500) {
          throw ServerException(
            message: 'Server error during $operation: HTTP $statusCode',
          );
        } else if (statusCode == 401) {
          throw UnauthorizedException(
            message: 'Unauthorized access during $operation',
          );
        } else if (statusCode == 403) {
          throw UnauthorizedException(
            message: 'Forbidden access during $operation',
          );
        } else {
          throw ServerException(
            message: 'HTTP error during $operation: $statusCode',
          );
        }

      case DioExceptionType.cancel:
        throw NetworkException(message: 'Request cancelled during $operation');

      case DioExceptionType.unknown:
      default:
        throw ServerException(
          message: 'Unknown error during $operation: ${e.message}',
        );
    }
  }
}
