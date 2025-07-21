class WeeklyInsightsModel {
  final String mostCommonMood;
  final double averageMoodScore;
  final int totalEntries;
  final int currentStreak;
  final Map<String, int> moodDistribution;
  final List<String> insights;
  final double weekProgress;
  
  // Enhanced fields for journey analytics
  final int longestStreak;
  final int totalFriends;
  final int helpedFriends;
  final int badgesEarned;
  final String userLevel;
  final String favoriteEmotion;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;
  final DateTime lastActivity;
  final int daysSinceJoined;

  const WeeklyInsightsModel({
    required this.mostCommonMood,
    required this.averageMoodScore,
    required this.totalEntries,
    required this.currentStreak,
    required this.moodDistribution,
    required this.insights,
    required this.weekProgress,
    this.longestStreak = 0,
    this.totalFriends = 0,
    this.helpedFriends = 0,
    this.badgesEarned = 0,
    this.userLevel = 'New Explorer',
    this.favoriteEmotion = '',
    this.weeklyStats = const {},
    this.monthlyStats = const {},
    required this.lastActivity,
    this.daysSinceJoined = 0,
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
      longestStreak: json['longestStreak'] ?? 0,
      totalFriends: json['totalFriends'] ?? 0,
      helpedFriends: json['helpedFriends'] ?? 0,
      badgesEarned: json['badgesEarned'] ?? 0,
      userLevel: json['userLevel'] ?? 'New Explorer',
      favoriteEmotion: json['favoriteEmotion'] ?? '',
      weeklyStats: Map<String, dynamic>.from(json['weeklyStats'] ?? {}),
      monthlyStats: Map<String, dynamic>.from(json['monthlyStats'] ?? {}),
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity']) 
          : DateTime.now(),
      daysSinceJoined: json['daysSinceJoined'] ?? 0,
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
      'longestStreak': longestStreak,
      'totalFriends': totalFriends,
      'helpedFriends': helpedFriends,
      'badgesEarned': badgesEarned,
      'userLevel': userLevel,
      'favoriteEmotion': favoriteEmotion,
      'weeklyStats': weeklyStats,
      'monthlyStats': monthlyStats,
      'lastActivity': lastActivity.toIso8601String(),
      'daysSinceJoined': daysSinceJoined,
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
    int? longestStreak,
    int? totalFriends,
    int? helpedFriends,
    int? badgesEarned,
    String? userLevel,
    String? favoriteEmotion,
    Map<String, dynamic>? weeklyStats,
    Map<String, dynamic>? monthlyStats,
    DateTime? lastActivity,
    int? daysSinceJoined,
  }) {
    return WeeklyInsightsModel(
      mostCommonMood: mostCommonMood ?? this.mostCommonMood,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
      moodDistribution: moodDistribution ?? this.moodDistribution,
      insights: insights ?? this.insights,
      weekProgress: weekProgress ?? this.weekProgress,
      longestStreak: longestStreak ?? this.longestStreak,
      totalFriends: totalFriends ?? this.totalFriends,
      helpedFriends: helpedFriends ?? this.helpedFriends,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      userLevel: userLevel ?? this.userLevel,
      favoriteEmotion: favoriteEmotion ?? this.favoriteEmotion,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      lastActivity: lastActivity ?? this.lastActivity,
      daysSinceJoined: daysSinceJoined ?? this.daysSinceJoined,
    );
  }

  @override
  String toString() {
    return 'WeeklyInsightsModel(mostCommonMood: $mostCommonMood, averageMoodScore: $averageMoodScore, totalEntries: $totalEntries, currentStreak: $currentStreak, weekProgress: $weekProgress, longestStreak: $longestStreak, totalFriends: $totalFriends, badgesEarned: $badgesEarned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyInsightsModel &&
        other.mostCommonMood == mostCommonMood &&
        other.averageMoodScore == averageMoodScore &&
        other.totalEntries == totalEntries &&
        other.currentStreak == currentStreak &&
        other.weekProgress == weekProgress &&
        other.longestStreak == longestStreak &&
        other.totalFriends == totalFriends &&
        other.badgesEarned == badgesEarned;
  }

  @override
  int get hashCode {
    return mostCommonMood.hashCode ^
        averageMoodScore.hashCode ^
        totalEntries.hashCode ^
        currentStreak.hashCode ^
        weekProgress.hashCode ^
        longestStreak.hashCode ^
        totalFriends.hashCode ^
        badgesEarned.hashCode;
  }
} 