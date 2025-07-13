import 'package:dio/dio.dart';

import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/emotion_entry_model.dart';

class EmotionApiService {
  final ApiService _apiService;

  EmotionApiService(this._apiService);

  // Get emotion constants from backend
  Future<Map<String, dynamic>> getEmotionConstants() async {
    try {
      Logger.info('📊 Fetching emotion constants from backend...');
      
      final response = await _apiService.get('/emotions/constants');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        Logger.info('✅ Emotion constants retrieved successfully');
        return data;
      } else {
        throw Exception('Failed to get emotion constants: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting emotion constants: $e');
      rethrow;
    }
  }

  // Log a new emotion entry
  Future<EmotionEntryModel> logEmotion({
    required String emotion,
    required double intensity,
    String? note,
    List<String>? tags,
    Map<String, dynamic>? location,
    Map<String, dynamic>? context,
    String privacyLevel = 'private',
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info('📝 Logging emotion: $emotion (intensity: $intensity)');
      
      final payload = {
        'type': emotion,
        'intensity': intensity.round(),
        'note': note ?? '',
        'tags': tags ?? [],
        'location': location,
        'context': context ?? {},
        'privacyLevel': privacyLevel,
        'isAnonymous': isAnonymous,
      };

      final response = await _apiService.post(
        '/emotions',
        data: payload,
      );
      
      if (response.statusCode == 201) {
        final emotionData = response.data['data']['emotion'];
        final emotionEntry = EmotionEntryModel.fromJson(emotionData);
        
        Logger.info('✅ Emotion logged successfully: ${emotionEntry.id}');
        return emotionEntry;
      } else {
        throw Exception('Failed to log emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error logging emotion: $e');
      rethrow;
    }
  }

  // Get user's emotion history
  Future<List<EmotionEntryModel>> getEmotionHistory({
    int limit = 100,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
    String? emotionType,
    double? minIntensity,
    double? maxIntensity,
  }) async {
    try {
      Logger.info('📊 Fetching emotion history...');
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (emotionType != null) {
        queryParams['type'] = emotionType;
      }
      if (minIntensity != null) {
        queryParams['minIntensity'] = minIntensity;
      }
      if (maxIntensity != null) {
        queryParams['maxIntensity'] = maxIntensity;
      }

      final response = await _apiService.get('/emotions', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final emotionsData = response.data['data']['emotions'] as List;
        final emotions = emotionsData
            .map((data) => EmotionEntryModel.fromJson(data))
            .toList();
        
        Logger.info('✅ Retrieved ${emotions.length} emotions from history');
        return emotions;
      } else {
        throw Exception('Failed to get emotion history: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting emotion history: $e');
      rethrow;
    }
  }

  // Get emotion statistics
  Future<Map<String, dynamic>> getEmotionStats({
    String period = '7d',
  }) async {
    try {
      Logger.info('📊 Fetching emotion statistics for period: $period');
      
      final response = await _apiService.get('/emotions/stats', queryParameters: {
        'period': period,
      });
      
      if (response.statusCode == 200) {
        final stats = response.data['data'];
        Logger.info('✅ Emotion statistics retrieved successfully');
        return stats;
      } else {
        throw Exception('Failed to get emotion stats: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting emotion statistics: $e');
      rethrow;
    }
  }

  // Get user insights
  Future<Map<String, dynamic>> getUserInsights({
    String timeframe = '30d',
  }) async {
    try {
      Logger.info('🧠 Fetching user insights for timeframe: $timeframe');
      
      final response = await _apiService.get('/emotions/insights', queryParameters: {
        'timeframe': timeframe,
      });
      
      if (response.statusCode == 200) {
        final insights = response.data['data'];
        Logger.info('✅ User insights retrieved successfully');
        return insights;
      } else {
        throw Exception('Failed to get user insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting user insights: $e');
      rethrow;
    }
  }

  // Get emotion timeline
  Future<Map<String, dynamic>> getEmotionTimeline({
    String timeframe = '7d',
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Logger.info('📅 Fetching emotion timeline for timeframe: $timeframe');
      
      final response = await _apiService.get('/emotions/timeline', queryParameters: {
        'timeframe': timeframe,
        'page': page,
        'limit': limit,
      });
      
      if (response.statusCode == 200) {
        final timeline = response.data['data'];
        Logger.info('✅ Emotion timeline retrieved successfully');
        return timeline;
      } else {
        throw Exception('Failed to get emotion timeline: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting emotion timeline: $e');
      rethrow;
    }
  }

  // Search emotions
  Future<Map<String, dynamic>> searchEmotions({
    String? query,
    String? emotion,
    String? coreEmotion,
    double? minIntensity,
    double? maxIntensity,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('🔍 Searching emotions...');
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (query != null) queryParams['q'] = query;
      if (emotion != null) queryParams['emotion'] = emotion;
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (minIntensity != null) queryParams['minIntensity'] = minIntensity;
      if (maxIntensity != null) queryParams['maxIntensity'] = maxIntensity;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get('/emotions/search', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final searchResults = response.data['data'];
        Logger.info('✅ Emotion search completed successfully');
        return searchResults;
      } else {
        throw Exception('Failed to search emotions: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error searching emotions: $e');
      rethrow;
    }
  }

  // Update emotion entry
  Future<EmotionEntryModel> updateEmotion({
    required String id,
    String? emotion,
    double? intensity,
    String? note,
    String? privacyLevel,
    Map<String, dynamic>? context,
    Map<String, dynamic>? location,
  }) async {
    try {
      Logger.info('✏️ Updating emotion: $id');
      
      final payload = <String, dynamic>{};
      if (emotion != null) payload['emotion'] = emotion;
      if (intensity != null) payload['intensity'] = intensity;
      if (note != null) payload['note'] = note;
      if (privacyLevel != null) payload['privacyLevel'] = privacyLevel;
      if (context != null) payload['context'] = context;
      if (location != null) payload['location'] = location;

      final response = await _apiService.put(
        '/emotions/$id',
        data: payload,
      );
      
      if (response.statusCode == 200) {
        final emotionData = response.data['data'];
        final emotionEntry = EmotionEntryModel.fromJson(emotionData);
        
        Logger.info('✅ Emotion updated successfully: ${emotionEntry.id}');
        return emotionEntry;
      } else {
        throw Exception('Failed to update emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error updating emotion: $e');
      rethrow;
    }
  }

  // Delete emotion entry
  Future<void> deleteEmotion(String id) async {
    try {
      Logger.info('🗑️ Deleting emotion: $id');
      
      final response = await _apiService.delete('/emotions/$id');
      
      if (response.statusCode == 200) {
        Logger.info('✅ Emotion deleted successfully: $id');
      } else {
        throw Exception('Failed to delete emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error deleting emotion: $e');
      rethrow;
    }
  }

  // Get global emotion statistics
  Future<Map<String, dynamic>> getGlobalStats({
    String timeframe = '7d',
  }) async {
    try {
      Logger.info('🌍 Fetching global emotion statistics for timeframe: $timeframe');
      
      final response = await _apiService.get('/emotions/global/stats', queryParameters: {
        'timeframe': timeframe,
      });
      
      if (response.statusCode == 200) {
        final stats = response.data['data'];
        Logger.info('✅ Global emotion statistics retrieved successfully');
        return stats;
      } else {
        throw Exception('Failed to get global stats: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting global emotion statistics: $e');
      rethrow;
    }
  }

  // Get public emotion feed
  Future<Map<String, dynamic>> getPublicEmotionFeed({
    int page = 1,
    int limit = 20,
    bool friendsOnly = false,
  }) async {
    try {
      Logger.info('📰 Fetching public emotion feed...');
      
      final response = await _apiService.get('/emotions/feed', queryParameters: {
        'page': page,
        'limit': limit,
        'friendsOnly': friendsOnly,
      });
      
      if (response.statusCode == 200) {
        final feed = response.data['data'];
        Logger.info('✅ Public emotion feed retrieved successfully');
        return feed;
      } else {
        throw Exception('Failed to get public emotion feed: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error getting public emotion feed: $e');
      rethrow;
    }
  }

  // Send comfort reaction
  Future<Map<String, dynamic>> sendComfortReaction({
    required String emotionId,
    required String reactionType,
    String? message,
  }) async {
    try {
      Logger.info('💝 Sending comfort reaction to emotion: $emotionId');
      
      final payload = {
        'reactionType': reactionType,
        if (message != null) 'message': message,
      };

      final response = await _apiService.post(
        '/emotions/$emotionId/reactions',
        data: payload,
      );
      
      if (response.statusCode == 201) {
        final reaction = response.data['data'];
        Logger.info('✅ Comfort reaction sent successfully');
        return reaction;
      } else {
        throw Exception('Failed to send comfort reaction: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error sending comfort reaction: $e');
      rethrow;
    }
  }
} 