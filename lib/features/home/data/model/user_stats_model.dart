import 'package:equatable/equatable.dart';

import '../../domain/entity/user_stats_entity.dart';

class UserStatsModel extends Equatable {
  final int totalMoodEntries;
  final int streakDays;
  final int totalSessions;
  final int moodCheckins;
  final double averageMoodScore;
  final String mostFrequentMood;
  final DateTime lastMoodLog;
  final Map<String, dynamic> weeklyStats;
  final Map<String, dynamic> monthlyStats;

  const UserStatsModel({
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

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalMoodEntries: json['totalMoodEntries'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      moodCheckins: json['moodCheckins'] ?? 0,
      averageMoodScore: (json['averageMoodScore'] ?? 0.0).toDouble(),
      mostFrequentMood: json['mostFrequentMood'] ?? 'neutral',
      lastMoodLog:
          DateTime.tryParse(json['lastMoodLog'] ?? '') ?? DateTime.now(),
      weeklyStats: Map<String, dynamic>.from(json['weeklyStats'] ?? {}),
      monthlyStats: Map<String, dynamic>.from(json['monthlyStats'] ?? {}),
    );
  }

  factory UserStatsModel.fromEntity(UserStatsEntity entity) {
    return UserStatsModel(
      totalMoodEntries: entity.totalMoodEntries,
      streakDays: entity.streakDays,
      totalSessions: entity.totalSessions,
      moodCheckins: entity.moodCheckins,
      averageMoodScore: entity.averageMoodScore,
      mostFrequentMood: entity.mostFrequentMood,
      lastMoodLog: entity.lastMoodLog,
      weeklyStats: entity.weeklyStats,
      monthlyStats: entity.monthlyStats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMoodEntries': totalMoodEntries,
      'streakDays': streakDays,
      'totalSessions': totalSessions,
      'moodCheckins': moodCheckins,
      'averageMoodScore': averageMoodScore,
      'mostFrequentMood': mostFrequentMood,
      'lastMoodLog': lastMoodLog.toIso8601String(),
      'weeklyStats': weeklyStats,
      'monthlyStats': monthlyStats,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  UserStatsEntity toEntity() {
    return UserStatsEntity(
      totalMoodEntries: totalMoodEntries,
      streakDays: streakDays,
      totalSessions: totalSessions,
      moodCheckins: moodCheckins,
      averageMoodScore: averageMoodScore,
      mostFrequentMood: mostFrequentMood,
      lastMoodLog: lastMoodLog,
      weeklyStats: weeklyStats,
      monthlyStats: monthlyStats,
    );
  }

  UserStatsModel copyWith({
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
    return UserStatsModel(
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
