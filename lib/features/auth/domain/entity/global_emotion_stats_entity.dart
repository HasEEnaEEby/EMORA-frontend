class GlobalEmotionStatsEntity {
  final int totalEmotions;
  final int activeUsers;
  final Map<String, double> emotionDistribution;
  final Map<String, int> topEmotions;
  final String mostCommonEmotion;
  final double averageIntensity;
  final Map<String, dynamic>? trends;
  final DateTime lastUpdated;

  const GlobalEmotionStatsEntity({
    required this.totalEmotions,
    required this.activeUsers,
    required this.emotionDistribution,
    required this.topEmotions,
    required this.mostCommonEmotion,
    required this.averageIntensity,
    this.trends,
    required this.lastUpdated,
  });

  factory GlobalEmotionStatsEntity.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return GlobalEmotionStatsEntity(
      totalEmotions: data['totalEmotions'] ?? 0,
      activeUsers: data['activeUsers'] ?? 0,
      emotionDistribution: Map<String, double>.from(
        data['emotionDistribution'] ?? {},
      ),
      topEmotions: Map<String, int>.from(data['topEmotions'] ?? {}),
      mostCommonEmotion: data['mostCommonEmotion'] ?? 'joy',
      averageIntensity: (data['averageIntensity'] ?? 0.5).toDouble(),
      trends: data['trends'],
      lastUpdated: DateTime.parse(
        data['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmotions': totalEmotions,
      'activeUsers': activeUsers,
      'emotionDistribution': emotionDistribution,
      'topEmotions': topEmotions,
      'mostCommonEmotion': mostCommonEmotion,
      'averageIntensity': averageIntensity,
      'trends': trends,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
