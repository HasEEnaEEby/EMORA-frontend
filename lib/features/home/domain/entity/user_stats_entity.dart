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
  ];
}
