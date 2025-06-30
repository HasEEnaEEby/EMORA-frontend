// lib/features/home/presentation/view_model/bloc/home_state.dart
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
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

  const HomeDashboardState({required this.homeData, this.userStats});

  @override
  List<Object?> get props => [homeData, userStats];

  // Add these getter methods for compatibility with AppRouter
  Map<String, dynamic> get dashboardData => homeData.toMap();
  String get username => homeData.username;
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};

  HomeDashboardState copyWith({
    HomeDataModel? homeData,
    UserStatsModel? userStats,
  }) {
    return HomeDashboardState(
      homeData: homeData ?? this.homeData,
      userStats: userStats ?? this.userStats,
    );
  }
}

/// Stats refreshing state (when user is on dashboard)
class HomeStatsRefreshing extends HomeDashboardState {
  const HomeStatsRefreshing({required super.homeData, super.userStats});

  @override
  Map<String, dynamic> get dashboardData => homeData.toMap();

  @override
  String get username => homeData.username;

  @override
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};
}

/// Data refreshing state (when user pulls to refresh)
class HomeDataRefreshing extends HomeDashboardState {
  const HomeDataRefreshing({required super.homeData, super.userStats});

  @override
  Map<String, dynamic> get dashboardData => homeData.toMap();

  @override
  String get username => homeData.username;

  @override
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};
}

/// Error state
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
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
