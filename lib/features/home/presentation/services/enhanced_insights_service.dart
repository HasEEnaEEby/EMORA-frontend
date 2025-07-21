import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';

class EnhancedInsightsService {
  final DioClient _dioClient;

  EnhancedInsightsService(this._dioClient);

  Future<Map<String, dynamic>> getEnhancedInsights({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('📊 Fetching enhanced insights from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/insights',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('Enhanced insights retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch enhanced insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Failed to fetch enhanced insights', e);
      rethrow;
    }
  }

  /// Get emotion analytics for charts
  Future<Map<String, dynamic>> getEmotionAnalytics({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('📈 Fetching emotion analytics from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/analytics',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Emotion analytics retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch emotion analytics: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch emotion analytics', e);
      rethrow;
    }
  }

  /// Get AI-powered insights and patterns
  Future<Map<String, dynamic>> getAIInsights({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🤖 Fetching AI insights from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/ai-insights',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ AI insights retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch AI insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch AI insights', e);
      rethrow;
    }
  }

  /// Get predictive analytics
  Future<Map<String, dynamic>> getPredictiveAnalytics({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🔮 Fetching predictive analytics from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/predictions',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Predictive analytics retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch predictive analytics: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch predictive analytics', e);
      rethrow;
    }
  }

  /// Get pattern analysis
  Future<Map<String, dynamic>> getPatternAnalysis({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🔍 Fetching pattern analysis from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/patterns',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Pattern analysis retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch pattern analysis: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch pattern analysis', e);
      rethrow;
    }
  }

  /// Get recommendations based on emotion data
  Future<Map<String, dynamic>> getRecommendations({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('💡 Fetching recommendations from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/recommendations',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Recommendations retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch recommendations: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch recommendations', e);
      rethrow;
    }
  }

  /// Get emotion history for a specific period
  Future<List<EmotionEntryModel>> getEmotionHistory({
    required String timeframe,
    String? userId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      Logger.info('📜 Fetching emotion history from backend for timeframe: $timeframe');

      // Calculate date range based on timeframe
      final now = DateTime.now();
      DateTime startDate;
      
      switch (timeframe) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'quarter':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }

      final response = await _dioClient.get(
        '/api/emotions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'startDate': startDate.toIso8601String(),
          'endDate': now.toIso8601String(),
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final emotions = data['data']?['emotions'] ?? [];

        final emotionEntries = emotions.map<EmotionEntryModel>((emotion) {
          return EmotionEntryModel.fromJson(emotion);
        }).toList();

        Logger.info('✅ Retrieved ${emotionEntries.length} emotion entries for timeframe: $timeframe');
        return emotionEntries;
      } else {
        throw Exception('Failed to fetch emotion history: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch emotion history', e);
      rethrow;
    }
  }

  /// Get comprehensive insights data in a single call
  Future<Map<String, dynamic>> getComprehensiveInsights({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🎯 Fetching comprehensive insights from backend for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/comprehensive-insights',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Comprehensive insights retrieved successfully');
        return data['data'] ?? {};
      } else {
        throw Exception('Failed to fetch comprehensive insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch comprehensive insights', e);
      rethrow;
    }
  }
} 