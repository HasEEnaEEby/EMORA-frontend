// gemini.service.dart - Enhanced AI Service for Global Emotion Insights
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with actual API key
  
  // Enhanced prompt templates for different use cases
  static const Map<String, String> _promptTemplates = {
    'regional_summary': '''
Analyze the emotional data for {region} and provide insights:

Emotion Data:
- Total emotions: {totalEmotions}
- Dominant emotion: {dominantEmotion}
- Average intensity: {avgIntensity}/5
- Top emotions: {topEmotions}
- Recent trends: {recentTrends}

Provide a concise, engaging summary (2-3 sentences) that explains:
1. What the emotional climate is like in this region
2. Any notable patterns or insights
3. What might be influencing these emotions

Make it conversational and insightful, as if explaining to someone interested in human psychology and social trends.
''',

    'global_trends': '''
Analyze global emotional trends and provide insights:

Global Data:
- Total emotions tracked: {totalEmotions}
- Global average intensity: {avgIntensity}/5
- Dominant global emotion: {dominantEmotion}
- Regional breakdown: {regionalBreakdown}
- Time period: {timePeriod}

Provide a brief analysis (2-3 sentences) about:
1. What the global emotional climate reveals
2. Any interesting patterns or shifts
3. What this might indicate about human well-being worldwide

Make it insightful and accessible to general audiences.
''',

    'emotion_cluster_analysis': '''
Analyze this emotion cluster and provide insights:

Cluster Data:
- Location: {location}
- Core emotion: {coreEmotion}
- Number of people: {count}
- Average intensity: {avgIntensity}/5
- Emotion types: {emotionTypes}
- Time period: {timePeriod}

Provide a brief, engaging explanation (2-3 sentences) about:
1. What this cluster of emotions suggests about the area
2. Possible factors influencing these emotions
3. What makes this pattern interesting or notable

Make it conversational and insightful.
''',

    'personal_insight': '''
Based on the user's emotional data, provide personalized insights:

User Data:
- Recent emotions: {recentEmotions}
- Average intensity: {avgIntensity}/5
- Emotional patterns: {patterns}
- Global context: {globalContext}

Provide a brief, encouraging insight (2-3 sentences) about:
1. What their emotional patterns reveal
2. How they compare to global trends
3. A positive or constructive observation

Make it supportive and insightful, focusing on emotional intelligence and growth.
''',

    'weather_metaphor': '''
Create an emotional weather report metaphor for {region}:

Emotion Data:
- Dominant emotion: {dominantEmotion}
- Intensity level: {intensity}/5
- Recent changes: {changes}
- Overall climate: {climate}

Describe the emotional weather in this region using weather metaphors (e.g., "sunny with scattered joy," "overcast with pockets of anxiety"). Make it engaging and relatable, like a weather forecast but for emotions.

Keep it to 2-3 sentences maximum.
''',
  };

  // Generate regional emotion summary
  static Future<String> generateRegionalSummary({
    required String region,
    required int totalEmotions,
    required String dominantEmotion,
    required double avgIntensity,
    required List<String> topEmotions,
    required List<String> recentTrends,
  }) async {
    try {
      final prompt = _promptTemplates['regional_summary']!
          .replaceAll('{region}', region)
          .replaceAll('{totalEmotions}', totalEmotions.toString())
          .replaceAll('{dominantEmotion}', dominantEmotion)
          .replaceAll('{avgIntensity}', avgIntensity.toStringAsFixed(1))
          .replaceAll('{topEmotions}', topEmotions.join(', '))
          .replaceAll('{recentTrends}', recentTrends.join(', '));

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      return _generateFallbackRegionalSummary(region, dominantEmotion, avgIntensity);
    }
  }

  // Generate global trends analysis
  static Future<String> generateGlobalTrends({
    required int totalEmotions,
    required double avgIntensity,
    required String dominantEmotion,
    required Map<String, dynamic> regionalBreakdown,
    required String timePeriod,
  }) async {
    try {
      final prompt = _promptTemplates['global_trends']!
          .replaceAll('{totalEmotions}', totalEmotions.toString())
          .replaceAll('{avgIntensity}', avgIntensity.toStringAsFixed(1))
          .replaceAll('{dominantEmotion}', dominantEmotion)
          .replaceAll('{regionalBreakdown}', regionalBreakdown.toString())
          .replaceAll('{timePeriod}', timePeriod);

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      return _generateFallbackGlobalTrends(dominantEmotion, avgIntensity);
    }
  }

  // Generate emotion cluster analysis
  static Future<String> generateClusterAnalysis({
    required String location,
    required String coreEmotion,
    required int count,
    required double avgIntensity,
    required List<String> emotionTypes,
    required String timePeriod,
  }) async {
    try {
      final prompt = _promptTemplates['emotion_cluster_analysis']!
          .replaceAll('{location}', location)
          .replaceAll('{coreEmotion}', coreEmotion)
          .replaceAll('{count}', count.toString())
          .replaceAll('{avgIntensity}', avgIntensity.toStringAsFixed(1))
          .replaceAll('{emotionTypes}', emotionTypes.join(', '))
          .replaceAll('{timePeriod}', timePeriod);

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      return _generateFallbackClusterAnalysis(location, coreEmotion, count);
    }
  }

  // Generate personal emotional insight
  static Future<String> generatePersonalInsight({
    required List<String> recentEmotions,
    required double avgIntensity,
    required Map<String, dynamic> patterns,
    required Map<String, dynamic> globalContext,
  }) async {
    try {
      final prompt = _promptTemplates['personal_insight']!
          .replaceAll('{recentEmotions}', recentEmotions.join(', '))
          .replaceAll('{avgIntensity}', avgIntensity.toStringAsFixed(1))
          .replaceAll('{patterns}', patterns.toString())
          .replaceAll('{globalContext}', globalContext.toString());

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      return _generateFallbackPersonalInsight(recentEmotions, avgIntensity);
    }
  }

  // Generate emotional weather metaphor
  static Future<String> generateEmotionalWeather({
    required String region,
    required String dominantEmotion,
    required double intensity,
    required List<String> changes,
    required String climate,
  }) async {
    try {
      final prompt = _promptTemplates['weather_metaphor']!
          .replaceAll('{region}', region)
          .replaceAll('{dominantEmotion}', dominantEmotion)
          .replaceAll('{intensity}', intensity.toStringAsFixed(1))
          .replaceAll('{changes}', changes.join(', '))
          .replaceAll('{climate}', climate);

      final response = await _generateContent(prompt);
      return response;
    } catch (e) {
      return _generateFallbackEmotionalWeather(region, dominantEmotion, intensity);
    }
  }

  // Core API call method
  static Future<String> _generateContent(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 150,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final candidates = data['candidates'] as List<dynamic>? ?? [];
      if (candidates.isNotEmpty) {
        final parts = candidates.first['content']['parts'] as List<dynamic>? ?? [];
        if (parts.isNotEmpty) {
          return parts.first['text'] as String? ?? '';
        }
      }
    }

    throw Exception('Failed to generate content: ${response.statusCode}');
  }

  // Fallback methods for when API is unavailable
  static String _generateFallbackRegionalSummary(String region, String dominantEmotion, double avgIntensity) {
    final emotionEmoji = PlutchikCoreEmotion.getEmoji(dominantEmotion);
    final intensityLevel = avgIntensity >= 4.0 ? 'high' : avgIntensity >= 3.0 ? 'moderate' : 'low';
    
    return '$region is experiencing a $intensityLevel level of $dominantEmotion $emotionEmoji right now. This suggests a ${_getEmotionContext(dominantEmotion)} emotional climate in the area.';
  }

  static String _generateFallbackGlobalTrends(String dominantEmotion, double avgIntensity) {
    final emotionEmoji = PlutchikCoreEmotion.getEmoji(dominantEmotion);
    final globalMood = avgIntensity >= 4.0 ? 'positive' : avgIntensity >= 3.0 ? 'balanced' : 'challenging';
    
    return 'Globally, $dominantEmotion $emotionEmoji is the dominant emotion, indicating a $globalMood emotional climate worldwide. This reflects the current state of human well-being across different regions.';
  }

  static String _generateFallbackClusterAnalysis(String location, String coreEmotion, int count) {
    final emotionEmoji = PlutchikCoreEmotion.getEmoji(coreEmotion);
    final clusterSize = count > 20 ? 'large' : count > 10 ? 'moderate' : 'small';
    
    return 'A $clusterSize cluster of $coreEmotion $emotionEmoji emotions has formed in $location, suggesting a shared emotional experience among people in this area. This pattern indicates ${_getEmotionContext(coreEmotion)}.';
  }

  static String _generateFallbackPersonalInsight(List<String> recentEmotions, double avgIntensity) {
    final mostRecent = recentEmotions.isNotEmpty ? recentEmotions.first : 'neutral';
    final emotionEmoji = PlutchikCoreEmotion.getEmoji(mostRecent);
    final intensityLevel = avgIntensity >= 4.0 ? 'strong' : avgIntensity >= 3.0 ? 'moderate' : 'mild';
    
    return 'Your recent emotional pattern shows $mostRecent $emotionEmoji with $intensityLevel intensity. This suggests you\'re experiencing ${_getEmotionContext(mostRecent)} in your daily life.';
  }

  static String _generateFallbackEmotionalWeather(String region, String dominantEmotion, double intensity) {
    final emotionEmoji = PlutchikCoreEmotion.getEmoji(dominantEmotion);
    final weatherType = _getWeatherForEmotion(dominantEmotion, intensity);
    
    return 'The emotional weather in $region is $weatherType with $dominantEmotion $emotionEmoji prevailing. This creates a ${_getEmotionContext(dominantEmotion)} atmosphere in the area.';
  }

  // Helper methods for fallback generation
  static String _getEmotionContext(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return 'uplifting and positive';
      case 'trust': return 'connected and supportive';
      case 'fear': return 'anxious and uncertain';
      case 'surprise': return 'curious and alert';
      case 'sadness': return 'reflective and somber';
      case 'disgust': return 'critical and cautious';
      case 'anger': return 'intense and passionate';
      case 'anticipation': return 'hopeful and forward-looking';
      default: return 'balanced and stable';
    }
  }

  static String _getWeatherForEmotion(String emotion, double intensity) {
    final intensityModifier = intensity >= 4.0 ? 'intense' : intensity >= 3.0 ? 'moderate' : 'light';
    
    switch (emotion.toLowerCase()) {
      case 'joy': return '$intensityModifier sunny';
      case 'trust': return '$intensityModifier clear skies';
      case 'fear': return '$intensityModifier stormy';
      case 'surprise': return '$intensityModifier partly cloudy';
      case 'sadness': return '$intensityModifier overcast';
      case 'disgust': return '$intensityModifier foggy';
      case 'anger': return '$intensityModifier thunderous';
      case 'anticipation': return '$intensityModifier dawn-like';
      default: return '$intensityModifier calm';
    }
  }

  // Enhanced methods for specific use cases
  static Future<String> generateEmotionInsight({
    required GlobalEmotionPoint point,
    required GlobalEmotionStats? globalStats,
  }) async {
    final globalContext = globalStats != null ? {
      'dominantGlobal': globalStats.dominantEmotion,
      'globalIntensity': globalStats.avgIntensity,
      'totalGlobal': globalStats.totalEmotions,
    } : {};

    return generateClusterAnalysis(
      location: point.displayName,
      coreEmotion: point.coreEmotion,
      count: point.count,
      avgIntensity: point.avgIntensity,
      emotionTypes: point.emotionTypes,
      timePeriod: 'recent',
    );
  }

  static Future<String> generateRegionalComparison({
    required String region1,
    required String region2,
    required Map<String, dynamic> region1Data,
    required Map<String, dynamic> region2Data,
  }) async {
    final prompt = '''
Compare the emotional climates of $region1 and $region2:

$region1:
- Dominant emotion: ${region1Data['dominantEmotion']}
- Average intensity: ${region1Data['avgIntensity']}/5
- Total emotions: ${region1Data['totalEmotions']}

$region2:
- Dominant emotion: ${region2Data['dominantEmotion']}
- Average intensity: ${region2Data['avgIntensity']}/5
- Total emotions: ${region2Data['totalEmotions']}

Provide a brief comparison (2-3 sentences) highlighting the key differences and what they might indicate about the emotional well-being in these regions.
''';

    try {
      return await _generateContent(prompt);
    } catch (e) {
      return _generateFallbackRegionalComparison(region1, region2, region1Data, region2Data);
    }
  }

  static String _generateFallbackRegionalComparison(
    String region1,
    String region2,
    Map<String, dynamic> region1Data,
    Map<String, dynamic> region2Data,
  ) {
    final emotion1 = region1Data['dominantEmotion'] as String;
    final emotion2 = region2Data['dominantEmotion'] as String;
    final emoji1 = PlutchikCoreEmotion.getEmoji(emotion1);
    final emoji2 = PlutchikCoreEmotion.getEmoji(emotion2);

    return '$region1 shows $emotion1 $emoji1 while $region2 experiences $emotion2 $emoji2, indicating different emotional climates in these regions. This suggests varying social and environmental factors influencing emotional well-being.';
  }

  // Method to generate insights for the Gemini Summary Modal
  static Future<Map<String, String>> generateComprehensiveInsights({
    required String region,
    required GlobalEmotionStats? globalStats,
    required List<GlobalEmotionPoint> localPoints,
    required List<EmotionCluster> clusters,
  }) async {
    final insights = <String, String>{};

    try {
      // Regional summary
      if (localPoints.isNotEmpty) {
        final dominantEmotion = _getDominantEmotion(localPoints);
        final avgIntensity = _calculateAverageIntensity(localPoints);
        final totalEmotions = localPoints.fold(0, (sum, point) => sum + point.count);
        final topEmotions = _getTopEmotions(localPoints);

        insights['regional_summary'] = await generateRegionalSummary(
          region: region,
          totalEmotions: totalEmotions,
          dominantEmotion: dominantEmotion,
          avgIntensity: avgIntensity,
          topEmotions: topEmotions,
          recentTrends: ['recent activity'],
        );
      }

      // Global context
      if (globalStats != null) {
        insights['global_context'] = await generateGlobalTrends(
          totalEmotions: globalStats.totalEmotions,
          avgIntensity: globalStats.avgIntensity,
          dominantEmotion: globalStats.dominantEmotion,
          regionalBreakdown: {},
          timePeriod: 'recent',
        );
      }

      // Emotional weather
      if (localPoints.isNotEmpty) {
        final dominantEmotion = _getDominantEmotion(localPoints);
        final avgIntensity = _calculateAverageIntensity(localPoints);

        insights['emotional_weather'] = await generateEmotionalWeather(
          region: region,
          dominantEmotion: dominantEmotion,
          intensity: avgIntensity,
          changes: ['recent changes'],
          climate: 'current',
        );
      }

      // Cluster insights
      if (clusters.isNotEmpty) {
        final largestCluster = clusters.reduce((a, b) => a.count > b.count ? a : b);
        insights['cluster_insight'] = await generateClusterAnalysis(
          location: largestCluster.displayName,
          coreEmotion: largestCluster.coreEmotion,
          count: largestCluster.count,
          avgIntensity: largestCluster.avgIntensity,
          emotionTypes: largestCluster.emotionTypes,
          timePeriod: 'recent',
        );
      }
    } catch (e) {
      // Generate fallback insights
      insights['regional_summary'] = _generateFallbackRegionalSummary(
        region, 'joy', 3.5);
      insights['global_context'] = _generateFallbackGlobalTrends('joy', 3.5);
      insights['emotional_weather'] = _generateFallbackEmotionalWeather(
        region, 'joy', 3.5);
    }

    return insights;
  }

  // Helper methods for data processing
  static String _getDominantEmotion(List<GlobalEmotionPoint> points) {
    final emotionCounts = <String, int>{};
    for (final point in points) {
      emotionCounts[point.coreEmotion] = (emotionCounts[point.coreEmotion] ?? 0) + point.count;
    }
    
    String dominant = 'joy';
    int maxCount = 0;
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = emotion;
      }
    });
    
    return dominant;
  }

  static double _calculateAverageIntensity(List<GlobalEmotionPoint> points) {
    if (points.isEmpty) return 0.0;
    
    double totalIntensity = 0.0;
    int totalCount = 0;
    
    for (final point in points) {
      totalIntensity += point.avgIntensity * point.count;
      totalCount += point.count;
    }
    
    return totalCount > 0 ? totalIntensity / totalCount : 0.0;
  }

  static List<String> _getTopEmotions(List<GlobalEmotionPoint> points) {
    final emotionCounts = <String, int>{};
    for (final point in points) {
      emotionCounts[point.coreEmotion] = (emotionCounts[point.coreEmotion] ?? 0) + point.count;
    }
    
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEmotions.take(3).map((e) => e.key).toList();
  }
} 