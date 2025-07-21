// lib/features/home/presentation/view_model/bloc/home_bloc.dart - COMPLETE FIXED VERSION
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/navigation/app_router.dart';
import 'package:emora_mobile_app/core/navigation/navigation_service.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/home/data/data_source/local/home_local_data_source.dart';
import 'package:emora_mobile_app/features/home/data/model/home_data_model.dart';
import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart' hide WeeklyInsightsModel;
import 'package:emora_mobile_app/features/home/data/model/weekly_insights_model.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/get_user_stats.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/load_home_data.dart'
    as use_case;
import 'package:emora_mobile_app/features/home/domain/use_case/navigate_to_main_flow.dart'
    as nav_use_case;
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/dio_client.dart';
import '../../services/emotion_api_service.dart';

import '../../../../../core/errors/failures.dart';
import 'package:get_it/get_it.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final use_case.LoadHomeData loadHomeData;
  final GetUserStats getUserStats;
  final nav_use_case.NavigateToMainFlow navigateToMainFlow;
  late final EmotionApiService _emotionApiService;

  // Add these fields to prevent duplicate requests
  bool _isLoadingHomeData = false;
  bool _isLoadingUserStats = false;
  bool _isLoadingEmotionHistory = false;
  bool _isLoadingWeeklyInsights = false;
  DateTime? _lastHomeDataLoad;
  DateTime? _lastUserStatsLoad;
  DateTime? _lastEmotionHistoryLoad;
  DateTime? _lastWeeklyInsightsLoad;

  // Cache duration for API calls
  static const Duration _cacheDuration = Duration(minutes: 2);
  static const Duration _userStatsCacheDuration = Duration(minutes: 5);

  HomeBloc({
    required this.loadHomeData,
    required this.getUserStats,
    required this.navigateToMainFlow,
  }) : super(const HomeInitial()) {
    // Initialize emotion API service
    _emotionApiService = EmotionApiService(DioClient.instance);
    // Register all event handlers
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<LoadHomeData>(_onLoadHomeDataCompatibility); // Compatibility handler
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
    on<RefreshHomeData>(
      _onRefreshHomeDataCompatibility,
    ); // Compatibility handler
    on<MarkFirstTimeLoginCompleteEvent>(_onMarkFirstTimeLoginComplete);
    on<NavigateToMainFlowEvent>(_onNavigateToMainFlow);
    on<NavigateToMainFlow>(
      _onNavigateToMainFlowCompatibility,
    ); // Compatibility handler
    on<RefreshUserStatsEvent>(_onRefreshUserStats);
    on<LoadUserStatsEvent>(_onLoadUserStats);
    on<LoadUserStats>(_onLoadUserStatsCompatibility); // Compatibility handler
    on<UpdateLastActivityEvent>(_onUpdateLastActivity);
    on<ClearHomeDataEvent>(_onClearHomeData);
    on<LogoutEvent>(_onLogout);
    on<EmotionLoggedEvent>(_onEmotionLogged);
    on<LoadEmotionHistoryEvent>(_onLoadEmotionHistory);
    on<LoadWeeklyInsightsEvent>(_onLoadWeeklyInsights);
    on<LoadTodaysJourneyEvent>(_onLoadTodaysJourney);
    on<LoadEmotionCalendarEvent>(_onLoadEmotionCalendar);
    on<SelectCalendarDateEvent>(_onSelectCalendarDate);
    on<LogEmotionEvent>(_onLogEmotion);
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
        Logger.info('. First-time login marked complete');
      } else {
        Logger.warning(
          '. Attempted to mark first-time login complete but not in welcome state',
        );
      }
    } catch (e) {
      Logger.error('. Error marking first-time login complete', e);
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

      Logger.info('. Last activity updated');
    } catch (e) {
      Logger.error('. Error updating last activity', e);
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

      Logger.info('. Home data cleared');
    } catch (e) {
      Logger.error('. Error clearing home data', e);
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

      Logger.info('. Logout successful');

      // Navigate to auth screen
      NavigationService.safeNavigate(AppRouter.auth, clearStack: true);
      NavigationService.showSuccessSnackBar('You have been logged out');
    } catch (e) {
      Logger.error('. Error during logout', e);
      emit(const HomeError(message: 'Failed to logout'));
    }
  }


Future<void> _onEmotionLogged(
  EmotionLoggedEvent event,
  Emitter<HomeState> emit,
) async {
  try {
    Logger.info('🎭 Emotion logged, updating user state...');

    if (state is HomeDashboardState) {
      final currentState = state as HomeDashboardState;
      
      // Check if this is the user's first emotion
      final wasNewUser = currentState.userStats?.totalMoodEntries == 0;
      
      // Create new emotion entry
      final newEmotion = EmotionEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentState.homeData.username,
        type: event.emotion,
        emotion: event.emotion,
        intensity: event.intensity.toInt(),
        note: event.metadata?['note']?.toString() ?? '',
        tags: event.metadata?['tags'] as List<String>? ?? [],
        createdAt: DateTime.now(),
        hasLocation: false,
        timeOfDay: _determineTimeOfDay(),
      );

      // Add to current emotion entries
      final updatedEmotions = [newEmotion, ...currentState.emotionEntries];

      // Update user stats to reflect the new emotion
      final updatedStats = currentState.userStats?.copyWith(
        totalMoodEntries: (currentState.userStats?.totalMoodEntries ?? 0) + 1,
        moodCheckins: (currentState.userStats?.moodCheckins ?? 0) + 1,
        lastMoodLog: event.timestamp ?? DateTime.now(),
        // Update streak if this is a new day
        streakDays: _shouldUpdateStreak(currentState.userStats?.lastMoodLog)
            ? (currentState.userStats?.streakDays ?? 0) + 1
            : (currentState.userStats?.streakDays ?? 1),
        // Update most frequent mood and average score
        mostFrequentMood: event.emotion,
        averageMoodScore: _calculateNewAverageScore(
          currentState.userStats?.averageMoodScore ?? 0.0,
          currentState.userStats?.totalMoodEntries ?? 0,
          event.intensity,
        ),
        lastActivity: event.timestamp ?? DateTime.now(),
      ) ?? UserStatsModel(
        totalMoodEntries: 1,
        streakDays: 1,
        totalSessions: 1,
        moodCheckins: 1,
        lastActivity: event.timestamp ?? DateTime.now(),
        averageMoodScore: event.intensity,
        mostFrequentMood: event.emotion,
        lastMoodLog: event.timestamp ?? DateTime.now(),
        weeklyStats: {},
        monthlyStats: {},
      );

      // Update home data if this was the first emotion (transition from new user)
      HomeDataModel updatedHomeData = currentState.homeData;
      if (wasNewUser) {
        Logger.info('🎉 First emotion logged! Transitioning user from new to existing state');
        updatedHomeData = currentState.homeData.copyWith(
          currentMood: event.emotion,
          lastUpdated: DateTime.now(),
        );
      }

      // Emit updated state with new emotion and stats
      emit(currentState.copyWith(
        homeData: updatedHomeData,
        userStats: updatedStats,
        emotionEntries: updatedEmotions,
      ));

      // Show celebration for first emotion
      if (wasNewUser) {
        Logger.info('🎊 Showing first emotion celebration');
        NavigationService.showSuccessSnackBar(
          'Congratulations! You\'ve logged your first emotion! 🎉',
        );
        
        // Optional: Add a brief delay then refresh data
        Future.delayed(const Duration(seconds: 1), () {
          if (!isClosed) {
            add(const LoadEmotionHistoryEvent(forceRefresh: true));
          }
        });
      }

      Logger.info('✅ User stats updated after emotion logging');
    }
  } catch (e) {
    Logger.error('❌ Error updating stats after emotion logged', e);
    // Don't emit error state, just log the error
    // The emotion logging itself succeeded, this is just a UI update issue
  }
}

// Helper method to calculate new average mood score
double _calculateNewAverageScore(double currentAvg, int currentCount, double newScore) {
  if (currentCount == 0) return newScore;
  return ((currentAvg * currentCount) + newScore) / (currentCount + 1);
}

// Helper method to determine if streak should be updated
bool _shouldUpdateStreak(DateTime? lastMoodLog) {
  if (lastMoodLog == null) return true;

  final now = DateTime.now();
  final lastLog = DateTime(
    lastMoodLog.year,
    lastMoodLog.month,
    lastMoodLog.day,
  );
  final today = DateTime(now.year, now.month, now.day);

  // Update streak if it's a new day
  return today.difference(lastLog).inDays >= 1;
}

  Future<void> _onLoadEmotionHistory(
    LoadEmotionHistoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Prevent duplicate requests
      if (_isLoadingEmotionHistory) {
        Logger.info('⏳ Emotion history already loading, skipping...');
        return;
      }

      // Check cache first (unless forcing refresh)
      if (!event.forceRefresh && _lastEmotionHistoryLoad != null) {
        final timeSinceLastLoad = DateTime.now().difference(_lastEmotionHistoryLoad!);
        if (timeSinceLastLoad < _cacheDuration) {
          Logger.info('📦 Using cached emotion history');
          return;
        }
      }

      _isLoadingEmotionHistory = true;
      Logger.info('🎭 Loading emotion history...');

      // Try to get cached data first
      List<EmotionEntryModel> cachedEmotions = [];
      try {
        final localDataSource = GetIt.instance<HomeLocalDataSource>();
        final cachedData = await localDataSource.getCachedEmotionFeed();
        if (cachedData.isNotEmpty) {
          cachedEmotions = cachedData.map((data) => EmotionEntryModel.fromJson(data)).toList();
          Logger.info('📦 Found ${cachedEmotions.length} cached emotion entries');
        }
      } catch (e) {
        Logger.warning('⚠️ Could not load cached emotions: $e');
      }

      // If we have cached data and not forcing refresh, use it
      if (!event.forceRefresh && cachedEmotions.isNotEmpty) {
        Logger.info('📦 Using cached emotion data');
        if (state is HomeDashboardState) {
          final currentState = state as HomeDashboardState;
          emit(currentState.copyWith(
            emotionEntries: cachedEmotions,
          ));
        }
        _lastEmotionHistoryLoad = DateTime.now();
        _isLoadingEmotionHistory = false;
        return;
      }

      // Load fresh data from backend
      Logger.info('🌐 Fetching fresh emotion data from backend...');
      final emotions = await _emotionApiService.getUserEmotions(
        limit: 100,
        offset: 0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      // Cache the fresh data
      try {
        final localDataSource = GetIt.instance<HomeLocalDataSource>();
        final emotionData = emotions.map((e) => e.toJson()).toList();
        await localDataSource.cacheEmotionFeed(emotionData);
        Logger.info('💾 Cached ${emotions.length} emotion entries');
      } catch (e) {
        Logger.warning('⚠️ Could not cache emotion data: $e');
      }

      _lastEmotionHistoryLoad = DateTime.now();
      _isLoadingEmotionHistory = false;

      Logger.info('. Loaded ${emotions.length} emotion entries from backend');

      // Debug logging for emotion entries
      if (emotions.isNotEmpty) {
        Logger.info('🔍 DEBUG: First emotion entry: ${emotions.first.emotion} (${emotions.first.intensity}) at ${emotions.first.createdAt}');
        Logger.info('🔍 DEBUG: Last emotion entry: ${emotions.last.emotion} (${emotions.last.intensity}) at ${emotions.last.createdAt}');
      }

      // Update current state with emotion history
      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;
        
        // Update userStats with the real emotion count
        final updatedUserStats = currentState.userStats?.copyWith(
          totalMoodEntries: emotions.length,
        );
        
        emit(currentState.copyWith(
          emotionEntries: emotions,
          userStats: updatedUserStats,
        ));
        Logger.info('🔍 DEBUG: Updated HomeDashboardState with ${emotions.length} emotion entries and updated userStats');
      }

    } catch (e) {
      _isLoadingEmotionHistory = false;
      Logger.error('. Failed to load emotion history', e);
      
      // Try to use cached data as fallback
      try {
        final localDataSource = GetIt.instance<HomeLocalDataSource>();
        final cachedData = await localDataSource.getCachedEmotionFeed();
        if (cachedData.isNotEmpty) {
          final cachedEmotions = cachedData.map((data) => EmotionEntryModel.fromJson(data)).toList();
          Logger.info('📦 Using cached emotion data as fallback');
          
          if (state is HomeDashboardState) {
            final currentState = state as HomeDashboardState;
            emit(currentState.copyWith(
              emotionEntries: cachedEmotions,
            ));
          }
        }
      } catch (cacheError) {
        Logger.error('. Failed to load cached emotion data as fallback', cacheError);
      }
    }
  }

  Future<void> _onLoadWeeklyInsights(
    LoadWeeklyInsightsEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Prevent duplicate requests
      if (_isLoadingWeeklyInsights) {
        Logger.info('⏳ Weekly insights already loading, skipping...');
        return;
      }

      // Check cache
      if (!event.forceRefresh && _lastWeeklyInsightsLoad != null) {
        final timeSinceLastLoad = DateTime.now().difference(_lastWeeklyInsightsLoad!);
        if (timeSinceLastLoad < _cacheDuration) {
          Logger.info('📦 Using cached weekly insights');
          return;
        }
      }

      _isLoadingWeeklyInsights = true;
      Logger.info('📈 Loading weekly insights from backend...');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        // Get weekly insights from backend
        final weeklyInsightsData = await _emotionApiService.getWeeklyInsights();

        // Create weekly insights model from backend data
        final weeklyInsights = WeeklyInsightsModel(
          mostCommonMood: weeklyInsightsData['mostCommonEmotion'] ?? 'neutral',
          averageMoodScore: (weeklyInsightsData['averageIntensity'] ?? 3.0).toDouble(),
          totalEntries: weeklyInsightsData['totalEntries'] ?? 0,
          currentStreak: currentState.userStats?.streakDays ?? 0,
          lastActivity: (weeklyInsightsData['lastActivity'] != null && weeklyInsightsData['lastActivity'].isNotEmpty)
              ? DateTime.parse(weeklyInsightsData['lastActivity'])
              : DateTime.fromMillisecondsSinceEpoch(0),
          moodDistribution: Map<String, int>.from(weeklyInsightsData['stats']?['emotionBreakdown'] ?? {}),
          insights: List<String>.from(weeklyInsightsData['insights'] ?? []),
          weekProgress: _calculateWeekProgress(currentState.emotionEntries),
        );

        _lastWeeklyInsightsLoad = DateTime.now();
        _isLoadingWeeklyInsights = false;

        emit(
          currentState.copyWith(
            weeklyInsights: weeklyInsights,
          ),
        );

        Logger.info('. Weekly insights loaded successfully');
      }
    } catch (e) {
      _isLoadingWeeklyInsights = false;
      Logger.error('. Failed to load weekly insights', e);
      
      // Don't emit error state for weekly insights loading
      // Just log the error and continue
    }
  }

  Future<void> _onLoadTodaysJourney(
    LoadTodaysJourneyEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🌅 Loading today\'s emotion journey...');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        // Get today's emotions from backend
        final todaysEmotions = await _emotionApiService.getTodaysJourney();

        emit(
          currentState.copyWith(
            todaysEmotions: todaysEmotions,
          ),
        );

        Logger.info('. Today\'s journey loaded: ${todaysEmotions.length} emotions');
      }
    } catch (e) {
      Logger.error('. Failed to load today\'s journey', e);
      // Don't emit error state, just log the error
    }
  }

  Future<void> _onLoadEmotionCalendar(
    LoadEmotionCalendarEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('📅 Loading emotion calendar data...');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        // Get calendar data from backend
        final calendarData = await _emotionApiService.getEmotionCalendar(
          month: event.month,
        );

        emit(
          currentState.copyWith(
            emotionCalendarData: calendarData,
            selectedMonth: event.month,
          ),
        );

        Logger.info('. Calendar data loaded for ${calendarData.length} days');
      }
    } catch (e) {
      Logger.error('. Failed to load calendar data', e);
      // Don't emit error state, just log the error
    }
  }

  Future<void> _onSelectCalendarDate(
    SelectCalendarDateEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('📅 Calendar date selected: ${event.selectedDate}');

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        emit(
          currentState.copyWith(
            selectedDate: event.selectedDate,
          ),
        );

        // Optionally load emotions for the selected date
        final dateKey = '${event.selectedDate.year}-${event.selectedDate.month.toString().padLeft(2, '0')}-${event.selectedDate.day.toString().padLeft(2, '0')}';
        final emotionsForDate = currentState.emotionCalendarData?[dateKey] ?? [];

        emit(
          currentState.copyWith(
            selectedDateEmotions: emotionsForDate,
          ),
        );

        Logger.info('. Selected date emotions: ${emotionsForDate.length} entries');
      }
    } catch (e) {
      Logger.error('. Failed to select calendar date', e);
    }
  }

  Future<void> _onLogEmotion(
    LogEmotionEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🎭 Logging new emotion: ${event.emotion}');

      // Log emotion to backend
      final result = await _emotionApiService.logEmotion(
        emotion: event.emotion,
        intensity: event.intensity,
        note: event.note,
        tags: event.tags,
        location: event.location,
        context: event.context,
      );

      if (state is HomeDashboardState) {
        final currentState = state as HomeDashboardState;

        // Create new emotion entry
        final newEmotion = EmotionEntryModel(
          id: result['data']?['emotion']?['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '', // Will be set by backend
          type: event.emotion,
          emotion: event.emotion,
          intensity: event.intensity.toInt(),
          note: event.note ?? '',
          tags: event.tags ?? [],
          createdAt: DateTime.now(),
          hasLocation: false,
          timeOfDay: _determineTimeOfDay(),
        );

        // Add to current emotion entries
        final updatedEmotions = [newEmotion, ...currentState.emotionEntries];

        emit(
          currentState.copyWith(
            emotionEntries: updatedEmotions,
          ),
        );

        Logger.info('. Emotion logged successfully');
      }
    } catch (e) {
      Logger.error('. Failed to log emotion', e);
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
        Logger.warning('. Unknown operation to retry: ${event.operation}');
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

        Logger.info('. Home data updated successfully');
      }
    } catch (e) {
      Logger.error('. Error updating home data', e);
    }
  }

  Future<void> _onInitializeHome(
    InitializeHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      Logger.info('🏠 Initializing home with emotion data persistence...');
      
      // Load cached emotion data immediately for better UX
      await _loadCachedEmotionData(emit);
      
      // Then load fresh data from backend
      add(const LoadEmotionHistoryEvent(forceRefresh: false));
      add(const LoadWeeklyInsightsEvent(forceRefresh: false));
      
      Logger.info('. Home initialization completed');
    } catch (e) {
      Logger.error('. Error initializing home', e);
      emit(const HomeError(message: 'Failed to initialize home'));
    }
  }

  /// Load cached emotion data for immediate display
  Future<void> _loadCachedEmotionData(Emitter<HomeState> emit) async {
    try {
      Logger.info('📦 Loading cached emotion data for immediate display...');
      
      final localDataSource = GetIt.instance<HomeLocalDataSource>();
      final cachedData = await localDataSource.getCachedEmotionFeed();
      
      if (cachedData.isNotEmpty) {
        final cachedEmotions = cachedData.map((data) => EmotionEntryModel.fromJson(data)).toList();
        Logger.info('📦 Loaded ${cachedEmotions.length} cached emotion entries');
        
        if (state is HomeDashboardState) {
          final currentState = state as HomeDashboardState;
          emit(currentState.copyWith(
            emotionEntries: cachedEmotions,
          ));
        }
      } else {
        Logger.info('📦 No cached emotion data found');
      }
    } catch (e) {
      Logger.warning('⚠️ Could not load cached emotion data: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  List<String> _generateInsightsFromData(Map<String, dynamic> emotionSummary) {
    final insights = <String>[];
    
    final totalEmotions = emotionSummary['totalEmotions'] ?? 0;
    final averageIntensity = emotionSummary['averageIntensity'] ?? 3.0;
    final mostCommonEmotion = emotionSummary['mostCommonEmotion'] ?? 'neutral';
    
    if (totalEmotions == 0) {
      insights.add('Start logging your emotions to get personalized insights');
      insights.add('Try logging at least one emotion per day');
    } else if (totalEmotions < 3) {
      insights.add('Great start! Try logging emotions more frequently');
      insights.add('Your most common emotion this week was $mostCommonEmotion');
    } else {
      insights.add('Your most common emotion this week was $mostCommonEmotion');
      
      if (averageIntensity > 4.0) {
        insights.add('You\'ve been experiencing strong emotions this week');
      } else if (averageIntensity < 2.0) {
        insights.add('Your emotions have been relatively mild this week');
      } else {
        insights.add('Your emotional intensity has been balanced this week');
      }
    }
    
    return insights;
  }

  double _calculateWeekProgress(List<EmotionEntryModel> emotionEntries) {
    if (emotionEntries.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekEmotions = emotionEntries.where((emotion) {
      return emotion.createdAt.isAfter(weekStart) && 
             emotion.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
    
    // Assume 7 emotions per week is 100% progress
    return (weekEmotions / 7.0).clamp(0.0, 1.0);
  }

  // Helper method to determine time of day
  String _determineTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  // ============================================================================
  // IMPLEMENTATION METHODS - FIXED
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
      Logger.info('🏠 Loading home data... (forceRefresh: $forceRefresh)');
      emit(const HomeLoading());

      final result = await loadHomeData(NoParams());

      result.fold(
        (failure) {
          Logger.error(
            '💥 Home data load failure: ${failure.runtimeType} - ${failure.message}',
            failure.message,
          );

          // . Check for authentication failures and redirect to login
          if (_isAuthenticationFailure(failure)) {
            Logger.warning('🔑 Authentication failure detected, redirecting to login');
            _handleAuthenticationFailure(emit);
            return;
          }

          // . Proper error handling with user-friendly messages and retry options
          emit(HomeError(
            message: _getFriendlyErrorMessage(failure.message),
            canRetry: true,
            retryAction: 'load_home_data',
          ));
        },
        (homeDataEntity) {
          Logger.info('. Home data loaded successfully');
          _lastHomeDataLoad = DateTime.now();

          final homeData = HomeDataModel.fromEntity(homeDataEntity);

          // CRITICAL FIX: Always go to dashboard
          Logger.info('🚀 Calling _loadUserStatsForDashboard');
          _loadUserStatsForDashboard(homeData, emit);
        },
      );
    } catch (e, stack) {
      Logger.error('. Unexpected error loading home data', e, stack);

      // . Emit proper error state instead of mock data
      emit(HomeError(
        message: 'Unable to load your dashboard. Please check your connection and try again.',
        canRetry: true,
        retryAction: 'load_home_data',
        originalError: e.toString(),
      ));
    } finally {
      _isLoadingHomeData = false;
    }
  }

  // CRITICAL FIX: Completely rewritten method to ensure dashboard state is always emitted
  Future<void> _loadUserStatsForDashboard(
    HomeDataModel homeData,
    Emitter<HomeState> emit,
  ) async {
    Logger.info('. Starting _loadUserStatsForDashboard');

    // CRITICAL: ALWAYS emit dashboard state immediately with default stats
    final defaultUserStats = _createNewUserStats();

    if (!emit.isDone) {
      Logger.info('🚀 FORCE EMITTING HomeDashboardState immediately');
      emit(HomeDashboardState(homeData: homeData, userStats: defaultUserStats));
    }

    // Now try to load actual user stats in the background
    if (_isLoadingUserStats) {
      Logger.info('. User stats already loading, dashboard already shown');
      return;
    }

    _isLoadingUserStats = true;

    try {
      Logger.info('. Loading actual user stats in background...');

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('. Failed to load user stats: ${failure.message}');
          // Don't emit error - dashboard is already shown with default stats
          Logger.info(
            '. Keeping dashboard with default stats due to user stats failure',
          );
        },
        (userStatsEntity) {
          Logger.info('. User stats loaded - updating dashboard');
          _lastUserStatsLoad = DateTime.now();

          try {
            Logger.info('🔍 Creating UserStatsModel from entity...');
            Logger.info('🔍 Entity longestStreak: ${userStatsEntity.longestStreak}');
            Logger.info('🔍 Entity totalFriends: ${userStatsEntity.totalFriends}');
            Logger.info('🔍 Entity helpedFriends: ${userStatsEntity.helpedFriends}');
            Logger.info('🔍 Entity badgesEarned: ${userStatsEntity.badgesEarned}');
            
            final userStats = UserStatsModel.fromEntity(userStatsEntity);
            
            Logger.info('✅ UserStatsModel created successfully');

            // Update dashboard with real stats
            if (!emit.isDone) {
              Logger.info('🔄 Updating dashboard with real user stats');
              emit(HomeDashboardState(homeData: homeData, userStats: userStats));
            }
          } catch (e) {
            Logger.error('❌ Error creating UserStatsModel from entity: $e');
            Logger.error('❌ Entity data: ${userStatsEntity.toString()}');
            // Use default stats instead
            final defaultStats = _createNewUserStats();
            if (!emit.isDone) {
              emit(HomeDashboardState(homeData: homeData, userStats: defaultStats));
            }
          }
        },
      );
    } catch (e) {
      Logger.error('. Error loading user stats in background', e);
      // Don't emit error - dashboard is already shown with default stats
      Logger.info('. Keeping dashboard with default stats due to exception');
    } finally {
      _isLoadingUserStats = false;
    }

    Logger.info(
      '. _loadUserStatsForDashboard completed - dashboard should be visible',
    );
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
          Logger.error('. Navigation failed', failure.message);

          // Handle navigation gracefully in development
          if (AppConfig.isDevelopmentMode) {
            Logger.info('. Navigation handled gracefully in development');
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
          Logger.info('. Navigation successful');
          // The state change will be handled by subsequent events
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error during navigation', e);

      // Handle navigation error gracefully in development
      if (AppConfig.isDevelopmentMode) {
        Logger.info('. Navigation exception handled in development');
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
      Logger.info('. User stats already loading, ignoring duplicate request');
      return;
    }

    try {
      Logger.info('. Refreshing user stats... (forceRefresh: $forceRefresh)');

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
              '. Failed to refresh user stats: ${failure.message}',
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
            Logger.info('. User stats refreshed successfully');
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
          '. Attempted to refresh stats but not in dashboard state',
        );
      }
    } catch (e) {
      Logger.error('. Unexpected error refreshing user stats', e);

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
      Logger.info('. User stats already loading, ignoring duplicate request');
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
      Logger.info('. Loading user stats... (forceRefresh: $forceRefresh)');

      final result = await getUserStats(NoParams());

      result.fold(
        (failure) {
          Logger.warning('. Failed to load user stats: ${failure.message}');

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
          Logger.info('. User stats loaded successfully');
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
      Logger.error('. Unexpected error loading user stats', e);

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

  UserStatsModel _createNewUserStats() {
    return UserStatsModel(
      totalMoodEntries: 0,
      streakDays: 0,
      totalSessions: 0,
      moodCheckins: 0,
      lastActivity: DateTime.now(),
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
      comprehensiveStats: {},
      achievements: {},
    );
  }

  UserStatsModel _createMockUserStats() {
    return UserStatsModel(
      totalMoodEntries: 5,
      streakDays: 3,
      totalSessions: 8,
      moodCheckins: 12,
      lastActivity: DateTime.now(),
      averageMoodScore: 3.5,
      mostFrequentMood: 'joy',
      lastMoodLog: DateTime.now().subtract(const Duration(hours: 2)),
      weeklyStats: {'totalEntries': 5, 'averageScore': 3.5},
      monthlyStats: {'totalEntries': 15, 'averageScore': 3.2},
      longestStreak: 7,
      totalFriends: 3,
      helpedFriends: 2,
      badgesEarned: 1,
      userLevel: 'Emotion Explorer',
      favoriteEmotion: 'joy',
      daysSinceJoined: 14,
      comprehensiveStats: {'totalEntries': 15, 'currentStreak': 3},
      achievements: {'firstEmotion': true, 'weekStreak': true},
    );
  }

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
  // AUTHENTICATION HELPER METHODS
  // ============================================================================

  /// Check if the failure is related to authentication (401, token expired, etc.)
  bool _isAuthenticationFailure(Failure failure) {
    // Check for explicit authentication failures
    if (failure is AuthFailure) {
      return true;
    }

    // Check for server failures with 401 status code
    if (failure is ServerFailure) {
      final message = failure.message.toLowerCase();
      return message.contains('unauthorized') ||
          message.contains('401') ||
          message.contains('token') ||
          message.contains('invalid token') ||
          message.contains('token expired') ||
          message.contains('authentication');
    }

    // Check the message for authentication-related keywords
    final message = failure.message.toLowerCase();
    return message.contains('unauthorized') ||
        message.contains('401') ||
        message.contains('invalid token') ||
        message.contains('token expired') ||
        message.contains('authentication failed') ||
        message.contains('session expired');
  }

  /// Handle authentication failure by clearing data and redirecting to login
  void _handleAuthenticationFailure(Emitter<HomeState> emit) {
    try {
      Logger.warning('🔑 Handling authentication failure - clearing session');

      // Clear cache
      _lastHomeDataLoad = null;
      _lastUserStatsLoad = null;
      _isLoadingHomeData = false;
      _isLoadingUserStats = false;

      // Emit authentication error state using existing HomeError
      emit(const HomeError(
        message: 'Your session has expired. Please sign in again.',
        canRetry: false, // Don't allow retry for auth errors
      ));

      // Navigate to auth screen with delay to ensure state is emitted
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          Logger.info('🔄 Redirecting to auth screen due to authentication failure');
          NavigationService.safeNavigate(
            AppRouter.authChoice,
            clearStack: true,
          );
          NavigationService.showWarningSnackBar(
            'Your session has expired. Please sign in again.',
          );
        }
      });
    } catch (e) {
      Logger.error('. Error handling authentication failure', e);
      // Fallback - still try to navigate to auth
      NavigationService.safeNavigate(
        AppRouter.authChoice,
        clearStack: true,
      );
    }
  }

  // ============================================================================
  // OVERRIDE METHODS
  // ============================================================================

  @override
  void add(HomeEvent event) {
    // ✅ CRITICAL FIX: Add safety check before adding events
    if (isClosed) {
      Logger.warning('🏠 Home BLoC: Cannot add event after close: ${event.runtimeType}');
      return;
    }
    
    super.add(event);
  }

  @override
  void onTransition(Transition<HomeEvent, HomeState> transition) {
    super.onTransition(transition);
    
    // ✅ CRITICAL FIX: Add safety check to prevent events after close
    if (isClosed) {
      Logger.warning('🏠 Home BLoC: Attempted to add event after close: ${transition.event.runtimeType}');
      return;
    }
    
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
