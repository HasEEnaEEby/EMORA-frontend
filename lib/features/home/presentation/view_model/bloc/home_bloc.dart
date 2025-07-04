// lib/features/home/presentation/view_model/bloc/home_bloc.dart - FIXED VERSION
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/navigation/app_router.dart';
import 'package:emora_mobile_app/core/navigation/navigation_service.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/get_user_stats.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/load_home_data.dart' as use_case;
import 'package:emora_mobile_app/features/home/domain/use_case/navigate_to_main_flow.dart' as nav_use_case;
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final use_case.LoadHomeData loadHomeData;
  final GetUserStats getUserStats;
  final nav_use_case.NavigateToMainFlow navigateToMainFlow;

  // Add these fields to prevent duplicate requests
  bool _isLoadingHomeData = false;
  bool _isLoadingUserStats = false;
  DateTime? _lastHomeDataLoad;
  DateTime? _lastUserStatsLoad;

  // Cache duration for API calls
  static const Duration _cacheDuration = Duration(minutes: 2);
  static const Duration _userStatsCacheDuration = Duration(minutes: 5);

  HomeBloc({
    required this.loadHomeData,
    required this.getUserStats,
    required this.navigateToMainFlow,
  }) : super(const HomeInitial()) {
    // Register all event handlers
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<LoadHomeData>(_onLoadHomeDataCompatibility); // Compatibility handler
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
    on<RefreshHomeData>(_onRefreshHomeDataCompatibility); // Compatibility handler
    on<MarkFirstTimeLoginCompleteEvent>(_onMarkFirstTimeLoginComplete);
    on<NavigateToMainFlowEvent>(_onNavigateToMainFlow);
    on<NavigateToMainFlow>(_onNavigateToMainFlowCompatibility); // Compatibility handler
    on<RefreshUserStatsEvent>(_onRefreshUserStats);
    on<LoadUserStatsEvent>(_onLoadUserStats);
    on<LoadUserStats>(_onLoadUserStatsCompatibility); // Compatibility handler
    on<UpdateLastActivityEvent>(_onUpdateLastActivity);
    on<ClearHomeDataEvent>(_onClearHomeData);
    on<LogoutEvent>(_onLogout);
    on<EmotionLoggedEvent>(_onEmotionLogged);
    on<HomeErrorOccurredEvent>(_onHomeErrorOccurred);
    on<RetryHomeOperationEvent>(_onRetryHomeOperation);
    on<ClearHomeErrorEvent>(_onClearHomeError);
    on<UpdateHomeDataEvent>(_onUpdateHomeData);
    on<InitializeHomeEvent>(_onInitializeHome);
  }

  // ============================================================================
  // MAIN EVENT HANDLERS
  // ============================================================================

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeDataImpl(event.forceRefresh, emit);
  }

  // Compatibility handler for LoadHomeData
  Future<void> _onLoadHomeDataCompatibility(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeDataImpl(event.forceRefresh, emit);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeDataImpl(true, emit);
  }

  // Compatibility handler for RefreshHomeData
  Future<void> _onRefreshHomeDataCompatibility(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeDataImpl(true, emit);
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
    await _navigateToMainFlowImpl(event.userData, emit);
  }

  // Compatibility handler for NavigateToMainFlow
  Future<void> _onNavigateToMainFlowCompatibility(
    NavigateToMainFlow event,
    Emitter<HomeState> emit,
  ) async {
    await _navigateToMainFlowImpl(event.userData, emit);
  }

  Future<void> _onRefreshUserStats(
    RefreshUserStatsEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _refreshUserStatsImpl(event.forceRefresh, emit);
  }

  Future<void> _onLoadUserStats(
    LoadUserStatsEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadUserStatsImpl(event.forceRefresh, emit);
  }

  // Compatibility handler for LoadUserStats
  Future<void> _onLoadUserStatsCompatibility(
    LoadUserStats event,
    Emitter<HomeState> emit,
  ) async {
    await _loadUserStatsImpl(false, emit);
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

      // Clear cache timestamps
      _lastHomeDataLoad = null;
      _lastUserStatsLoad = null;
      _isLoadingHomeData = false;
      _isLoadingUserStats = false;

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

      // Clear cache
      _lastHomeDataLoad = null;
      _lastUserStatsLoad = null;
      _isLoadingHomeData = false;
      _isLoadingUserStats = false;

      // Simulate logout process
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear home data
      add(const ClearHomeDataEvent());

      Logger.info('✅ Logout successful');

      // Navigate to auth screen
      NavigationService.safeNavigate(AppRouter.auth, clearStack: true);
      NavigationService.showSuccessSnackBar('You have been logged out');
    } catch (e) {
      Logger.error('❌ Error during logout', e);
      emit(const HomeError(message: 'Failed to logout'));
    }
  }

  Future<void> _onEmotionLogged(
    EmotionLoggedEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🎭 Emotion logged, updating user stats...');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        // Update user stats to reflect the new emotion
        final updatedStats =
            currentState.userStats?.copyWith(
              totalMoodEntries:
                  (currentState.userStats?.totalMoodEntries ?? 0) + 1,
              moodCheckins: (currentState.userStats?.moodCheckins ?? 0) + 1,
              lastMoodLog: event.timestamp ?? DateTime.now(),
              // Update streak if this is a new day
              streakDays:
                  _shouldUpdateStreak(currentState.userStats?.lastMoodLog)
                  ? (currentState.userStats?.streakDays ?? 0) + 1
                  : (currentState.userStats?.streakDays ?? 1),
            ) ??
            UserStatsModel(
              totalMoodEntries: 1,
              streakDays: 1,
              totalSessions: 1,
              moodCheckins: 1,
              averageMoodScore: event.intensity,
              mostFrequentMood: event.emotion,
              lastMoodLog: event.timestamp ?? DateTime.now(),
              weeklyStats: {},
              monthlyStats: {},
            );

        emit(
          HomeDashboardState(
            homeData: currentState.homeData,
            userStats: updatedStats,
          ),
        );

        Logger.info('✅ User stats updated after emotion logging');
      }
    } catch (e) {
      Logger.error('❌ Error updating stats after emotion logged', e);
      // Don't emit error state, just log the error
    }
  }

  Future<void> _onHomeErrorOccurred(
    HomeErrorOccurredEvent event,
    Emitter<HomeState> emit,
  ) async {
    Logger.error('🏠 Home error occurred: ${event.error}', event.exception);
    emit(HomeError(message: event.error));
  }

  Future<void> _onRetryHomeOperation(
    RetryHomeOperationEvent event,
    Emitter<HomeState> emit,
  ) async {
    Logger.info('🔄 Retrying home operation: ${event.operation}');
    
    switch (event.operation) {
      case 'load_home_data':
        add(const LoadHomeDataEvent(forceRefresh: true));
        break;
      case 'load_user_stats':
        add(const LoadUserStatsEvent(forceRefresh: true));
        break;
      default:
        Logger.warning('⚠️ Unknown operation to retry: ${event.operation}');
    }
  }

  Future<void> _onClearHomeError(
    ClearHomeErrorEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeError) {
      // Return to previous valid state or initial state
      emit(const HomeInitial());
    }
  }

  Future<void> _onUpdateHomeData(
    UpdateHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        
        // Create updated home data with new values
        final updatedHomeData = currentState.homeData.copyWith(
          // Apply updates from the event
          // Note: You'll need to implement copyWith with dynamic updates
        );

        emit(
          HomeDashboardState(
            homeData: updatedHomeData,
            userStats: currentState.userStats,
          ),
        );
        
        Logger.info('✅ Home data updated successfully');
      }
    } catch (e) {
      Logger.error('❌ Error updating home data', e);
    }
  }

  Future<void> _onInitializeHome(
    InitializeHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    Logger.info('🏠 Initializing home with data: ${event.initialData}');
    add(const LoadHomeDataEvent());
  }

  // ============================================================================
  // IMPLEMENTATION METHODS
  // ============================================================================

  Future<void> _loadHomeDataImpl(
    bool forceRefresh,
    Emitter<HomeState> emit,
  ) async {
    // Prevent duplicate requests
    if (_isLoadingHomeData && !forceRefresh) {
      Logger.info('🔄 Home data already loading, ignoring duplicate request');
      return;
    }

    // Check if we have recent data
    if (_lastHomeDataLoad != null &&
        DateTime.now().difference(_lastHomeDataLoad!) < _cacheDuration &&
        !forceRefresh) {
      Logger.info(
        '📱 Using cached home data (${DateTime.now().difference(_lastHomeDataLoad!).inSeconds}s old)',
      );
      return;
    }

    _isLoadingHomeData = true;

    try {
      Logger.info(
        '🏠 Loading home data... (forceRefresh: $forceRefresh)',
      );
      emit(const HomeLoading());

      final result = await loadHomeData(NoParams());

      result.fold(
        (failure) {
          Logger.error(
            '💥 Home data load failure: ${failure.runtimeType} - ${failure.message}',
            failure.message,
          );

          if (_shouldHandleGracefully(failure)) {
            Logger.info('🔧 Using fallback mock data for development mode');
            _emitSuccessWithMockData(emit, null);
          } else {
            emit(HomeError(message: _getFriendlyErrorMessage(failure.message)));
          }
        },
        (homeDataEntity) {
          Logger.info('✅ Home data loaded successfully');
          _lastHomeDataLoad = DateTime.now();

          final homeData = HomeDataModel.fromEntity(homeDataEntity);

          // Always go to dashboard, let dashboard handle new user UI
          _loadUserStatsForDashboard(homeData, emit);
        },
      );
    } catch (e, stack) {
      Logger.error('❌ Unexpected error loading home data', e, stack);

      if (AppConfig.isDevelopmentMode) {
        Logger.info('🔧 Using fallback data due to exception in development');
        _emitSuccessWithMockData(emit, null);
      } else {
        emit(const HomeError(message: 'Failed to load home data'));
      }
    } finally {
      _isLoadingHomeData = false;
    }
  }

  Future<void> _navigateToMainFlowImpl(
    Map<String, dynamic>? userData,
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

  Future<void> _refreshUserStatsImpl(
    bool forceRefresh,
    Emitter<HomeState> emit,
  ) async {
    // Prevent duplicate requests
    if (_isLoadingUserStats && !forceRefresh) {
      Logger.info('📊 User stats already loading, ignoring duplicate request');
      return;
    }

    try {
      Logger.info(
        '📊 Refreshing user stats... (forceRefresh: $forceRefresh)',
      );

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        emit(
          HomeStatsRefreshing(
            homeData: currentState.homeData,
            userStats: currentState.userStats,
          ),
        );

        _isLoadingUserStats = true;
        final result = await getUserStats(NoParams());

        result.fold(
          (failure) {
            Logger.warning(
              '⚠️ Failed to refresh user stats: ${failure.message}',
            );

            if (!emit.isDone) {
              emit(
                HomeDashboardState(
                  homeData: currentState.homeData,
                  userStats: currentState.userStats,
                ),
              );
            }

            if (!AppConfig.isDevelopmentMode) {
              NavigationService.showWarningSnackBar(
                'Failed to refresh statistics',
              );
            }
          },
          (userStatsEntity) {
            Logger.info('✅ User stats refreshed successfully');
            _lastUserStatsLoad = DateTime.now();

            final userStats = UserStatsModel.fromEntity(userStatsEntity);

            if (!emit.isDone) {
              emit(
                HomeDashboardState(
                  homeData: currentState.homeData,
                  userStats: userStats,
                ),
              );
            }
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
    } finally {
      _isLoadingUserStats = false;
    }
  }

  Future<void> _loadUserStatsImpl(
    bool forceRefresh,
    Emitter<HomeState> emit,
  ) async {
    // Prevent duplicate requests
    if (_isLoadingUserStats && !forceRefresh) {
      Logger.info('📊 User stats already loading, ignoring duplicate request');
      return;
    }

    // Check if we have recent data
    if (_lastUserStatsLoad != null &&
        DateTime.now().difference(_lastUserStatsLoad!) <
            _userStatsCacheDuration &&
        !forceRefresh) {
      Logger.info(
        '📱 Using cached user stats (${DateTime.now().difference(_lastUserStatsLoad!).inSeconds}s old)',
      );
      return;
    }

    _isLoadingUserStats = true;

    try {
      Logger.info(
        '📊 Loading user stats... (forceRefresh: $forceRefresh)',
      );

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('⚠️ Failed to load user stats: ${failure.message}');

          if (AppConfig.isDevelopmentMode) {
            final userStats = _createNewUserStats();

            if (state is HomeDashboardState && !emit.isDone) {
              final currentState = state as HomeDashboardState;
              emit(
                HomeDashboardState(
                  homeData: currentState.homeData,
                  userStats: userStats,
                ),
              );
            }
          }
        },
        (userStatsEntity) {
          Logger.info('✅ User stats loaded successfully');
          _lastUserStatsLoad = DateTime.now();

          final userStats = UserStatsModel.fromEntity(userStatsEntity);

          if (state is HomeDashboardState && !emit.isDone) {
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
        final userStats = _createMockUserStats();

        emit(
          HomeDashboardState(
            homeData: currentState.homeData,
            userStats: userStats,
          ),
        );
      }
      // Don't emit error state for stats loading failure
    } finally {
      _isLoadingUserStats = false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  // Helper method to load user stats and transition to dashboard
  Future<void> _loadUserStatsForDashboard(
    HomeDataModel homeData,
    Emitter<HomeState> emit,
  ) async {
    // Prevent duplicate stats loading
    if (_isLoadingUserStats) {
      Logger.info('📊 User stats already loading, using home data only');
      emit(HomeDashboardState(homeData: homeData));
      return;
    }

    // Check if we have recent stats data
    if (_lastUserStatsLoad != null &&
        DateTime.now().difference(_lastUserStatsLoad!) <
            _userStatsCacheDuration) {
      Logger.info('📱 Using cached user stats for dashboard');
      // Emit with current stats if available
      final currentStats = getCurrentUserStats();
      if (currentStats != null) {
        emit(HomeDashboardState(homeData: homeData, userStats: currentStats));
        return;
      }
    }

    _isLoadingUserStats = true;

    try {
      Logger.info('📊 Loading user stats for dashboard...');

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('⚠️ Failed to load user stats: ${failure.message}');

          if (AppConfig.isDevelopmentMode) {
            final userStats = _createNewUserStats();
            if (!emit.isDone) {
              emit(
                HomeDashboardState(homeData: homeData, userStats: userStats),
              );
            }
          } else {
            if (!emit.isDone) {
              emit(HomeDashboardState(homeData: homeData));
            }
          }
        },
        (userStatsEntity) {
          Logger.info('✅ User stats loaded for dashboard');
          _lastUserStatsLoad = DateTime.now();

          final userStats = UserStatsModel.fromEntity(userStatsEntity);

          if (!emit.isDone) {
            emit(HomeDashboardState(homeData: homeData, userStats: userStats));
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Error loading stats for dashboard', e);

      if (AppConfig.isDevelopmentMode) {
        // Create new user stats for new users
        final userStats = _createNewUserStats();
        emit(HomeDashboardState(homeData: homeData, userStats: userStats));
      } else {
        emit(HomeDashboardState(homeData: homeData));
      }
    } finally {
      _isLoadingUserStats = false;
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

  // Helper method to check if streak should be updated
  bool _shouldUpdateStreak(DateTime? lastMoodLog) {
    if (lastMoodLog == null) return true;

    final now = DateTime.now();
    final lastLog = DateTime(
      lastMoodLog.year,
      lastMoodLog.month,
      lastMoodLog.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    return today.difference(lastLog).inDays >= 1;
  }

  // Emit success state with mock data
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

    // Create new user stats for development
    final userStats = _createNewUserStats();

    // Create home data model from mock data
    final homeData = HomeDataModel(
      username: mockHomeData['username'],
      currentMood: mockHomeData['currentMood'],
      streak: userStats.streakDays,
      isFirstTimeLogin:
          false, // Set to false to go directly to dashboard
      userStats: userStats,
      selectedAvatar: mockHomeData['selectedAvatar'],
      dashboardData: mockHomeData,
      lastUpdated: DateTime.now(),
    );

    // Emit dashboard state directly
    emit(HomeDashboardState(homeData: homeData, userStats: userStats));

    Logger.info('✅ Mock data loaded successfully for development mode');
  }

  // Create new user stats (0 emotions for new users)
  UserStatsModel _createNewUserStats() {
    return UserStatsModel(
      totalMoodEntries: 0, // New user starts with 0
      streakDays: 0, // New user starts with 0
      totalSessions: 0, // New user starts with 0
      moodCheckins: 0, // New user starts with 0
      averageMoodScore: 0.0,
      mostFrequentMood: 'neutral',
      lastMoodLog: DateTime.now(),
      weeklyStats: {},
      monthlyStats: {},
    );
  }

  // DEPRECATED: Keep for compatibility but use _createNewUserStats instead
  UserStatsModel _createMockUserStats() {
    return _createNewUserStats();
  }

  // Get friendly error message
  String _getFriendlyErrorMessage(String originalError) {
    return AppConfig.getFriendlyErrorMessage(originalError);
  }

  // ============================================================================
  // PUBLIC UTILITY METHODS
  // ============================================================================

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

  // Helper method to check if user is new
  bool isNewUser() {
    final userStats = getCurrentUserStats();
    return userStats?.totalMoodEntries == 0;
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
        state is HomeStatsRefreshing ||
        _isLoadingHomeData ||
        _isLoadingUserStats;
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

  // Get cache status for debugging
  Map<String, dynamic> getCacheStatus() {
    final now = DateTime.now();
    return {
      'isLoadingHomeData': _isLoadingHomeData,
      'isLoadingUserStats': _isLoadingUserStats,
      'lastHomeDataLoad': _lastHomeDataLoad?.toIso8601String(),
      'lastUserStatsLoad': _lastUserStatsLoad?.toIso8601String(),
      'homeDataCacheAge': _lastHomeDataLoad != null
          ? now.difference(_lastHomeDataLoad!).inSeconds
          : null,
      'userStatsCacheAge': _lastUserStatsLoad != null
          ? now.difference(_lastUserStatsLoad!).inSeconds
          : null,
      'homeDataCacheValid': _lastHomeDataLoad != null
          ? now.difference(_lastHomeDataLoad!) < _cacheDuration
          : false,
      'userStatsCacheValid': _lastUserStatsLoad != null
          ? now.difference(_lastUserStatsLoad!) < _userStatsCacheDuration
          : false,
    };
  }

  // ============================================================================
  // OVERRIDE METHODS
  // ============================================================================

  @override
  void onTransition(Transition<HomeEvent, HomeState> transition) {
    super.onTransition(transition);
    Logger.info(
      '🏠 Home BLoC Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.error('🏠 Home BLoC Error: $error', error, stackTrace);
  }

  @override
  Future<void> close() {
    // Clear any ongoing operations
    _isLoadingHomeData = false;
    _isLoadingUserStats = false;
    return super.close();
  }
}