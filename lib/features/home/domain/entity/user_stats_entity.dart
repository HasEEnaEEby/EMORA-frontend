import 'package:equatable/equatable.dart';

class UserStatsEntity extends Equatable {
  final int totalMoodEntries;
  final int streakDays;
  final int totalSessions;
  final int moodCheckins;
  final double averageMoodScore;
  final String mostFrequentMood;
  final DateTime lastMoodLog;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;
  
  // Enhanced fields for journey analytics
  final int longestStreak;
  final int totalFriends;
  final int helpedFriends;
  final int badgesEarned;
  final String userLevel;
  final String favoriteEmotion;
  final int daysSinceJoined;
  final DateTime lastActivity;
  final Map<String, dynamic> comprehensiveStats;
  final Map<String, dynamic> achievements;

  const UserStatsEntity({
    required this.totalMoodEntries,
    required this.streakDays,
    required this.totalSessions,
    required this.moodCheckins,
    required this.averageMoodScore,
    required this.mostFrequentMood,
    required this.lastMoodLog,
    required this.weeklyStats,
    required this.monthlyStats,
    this.longestStreak = 0,
    this.totalFriends = 0,
    this.helpedFriends = 0,
    this.badgesEarned = 0,
    this.userLevel = 'New Explorer',
    this.favoriteEmotion = '',
    this.daysSinceJoined = 0,
    required this.lastActivity,
    this.comprehensiveStats = const {},
    this.achievements = const {},
  });

  UserStatsEntity copyWith({
    int? totalMoodEntries,
    int? streakDays,
    int? totalSessions,
    int? moodCheckins,
    double? averageMoodScore,
    String? mostFrequentMood,
    DateTime? lastMoodLog,
    Map<String, dynamic>? weeklyStats,
    Map<String, dynamic>? monthlyStats,
    int? longestStreak,
    int? totalFriends,
    int? helpedFriends,
    int? badgesEarned,
    String? userLevel,
    String? favoriteEmotion,
    int? daysSinceJoined,
    DateTime? lastActivity,
    Map<String, dynamic>? comprehensiveStats,
    Map<String, dynamic>? achievements,
  }) {
    return UserStatsEntity(
      totalMoodEntries: totalMoodEntries ?? this.totalMoodEntries,
      streakDays: streakDays ?? this.streakDays,
      totalSessions: totalSessions ?? this.totalSessions,
      moodCheckins: moodCheckins ?? this.moodCheckins,
      averageMoodScore: averageMoodScore ?? this.averageMoodScore,
      mostFrequentMood: mostFrequentMood ?? this.mostFrequentMood,
      lastMoodLog: lastMoodLog ?? this.lastMoodLog,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      longestStreak: longestStreak ?? this.longestStreak,
      totalFriends: totalFriends ?? this.totalFriends,
      helpedFriends: helpedFriends ?? this.helpedFriends,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      userLevel: userLevel ?? this.userLevel,
      favoriteEmotion: favoriteEmotion ?? this.favoriteEmotion,
      daysSinceJoined: daysSinceJoined ?? this.daysSinceJoined,
      lastActivity: lastActivity ?? this.lastActivity,
      comprehensiveStats: comprehensiveStats ?? this.comprehensiveStats,
      achievements: achievements ?? this.achievements,
    );
  }

  @override
  List<Object?> get props => [
    totalMoodEntries,
    streakDays,
    totalSessions,
    moodCheckins,
    averageMoodScore,
    mostFrequentMood,
    lastMoodLog,
    weeklyStats,
    monthlyStats,
    longestStreak,
    totalFriends,
    helpedFriends,
    badgesEarned,
    userLevel,
    favoriteEmotion,
    daysSinceJoined,
    lastActivity,
    comprehensiveStats,
    achievements,
  ];
}
