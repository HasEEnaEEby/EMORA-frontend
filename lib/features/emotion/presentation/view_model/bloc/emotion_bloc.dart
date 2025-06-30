import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_heatmap.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/repository/emotion_repository.dart';
import '../../../domain/use_case/get_emotion_feed.dart';
import '../../../domain/use_case/get_global_emotion_stats.dart';
import '../../../domain/use_case/log_emotion.dart';

part 'emotion_event.dart';
part 'emotion_state.dart';

class EmotionBloc extends Bloc<EmotionEvent, EmotionState> {
  final LogEmotion logEmotion;
  final GetEmotionFeed getEmotionFeed;
  final GetGlobalEmotionStats getGlobalEmotionStats;
  final GetGlobalEmotionHeatmap getGlobalHeatmap;
  final EmotionRepository emotionRepository;

  // Cache for current data
  List<Map<String, dynamic>> _currentEmotionFeed = [];
  Map<String, dynamic> _currentGlobalStats = {};
  Map<String, dynamic> _currentHeatmapData = {};
  List<Map<String, dynamic>> _currentUserEmotionHistory = [];

  EmotionBloc({
    required this.logEmotion,
    required this.getEmotionFeed,
    required this.getGlobalEmotionStats,
    required this.getGlobalHeatmap,
    required this.emotionRepository,
  }) : super(EmotionInitial()) {
    on<LogEmotionEvent>(_onLogEmotion);
    on<LoadEmotionFeedEvent>(_onLoadEmotionFeed);
    on<LoadGlobalEmotionStatsEvent>(_onLoadGlobalEmotionStats);
    on<LoadGlobalHeatmapEvent>(_onLoadGlobalHeatmap);
    on<LoadUserEmotionHistoryEvent>(_onLoadUserEmotionHistory);
    on<ClearEmotionCacheEvent>(_onClearEmotionCache);
    on<RefreshAllEmotionDataEvent>(_onRefreshAllEmotionData);
    on<InitializeEmotionDataEvent>(_onInitializeEmotionData);
  }

  Future<void> _onLogEmotion(
    LogEmotionEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🎭 EmotionBloc: Logging emotion ${event.emotion}');
      emit(EmotionLoading(message: 'Logging your emotion...'));

      // Create params object for use case
      final params = LogEmotionParams(
        userId: event.userId,
        emotion: event.emotion,
        intensity: event.intensity,
        context: event.context,
        memory: event.memory,
        latitude: event.latitude,
        longitude: event.longitude,
        additionalData: event.additionalData,
      );

      final result = await logEmotion.call(params);

      result.fold(
        (failure) {
          Logger.error('❌ EmotionBloc: Failed to log emotion', failure);
          emit(
            EmotionError(
              message: 'Failed to log emotion',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (emotionEntity) {
          // Convert entity to map for backward compatibility
          final resultMap = {
            'emotionId': emotionEntity.id,
            'userId': emotionEntity.userId,
            'emotion': emotionEntity.emotion,
            'intensity': emotionEntity.intensity,
            'timestamp': emotionEntity.timestamp.toIso8601String(),
            'context': emotionEntity.context,
            'memory': emotionEntity.memory,
            'latitude': emotionEntity.latitude,
            'longitude': emotionEntity.longitude,
            'additionalData': emotionEntity.additionalData,
            'syncedToRemote': true, // Assume synced if no error
          };

          Logger.info('✅ EmotionBloc: Emotion logged successfully');
          emit(
            EmotionLogSuccess(loggedEmotion: resultMap, syncedToRemote: true),
          );

          // Refresh emotion feed to show the new emotion
          add(LoadEmotionFeedEvent(forceRefresh: true));
          add(LoadGlobalEmotionStatsEvent(forceRefresh: true));
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to log emotion', e);
      emit(
        EmotionError(
          message: 'Failed to log emotion',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onLoadEmotionFeed(
    LoadEmotionFeedEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('📰 EmotionBloc: Loading emotion feed');

      // Don't emit loading if we have cached data and not forcing refresh
      if (_currentEmotionFeed.isEmpty || event.forceRefresh) {
        emit(EmotionLoading(message: 'Loading emotion feed...'));
      }

      // Create params object for use case
      final params = GetEmotionFeedParams(
        limit: event.limit,
        offset: event.offset,
        forceRefresh: event.forceRefresh,
      );

      final result = await getEmotionFeed.call(params);

      result.fold(
        (failure) {
          Logger.error('❌ EmotionBloc: Failed to load emotion feed', failure);
          emit(
            EmotionError(
              message: 'Failed to load emotion feed',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (emotionEntities) {
          // Convert entities to maps
          _currentEmotionFeed = emotionEntities
              .map(
                (entity) => {
                  'id': entity.id,
                  'userId': entity.userId,
                  'emotion': entity.emotion,
                  'intensity': entity.intensity,
                  'timestamp': entity.timestamp.toIso8601String(),
                  'context': entity.context,
                  'memory': entity.memory,
                  'latitude': entity.latitude,
                  'longitude': entity.longitude,
                  'additionalData': entity.additionalData,
                },
              )
              .toList();

          Logger.info(
            '✅ EmotionBloc: Emotion feed loaded with ${_currentEmotionFeed.length} items',
          );
          emit(
            EmotionLoaded(
              emotionFeed: _currentEmotionFeed,
              globalStats: _currentGlobalStats,
              heatmapData: _currentHeatmapData,
              userEmotionHistory: _currentUserEmotionHistory,
              lastUpdated: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to load emotion feed', e);
      emit(
        EmotionError(
          message: 'Failed to load emotion feed',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onLoadGlobalEmotionStats(
    LoadGlobalEmotionStatsEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🌍 EmotionBloc: Loading global emotion stats');

      // Don't emit loading if we have cached data and not forcing refresh
      if (_currentGlobalStats.isEmpty || event.forceRefresh) {
        emit(EmotionLoading(message: 'Loading global stats...'));
      }

      // Create params object for use case
      final params = GetGlobalEmotionStatsParams(
        timeframe: event.timeframe,
        forceRefresh: event.forceRefresh,
      );

      final result = await getGlobalEmotionStats.call(params);

      result.fold(
        (failure) {
          Logger.error(
            '❌ EmotionBloc: Failed to load global emotion stats',
            failure,
          );
          emit(
            EmotionError(
              message: 'Failed to load global emotion stats',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (globalStats) {
          _currentGlobalStats = globalStats;

          Logger.info('✅ EmotionBloc: Global emotion stats loaded');
          emit(
            EmotionLoaded(
              emotionFeed: _currentEmotionFeed,
              globalStats: _currentGlobalStats,
              heatmapData: _currentHeatmapData,
              userEmotionHistory: _currentUserEmotionHistory,
              lastUpdated: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to load global emotion stats', e);
      emit(
        EmotionError(
          message: 'Failed to load global emotion stats',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onLoadGlobalHeatmap(
    LoadGlobalHeatmapEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🗺️ EmotionBloc: Loading global heatmap');

      // Don't emit loading if we have cached data and not forcing refresh
      if (_currentHeatmapData.isEmpty || event.forceRefresh) {
        emit(EmotionLoading(message: 'Loading global heatmap...'));
      }

      // Create params object for use case - CORRECTED
      final params = GetGlobalEmotionHeatmapParams(
        forceRefresh: event.forceRefresh,
      );

      final result = await getGlobalHeatmap.call(params);

      result.fold(
        (failure) {
          Logger.error('❌ EmotionBloc: Failed to load global heatmap', failure);
          emit(
            EmotionError(
              message: 'Failed to load global heatmap',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (heatmapEntity) {
          // Convert heatmap entity to map - CORRECTED
          _currentHeatmapData = {
            'locations': heatmapEntity.locations,
            'summary': heatmapEntity.summary,
            'lastUpdated': heatmapEntity.lastUpdated?.toIso8601String(),
          };

          Logger.info('✅ EmotionBloc: Global heatmap loaded');
          emit(
            EmotionLoaded(
              emotionFeed: _currentEmotionFeed,
              globalStats: _currentGlobalStats,
              heatmapData: _currentHeatmapData,
              userEmotionHistory: _currentUserEmotionHistory,
              lastUpdated: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to load global heatmap', e);
      emit(
        EmotionError(
          message: 'Failed to load global heatmap',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onLoadUserEmotionHistory(
    LoadUserEmotionHistoryEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('👤 EmotionBloc: Loading user emotion history');

      // Don't emit loading if we have cached data and not forcing refresh
      if (_currentUserEmotionHistory.isEmpty || event.forceRefresh) {
        emit(EmotionLoading(message: 'Loading your emotion history...'));
      }

      final result = await emotionRepository.getUserEmotionHistory(
        userId: event.userId,
        limit: event.limit,
        offset: event.offset,
        forceRefresh: event.forceRefresh,
      );

      result.fold(
        (failure) {
          Logger.error(
            '❌ EmotionBloc: Failed to load user emotion history',
            failure,
          );
          emit(
            EmotionError(
              message: 'Failed to load your emotion history',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (emotionEntities) {
          // Convert entities to maps
          _currentUserEmotionHistory = emotionEntities
              .map(
                (entity) => {
                  'id': entity.id,
                  'userId': entity.userId,
                  'emotion': entity.emotion,
                  'intensity': entity.intensity,
                  'timestamp': entity.timestamp.toIso8601String(),
                  'context': entity.context,
                  'memory': entity.memory,
                  'latitude': entity.latitude,
                  'longitude': entity.longitude,
                  'additionalData': entity.additionalData,
                },
              )
              .toList();

          Logger.info(
            '✅ EmotionBloc: User emotion history loaded with ${_currentUserEmotionHistory.length} items',
          );
          emit(
            EmotionLoaded(
              emotionFeed: _currentEmotionFeed,
              globalStats: _currentGlobalStats,
              heatmapData: _currentHeatmapData,
              userEmotionHistory: _currentUserEmotionHistory,
              lastUpdated: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to load user emotion history', e);
      emit(
        EmotionError(
          message: 'Failed to load your emotion history',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onClearEmotionCache(
    ClearEmotionCacheEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🧹 EmotionBloc: Clearing emotion cache');
      emit(EmotionLoading(message: 'Clearing cache...'));

      // Clear the repository cache
      final result = await emotionRepository.clearEmotionCache();

      result.fold(
        (failure) {
          Logger.error('❌ EmotionBloc: Failed to clear emotion cache', failure);
          emit(
            EmotionError(
              message: 'Failed to clear emotion cache',
              details: failure.message,
              errorType: _getErrorTypeFromFailure(failure),
            ),
          );
        },
        (_) {
          // Clear local cache
          _currentEmotionFeed = [];
          _currentGlobalStats = {};
          _currentHeatmapData = {};
          _currentUserEmotionHistory = [];

          Logger.info('✅ EmotionBloc: Emotion cache cleared');
          emit(EmotionCacheCleared());
        },
      );
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to clear emotion cache', e);
      emit(
        EmotionError(
          message: 'Failed to clear emotion cache',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onRefreshAllEmotionData(
    RefreshAllEmotionDataEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🔄 EmotionBloc: Refreshing all emotion data');
      emit(EmotionLoading(message: 'Refreshing all data...'));

      final List<String> failedOperations = [];

      // Load all data in parallel with error handling
      final futures = <Future>[];

      // Emotion feed
      futures.add(
        getEmotionFeed
            .call(GetEmotionFeedParams(forceRefresh: true))
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to refresh emotion feed: ${failure.message}',
                  );
                  failedOperations.add('emotion_feed');
                },
                (entities) {
                  _currentEmotionFeed = entities
                      .map(
                        (entity) => {
                          'id': entity.id,
                          'userId': entity.userId,
                          'emotion': entity.emotion,
                          'intensity': entity.intensity,
                          'timestamp': entity.timestamp.toIso8601String(),
                          'context': entity.context,
                          'memory': entity.memory,
                          'latitude': entity.latitude,
                          'longitude': entity.longitude,
                          'additionalData': entity.additionalData,
                        },
                      )
                      .toList();
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to refresh emotion feed: $e');
              failedOperations.add('emotion_feed');
            }),
      );

      // Global stats
      futures.add(
        getGlobalEmotionStats
            .call(GetGlobalEmotionStatsParams(forceRefresh: true))
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to refresh global stats: ${failure.message}',
                  );
                  failedOperations.add('global_stats');
                },
                (stats) {
                  _currentGlobalStats = stats;
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to refresh global stats: $e');
              failedOperations.add('global_stats');
            }),
      );

      // Heatmap data - CORRECTED
      futures.add(
        getGlobalHeatmap
            .call(GetGlobalEmotionHeatmapParams(forceRefresh: true))
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to refresh heatmap: ${failure.message}',
                  );
                  failedOperations.add('heatmap');
                },
                (heatmapEntity) {
                  _currentHeatmapData = {
                    'locations': heatmapEntity.locations,
                    'summary': heatmapEntity.summary,
                    'lastUpdated': heatmapEntity.lastUpdated?.toIso8601String(),
                  };
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to refresh heatmap: $e');
              failedOperations.add('heatmap');
            }),
      );

      await Future.wait(futures);

      if (failedOperations.isEmpty) {
        Logger.info('✅ EmotionBloc: All emotion data refreshed successfully');
        emit(
          EmotionLoaded(
            emotionFeed: _currentEmotionFeed,
            globalStats: _currentGlobalStats,
            heatmapData: _currentHeatmapData,
            userEmotionHistory: _currentUserEmotionHistory,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        Logger.warning('⚠️ EmotionBloc: Some data failed to refresh');
        emit(
          EmotionPartiallyLoaded(
            emotionFeed: _currentEmotionFeed.isNotEmpty
                ? _currentEmotionFeed
                : null,
            globalStats: _currentGlobalStats.isNotEmpty
                ? _currentGlobalStats
                : null,
            heatmapData: _currentHeatmapData.isNotEmpty
                ? _currentHeatmapData
                : null,
            userEmotionHistory: _currentUserEmotionHistory.isNotEmpty
                ? _currentUserEmotionHistory
                : null,
            failedOperations: failedOperations,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to refresh all emotion data', e);
      emit(
        EmotionError(
          message: 'Failed to refresh emotion data',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onInitializeEmotionData(
    InitializeEmotionDataEvent event,
    Emitter<EmotionState> emit,
  ) async {
    try {
      Logger.info('🚀 EmotionBloc: Initializing emotion data');
      emit(EmotionLoading(message: 'Initializing...'));

      final List<String> failedOperations = [];

      // Load all data in parallel with error handling
      final futures = <Future>[];

      // Emotion feed
      futures.add(
        getEmotionFeed
            .call(GetEmotionFeedParams())
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to load emotion feed: ${failure.message}',
                  );
                  failedOperations.add('emotion_feed');
                },
                (entities) {
                  _currentEmotionFeed = entities
                      .map(
                        (entity) => {
                          'id': entity.id,
                          'userId': entity.userId,
                          'emotion': entity.emotion,
                          'intensity': entity.intensity,
                          'timestamp': entity.timestamp.toIso8601String(),
                          'context': entity.context,
                          'memory': entity.memory,
                          'latitude': entity.latitude,
                          'longitude': entity.longitude,
                          'additionalData': entity.additionalData,
                        },
                      )
                      .toList();
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to load emotion feed: $e');
              failedOperations.add('emotion_feed');
            }),
      );

      // Global stats
      futures.add(
        getGlobalEmotionStats
            .call(GetGlobalEmotionStatsParams())
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to load global stats: ${failure.message}',
                  );
                  failedOperations.add('global_stats');
                },
                (stats) {
                  _currentGlobalStats = stats;
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to load global stats: $e');
              failedOperations.add('global_stats');
            }),
      );

      // Heatmap data - CORRECTED
      futures.add(
        getGlobalHeatmap
            .call(GetGlobalEmotionHeatmapParams(forceRefresh: false))
            .then((result) {
              result.fold(
                (failure) {
                  Logger.warning(
                    '⚠️ Failed to load heatmap: ${failure.message}',
                  );
                  failedOperations.add('heatmap');
                },
                (heatmapEntity) {
                  _currentHeatmapData = {
                    'locations': heatmapEntity.locations,
                    'summary': heatmapEntity.summary,
                    'lastUpdated': heatmapEntity.lastUpdated?.toIso8601String(),
                  };
                },
              );
            })
            .catchError((e) {
              Logger.warning('⚠️ Failed to load heatmap: $e');
              failedOperations.add('heatmap');
            }),
      );

      await Future.wait(futures);

      if (failedOperations.isEmpty) {
        Logger.info('✅ EmotionBloc: Emotion data initialized successfully');
        emit(
          EmotionLoaded(
            emotionFeed: _currentEmotionFeed,
            globalStats: _currentGlobalStats,
            heatmapData: _currentHeatmapData,
            userEmotionHistory: _currentUserEmotionHistory,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        Logger.warning('⚠️ EmotionBloc: Some data failed to initialize');
        emit(
          EmotionPartiallyLoaded(
            emotionFeed: _currentEmotionFeed.isNotEmpty
                ? _currentEmotionFeed
                : null,
            globalStats: _currentGlobalStats.isNotEmpty
                ? _currentGlobalStats
                : null,
            heatmapData: _currentHeatmapData.isNotEmpty
                ? _currentHeatmapData
                : null,
            userEmotionHistory: _currentUserEmotionHistory.isNotEmpty
                ? _currentUserEmotionHistory
                : null,
            failedOperations: failedOperations,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ EmotionBloc: Failed to initialize emotion data', e);
      emit(
        EmotionError(
          message: 'Failed to initialize emotion data',
          details: e.toString(),
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  // Helper method to determine error type from exceptions
  EmotionErrorType _getErrorType(dynamic error) {
    if (error is ServerException) return EmotionErrorType.server;
    if (error is CacheException) return EmotionErrorType.cache;
    if (error is NetworkException) return EmotionErrorType.network;
    if (error.toString().contains('validation') ||
        error.toString().contains('invalid')) {
      return EmotionErrorType.validation;
    }
    return EmotionErrorType.general;
  }

  // Helper method to determine error type from failures
  EmotionErrorType _getErrorTypeFromFailure(Failure failure) {
    if (failure is ServerFailure) return EmotionErrorType.server;
    if (failure is CacheFailure) return EmotionErrorType.cache;
    if (failure is NetworkFailure) return EmotionErrorType.network;
    if (failure.message.contains('validation') ||
        failure.message.contains('invalid')) {
      return EmotionErrorType.validation;
    }
    return EmotionErrorType.general;
  }

  // Convenience methods for getting current data
  List<Map<String, dynamic>> get currentEmotionFeed => _currentEmotionFeed;
  Map<String, dynamic> get currentGlobalStats => _currentGlobalStats;
  Map<String, dynamic> get currentHeatmapData => _currentHeatmapData;
  List<Map<String, dynamic>> get currentUserEmotionHistory =>
      _currentUserEmotionHistory;

  // Check if we have any data loaded
  bool get hasData =>
      _currentEmotionFeed.isNotEmpty ||
      _currentGlobalStats.isNotEmpty ||
      _currentHeatmapData.isNotEmpty ||
      _currentUserEmotionHistory.isNotEmpty;

  // Check if specific data is loaded
  bool get hasEmotionFeed => _currentEmotionFeed.isNotEmpty;
  bool get hasGlobalStats => _currentGlobalStats.isNotEmpty;
  bool get hasHeatmapData => _currentHeatmapData.isNotEmpty;
  bool get hasUserHistory => _currentUserEmotionHistory.isNotEmpty;

  // Get data counts
  int get emotionFeedCount => _currentEmotionFeed.length;
  int get userHistoryCount => _currentUserEmotionHistory.length;
  int get heatmapLocationCount =>
      (_currentHeatmapData['locations'] as List?)?.length ?? 0;

  // Initialize emotion data on first load
  void initializeEmotionData() {
    add(InitializeEmotionDataEvent());
  }

  // Refresh all data
  void refreshAllData() {
    add(RefreshAllEmotionDataEvent());
  }

  // Log a new emotion
  void logUserEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    String? context,
    String? memory,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  }) {
    add(
      LogEmotionEvent(
        userId: userId,
        emotion: emotion,
        intensity: intensity,
        context: context,
        memory: memory,
        latitude: latitude,
        longitude: longitude,
        additionalData: additionalData,
      ),
    );
  }

  // Load specific data
  void loadEmotionFeed({bool forceRefresh = false}) {
    add(LoadEmotionFeedEvent(forceRefresh: forceRefresh));
  }

  void loadGlobalStats({String timeframe = '24h', bool forceRefresh = false}) {
    add(
      LoadGlobalEmotionStatsEvent(
        timeframe: timeframe,
        forceRefresh: forceRefresh,
      ),
    );
  }

  void loadHeatmap({bool forceRefresh = false}) {
    add(LoadGlobalHeatmapEvent(forceRefresh: forceRefresh));
  }

  void loadUserHistory({required String userId, bool forceRefresh = false}) {
    add(
      LoadUserEmotionHistoryEvent(userId: userId, forceRefresh: forceRefresh),
    );
  }

  // Clear cache
  void clearCache() {
    add(ClearEmotionCacheEvent());
  }

  // Get most recent emotion
  Map<String, dynamic>? get mostRecentEmotion {
    if (_currentUserEmotionHistory.isNotEmpty) {
      return _currentUserEmotionHistory.first;
    }
    return null;
  }

  // Get emotion summary for today
  Map<String, dynamic> getTodayEmotionSummary() {
    final today = DateTime.now();
    final todayEmotions = _currentUserEmotionHistory.where((emotion) {
      final emotionDate = DateTime.tryParse(emotion['timestamp'] ?? '');
      if (emotionDate == null) return false;

      return emotionDate.year == today.year &&
          emotionDate.month == today.month &&
          emotionDate.day == today.day;
    }).toList();

    if (todayEmotions.isEmpty) {
      return {
        'count': 0,
        'emotions': [],
        'averageIntensity': 0.0,
        'mostCommon': null,
      };
    }

    // Calculate average intensity
    final totalIntensity = todayEmotions.fold<double>(
      0.0,
      (sum, emotion) => sum + (emotion['intensity'] as double? ?? 0.0),
    );
    final averageIntensity = totalIntensity / todayEmotions.length;

    // Find most common emotion
    final emotionCounts = <String, int>{};
    for (final emotion in todayEmotions) {
      final emotionName = emotion['emotion'] as String? ?? 'unknown';
      emotionCounts[emotionName] = (emotionCounts[emotionName] ?? 0) + 1;
    }

    String? mostCommon;
    int maxCount = 0;
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = emotion;
      }
    });

    return {
      'count': todayEmotions.length,
      'emotions': todayEmotions,
      'averageIntensity': averageIntensity,
      'mostCommon': mostCommon,
    };
  }

  @override
  Future<void> close() {
    Logger.info('🔄 EmotionBloc: Closing...');
    return super.close();
  }
}
