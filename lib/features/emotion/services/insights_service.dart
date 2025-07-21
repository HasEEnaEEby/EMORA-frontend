// lib/features/emotion/services/insights_service.dart - AI-Powered Emotion Insights
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';

class InsightsService {
  final ApiService _apiService;

  InsightsService(this._apiService);

  /// Get AI-powered region insights
  Future<EmotionInsight> getRegionInsights({
    required String region,
    String timeRange = '7d',
  }) async {
    try {
      print('🔍 InsightsService: Requesting insights for region: "$region"');
      final response = await _apiService.get(
        '/api/map/insights',
        queryParameters: {
          'region': region,
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('📥 InsightsService: Response for "$region": ${data['success']} - ${data['totalEmotions']} emotions');
        if (data['success'] == true) {
          return EmotionInsight.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get region insights');
        }
      } else {
        throw Exception('Failed to get region insights: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting region insights: $e');
      rethrow;
    }
  }

  /// Get global AI insights
  Future<EmotionInsight> getGlobalInsights({
    String timeRange = '7d',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/map/insights/global',
        queryParameters: {
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return EmotionInsight.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get global insights');
        }
      } else {
        throw Exception('Failed to get global insights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting global insights: $e');
      rethrow;
    }
  }

  /// Get emotion trends with AI analysis
  Future<EmotionTrendData> getEmotionTrends({
    String? region,
    String? emotion,
    int days = 7,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'days': days,
      };

      if (region != null) queryParams['region'] = region;
      if (emotion != null) queryParams['emotion'] = emotion;

      final response = await _apiService.get(
        '/api/map/trends',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return EmotionTrendData.fromJson(data);
        } else {
          throw Exception(data['message'] ?? 'Failed to get emotion trends');
        }
      } else {
        throw Exception('Failed to get emotion trends: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting emotion trends: $e');
      rethrow;
    }
  }

  /// Get contextual insight for a specific emotion
  Future<String> getContextualInsight({
    required String emotion,
    required double intensity,
    required Map<String, dynamic> context,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/map/contextual-insight',
        data: {
          'emotion': emotion,
          'intensity': intensity,
          'context': context,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['insight'] ?? 'No insight available';
        } else {
          throw Exception(data['message'] ?? 'Failed to get contextual insight');
        }
      } else {
        throw Exception('Failed to get contextual insight: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting contextual insight: $e');
      return 'Unable to generate insight at this time.';
    }
  }

  /// Get emotion prediction for a region
  Future<String> getEmotionPrediction({
    required String region,
    required List<Map<String, dynamic>> historicalData,
    String timeRange = '7d',
  }) async {
    try {
      final response = await _apiService.post(
        '/api/map/prediction',
        data: {
          'region': region,
          'historicalData': historicalData,
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['prediction'] ?? 'No prediction available';
        } else {
          throw Exception(data['message'] ?? 'Failed to get prediction');
        }
      } else {
        throw Exception('Failed to get prediction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting emotion prediction: $e');
      return 'Unable to generate prediction at this time.';
    }
  }

  /// Get comparative insights between two regions
  Future<Map<String, dynamic>> getComparativeInsights({
    required String region1,
    required String region2,
    String timeRange = '7d',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/map/compare',
        queryParameters: {
          'region1': region1,
          'region2': region2,
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'comparison': data['comparison'],
            'insights': data['insights'],
            'region1': data['region1'],
            'region2': data['region2'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to get comparative insights');
        }
      } else {
        throw Exception('Failed to get comparative insights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting comparative insights: $e');
      rethrow;
    }
  }

  /// Get wellness insights for a region
  Future<Map<String, dynamic>> getWellnessInsights({
    required String region,
    String timeRange = '7d',
  }) async {
    try {
      final response = await _apiService.get(
        '/api/map/wellness',
        queryParameters: {
          'region': region,
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'wellnessScore': data['wellnessScore'],
            'recommendations': data['recommendations'],
            'trends': data['trends'],
            'insights': data['insights'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to get wellness insights');
        }
      } else {
        throw Exception('Failed to get wellness insights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting wellness insights: $e');
      rethrow;
    }
  }
} 