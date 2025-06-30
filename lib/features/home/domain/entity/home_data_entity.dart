import 'package:equatable/equatable.dart';

import 'user_stats_entity.dart';

class HomeDataEntity extends Equatable {
  final String username;
  final String? currentMood;
  final int streak;
  final bool isFirstTimeLogin;
  final UserStatsEntity userStats;
  final String? selectedAvatar;
  final Map<String, dynamic> dashboardData;
  final DateTime lastUpdated;

  const HomeDataEntity({
    required this.username,
    this.currentMood,
    required this.streak,
    required this.isFirstTimeLogin,
    required this.userStats,
    this.selectedAvatar,
    required this.dashboardData,
    required this.lastUpdated,
  });

  HomeDataEntity copyWith({
    String? username,
    String? currentMood,
    int? streak,
    bool? isFirstTimeLogin,
    UserStatsEntity? userStats,
    String? selectedAvatar,
    Map<String, dynamic>? dashboardData,
    DateTime? lastUpdated,
  }) {
    return HomeDataEntity(
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
