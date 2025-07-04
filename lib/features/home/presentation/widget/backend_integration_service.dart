import 'dart:developer' as dev;

import 'package:emora_mobile_app/features/auth/domain/entity/emotion_entry_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/global_emotion_map_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/global_emotion_stats_entity.dart';

import '../../../../core/network/dio_client.dart';

class EmotionBackendService {
  final DioClient _dioClient;

  const EmotionBackendService(this._dioClient);

  Future<bool> logEmotionEntry({
    required String userId,
    required String emotion,
    required double intensity,
    String? journalText,
    String? location,
    String? trigger,
    String? socialContext,
    String? activity,
    List<String>? tags,
    bool isPrivate = false,
    bool isShared = false,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/emotions/users/$userId/log',
        data: {
          'emotion': emotion,
          'intensity': intensity,
          'context': {
            'trigger': trigger ?? journalText,
            'socialContext': socialContext ?? 'alone',
            'activity': activity ?? 'other',
            'weather': 'unknown',
          },
          'memory': {
            'description': journalText,
            'tags': tags ?? [],
            'isPrivate': isPrivate,
          },
          'globalSharing': {'isShared': isShared},
          'source': 'mobile',
          if (location != null) 'location': location,
        },
      );

      dev.log('Emotion logged: ${response.statusCode}', name: 'EmotionService');
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      dev.log('Error logging emotion: $e', name: 'EmotionService');
      return false;
    }
  }

  /// Get user's emotion journey
  Future<List<EmotionEntryEntity>> getEmotionJourney(
    String userId, {
    int days = 30,
    String format = 'unified',
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/emotions/users/$userId/journey',
        queryParameters: {'days': days, 'format': format},
      );

      dev.log(
        'Journey response: ${response.statusCode}',
        name: 'EmotionService',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> emotions = data['data'] ?? [];
        return emotions
            .map((json) => EmotionEntryEntity.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      dev.log('Error fetching emotion journey: $e', name: 'EmotionService');
      return [];
    }
  }

  /// Get global emotion statistics
  Future<GlobalEmotionStatsEntity?> getGlobalEmotionStats({
    String timeframe = '24h',
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/emotions/global-stats',
        queryParameters: {'timeframe': timeframe},
      );

      dev.log(
        'Global stats response: ${response.statusCode}',
        name: 'EmotionService',
      );

      if (response.statusCode == 200) {
        return GlobalEmotionStatsEntity.fromJson(response.data);
      }

      return null;
    } catch (e) {
      dev.log('Error fetching global stats: $e', name: 'EmotionService');
      return null;
    }
  }

  /// Get real-time global emotion map data
  Future<List<GlobalEmotionMapEntity>> getGlobalEmotionMap({
    Map<String, dynamic>? bounds,
    Map<String, String>? timeRange,
    String format = 'unified',
  }) async {
    try {
      final queryParams = <String, dynamic>{'format': format};

      if (bounds != null) {
        queryParams['bounds'] = bounds;
      }
      if (timeRange != null) {
        queryParams['timeRange'] = timeRange;
      }

      final response = await _dioClient.get(
        '/api/emotions/global-heatmap',
        queryParameters: queryParams,
      );

      dev.log(
        'Global map response: ${response.statusCode}',
        name: 'EmotionService',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> locations =
            data['data']?['heatmapData'] ?? data['locations'] ?? [];
        return locations
            .map((json) => GlobalEmotionMapEntity.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      dev.log('Error fetching global emotion map: $e', name: 'EmotionService');
      return [];
    }
  }

  /// Get emotion feed (anonymous)
  Future<List<EmotionEntryEntity>> getEmotionFeed({
    int limit = 10,
    int offset = 0,
    String? emotion,
    String? coreEmotion,
    String format = 'unified',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'format': format,
      };

      if (emotion != null) queryParams['emotion'] = emotion;
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;

      final response = await _dioClient.get(
        '/api/emotions/feed',
        queryParameters: queryParams,
      );

      dev.log(
        'Emotion feed response: ${response.statusCode}',
        name: 'EmotionService',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns: { success: true, message: "...", data: emotionsArray, meta: pagination }
        final List<dynamic> emotions = data['data'] ?? [];
        return emotions
            .map((json) => EmotionEntryEntity.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      dev.log('Error fetching emotion feed: $e', name: 'EmotionService');
      return [];
    }
  }

  /// Submit venting session (anonymous)
  Future<bool> submitVentingSession({
    required String sessionId,
    required int duration,
    required String emotionBefore,
    String? emotionAfter,
    Map<String, double>? intensity,
    String? thoughts,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/emotions/vent',
        data: {
          'sessionId': sessionId,
          'duration': duration,
          'emotionBefore': emotionBefore,
          'emotionAfter': emotionAfter,
          'intensity': intensity ?? {'before': 0.8, 'after': 0.3},
          'thoughts': thoughts,
        },
      );

      dev.log(
        'Venting session response: ${response.statusCode}',
        name: 'EmotionService',
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      dev.log('Error submitting venting session: $e', name: 'EmotionService');
      return false;
    }
  }

  /// Get user emotion insights
  Future<Map<String, dynamic>?> getUserEmotionInsights(
    String userId, {
    String timeframe = '30d',
  }) async {
    try {
      final response = await _dioClient.get(
        '/api/emotions/users/$userId/insights',
        queryParameters: {'timeframe': timeframe},
      );

      dev.log(
        'User insights response: ${response.statusCode}',
        name: 'EmotionService',
      );

      if (response.statusCode == 200) {
        return response.data['data'] ?? response.data;
      }

      return null;
    } catch (e) {
      dev.log('Error fetching user insights: $e', name: 'EmotionService');
      return null;
    }
  }

  /// Update emotion entry
  Future<bool> updateEmotionEntry({
    required String emotionId,
    String? emotion,
    double? intensity,
    String? memoryDescription,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (emotion != null) updateData['emotion'] = emotion;
      if (intensity != null) updateData['intensity'] = intensity;
      if (memoryDescription != null) {
        updateData['memory'] = {'description': memoryDescription};
      }

      final response = await _dioClient.put(
        '/api/emotions/$emotionId',
        data: updateData,
      );

      dev.log(
        'Update emotion response: ${response.statusCode}',
        name: 'EmotionService',
      );
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Error updating emotion: $e', name: 'EmotionService');
      return false;
    }
  }

  /// Delete emotion entry
  Future<bool> deleteEmotionEntry(String emotionId) async {
    try {
      final response = await _dioClient.delete('/api/emotions/$emotionId');

      dev.log(
        'Delete emotion response: ${response.statusCode}',
        name: 'EmotionService',
      );
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Error deleting emotion: $e', name: 'EmotionService');
      return false;
    }
  }

  /// Health check
  Future<bool> checkBackendHealth() async {
    try {
      final response = await _dioClient.get('/api/health');
      dev.log(
        'Health check response: ${response.statusCode}',
        name: 'EmotionService',
      );
      return response.statusCode == 200;
    } catch (e) {
      dev.log('Backend health check failed: $e', name: 'EmotionService');
      return false;
    }
  }
}
