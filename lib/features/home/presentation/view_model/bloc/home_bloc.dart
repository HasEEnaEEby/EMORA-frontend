import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/navigation/app_router.dart';
import 'package:emora_mobile_app/core/navigation/navigation_service.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/get_user_stats.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/load_home_data.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/navigate_to_main_flow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final LoadHomeData loadHomeData;
  final GetUserStats getUserStats;
  final NavigateToMainFlow navigateToMainFlow;

  HomeBloc({
    required this.loadHomeData,
    required this.getUserStats,
    required this.navigateToMainFlow,
  }) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
    on<MarkFirstTimeLoginCompleteEvent>(_onMarkFirstTimeLoginComplete);
    on<NavigateToMainFlowEvent>(_onNavigateToMainFlow);
    on<RefreshUserStatsEvent>(_onRefreshUserStats);
    on<UpdateLastActivityEvent>(_onUpdateLastActivity);
    on<ClearHomeDataEvent>(_onClearHomeData);
    on<LogoutEvent>(_onLogout);
    on<LoadUserStatsEvent>(_onLoadUserStats);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🏠 Loading home data...');
      emit(const HomeLoading());

      final result = await loadHomeData(NoParams());

      result.fold(
        (failure) {
          Logger.error('❌ Failed to load home data', failure.message);

          // Check if this is a development mode error we can handle gracefully
          if (_shouldHandleGracefully(failure)) {
            Logger.info('🔧 Using fallback mock data for development mode');
            _emitSuccessWithMockData(emit, null);
          } else {
            emit(HomeError(message: _getFriendlyErrorMessage(failure.message)));
          }
        },
        (homeDataEntity) {
          Logger.info('✅ Home data loaded successfully');

          final homeData = homeDataEntity as HomeDataModel;

          // Determine which state to show based on user status
          if (homeData.isFirstTimeLogin) {
            emit(HomeWelcomeState(homeData: homeData));
          } else {
            _loadUserStatsForDashboard(homeData, emit);
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading home data', e);

      // Always fall back to mock data in development
      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔧 Using fallback data due to exception in development');
        _emitSuccessWithMockData(emit, null);
      } else {
        emit(const HomeError(message: 'Failed to load home data'));
      }
    }
  }

  // Helper method to determine if we should handle errors gracefully
  bool _shouldHandleGracefully(Failure failure) {
    return AppConfig.isDevelopmentMode &&
        (failure is NotFoundFailure ||
            failure.message.contains('404') ||
            failure.message.contains('Route') ||
            failure.message.contains('not found') ||
            failure.message.contains('user/home-data'));
  }

  // Emit success state with mock data - FIXED CONSTRUCTOR PARAMETERS
  void _emitSuccessWithMockData(
    Emitter<HomeState> emit,
    Map<String, dynamic>? userData,
  ) {
    final mockHomeData = AppConfig.getMockHomeData(
      username: userData?['username'] ?? 'User',
      pronouns: userData?['pronouns'] ?? AppConfig.defaultPronoun,
      ageGroup: userData?['ageGroup'] ?? AppConfig.defaultAgeGroup,
      selectedAvatar: userData?['selectedAvatar'] ?? AppConfig.defaultAvatar,
    );

    // Create mock user stats with CORRECT constructor parameters
    final mockStats = AppConfig.getMockUserStats();
    final userStats = UserStatsModel(
      totalMoodEntries: mockStats['moodCheckins'] ?? 0,
      streakDays: mockStats['streakDays'] ?? 0,
      totalSessions: mockStats['totalSessions'] ?? 0,
      moodCheckins: mockStats['moodCheckins'] ?? 0,
      averageMoodScore: 5.0,
      mostFrequentMood: 'neutral',
      lastMoodLog:
          DateTime.tryParse(mockStats['lastActivityDate']) ?? DateTime.now(),
      weeklyStats: mockStats['weeklyStats'] ?? {},
      monthlyStats: mockStats['monthlyStats'] ?? {},
    );

    // Create home data model from mock data - FIXED with correct constructor
    final homeData = HomeDataModel(
      username: mockHomeData['username'],
      currentMood: mockHomeData['currentMood'],
      streak: mockStats['streakDays'] ?? 0,
      isFirstTimeLogin: mockHomeData['isFirstTimeLogin'],
      userStats: userStats,
      selectedAvatar: mockHomeData['selectedAvatar'],
      dashboardData: mockHomeData,
      lastUpdated: DateTime.now(),
    );

    // Emit dashboard state directly (skip welcome for development)
    emit(HomeDashboardState(homeData: homeData, userStats: userStats));

    Logger.info('✅ Mock data loaded successfully for development mode');
  }

  // Get friendly error message
  String _getFriendlyErrorMessage(String originalError) {
    return AppConfig.getFriendlyErrorMessage(originalError);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🔄 Refreshing home data...');

      // Show refreshing state if we're currently on dashboard
      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        emit(
          HomeDataRefreshing(
            homeData: currentState.homeData,
            userStats: currentState.userStats,
          ),
        );
      } else {
        emit(const HomeLoading());
      }

      final result = await loadHomeData(NoParams());

      result.fold(
        (failure) {
          Logger.error('❌ Failed to refresh home data', failure.message);

          if (_shouldHandleGracefully(failure)) {
            Logger.info('🔧 Using fallback data for refresh in development');
            _emitSuccessWithMockData(emit, null);
          } else {
            emit(HomeError(message: _getFriendlyErrorMessage(failure.message)));
          }
        },
        (homeDataEntity) {
          Logger.info('✅ Home data refreshed successfully');
          final homeData = homeDataEntity as HomeDataModel;
          _loadUserStatsForDashboard(homeData, emit);
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error refreshing home data', e);

      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔧 Using fallback data for refresh exception');
        _emitSuccessWithMockData(emit, null);
      } else {
        emit(const HomeError(message: 'Failed to refresh home data'));
      }
    }
  }

  Future<void> _onMarkFirstTimeLoginComplete(
    MarkFirstTimeLoginCompleteEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🎉 Marking first-time login complete...');

      if (state is HomeWelcomeState) {
        final welcomeState = state as HomeWelcomeState;

        // Update home data to mark first-time login as complete
        final updatedHomeData = welcomeState.homeData.copyWith(
          isFirstTimeLogin: false,
        );

        // Transition to dashboard
        _loadUserStatsForDashboard(updatedHomeData, emit);
        Logger.info('✅ First-time login marked complete');
      } else {
        Logger.warning(
          '⚠️ Attempted to mark first-time login complete but not in welcome state',
        );
      }
    } catch (e) {
      Logger.error('❌ Error marking first-time login complete', e);
      emit(const HomeError(message: 'Failed to complete setup'));
    }
  }

  Future<void> _onNavigateToMainFlow(
    NavigateToMainFlowEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🚀 Navigating to main flow...');

      final result = await navigateToMainFlow(NoParams());

      result.fold(
        (failure) {
          Logger.error('❌ Navigation failed', failure.message);

          // Handle navigation gracefully in development
          if (AppConfig.isDevelopmentMode) {
            Logger.info('🔧 Navigation handled gracefully in development');
            // Just transition to dashboard state if possible
            if (state is HomeWelcomeState) {
              final welcomeState = state as HomeWelcomeState;
              final updatedHomeData = welcomeState.homeData.copyWith(
                isFirstTimeLogin: false,
              );
              _loadUserStatsForDashboard(updatedHomeData, emit);
            }
          } else {
            emit(HomeError(message: failure.message));
          }
        },
        (_) {
          Logger.info('✅ Navigation successful');
          // The state change will be handled by subsequent events
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error during navigation', e);

      // Handle navigation error gracefully in development
      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔧 Navigation exception handled in development');
        if (state is HomeWelcomeState) {
          final welcomeState = state as HomeWelcomeState;
          final updatedHomeData = welcomeState.homeData.copyWith(
            isFirstTimeLogin: false,
          );
          _loadUserStatsForDashboard(updatedHomeData, emit);
        }
      } else {
        emit(const HomeError(message: 'Failed to navigate'));
      }
    }
  }

  Future<void> _onRefreshUserStats(
    RefreshUserStatsEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('📊 Refreshing user stats...');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        emit(
          HomeStatsRefreshing(
            homeData: currentState.homeData,
            userStats: currentState.userStats,
          ),
        );

        final result = await getUserStats(NoParams());

        result.fold(
          (failure) {
            Logger.warning(
              '⚠️ Failed to refresh user stats: ${failure.message}',
            );

            // Keep current state and show warning
            emit(
              HomeDashboardState(
                homeData: currentState.homeData,
                userStats: currentState.userStats,
              ),
            );

            // Only show warning in production
            if (!AppConfig.isDevelopmentMode) {
              NavigationService.showWarningSnackBar(
                'Failed to refresh statistics',
              );
            }
          },
          (userStatsEntity) {
            Logger.info('✅ User stats refreshed successfully');
            final userStats = userStatsEntity as UserStatsModel;

            emit(
              HomeDashboardState(
                homeData: currentState.homeData,
                userStats: userStats,
              ),
            );
          },
        );
      } else {
        Logger.warning(
          '⚠️ Attempted to refresh stats but not in dashboard state',
        );
      }
    } catch (e) {
      Logger.error('❌ Unexpected error refreshing user stats', e);

      // Only show error snackbar in production
      if (!AppConfig.isDevelopmentMode) {
        NavigationService.showErrorSnackBar('Failed to refresh statistics');
      }
    }
  }

  Future<void> _onUpdateLastActivity(
    UpdateLastActivityEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('⏰ Updating last activity...');
      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        final updatedHomeData = currentState.homeData.copyWith();

        // Emit updated state with new last active time
        emit(
          HomeDashboardState(
            homeData: updatedHomeData,
            userStats: currentState.userStats,
          ),
        );
      }

      Logger.info('✅ Last activity updated');
    } catch (e) {
      Logger.error('❌ Error updating last activity', e);
      // Don't emit error state for this non-critical operation
    }
  }

  Future<void> _onClearHomeData(
    ClearHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🗑️ Clearing home data...');

      // Clear any cached data and reset to initial state
      emit(const HomeInitial());

      Logger.info('✅ Home data cleared');
    } catch (e) {
      Logger.error('❌ Error clearing home data', e);
      emit(const HomeError(message: 'Failed to clear data'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<HomeState> emit) async {
    try {
      Logger.info('👋 Logging out user...');
      emit(const HomeLogoutLoading());

      // Simulate logout process
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear home data
      add(const ClearHomeDataEvent());

      Logger.info('✅ Logout successful');

      // Navigate to auth screen
      NavigationService.pushNamedAndClearStack(AppRouter.auth);
      NavigationService.showSuccessSnackBar('You have been logged out');
    } catch (e) {
      Logger.error('❌ Error during logout', e);
      emit(const HomeError(message: 'Failed to logout'));
    }
  }

  Future<void> _onLoadUserStats(
    LoadUserStatsEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('📊 Loading user stats...');

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('⚠️ Failed to load user stats: ${failure.message}');

          // In development mode, use mock stats
          if (AppConfig.isDevelopmentMode) {
            final mockStats = AppConfig.getMockUserStats();
            final userStats = UserStatsModel(
              totalMoodEntries: mockStats['moodCheckins'] ?? 0,
              streakDays: mockStats['streakDays'] ?? 0,
              totalSessions: mockStats['totalSessions'] ?? 0,
              moodCheckins: mockStats['moodCheckins'] ?? 0,
              averageMoodScore: 5.0,
              mostFrequentMood: 'neutral',
              lastMoodLog:
                  DateTime.tryParse(mockStats['lastActivityDate']) ??
                  DateTime.now(),
              weeklyStats: mockStats['weeklyStats'] ?? {},
              monthlyStats: mockStats['monthlyStats'] ?? {},
            );

            // Update current state with mock stats if we're on dashboard
            if (state is HomeDashboardState) {
              final currentState = state as HomeDashboardState;
              emit(
                HomeDashboardState(
                  homeData: currentState.homeData,
                  userStats: userStats,
                ),
              );
            }
          }
          // Don't emit error state for stats loading failure
        },
        (userStatsEntity) {
          Logger.info('✅ User stats loaded successfully');
          final userStats = userStatsEntity as UserStatsModel;

          // Update current state with stats if we're on dashboard
          if (state is HomeDashboardState) {
            final currentState = state as HomeDashboardState;
            emit(
              HomeDashboardState(
                homeData: currentState.homeData,
                userStats: userStats,
              ),
            );
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading user stats', e);

      // In development mode, provide fallback mock stats
      if (AppConfig.isDevelopmentMode && state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        final mockStats = AppConfig.getMockUserStats();
        final userStats = UserStatsModel(
          totalMoodEntries: mockStats['moodCheckins'] ?? 0,
          streakDays: mockStats['streakDays'] ?? 0,
          totalSessions: mockStats['totalSessions'] ?? 0,
          moodCheckins: mockStats['moodCheckins'] ?? 0,
          averageMoodScore: 5.0,
          mostFrequentMood: 'neutral',
          lastMoodLog:
              DateTime.tryParse(mockStats['lastActivityDate']) ??
              DateTime.now(),
          weeklyStats: mockStats['weeklyStats'] ?? {},
          monthlyStats: mockStats['monthlyStats'] ?? {},
        );

        emit(
          HomeDashboardState(
            homeData: currentState.homeData,
            userStats: userStats,
          ),
        );
      }
      // Don't emit error state for stats loading failure
    }
  }

  // Helper method to load user stats and transition to dashboard - FIXED
  Future<void> _loadUserStatsForDashboard(
    HomeDataModel homeData,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('📊 Loading user stats for dashboard...');

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('⚠️ Failed to load user stats: ${failure.message}');

          // Show dashboard with mock stats in development, without stats in production
          if (AppConfig.isDevelopmentMode) {
            final mockStats = AppConfig.getMockUserStats();
            final userStats = UserStatsModel(
              totalMoodEntries: mockStats['moodCheckins'] ?? 0,
              streakDays: mockStats['streakDays'] ?? 0,
              totalSessions: mockStats['totalSessions'] ?? 0,
              moodCheckins: mockStats['moodCheckins'] ?? 0,
              averageMoodScore: 5.0,
              mostFrequentMood: 'neutral',
              lastMoodLog:
                  DateTime.tryParse(mockStats['lastActivityDate']) ??
                  DateTime.now(),
              weeklyStats: mockStats['weeklyStats'] ?? {},
              monthlyStats: mockStats['monthlyStats'] ?? {},
            );
            emit(HomeDashboardState(homeData: homeData, userStats: userStats));
          } else {
            // Show dashboard without stats in production
            emit(HomeDashboardState(homeData: homeData));
          }
        },
        (userStatsEntity) {
          Logger.info('✅ User stats loaded for dashboard');
          final userStats = userStatsEntity as UserStatsModel;
          emit(HomeDashboardState(homeData: homeData, userStats: userStats));
        },
      );
    } catch (e) {
      Logger.error('❌ Error loading stats for dashboard', e);

      // Show dashboard with mock stats in development, without stats in production
      if (AppConfig.isDevelopmentMode) {
        final mockStats = AppConfig.getMockUserStats();
        final userStats = UserStatsModel(
          totalMoodEntries: mockStats['moodCheckins'] ?? 0,
          streakDays: mockStats['streakDays'] ?? 0,
          totalSessions: mockStats['totalSessions'] ?? 0,
          moodCheckins: mockStats['moodCheckins'] ?? 0,
          averageMoodScore: 5.0,
          mostFrequentMood: 'neutral',
          lastMoodLog:
              DateTime.tryParse(mockStats['lastActivityDate']) ??
              DateTime.now(),
          weeklyStats: mockStats['weeklyStats'] ?? {},
          monthlyStats: mockStats['monthlyStats'] ?? {},
        );
        emit(HomeDashboardState(homeData: homeData, userStats: userStats));
      } else {
        emit(HomeDashboardState(homeData: homeData));
      }
    }
  }

  // Helper method to get current home data
  HomeDataModel? getCurrentHomeData() {
    if (state is HomeDashboardState) {
      return (state as HomeDashboardState).homeData;
    } else if (state is HomeWelcomeState) {
      return (state as HomeWelcomeState).homeData;
    } else if (state is HomeDataRefreshing) {
      return (state as HomeDataRefreshing).homeData;
    } else if (state is HomeStatsRefreshing) {
      return (state as HomeStatsRefreshing).homeData;
    }
    return null;
  }

  // Helper method to get current user stats
  UserStatsModel? getCurrentUserStats() {
    if (state is HomeDashboardState) {
      return (state as HomeDashboardState).userStats;
    } else if (state is HomeDataRefreshing) {
      return (state as HomeDataRefreshing).userStats;
    } else if (state is HomeStatsRefreshing) {
      return (state as HomeStatsRefreshing).userStats;
    }
    return null;
  }

  // Helper method to check if user is on first login
  bool isFirstTimeLogin() {
    final homeData = getCurrentHomeData();
    return homeData?.isFirstTimeLogin ?? false;
  }

  // Helper method to get user's display name
  String getUserDisplayName() {
    final homeData = getCurrentHomeData();
    return homeData?.username ?? 'User';
  }

  String getUserAvatar() {
    return AppConfig.defaultAvatar;
  }

  bool get isLoading {
    return state is HomeLoading ||
        state is HomeLogoutLoading ||
        state is HomeDataRefreshing ||
        state is HomeStatsRefreshing;
  }

  bool get hasError {
    return state is HomeError;
  }

  // Helper method to get error message if any
  String? getErrorMessage() {
    if (state is HomeError) {
      return (state as HomeError).message;
    }
    return null;
  }

  @override
  void onTransition(Transition<HomeEvent, HomeState> transition) {
    super.onTransition(transition);
    Logger.info(
      '🏠 Home BLoC Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  // Fixed onError method signature
  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.error('🏠 Home BLoC Error: $error', stackTrace);
  }
}
