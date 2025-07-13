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

  // Enhanced factory constructor with safe type handling
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserStatsModel(
        totalMoodEntries: _safeInt(json['totalMoodEntries']),
        streakDays: _safeInt(json['streakDays']),
        totalSessions: _safeInt(json['totalSessions']),
        moodCheckins: _safeInt(json['moodCheckins']),
        averageMoodScore: _safeDouble(json['averageMoodScore']),
        mostFrequentMood: _safeString(json['mostFrequentMood']),
        lastMoodLog: _parseDateTime(json['lastMoodLog']),
        weeklyStats: _parseMap(json['weeklyStats']),
        monthlyStats: _parseMap(json['monthlyStats']),
      );
    } catch (e) {
      return UserStatsModel.empty();
    }
  }

  // Create an empty/default instance for fallback
  factory UserStatsModel.empty() {
    return UserStatsModel(
      totalMoodEntries: 0,
      streakDays: 0,
      totalSessions: 0,
      moodCheckins: 0,
      averageMoodScore: 0.0,
      mostFrequentMood: 'neutral',
      lastMoodLog: DateTime.now(),
      weeklyStats: {},
      monthlyStats: {},
    );
  }

  // Safe type conversion methods
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _safeString(dynamic value) {
    if (value == null) return 'neutral';
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    try {
      if (value == null) return {};
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return {};
    } catch (e) {
      return {};
    }
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
