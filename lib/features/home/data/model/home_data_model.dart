import 'package:equatable/equatable.dart';

import '../../domain/entity/home_data_entity.dart';
import 'user_stats_model.dart';

class HomeDataModel extends Equatable {
  final String username;
  final String? currentMood;
  final int streak;
  final bool isFirstTimeLogin;
  final UserStatsModel userStats;
  final String? selectedAvatar;
  final Map<String, dynamic> dashboardData;
  final DateTime lastUpdated;

  const HomeDataModel({
    required this.username,
    this.currentMood,
    required this.streak,
    required this.isFirstTimeLogin,
    required this.userStats,
    this.selectedAvatar,
    required this.dashboardData,
    required this.lastUpdated,
  });

  // Enhanced factory constructor with safe type handling
  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    try {
      return HomeDataModel(
        username: _safeString(json['username']) ?? 'Unknown',
        currentMood: _safeString(json['currentMood']),
        streak: _safeInt(json['streak']) ?? 0,
        isFirstTimeLogin: _safeBool(json['isFirstTimeLogin']) ?? true,
        userStats: _parseUserStats(json['userStats']),
        selectedAvatar: _safeString(json['selectedAvatar']),
        dashboardData: _parseDashboardData(json['dashboardData']),
        lastUpdated: _parseDateTime(json['lastUpdated']) ?? DateTime.now(),
      );
    } catch (e) {
      // Return safe defaults if parsing fails
      return HomeDataModel(
        username: 'Unknown',
        currentMood: 'neutral',
        streak: 0,
        isFirstTimeLogin: true,
        userStats: UserStatsModel.empty(),
        selectedAvatar: 'default',
        dashboardData: {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  // CRITICAL: Mock factory method that was missing
  factory HomeDataModel.mock({String? username, String? avatar}) {
    return HomeDataModel(
      username: username ?? 'testuser',
      currentMood: 'neutral',
      streak: 0,
      isFirstTimeLogin: false,
      userStats: UserStatsModel.empty(),
      selectedAvatar: avatar ?? 'elephant',
      dashboardData: {},
      lastUpdated: DateTime.now(),
    );
  }

  // Convert from Entity to Model (for clean architecture)
  factory HomeDataModel.fromEntity(HomeDataEntity entity) {
    return HomeDataModel(
      username: entity.username,
      currentMood: entity.currentMood,
      streak: entity.streak,
      isFirstTimeLogin: entity.isFirstTimeLogin,
      userStats: UserStatsModel.fromEntity(entity.userStats),
      selectedAvatar: entity.selectedAvatar,
      dashboardData: entity.dashboardData,
      lastUpdated: entity.lastUpdated,
    );
  }

  // Safe type conversion methods
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  static UserStatsModel _parseUserStats(dynamic statsData) {
    try {
      if (statsData == null) return UserStatsModel.empty();

      if (statsData is Map<String, dynamic>) {
        return UserStatsModel.fromJson(statsData);
      }

      if (statsData is UserStatsModel) return statsData;

      // Try to convert if it's a different type of Map
      if (statsData is Map) {
        return UserStatsModel.fromJson(Map<String, dynamic>.from(statsData));
      }

      return UserStatsModel.empty();
    } catch (e) {
      return UserStatsModel.empty();
    }
  }

  static Map<String, dynamic> _parseDashboardData(dynamic dashboardData) {
    try {
      if (dashboardData == null) return {};

      if (dashboardData is Map<String, dynamic>) {
        return dashboardData;
      }

      if (dashboardData is Map) {
        return Map<String, dynamic>.from(dashboardData);
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  static DateTime _parseDateTime(dynamic dateData) {
    try {
      if (dateData == null) return DateTime.now();

      if (dateData is DateTime) return dateData;

      if (dateData is String && dateData.isNotEmpty) {
        return DateTime.tryParse(dateData) ?? DateTime.now();
      }

      if (dateData is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateData);
      }

      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'currentMood': currentMood,
      'streak': streak,
      'isFirstTimeLogin': isFirstTimeLogin,
      'userStats': userStats.toJson(),
      'selectedAvatar': selectedAvatar,
      'dashboardData': dashboardData,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  HomeDataEntity toEntity() {
    return HomeDataEntity(
      username: username,
      currentMood: currentMood,
      streak: streak,
      isFirstTimeLogin: isFirstTimeLogin,
      userStats: userStats.toEntity(),
      selectedAvatar: selectedAvatar,
      dashboardData: dashboardData,
      lastUpdated: lastUpdated,
    );
  }

  HomeDataModel copyWith({
    String? username,
    String? currentMood,
    int? streak,
    bool? isFirstTimeLogin,
    UserStatsModel? userStats,
    String? selectedAvatar,
    Map<String, dynamic>? dashboardData,
    DateTime? lastUpdated,
  }) {
    return HomeDataModel(
      username: username ?? this.username,
      currentMood: currentMood ?? this.currentMood,
      streak: streak ?? this.streak,
      isFirstTimeLogin: isFirstTimeLogin ?? this.isFirstTimeLogin,
      userStats: userStats ?? this.userStats,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      dashboardData: dashboardData ?? this.dashboardData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    username,
    currentMood,
    streak,
    isFirstTimeLogin,
    userStats,
    selectedAvatar,
    dashboardData,
    lastUpdated,
  ];
}
