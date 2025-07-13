// lib/features/home/presentation/view_model/bloc/home_state.dart
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeWelcomeState extends HomeState {
  final HomeDataModel homeData;

  const HomeWelcomeState({required this.homeData});

  @override
  List<Object?> get props => [homeData];
}

class HomeDashboardState extends HomeState {
  final HomeDataModel homeData;
  final UserStatsModel? userStats;
  final List<EmotionEntryModel> emotionEntries;
  final WeeklyInsightsModel? weeklyInsights;

  const HomeDashboardState({
    required this.homeData, 
    this.userStats,
    this.emotionEntries = const [],
    this.weeklyInsights,
  });

  @override
  List<Object?> get props => [homeData, userStats, emotionEntries, weeklyInsights];

  // Add these getter methods for compatibility with AppRouter
  Map<String, dynamic> get dashboardData => homeData.toMap();
  String get username => homeData.username;
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};

  HomeDashboardState copyWith({
    HomeDataModel? homeData,
    UserStatsModel? userStats,
    List<EmotionEntryModel>? emotionEntries,
    WeeklyInsightsModel? weeklyInsights,
  }) {
    return HomeDashboardState(
      homeData: homeData ?? this.homeData,
      userStats: userStats ?? this.userStats,
      emotionEntries: emotionEntries ?? this.emotionEntries,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
    );
  }
}

/// Stats refreshing state (when user is on dashboard)
class HomeStatsRefreshing extends HomeDashboardState {
  const HomeStatsRefreshing({
    required super.homeData, 
    super.userStats,
    super.emotionEntries,
    super.weeklyInsights,
  });

  @override
  Map<String, dynamic> get dashboardData => homeData.toMap();

  @override
  String get username => homeData.username;

  @override
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};
}

/// Data refreshing state (when user pulls to refresh)
class HomeDataRefreshing extends HomeDashboardState {
  const HomeDataRefreshing({
    required super.homeData, 
    super.userStats,
    super.emotionEntries,
    super.weeklyInsights,
  });

  @override
  Map<String, dynamic> get dashboardData => homeData.toMap();

  @override
  String get username => homeData.username;

  @override
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};
}

/// Error state with retry functionality
class HomeError extends HomeState {
  final String message;
  final bool canRetry;
  final String? retryAction;
  final String? originalError;

  const HomeError({
    required this.message,
    this.canRetry = true,
    this.retryAction,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, canRetry, retryAction, originalError];

  HomeError copyWith({
    String? message,
    bool? canRetry,
    String? retryAction,
    String? originalError,
  }) {
    return HomeError(
      message: message ?? this.message,
      canRetry: canRetry ?? this.canRetry,
      retryAction: retryAction ?? this.retryAction,
      originalError: originalError ?? this.originalError,
    );
  }
}

/// Logout loading state
class HomeLogoutLoading extends HomeState {
  const HomeLogoutLoading();
}

/// Success state for specific actions
class HomeActionSuccess extends HomeState {
  final String message;

  const HomeActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
