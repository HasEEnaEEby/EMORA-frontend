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

  UserStatsModel({
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
  }) {
    // Add runtime validation
    assert(longestStreak != null, 'longestStreak cannot be null');
    assert(totalFriends != null, 'totalFriends cannot be null');
    assert(helpedFriends != null, 'helpedFriends cannot be null');
    assert(badgesEarned != null, 'badgesEarned cannot be null');
  }

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
        longestStreak: _safeInt(json['longestStreak']),
        totalFriends: _safeInt(json['totalFriends']),
        helpedFriends: _safeInt(json['helpedFriends']),
        badgesEarned: _safeInt(json['badgesEarned']),
        userLevel: _safeString(json['userLevel']),
        favoriteEmotion: _safeString(json['favoriteEmotion']),
        daysSinceJoined: _safeInt(json['daysSinceJoined']),
        lastActivity: _parseDateTime(json['lastActivity']),
        comprehensiveStats: _parseMap(json['comprehensiveStats']),
        achievements: _parseMap(json['achievements']),
      );
    } catch (e) {
      print('❌ Error creating UserStatsModel from JSON: $e');
      print('❌ JSON data: $json');
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
      longestStreak: 0,
      totalFriends: 0,
      helpedFriends: 0,
      badgesEarned: 0,
      userLevel: 'New Explorer',
      favoriteEmotion: '',
      daysSinceJoined: 0,
      lastActivity: DateTime.now(),
      comprehensiveStats: {},
      achievements: {},
    );
  }

  // Safe type conversion methods
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    print('⚠️ _safeInt received unexpected type: ${value.runtimeType} for value: $value');
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
    try {
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
        longestStreak: entity.longestStreak,
        totalFriends: entity.totalFriends,
        helpedFriends: entity.helpedFriends,
        badgesEarned: entity.badgesEarned,
        userLevel: entity.userLevel,
        favoriteEmotion: entity.favoriteEmotion,
        daysSinceJoined: entity.daysSinceJoined,
        lastActivity: entity.lastActivity,
        comprehensiveStats: entity.comprehensiveStats,
        achievements: entity.achievements,
      );
    } catch (e) {
      print('❌ Error creating UserStatsModel from Entity: $e');
      print('❌ Entity longestStreak: ${entity.longestStreak}');
      return UserStatsModel.empty();
    }
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
      'longestStreak': longestStreak,
      'totalFriends': totalFriends,
      'helpedFriends': helpedFriends,
      'badgesEarned': badgesEarned,
      'userLevel': userLevel,
      'favoriteEmotion': favoriteEmotion,
      'daysSinceJoined': daysSinceJoined,
      'lastActivity': lastActivity.toIso8601String(),
      'comprehensiveStats': comprehensiveStats,
      'achievements': achievements,
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
      longestStreak: longestStreak,
      totalFriends: totalFriends,
      helpedFriends: helpedFriends,
      badgesEarned: badgesEarned,
      userLevel: userLevel,
      favoriteEmotion: favoriteEmotion,
      daysSinceJoined: daysSinceJoined,
      lastActivity: lastActivity,
      comprehensiveStats: comprehensiveStats,
      achievements: achievements,
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
