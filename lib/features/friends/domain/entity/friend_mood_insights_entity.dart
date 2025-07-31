
import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';

class FriendMoodInsightsEntity {
  final FriendEntity friend;
  final MoodInsightsEntity insights;
  final String period;

  FriendMoodInsightsEntity({
    required this.friend,
    required this.insights,
    required this.period,
  });

  factory FriendMoodInsightsEntity.fromJson(Map<String, dynamic> json) {
    return FriendMoodInsightsEntity(
      friend: FriendEntity.fromJson(json['friend'] ?? {}),
      insights: MoodInsightsEntity.fromJson(json['insights'] ?? {}),
      period: json['period'] ?? '30 days',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friend': friend.toJson(),
      'insights': insights.toJson(),
      'period': period,
    };
  }
}

class MoodInsightsEntity {
  final int totalMoods;
  final double averageIntensity;
  final Map<String, int> emotionBreakdown;
  final Map<String, int> commonTriggers;
  final Map<String, int> commonCopingStrategies;
  final String moodTrend;
  final List<MoodRecommendationEntity> recommendations;

  MoodInsightsEntity({
    required this.totalMoods,
    required this.averageIntensity,
    required this.emotionBreakdown,
    required this.commonTriggers,
    required this.commonCopingStrategies,
    required this.moodTrend,
    required this.recommendations,
  });

  factory MoodInsightsEntity.fromJson(Map<String, dynamic> json) {
    return MoodInsightsEntity(
      totalMoods: json['totalMoods'] ?? 0,
      averageIntensity: (json['averageIntensity'] ?? 0.0).toDouble(),
      emotionBreakdown: json['emotionBreakdown'] != null
          ? Map<String, int>.from(json['emotionBreakdown'])
          : {},
      commonTriggers: json['commonTriggers'] != null
          ? Map<String, int>.from(json['commonTriggers'])
          : {},
      commonCopingStrategies: json['commonCopingStrategies'] != null
          ? Map<String, int>.from(json['commonCopingStrategies'])
          : {},
      moodTrend: json['moodTrend'] ?? 'stable',
      recommendations: json['recommendations'] != null
          ? (json['recommendations'] as List)
              .map((rec) => MoodRecommendationEntity.fromJson(rec))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMoods': totalMoods,
      'averageIntensity': averageIntensity,
      'emotionBreakdown': emotionBreakdown,
      'commonTriggers': commonTriggers,
      'commonCopingStrategies': commonCopingStrategies,
      'moodTrend': moodTrend,
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
    };
  }

  String get dominantEmotion {
    if (emotionBreakdown.isEmpty) return 'unknown';
    
    final sorted = emotionBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  List<String> get topTriggers {
    final sorted = commonTriggers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> get topCopingStrategies {
    final sorted = commonCopingStrategies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(3).map((e) => e.key).toList();
  }

  bool get needsSupport {
    return dominantEmotion == 'sad' || 
           dominantEmotion == 'anxiety' || 
           dominantEmotion == 'anger';
  }

  double get moodScore {
    const positiveEmotions = ['joy', 'excitement', 'contentment', 'gratitude', 'love', 'hope'];
    const negativeEmotions = ['sadness', 'anger', 'fear', 'anxiety', 'disgust', 'shame'];
    
    double positiveScore = 0;
    double negativeScore = 0;
    int totalMoods = 0;
    
    emotionBreakdown.forEach((emotion, count) {
      totalMoods += count;
      if (positiveEmotions.contains(emotion)) {
        positiveScore += count;
      } else if (negativeEmotions.contains(emotion)) {
        negativeScore += count;
      }
    });
    
if (totalMoods == 0) return 0.5; 
    
    return (positiveScore - negativeScore) / totalMoods;
  }
}

class MoodRecommendationEntity {
  final String type;
  final String message;
  final String priority;

  MoodRecommendationEntity({
    required this.type,
    required this.message,
    required this.priority,
  });

  factory MoodRecommendationEntity.fromJson(Map<String, dynamic> json) {
    return MoodRecommendationEntity(
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'priority': priority,
    };
  }
} 