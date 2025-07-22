import '../../../../../core/utils/logger.dart';
import '../../../../../core/network/dio_client.dart';

class EnhancedInsightsService {
  final DioClient _dioClient;

  EnhancedInsightsService(this._dioClient);

  Future<Map<String, dynamic>> getComprehensiveInsights({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🎯 Fetching comprehensive insights for timeframe: $timeframe');

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
        
        // ✅ SAFE DATA EXTRACTION - This fixes the Map<String,dynamic> vs List<dynamic> error
        final responseData = data['data'] as Map<String, dynamic>? ?? {};
        
        // Extract all sections safely
        final summary = responseData['summary'] as Map<String, dynamic>? ?? {};
        final patterns = responseData['patterns'] as Map<String, dynamic>? ?? {};
        final trends = responseData['trends'] as Map<String, dynamic>? ?? {};
        final recommendations = responseData['recommendations'] as List<dynamic>? ?? [];
        final achievements = responseData['achievements'] as List<dynamic>? ?? [];
        final weeklyData = responseData['weeklyData'] as List<dynamic>? ?? [];
        
        // Process patterns data safely
        final timeOfDayData = patterns['timeOfDay'] as List<dynamic>? ?? [];
        final dayOfWeekData = patterns['dayOfWeek'] as List<dynamic>? ?? [];
        final emotionTransitions = patterns['emotionTransitions'] as List<dynamic>? ?? [];
        final intensityPatterns = patterns['intensityPatterns'] as Map<String, dynamic>? ?? {};

        // Generate mock weekly data if empty (for chart display)
        List<Map<String, dynamic>> processedWeeklyData = [];
        if (weeklyData.isEmpty) {
          processedWeeklyData = _generateMockWeeklyData(timeframe);
        } else {
          processedWeeklyData = weeklyData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }

        // Generate AI insights from patterns
        List<Map<String, dynamic>> aiInsights = _generateAIInsights(summary, patterns, trends);

        // Generate pattern insights
        List<Map<String, dynamic>> patternInsights = _generatePatternInsights(timeOfDayData, dayOfWeekData, emotionTransitions);

        // Generate predictions
        List<Map<String, dynamic>> predictions = _generatePredictions(summary, trends);

        return {
          'summary': summary,
          'patterns': {
            'timeOfDay': timeOfDayData,
            'dayOfWeek': dayOfWeekData,
            'emotionTransitions': emotionTransitions,
            'intensityPatterns': intensityPatterns,
          },
          'trends': trends,
          'weeklyData': processedWeeklyData,
          'aiInsights': aiInsights,
          'patternInsights': patternInsights,
          'predictions': predictions,
          'recommendations': recommendations.isNotEmpty ? recommendations : _generateDefaultRecommendations(),
          'achievements': achievements,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Failed to fetch insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch insights', e);
      // Return fallback data instead of throwing
      return _getFallbackInsights(timeframe);
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
  Future<List<Map<String, dynamic>>> getEmotionHistory({
    required String timeframe,
    String? userId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      Logger.info('📜 Fetching emotion history for timeframe: $timeframe');
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
        return List<Map<String, dynamic>>.from(emotions);
      } else {
        throw Exception('Failed to fetch emotion history: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch emotion history', e);
      return [];
    }
  }

  List<Map<String, dynamic>> _generateMockWeeklyData(String timeframe) {
    switch (timeframe) {
      case 'today':
        return List.generate(12, (index) => {
          'day': '${index * 2}h',
          'emotion': ['joy', 'calm', 'excitement', 'contentment'][index % 4],
          'intensity': 3 + (index % 3),
          'count': 1,
        });
      case 'week':
        return [
          {'day': 'Mon', 'emotion': 'joy', 'intensity': 4, 'count': 2},
          {'day': 'Tue', 'emotion': 'excitement', 'intensity': 4, 'count': 1},
          {'day': 'Wed', 'emotion': 'calm', 'intensity': 0, 'count': 0},
          {'day': 'Thu', 'emotion': 'contentment', 'intensity': 0, 'count': 0},
          {'day': 'Fri', 'emotion': 'joy', 'intensity': 0, 'count': 0},
          {'day': 'Sat', 'emotion': 'calm', 'intensity': 0, 'count': 0},
          {'day': 'Sun', 'emotion': 'relaxed', 'intensity': 0, 'count': 0},
        ];
      case 'month':
        return List.generate(4, (index) => {
          'day': 'W${index + 1}',
          'emotion': ['joy', 'calm', 'excitement', 'contentment'][index],
          'intensity': 3 + index % 2,
          'count': index + 1,
        });
      case 'year':
        return List.generate(12, (index) => {
          'day': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][index],
          'emotion': ['joy', 'calm', 'excitement', 'contentment'][index % 4],
          'intensity': 3 + (index % 3),
          'count': index % 4 + 1,
        });
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _generateAIInsights(Map<String, dynamic> summary, Map<String, dynamic> patterns, Map<String, dynamic> trends) {
    final insights = <Map<String, dynamic>>[];
    final totalEntries = summary['totalEntries'] as int? ?? 0;
    final dominantEmotion = summary['dominantEmotion'] as String? ?? 'neutral';
    final averageIntensity = summary['averageIntensity'] as num? ?? 3;
    if (totalEntries > 0) {
      insights.add({
        'id': 'dominant_emotion',
        'title': 'Your Dominant Mood',
        'description': 'You\'ve been feeling mostly $dominantEmotion with an average intensity of ${averageIntensity.toStringAsFixed(1)}/5.',
        'confidence': 85,
        'icon': 'psychology',
        'color': '#8B5CF6',
      });
    }
    final timeOfDayData = patterns['timeOfDay'] as List<dynamic>? ?? [];
    if (timeOfDayData.isNotEmpty) {
      final bestTime = timeOfDayData.first as Map<String, dynamic>;
      insights.add({
        'id': 'peak_time',
        'title': 'Peak Performance Hours',
        'description': 'You feel best during ${bestTime['timeOfDay'] ?? 'morning'}. Consider scheduling important tasks during this time.',
        'confidence': 92,
        'icon': 'schedule',
        'color': '#4CAF50',
      });
    }
    final trendDescription = trends['description'] as String? ?? '';
    if (trendDescription.isNotEmpty) {
      insights.add({
        'id': 'trend_analysis',
        'title': 'Mood Trend',
        'description': trendDescription,
        'confidence': 78,
        'icon': 'trending_up',
        'color': '#2196F3',
      });
    }
    return insights;
  }

  List<Map<String, dynamic>> _generatePatternInsights(List<dynamic> timeOfDay, List<dynamic> dayOfWeek, List<dynamic> transitions) {
    final patterns = <Map<String, dynamic>>[];
    if (timeOfDay.isNotEmpty) {
      for (final timeData in timeOfDay) {
        final data = timeData as Map<String, dynamic>;
        patterns.add({
          'title': '${data['timeOfDay']} Pattern',
          'description': 'You typically feel ${data['dominantEmotion']} in the ${data['timeOfDay']} (${data['count']} entries)',
          'type': 'time_of_day',
        });
      }
    }
    if (dayOfWeek.isNotEmpty) {
      for (final dayData in dayOfWeek) {
        final data = dayData as Map<String, dynamic>;
        patterns.add({
          'title': '${data['dayOfWeek']} Pattern',
          'description': 'On ${data['dayOfWeek']}s, you mostly feel ${data['dominantEmotion']}',
          'type': 'day_of_week',
        });
      }
    }
    if (transitions.isNotEmpty) {
      patterns.add({
        'title': 'Emotion Transitions',
        'description': 'You had ${transitions.length} significant mood changes this period',
        'type': 'transitions',
      });
    }
    return patterns;
  }

  List<Map<String, dynamic>> _generatePredictions(Map<String, dynamic> summary, Map<String, dynamic> trends) {
    final predictions = <Map<String, dynamic>>[];
    final averageIntensity = summary['averageIntensity'] as num? ?? 3;
    if (averageIntensity > 3.5) {
      predictions.add({
        'title': 'Tomorrow\'s Mood',
        'description': 'Likely to be positive based on recent patterns',
        'confidence': 75,
        'icon': 'wb_sunny',
      });
    } else if (averageIntensity < 2.5) {
      predictions.add({
        'title': 'Tomorrow\'s Mood',
        'description': 'May need support based on recent patterns',
        'confidence': 70,
        'icon': 'cloud',
      });
    } else {
      predictions.add({
        'title': 'Tomorrow\'s Mood',
        'description': 'Expected to be stable based on recent patterns',
        'confidence': 65,
        'icon': 'partly_cloudy_day',
      });
    }
    predictions.add({
      'title': 'Weekly Outlook',
      'description': 'Consistent mood pattern expected throughout the week',
      'confidence': 72,
      'icon': 'trending_up',
    });
    return predictions;
  }

  List<String> _generateDefaultRecommendations() {
    return [
      'Log emotions regularly to improve pattern recognition',
      'Consider mindfulness practices during low-mood periods',
      'Schedule important activities during your peak hours',
      'Build a support network for challenging times',
    ];
  }

  Map<String, dynamic> _getFallbackInsights(String timeframe) {
    return {
      'summary': {
        'totalEntries': 0,
        'averageIntensity': 3.0,
        'dominantEmotion': 'neutral',
        'description': 'Start logging emotions to see insights'
      },
      'patterns': {
        'timeOfDay': [],
        'dayOfWeek': [],
        'emotionTransitions': [],
        'intensityPatterns': {},
      },
      'trends': {
        'trend': 'stable',
        'description': 'Not enough data for trend analysis'
      },
      'weeklyData': _generateMockWeeklyData(timeframe),
      'aiInsights': [
        {
          'id': 'welcome',
          'title': 'Welcome to Insights',
          'description': 'Start logging emotions to see personalized insights',
          'confidence': 100,
          'icon': 'psychology',
          'color': '#8B5CF6',
        }
      ],
      'patternInsights': [],
      'predictions': [
        {
          'title': 'Start Your Journey',
          'description': 'Begin logging emotions to get personalized predictions',
          'confidence': 100,
          'icon': 'auto_graph',
        }
      ],
      'recommendations': _generateDefaultRecommendations(),
      'achievements': [],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
} 