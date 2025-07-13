class WeeklyInsightsModel {
  final String mostCommonMood;
  final double averageMoodScore;
  final int totalEntries;
  final int currentStreak;
  final Map<String, int> moodDistribution;
  final List<String> insights;
  final double weekProgress;

  const WeeklyInsightsModel({
    required this.mostCommonMood,
    required this.averageMoodScore,
    required this.totalEntries,
    required this.currentStreak,
    required this.moodDistribution,
    required this.insights,
    required this.weekProgress,
  });

  factory WeeklyInsightsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsModel(
      mostCommonMood: json['mostCommonMood'] ?? 'neutral',
      averageMoodScore: (json['averageMoodScore'] ?? 3.0).toDouble(),
      totalEntries: json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      moodDistribution: Map<String, int>.from(json['moodDistribution'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
      weekProgress: (json['weekProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mostCommonMood': mostCommonMood,
      'averageMoodScore': averageMoodScore,
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'moodDistribution': moodDistribution,
      'insights': insights,
      'weekProgress': weekProgress,
    };
  }

  WeeklyInsightsModel copyWith({
    String? mostCommonMood,
    double? averageMoodScore,
    int? totalEntries,
    int? currentStreak,
    Map<String, int>? moodDistribution,
    List<String>? insights,
    double? weekProgress,
  }) {
    return WeeklyInsightsModel(
      mostCommonMood: mostCommonMood ?? this.mostCommonMood,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      insights: insights ?? this.insights,
      weekProgress: weekProgress ?? this.weekProgress,
    );
  }

  @override
  String toString() {
    return 'WeeklyInsightsModel(mostCommonMood: $mostCommonMood, averageMoodScore: $averageMoodScore, totalEntries: $totalEntries, currentStreak: $currentStreak, weekProgress: $weekProgress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyInsightsModel &&
        other.mostCommonMood == mostCommonMood &&
        other.averageMoodScore == averageMoodScore &&
        other.totalEntries == totalEntries &&
        other.currentStreak == currentStreak &&
        other.weekProgress == weekProgress;
  }

  @override
  int get hashCode {
    return mostCommonMood.hashCode ^
        averageMoodScore.hashCode ^
        totalEntries.hashCode ^
        currentStreak.hashCode ^
        weekProgress.hashCode;
  }
} 