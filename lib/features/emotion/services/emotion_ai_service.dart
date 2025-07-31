import 'dart:math' as math;

class EmotionAIService {
  static const String _baseUrl = 'https://api.emora.ai/v1';
  
  static const Map<String, List<String>> emotionCategories = {
    'positive': ['happiness', 'excitement', 'gratitude', 'contentment', 'love', 'pride'],
    'negative': ['sadness', 'anger', 'fear', 'anxiety', 'frustration', 'disappointment'],
    'neutral': ['calm', 'contemplative', 'focused', 'tired', 'bored'],
    'complex': ['nostalgia', 'anticipation', 'curiosity', 'determination', 'relief']
  };

  
  Future<EmotionAnalysisResult> analyzeText(String text, {
    Map<String, dynamic>? context,
  }) async {
    try {
      final preprocessed = _preprocessText(text);
      
      final bertResult = await _bertEmotionClassification(preprocessed);
      final contextResult = await _contextualAnalysis(preprocessed, context);
      final sentimentResult = await _sentimentIntensityAnalysis(preprocessed);
      
      return _combineAnalysisResults([bertResult, sentimentResult], text);
    } catch (e) {
      return EmotionAnalysisResult.fallback(text);
    }
  }
  
  Future<Map<String, double>> _bertEmotionClassification(String text) async {
    
    final words = text.toLowerCase().split(' ');
    final emotions = <String, double>{};
    
    final positiveWords = ['happy', 'great', 'amazing', 'wonderful', 'love', 'excited'];
    final negativeWords = ['sad', 'angry', 'terrible', 'hate', 'frustrated', 'awful'];
    final anxietyWords = ['worried', 'nervous', 'scared', 'anxious', 'panic'];
    
    double positiveScore = _calculateWordScore(words, positiveWords);
    double negativeScore = _calculateWordScore(words, negativeWords);
    double anxietyScore = _calculateWordScore(words, anxietyWords);
    
    emotions['happiness'] = positiveScore;
    emotions['sadness'] = negativeScore;
    emotions['anxiety'] = anxietyScore;
    emotions['anger'] = negativeScore * 0.7;
    emotions['excitement'] = positiveScore * 0.8;
    emotions['calm'] = 1.0 - (negativeScore + anxietyScore);
    
    return emotions;
  }
  
  double _calculateWordScore(List<String> words, List<String> keywords) {
    double score = 0.0;
    for (String word in words) {
      for (String keyword in keywords) {
        if (word.contains(keyword)) {
          score += 0.2;
        }
      }
    }
    return math.min(1.0, score);
  }

  
  Future<Map<String, dynamic>> _contextualAnalysis(
    String text, 
    Map<String, dynamic>? context,
  ) async {
    final contextFactors = <String, double>{};
    
    if (context != null) {
      final hour = DateTime.now().hour;
      contextFactors['timeOfDay'] = _getTimeContext(hour);
      
      if (context.containsKey('weather')) {
        contextFactors['weather'] = _getWeatherContext(context['weather']);
      }
      
      if (context.containsKey('location')) {
        contextFactors['location'] = _getLocationContext(context['location']);
      }
      
      if (context.containsKey('socialSetting')) {
        contextFactors['social'] = _getSocialContext(context['socialSetting']);
      }
    }
    
    return {
      'contextFactors': contextFactors,
      'adjustedEmotions': _applyContextualAdjustments(text, contextFactors),
    };
  }
  
  double _getTimeContext(int hour) {
    if (hour >= 6 && hour <= 10) return 1.2;
    if (hour >= 18 && hour <= 22) return 0.9;
    if (hour >= 23 || hour <= 5) return 1.1;
    return 1.0;
  }
  
  double _getWeatherContext(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny': return 1.3;
      case 'rainy': return 0.8;
      case 'cloudy': return 0.9;
      case 'stormy': return 0.7;
      default: return 1.0;
    }
  }
  
  double _getLocationContext(Map<String, dynamic> location) {
    final locationType = location['type'] as String?;
    switch (locationType) {
case 'home': return 1.1; 
case 'work': return 0.8; 
case 'social': return 1.2; 
      default: return 1.0;
    }
  }
  
  double _getSocialContext(String socialSetting) {
    switch (socialSetting) {
      case 'alone': return 1.1;
      case 'friends': return 1.2;
      case 'family': return 1.0;
      case 'work': return 0.8;
      default: return 1.0;
    }
  }

  
  Future<List<EmotionCluster>> generateGlobalClusters({
    required List<EmotionDataPoint> emotionData,
    int maxClusters = 10,
  }) async {
    final geoClusters = await _performGeographicClustering(emotionData);
    
    final weightedClusters = _applyTemporalWeighting(geoClusters);
    
    final clustersWithInsights = await _generateClusterInsights(weightedClusters);
    
    return clustersWithInsights;
  }
  
  Future<List<EmotionCluster>> _performGeographicClustering(
    List<EmotionDataPoint> data,
  ) async {
    final clusters = <EmotionCluster>[];
    
    final locationGroups = <String, List<EmotionDataPoint>>{};
    
    for (final point in data) {
      final regionKey = _getRegionKey(point.latitude, point.longitude);
      locationGroups.putIfAbsent(regionKey, () => []).add(point);
    }
    
    for (final entry in locationGroups.entries) {
if (entry.value.length < 5) continue; 
      
      final cluster = await _createEmotionCluster(entry.value, entry.key);
      clusters.add(cluster);
    }
    
    return clusters;
  }
  
  String _getRegionKey(double lat, double lng) {
    final latGrid = (lat).round();
    final lngGrid = (lng).round();
    return '${latGrid}_${lngGrid}';
  }
  
  Future<EmotionCluster> _createEmotionCluster(
    List<EmotionDataPoint> points,
    String regionKey,
  ) async {
    final totalPoints = points.length;
    final centerLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / totalPoints;
    final centerLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / totalPoints;
    
    final emotionCounts = <String, int>{};
    double totalIntensity = 0;
    
    for (final point in points) {
      emotionCounts[point.emotion] = (emotionCounts[point.emotion] ?? 0) + 1;
      totalIntensity += point.intensity;
    }
    
    final dominantEmotion = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    final averageIntensity = totalIntensity / totalPoints;
    
    final insight = await _generateClusterInsight(points, dominantEmotion);
    
    return EmotionCluster(
      id: regionKey,
      centerLatitude: centerLat,
      centerLongitude: centerLng,
      dominantEmotion: dominantEmotion,
      participantCount: totalPoints,
      averageIntensity: averageIntensity,
      aiInsight: insight,
      size: _calculateClusterSize(totalPoints),
      confidence: _calculateConfidence(emotionCounts, totalPoints),
    );
  }

  
  Future<EmotionPrediction> predictEmotionTrends({
    required String userId,
    required List<EmotionDataPoint> historicalData,
    int daysAhead = 7,
  }) async {
    final personalPatterns = await _analyzePersonalPatterns(userId, historicalData);
    
    final globalTrends = await _getGlobalEmotionTrends();
    
    final environmentalFactors = await _getEnvironmentalPredictions(daysAhead);
    
    final predictions = _generatePredictions(
      personalPatterns,
      globalTrends,
      environmentalFactors,
      daysAhead,
    );
    
    return predictions;
  }
  
  Future<PersonalEmotionPatterns> _analyzePersonalPatterns(
    String userId,
    List<EmotionDataPoint> data,
  ) async {
    final weeklyPattern = _analyzeWeeklyPattern(data);
    
    final dailyPattern = _analyzeDailyPattern(data);
    
    final seasonalPattern = _analyzeSeasonalPattern(data);
    
    final triggers = await _identifyEmotionTriggers(data);
    
    return PersonalEmotionPatterns(
      weeklyPattern: weeklyPattern,
      dailyPattern: dailyPattern,
      seasonalPattern: seasonalPattern,
      triggers: triggers,
      confidence: _calculatePatternConfidence(data),
    );
  }

  
  Future<RealTimeInsight> generateRealTimeInsight(
    EmotionDataPoint currentEmotion,
    List<EmotionDataPoint> recentHistory,
  ) async {
    final personalBaseline = _calculatePersonalBaseline(recentHistory);
    final deviationFromNorm = _calculateDeviation(currentEmotion, personalBaseline);
    
    final globalContext = await _getGlobalEmotionalContext();
    
    final recommendations = await _generateRecommendations(
      currentEmotion,
      deviationFromNorm,
      globalContext,
    );
    
    return RealTimeInsight(
      emotion: currentEmotion.emotion,
      intensity: currentEmotion.intensity,
      personalContext: deviationFromNorm,
      globalContext: globalContext,
      recommendations: recommendations,
      timestamp: DateTime.now(),
    );
  }
  
  
  Future<List<Recommendation>> _generateRecommendations(
    EmotionDataPoint emotion,
    DeviationAnalysis deviation,
    GlobalEmotionalContext globalContext,
  ) async {
    final recommendations = <Recommendation>[];
    
    final musicRec = await _generateMusicRecommendation(emotion);
    recommendations.add(musicRec);
    
    final activityRec = await _generateActivityRecommendation(emotion, deviation);
    recommendations.add(activityRec);
    
    if (globalContext.communityMood != emotion.emotion) {
      final socialRec = await _generateSocialRecommendation(emotion, globalContext);
      recommendations.add(socialRec);
    }
    
    if (deviation.isSignificant) {
      final mindfulnessRec = await _generateMindfulnessRecommendation(deviation);
      recommendations.add(mindfulnessRec);
    }
    
    return recommendations;
  }
  
  
  String _preprocessText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  double _calculateClusterSize(int participantCount) {
    return math.min(100, 20 + (math.log(participantCount) * 10));
  }
  
  double _calculateConfidence(Map<String, int> emotionCounts, int totalPoints) {
    final maxCount = emotionCounts.values.reduce(math.max);
    return maxCount / totalPoints;
  }
  
  List<EmotionCluster> _applyTemporalWeighting(List<EmotionCluster> clusters) {
    final now = DateTime.now();
    
    return clusters.map((cluster) {
      final ageInHours = now.difference(cluster.lastUpdated).inHours;
final temporalWeight = math.exp(-ageInHours / 24); 
      
      return cluster.copyWith(
        weight: cluster.weight * temporalWeight,
      );
    }).toList();
  }
  
  Future<String> _generateClusterInsight(
    List<EmotionDataPoint> points,
    String dominantEmotion,
  ) async {
    final timePattern = _analyzeTimePattern(points);
    final intensityPattern = _analyzeIntensityPattern(points);
    
    if (timePattern.isWeekend && dominantEmotion == 'relaxed') {
      return 'Weekend relaxation trend - people are unwinding from the work week';
    } else if (intensityPattern.isHigh && dominantEmotion == 'excited') {
      return 'High-energy excitement spike - possibly related to local events or positive news';
    } else if (timePattern.isEvening && dominantEmotion == 'contemplative') {
      return 'Evening reflection pattern - people processing their day';
    }
    
    return 'Community showing ${dominantEmotion} patterns with ${intensityPattern.description}';
  }

  Future<Map<String, double>> _sentimentIntensityAnalysis(String text) async {
    return {'sentiment': 0.5};
  }
  
  EmotionAnalysisResult _combineAnalysisResults(List<Map<String, double>> results, String text) {
    return EmotionAnalysisResult.fallback(text);
  }
  
  Map<String, double> _applyContextualAdjustments(String text, Map<String, double> contextFactors) {
    return {'adjusted': 0.5};
  }
  
  Future<List<EmotionCluster>> _generateClusterInsights(List<EmotionCluster> clusters) async {
    return clusters;
  }
  
  Future<GlobalEmotionTrends> _getGlobalEmotionTrends() async {
    return GlobalEmotionTrends(trends: []);
  }
  
  Future<EnvironmentalFactors> _getEnvironmentalPredictions(int daysAhead) async {
    return EnvironmentalFactors(factors: {});
  }
  
  EmotionPrediction _generatePredictions(
    PersonalEmotionPatterns personalPatterns,
    GlobalEmotionTrends globalTrends,
    EnvironmentalFactors environmentalFactors,
    int daysAhead,
  ) {
    return EmotionPrediction(
      dailyForecasts: [],
      potentialTriggers: [],
      preemptiveRecommendations: [],
      confidence: 0.5,
    );
  }
  
  Map<String, double> _analyzeWeeklyPattern(List<EmotionDataPoint> data) {
    return {};
  }
  
  Map<int, double> _analyzeDailyPattern(List<EmotionDataPoint> data) {
    return {};
  }
  
  Map<String, double> _analyzeSeasonalPattern(List<EmotionDataPoint> data) {
    return {};
  }
  
  Future<List<EmotionTrigger>> _identifyEmotionTriggers(List<EmotionDataPoint> data) async {
    return [];
  }
  
  double _calculatePatternConfidence(List<EmotionDataPoint> data) {
    return 0.5;
  }
  
  PersonalBaseline _calculatePersonalBaseline(List<EmotionDataPoint> recentHistory) {
    return PersonalBaseline(averageIntensity: 0.5, dominantEmotion: 'neutral');
  }
  
  DeviationAnalysis _calculateDeviation(EmotionDataPoint currentEmotion, PersonalBaseline baseline) {
    return DeviationAnalysis(deviation: 0.0, isSignificant: false);
  }
  
  Future<GlobalEmotionalContext> _getGlobalEmotionalContext() async {
    return GlobalEmotionalContext(communityMood: 'neutral', globalIntensity: 0.5);
  }
  
  Future<Recommendation> _generateMusicRecommendation(EmotionDataPoint emotion) async {
    return Recommendation(
      type: 'music',
      title: 'Music Recommendation',
      description: 'Based on your current emotion',
      actionUrl: '',
      relevanceScore: 0.8,
    );
  }
  
  Future<Recommendation> _generateActivityRecommendation(EmotionDataPoint emotion, DeviationAnalysis deviation) async {
    return Recommendation(
      type: 'activity',
      title: 'Activity Recommendation',
      description: 'Based on your current emotion',
      actionUrl: '',
      relevanceScore: 0.8,
    );
  }
  
  Future<Recommendation> _generateSocialRecommendation(EmotionDataPoint emotion, GlobalEmotionalContext globalContext) async {
    return Recommendation(
      type: 'social',
      title: 'Social Recommendation',
      description: 'Based on your current emotion',
      actionUrl: '',
      relevanceScore: 0.8,
    );
  }
  
  Future<Recommendation> _generateMindfulnessRecommendation(DeviationAnalysis deviation) async {
    return Recommendation(
      type: 'mindfulness',
      title: 'Mindfulness Recommendation',
      description: 'Based on your emotional deviation',
      actionUrl: '',
      relevanceScore: 0.8,
    );
  }
  
  TimePattern _analyzeTimePattern(List<EmotionDataPoint> points) {
    return TimePattern(isWeekend: false, isEvening: false);
  }
  
  IntensityPattern _analyzeIntensityPattern(List<EmotionDataPoint> points) {
    return IntensityPattern(isHigh: false, description: 'moderate');
  }
}


class EmotionAnalysisResult {
  final String primaryEmotion;
  final double confidence;
  final Map<String, double> emotionScores;
  final Map<String, dynamic> contextualFactors;
  final List<String> detectedKeywords;
  final double sentimentIntensity;
  
  EmotionAnalysisResult({
    required this.primaryEmotion,
    required this.confidence,
    required this.emotionScores,
    required this.contextualFactors,
    required this.detectedKeywords,
    required this.sentimentIntensity,
  });
  
  factory EmotionAnalysisResult.fallback(String text) {
    return EmotionAnalysisResult(
      primaryEmotion: 'neutral',
      confidence: 0.5,
      emotionScores: {'neutral': 1.0},
      contextualFactors: {},
      detectedKeywords: [],
      sentimentIntensity: 0.0,
    );
  }
}

class EmotionCluster {
  final String id;
  final double centerLatitude;
  final double centerLongitude;
  final String dominantEmotion;
  final int participantCount;
  final double averageIntensity;
  final String aiInsight;
  final double size;
  final double confidence;
  final double weight;
  final DateTime lastUpdated;
  
  EmotionCluster({
    required this.id,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.dominantEmotion,
    required this.participantCount,
    required this.averageIntensity,
    required this.aiInsight,
    required this.size,
    required this.confidence,
    this.weight = 1.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
  
  EmotionCluster copyWith({
    double? weight,
    DateTime? lastUpdated,
  }) {
    return EmotionCluster(
      id: id,
      centerLatitude: centerLatitude,
      centerLongitude: centerLongitude,
      dominantEmotion: dominantEmotion,
      participantCount: participantCount,
      averageIntensity: averageIntensity,
      aiInsight: aiInsight,
      size: size,
      confidence: confidence,
      weight: weight ?? this.weight,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class EmotionDataPoint {
  final String userId;
  final String emotion;
  final double intensity;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  
  EmotionDataPoint({
    required this.userId,
    required this.emotion,
    required this.intensity,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.context,
  });
}

class EmotionPrediction {
  final List<DailyEmotionForecast> dailyForecasts;
  final List<String> potentialTriggers;
  final List<Recommendation> preemptiveRecommendations;
  final double confidence;
  
  EmotionPrediction({
    required this.dailyForecasts,
    required this.potentialTriggers,
    required this.preemptiveRecommendations,
    required this.confidence,
  });
}

class PersonalEmotionPatterns {
  final Map<String, double> weeklyPattern;
  final Map<int, double> dailyPattern;
  final Map<String, double> seasonalPattern;
  final List<EmotionTrigger> triggers;
  final double confidence;
  
  PersonalEmotionPatterns({
    required this.weeklyPattern,
    required this.dailyPattern,
    required this.seasonalPattern,
    required this.triggers,
    required this.confidence,
  });
}

class RealTimeInsight {
  final String emotion;
  final double intensity;
  final DeviationAnalysis personalContext;
  final GlobalEmotionalContext globalContext;
  final List<Recommendation> recommendations;
  final DateTime timestamp;
  
  RealTimeInsight({
    required this.emotion,
    required this.intensity,
    required this.personalContext,
    required this.globalContext,
    required this.recommendations,
    required this.timestamp,
  });
}

class Recommendation {
  final String type;
  final String title;
  final String description;
  final String actionUrl;
  final double relevanceScore;
  
  Recommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.actionUrl,
    required this.relevanceScore,
  });
}

class GlobalEmotionTrends {
  final List<EmotionTrend> trends;
  
  GlobalEmotionTrends({required this.trends});
}

class EmotionTrend {
  final String emotion;
  final double changePercentage;
  final bool isRising;
  
  EmotionTrend({
    required this.emotion,
    required this.changePercentage,
    required this.isRising,
  });
}

class EnvironmentalFactors {
  final Map<String, double> factors;
  
  EnvironmentalFactors({required this.factors});
}

class EmotionTrigger {
  final String trigger;
  final String emotion;
  final double intensity;
  
  EmotionTrigger({
    required this.trigger,
    required this.emotion,
    required this.intensity,
  });
}

class PersonalBaseline {
  final double averageIntensity;
  final String dominantEmotion;
  
  PersonalBaseline({
    required this.averageIntensity,
    required this.dominantEmotion,
  });
}

class DeviationAnalysis {
  final double deviation;
  final bool isSignificant;
  
  DeviationAnalysis({
    required this.deviation,
    required this.isSignificant,
  });
}

class GlobalEmotionalContext {
  final String communityMood;
  final double globalIntensity;
  
  GlobalEmotionalContext({
    required this.communityMood,
    required this.globalIntensity,
  });
}

class DailyEmotionForecast {
  final DateTime date;
  final String predictedEmotion;
  final double confidence;
  
  DailyEmotionForecast({
    required this.date,
    required this.predictedEmotion,
    required this.confidence,
  });
}

class TimePattern {
  final bool isWeekend;
  final bool isEvening;
  
  TimePattern({
    required this.isWeekend,
    required this.isEvening,
  });
}

class IntensityPattern {
  final bool isHigh;
  final String description;
  
  IntensityPattern({
    required this.isHigh,
    required this.description,
  });
} 