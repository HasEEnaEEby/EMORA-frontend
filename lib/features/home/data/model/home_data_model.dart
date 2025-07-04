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

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      username: json['username'] ?? '',
      currentMood: json['currentMood'],
      streak: json['streak'] ?? 0,
      isFirstTimeLogin: json['isFirstTimeLogin'] ?? true,
      userStats: UserStatsModel.fromJson(json['userStats'] ?? {}),
      selectedAvatar: json['selectedAvatar'],
      dashboardData: Map<String, dynamic>.from(json['dashboardData'] ?? {}),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  /// ✅ NEW: Convert from Entity to Model (for clean architecture)
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
