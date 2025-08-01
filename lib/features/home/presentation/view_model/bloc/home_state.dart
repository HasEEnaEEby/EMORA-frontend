import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart' hide WeeklyInsightsModel;
import 'package:emora_mobile_app/features/home/data/model/weekly_insights_model.dart';
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
  final List<EmotionEntryModel> todaysEmotions;
  final Map<String, List<EmotionEntryModel>>? emotionCalendarData;
  final DateTime? selectedMonth;
  final DateTime? selectedDate;
  final List<EmotionEntryModel> selectedDateEmotions;

  const HomeDashboardState({
    required this.homeData, 
    this.userStats,
    this.emotionEntries = const [],
    this.weeklyInsights,
    this.todaysEmotions = const [],
    this.emotionCalendarData,
    this.selectedMonth,
    this.selectedDate,
    this.selectedDateEmotions = const [],
  });

  @override
  List<Object?> get props => [
    homeData, 
    userStats, 
    emotionEntries, 
    weeklyInsights,
    todaysEmotions,
    emotionCalendarData,
    selectedMonth,
    selectedDate,
    selectedDateEmotions,
  ];

  Map<String, dynamic> get dashboardData => homeData.toMap();
  String get username => homeData.username;
  Map<String, dynamic> get userStatsMap => userStats?.toMap() ?? {};

  HomeDashboardState copyWith({
    HomeDataModel? homeData,
    UserStatsModel? userStats,
    List<EmotionEntryModel>? emotionEntries,
    WeeklyInsightsModel? weeklyInsights,
    List<EmotionEntryModel>? todaysEmotions,
    Map<String, List<EmotionEntryModel>>? emotionCalendarData,
    DateTime? selectedMonth,
    DateTime? selectedDate,
    List<EmotionEntryModel>? selectedDateEmotions,
  }) {
    return HomeDashboardState(
      homeData: homeData ?? this.homeData,
      userStats: userStats ?? this.userStats,
      emotionEntries: emotionEntries ?? this.emotionEntries,
      weeklyInsights: weeklyInsights ?? this.weeklyInsights,
      todaysEmotions: todaysEmotions ?? this.todaysEmotions,
      emotionCalendarData: emotionCalendarData ?? this.emotionCalendarData,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateEmotions: selectedDateEmotions ?? this.selectedDateEmotions,
    );
  }
}

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

class HomeLogoutLoading extends HomeState {
  const HomeLogoutLoading();
}

class HomeActionSuccess extends HomeState {
  final String message;

  const HomeActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
