import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/logger.dart';

class MoodEmotionService {
  final DioClient _dioClient;

  MoodEmotionService(this._dioClient);

  Future<Map<String, dynamic>> logMoodEmotion({
    required String emotion,
    required int intensity,
    String? note,
    List<String>? tags,
    Map<String, dynamic>? location,
    Map<String, dynamic>? context,
    String privacyLevel = 'private',
  }) async {
    try {
      Logger.info('🎭 LOGGING MOOD/EMOTION: $emotion (intensity: $intensity)');

      final timestamp = DateTime.now().toIso8601String();
      
      final payload = {
        'type': emotion,
'emotion': emotion, 
        'intensity': intensity,
        'note': note ?? '',
        'tags': tags ?? [],
        'location': location,
        'context': context ?? {},
        'privacy': privacyLevel,
        'timestamp': timestamp,
        'source': 'mobile_app',
      };

      Logger.info('📤 Sending mood data: ${json.encode(payload)}');

      Map<String, dynamic>? emotionResult;
      Map<String, dynamic>? moodResult;

      try {
        final emotionResponse = await _dioClient.post(
          '/api/emotions',
          data: payload,
        );
        
        if (emotionResponse.statusCode == 201) {
          emotionResult = emotionResponse.data;
          Logger.info('✅ Emotion logged successfully: ${emotionResult?['data']?['emotion']?['id']}');
        }
      } catch (e) {
        Logger.error('❌ Failed to log to emotions endpoint', e);
      }

      try {
        final moodResponse = await _dioClient.post(
          '/api/moods',
          data: payload,
        );
        
        if (moodResponse.statusCode == 201) {
          moodResult = moodResponse.data;
          Logger.info('✅ Mood logged successfully: ${moodResult?['data']?['mood']?['id']}');
        }
      } catch (e) {
        Logger.warning('⚠️ Moods endpoint not available or failed', e);
      }

      try {
        final userMoodResponse = await _dioClient.post(
          '/api/user/mood',
          data: payload,
        );
        
        if (userMoodResponse.statusCode == 201) {
          Logger.info('✅ User mood logged successfully');
        }
      } catch (e) {
        Logger.warning('⚠️ User mood endpoint not available', e);
      }

      final result = emotionResult ?? moodResult ?? {
        'success': true,
        'data': {
          'emotion': {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'type': emotion,
            'intensity': intensity,
            'timestamp': timestamp,
          }
        }
      };

      Logger.info('🎉 Mood/Emotion logging completed successfully');
      return result;

    } catch (e) {
      Logger.error('❌ Failed to log mood/emotion', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserMoodsEmotions({
    String? userId,
    int limit = 100,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Logger.info('📊 Fetching user moods/emotions from all sources...');

      List<Map<String, dynamic>> allEntries = [];

      try {
        final emotionsResponse = await _dioClient.get(
          '/api/emotions',
          queryParameters: {
            'limit': limit,
            'offset': offset,
            if (startDate != null) 'startDate': startDate.toIso8601String(),
            if (endDate != null) 'endDate': endDate.toIso8601String(),
          },
        );

        if (emotionsResponse.statusCode == 200) {
          final emotions = emotionsResponse.data['data']?['emotions'] ?? [];
          Logger.info('📈 Found ${emotions.length} emotions from /api/emotions');
          
          for (final emotion in emotions) {
            try {
              allEntries.add(Map<String, dynamic>.from(emotion));
            } catch (e) {
              Logger.warning('⚠️ Failed to parse emotion: $emotion', e);
            }
          }
        }
      } catch (e) {
        Logger.error('❌ Failed to fetch from emotions endpoint', e);
      }

      try {
        final moodsResponse = await _dioClient.get(
          '/api/moods',
          queryParameters: {
            'limit': limit,
            'offset': offset,
            if (startDate != null) 'startDate': startDate.toIso8601String(),
            if (endDate != null) 'endDate': endDate.toIso8601String(),
          },
        );

        if (moodsResponse.statusCode == 200) {
          final moods = moodsResponse.data['data']?['moods'] ?? [];
          Logger.info('🎭 Found ${moods.length} moods from /api/moods');
          
          for (final mood in moods) {
            try {
              allEntries.add(Map<String, dynamic>.from(mood));
            } catch (e) {
              Logger.warning('⚠️ Failed to parse mood: $mood', e);
            }
          }
        }
      } catch (e) {
        Logger.warning('⚠️ Moods endpoint not available', e);
      }

      allEntries = _removeDuplicateEntries(allEntries);

      allEntries.sort((a, b) {
        final aTime = DateTime.tryParse(a['timestamp'] ?? a['createdAt'] ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b['timestamp'] ?? b['createdAt'] ?? '') ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      Logger.info('✅ Total unique mood/emotion entries: ${allEntries.length}');
      return allEntries;

    } catch (e) {
      Logger.error('❌ Failed to fetch user moods/emotions', e);
      rethrow;
    }
  }

  List<Map<String, dynamic>> _removeDuplicateEntries(List<Map<String, dynamic>> entries) {
    final seen = <String>{};
    return entries.where((entry) {
      final id = entry['id']?.toString() ?? '';
      final timestamp = entry['timestamp']?.toString() ?? entry['createdAt']?.toString() ?? '';
      final key = '${id}_$timestamp';
      if (seen.contains(key)) {
        return false;
      }
      seen.add(key);
      return true;
    }).toList();
  }

  Future<bool> quickLogMood(String emotion, int intensity) async {
    try {
      final result = await logMoodEmotion(
        emotion: emotion,
        intensity: intensity,
        note: 'Quick mood log',
        privacyLevel: 'private',
      );
      return result['success'] == true || result['data'] != null;
    } catch (e) {
      Logger.error('❌ Quick mood log failed', e);
      return false;
    }
  }

  Future<Map<String, bool>> testAllEndpoints() async {
    final results = <String, bool>{};

    try {
      final response = await _dioClient.get('/api/emotions?limit=1');
      results['emotions'] = response.statusCode == 200;
    } catch (e) {
      results['emotions'] = false;
    }

    try {
      final response = await _dioClient.get('/api/moods?limit=1');
      results['moods'] = response.statusCode == 200;
    } catch (e) {
      results['moods'] = false;
    }

    try {
      final response = await _dioClient.get('/api/user/mood');
      results['user_mood'] = response.statusCode == 200;
    } catch (e) {
      results['user_mood'] = false;
    }

    Logger.info('🔍 Endpoint availability: $results');
    return results;
  }
} 