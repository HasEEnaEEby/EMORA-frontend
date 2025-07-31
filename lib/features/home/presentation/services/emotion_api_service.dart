import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';
import '../../data/model/emotion_entry_model.dart';

class EmotionApiService {
  final DioClient _dioClient;

  EmotionApiService(this._dioClient);

  Future<List<EmotionEntryModel>> getUserEmotions({
    String? userId,
    int limit = 100,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    int? minIntensity,
    int? maxIntensity,
  }) async {
    try {
      Logger.info('🎭 Fetching user emotions from backend...');

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
      if (type != null) {
        queryParams['type'] = type;
      }
      if (minIntensity != null) {
        queryParams['minIntensity'] = minIntensity;
      }
      if (maxIntensity != null) {
        queryParams['maxIntensity'] = maxIntensity;
      }

      Logger.info('🔍 DEBUG: Calling emotion history API with params: $queryParams');
      final response = await _dioClient.get(
        '/api/emotions',
        queryParameters: queryParams,
      );

      Logger.info('🔍 DEBUG: API Response Status: ${response.statusCode}');
      Logger.info('🔍 DEBUG: API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final emotions = data['data']?['emotions'] ?? [];

        Logger.info('🔍 DEBUG: Raw emotions data: ${emotions.length} items');
        if (emotions.isNotEmpty) {
          Logger.info('🔍 DEBUG: First emotion: ${emotions.first}');
        }

        final emotionEntries = emotions.map<EmotionEntryModel>((emotion) {
          try {
            return EmotionEntryModel.fromJson(emotion);
          } catch (e) {
            Logger.error('❌ Error parsing emotion: $emotion', e);
            rethrow;
          }
        }).toList();

        Logger.info('✅ Retrieved ${emotionEntries.length} emotions from backend');
        return emotionEntries;
      } else {
        Logger.error('❌ API returned status: ${response.statusCode}');
        throw Exception('Failed to fetch emotions: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch user emotions', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logEmotion({
    required String emotion,
    required int intensity,
    String? note,
    List<String>? tags,
    Map<String, dynamic>? location,
    Map<String, dynamic>? context,
  }) async {
    try {
      Logger.info('🎭 Logging emotion to backend: $emotion');

      final emotionData = {
        'type': emotion,
        'intensity': intensity,
        if (note != null) 'note': note,
        if (tags != null) 'tags': tags,
        if (location != null) 'location': location,
        if (context != null) 'context': context,
      };

      final response = await _dioClient.post(
        '/api/emotions',
        data: emotionData,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        Logger.info('. Emotion logged successfully: ${data['data']?['emotion']?['id']}');
        return data;
      } else {
        throw Exception('Failed to log emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to log emotion', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserEmotionStats({
    String? userId,
    String period = '30d',
  }) async {
    try {
      Logger.info('. Fetching user emotion stats from backend...');

      final response = await _dioClient.get(
        '/api/emotions/stats',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('. Retrieved emotion stats from backend');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch emotion stats: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to fetch emotion stats', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEmotionConstants() async {
    try {
      Logger.info('. Fetching emotion constants from backend...');

      final response = await _dioClient.get('/api/emotions/constants');

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('. Retrieved emotion constants from backend');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch emotion constants: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to fetch emotion constants', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateEmotion({
    required String emotionId,
    String? emotion,
    int? intensity,
    String? note,
    List<String>? tags,
  }) async {
    try {
      Logger.info('✏️ Updating emotion: $emotionId');

      final updateData = <String, dynamic>{};
      if (emotion != null) updateData['type'] = emotion;
      if (intensity != null) updateData['intensity'] = intensity;
      if (note != null) updateData['note'] = note;
      if (tags != null) updateData['tags'] = tags;

      final response = await _dioClient.put(
        '/api/emotions/$emotionId',
        data: updateData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('. Emotion updated successfully');
        return data;
      } else {
        throw Exception('Failed to update emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to update emotion', e);
      rethrow;
    }
  }

  Future<bool> deleteEmotion(String emotionId) async {
    try {
      Logger.info('🗑️ Deleting emotion: $emotionId');

      final response = await _dioClient.delete('/api/emotions/$emotionId');

      if (response.statusCode == 200) {
        Logger.info('. Emotion deleted successfully');
        return true;
      } else {
        throw Exception('Failed to delete emotion: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to delete emotion', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEmotionSummary({
    String period = '7d',
  }) async {
    try {
      Logger.info('📈 Fetching emotion summary from backend...');

      final response = await _dioClient.get(
        '/api/emotions/stats',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('. Retrieved emotion summary from backend');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch emotion summary: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Failed to fetch emotion summary', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWeeklyInsights() async {
    try {
      Logger.info('. Fetching weekly insights from backend...');

      final stats = await getUserEmotionStats(period: '7d');
      
      final recentEmotions = await getUserEmotions(
        limit: 50,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
      );

      final insights = _calculateWeeklyInsights(stats, recentEmotions);

      Logger.info('. Retrieved weekly insights from backend');
      return insights;
    } catch (e) {
      Logger.error('. Failed to fetch weekly insights', e);
      rethrow;
    }
  }

  Future<List<EmotionEntryModel>> getTodaysJourney() async {
    try {
      Logger.info('🌅 Fetching today\'s emotion journey...');

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final emotions = await getUserEmotions(
        startDate: startOfDay,
        endDate: endOfDay,
        limit: 20,
      );

      Logger.info('. Retrieved ${emotions.length} emotions for today');
      return emotions;
    } catch (e) {
      Logger.error('. Failed to fetch today\'s journey', e);
      rethrow;
    }
  }

  Future<Map<String, List<EmotionEntryModel>>> getEmotionCalendar({
    required DateTime month,
  }) async {
    try {
      Logger.info('📅 Fetching emotion calendar data...');

      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      final emotions = await getUserEmotions(
        startDate: startOfMonth,
        endDate: endOfMonth,
        limit: 200,
      );

      final emotionsByDate = <String, List<EmotionEntryModel>>{};
      
      for (final emotion in emotions) {
        final dateKey = '${emotion.createdAt.year}-${emotion.createdAt.month.toString().padLeft(2, '0')}-${emotion.createdAt.day.toString().padLeft(2, '0')}';
        if (!emotionsByDate.containsKey(dateKey)) {
          emotionsByDate[dateKey] = [];
        }
        emotionsByDate[dateKey]!.add(emotion);
      }

      Logger.info('. Retrieved calendar data for ${emotionsByDate.length} days');
      return emotionsByDate;
    } catch (e) {
      Logger.error('. Failed to fetch calendar data', e);
      rethrow;
    }
  }

  Future<bool> checkBackendHealth() async {
    try {
      final response = await _dioClient.healthCheck();
      return response.statusCode == 200;
    } catch (e) {
      Logger.error('. Backend health check failed', e);
      return false;
    }
  }

  Map<String, dynamic> _calculateWeeklyInsights(
    Map<String, dynamic> stats,
    List<EmotionEntryModel> recentEmotions,
  ) {
    final insights = <String>[];
    
    final emotionBreakdown = Map<String, int>.from(stats['emotionBreakdown'] ?? {});
    if (emotionBreakdown.isNotEmpty) {
      final mostCommon = emotionBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add('Your most frequent emotion this week was ${mostCommon.key}');
    }

    final avgIntensity = (stats['averageIntensity'] ?? 0.0).toDouble();
    if (avgIntensity > 4.0) {
      insights.add('You\'ve been experiencing high-intensity emotions this week');
    } else if (avgIntensity < 2.0) {
      insights.add('Your emotions have been relatively calm this week');
    }

    final emotionDiversity = stats['emotionDiversity'] ?? 0;
    if (emotionDiversity > 8) {
      insights.add('You\'ve experienced a wide range of emotions this week');
    } else if (emotionDiversity < 3) {
      insights.add('Your emotional range has been quite focused this week');
    }

    if (recentEmotions.isNotEmpty) {
      final positiveCount = recentEmotions.where((e) => 
        ['joy', 'happiness', 'excitement', 'love', 'gratitude', 'contentment', 
         'pride', 'relief', 'hope', 'enthusiasm', 'serenity', 'bliss']
        .contains(e.emotion.toLowerCase())).length;
      
      final negativeCount = recentEmotions.where((e) => 
        ['sadness', 'anger', 'fear', 'anxiety', 'frustration', 'disappointment', 
         'loneliness', 'stress', 'guilt', 'shame', 'jealousy', 'regret']
        .contains(e.emotion.toLowerCase())).length;

      if (positiveCount > negativeCount * 2) {
        insights.add('You\'ve had more positive than negative emotions this week');
      } else if (negativeCount > positiveCount * 2) {
        insights.add('You\'ve been experiencing more challenging emotions this week');
      }
    }

    return {
      'insights': insights,
      'stats': stats,
      'totalEntries': recentEmotions.length,
      'mostCommonEmotion': emotionBreakdown.isNotEmpty 
          ? emotionBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key 
          : null,
      'averageIntensity': avgIntensity,
      'emotionDiversity': emotionDiversity,
    };
  }
} 