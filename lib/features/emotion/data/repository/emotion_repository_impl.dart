import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/emotion_entity.dart';
import '../../domain/repository/emotion_repository.dart';
import '../data_source/local/emotion_local_data_source.dart';
import '../data_source/remote/emotion_remote_data_source.dart';

class EmotionRepositoryImpl implements EmotionRepository {
  final EmotionRemoteDataSource remoteDataSource;
  final EmotionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const EmotionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, EmotionEntity>> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    String? context,
    String? memory,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      Logger.info('🎭 Repository: Logging emotion: $emotion');

      final emotionData = {
        'emotion': emotion,
        'intensity': intensity,
        'timestamp': DateTime.now().toIso8601String(),
        if (context != null) 'context': {'trigger': context},
        if (memory != null)
          'memory': {'description': memory, 'isPrivate': true},
        if (latitude != null && longitude != null)
          'location': {
            'coordinates': [longitude, latitude],
            'type': 'Point',
          },
        if (additionalData != null) ...additionalData,
      };

      await localDataSource.cacheUserEmotion(emotionData);

      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDataSource.logEmotion(
            userId: userId,
            emotion: emotion,
            intensity: intensity,
            context: context,
            memory: memory,
            latitude: latitude,
            longitude: longitude,
            additionalData: additionalData,
          );

          final emotionEntity = EmotionEntity(
            id:
                result['emotionId'] ??
                result['data']?['_id'] ??
                'local_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            emotion: emotion,
            intensity: intensity,
            context: context,
            memory: memory,
            timestamp: DateTime.now(),
            latitude: latitude,
            longitude: longitude,
            additionalData: additionalData,
          );

          Logger.info(
            '. Repository: Emotion logged successfully to remote and local',
          );
          return Right(emotionEntity);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to sync emotion to remote, saved locally: $e',
          );

          final emotionEntity = EmotionEntity(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            emotion: emotion,
            intensity: intensity,
            context: context,
            memory: memory,
            timestamp: DateTime.now(),
            latitude: latitude,
            longitude: longitude,
            additionalData: additionalData,
          );

          return Right(emotionEntity);
        }
      } else {
        Logger.info('📱 Repository: No network, emotion saved locally');

        final emotionEntity = EmotionEntity(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          emotion: emotion,
          intensity: intensity,
          context: context,
          memory: memory,
          timestamp: DateTime.now(),
          latitude: latitude,
          longitude: longitude,
          additionalData: additionalData,
        );

        return Right(emotionEntity);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to log emotion', e);
      return Left(
        ServerFailure(message: 'Failed to log emotion: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<EmotionEntity>>> getEmotionFeed({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📰 Repository: Getting emotion feed...');

      if (!forceRefresh) {
        final cachedFeed = await localDataSource.getCachedEmotionFeed();
        if (cachedFeed.isNotEmpty) {
          Logger.info('. Repository: Returning cached emotion feed');
          final entities = cachedFeed
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteFeed = await remoteDataSource.getEmotionFeed(
            limit: limit,
            offset: offset,
          );

          await localDataSource.cacheEmotionFeed(remoteFeed);

          Logger.info(
            '. Repository: Emotion feed fetched from remote and cached',
          );
          final entities = remoteFeed
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch emotion feed from remote: $e',
          );

          final cachedFeed = await localDataSource.getCachedEmotionFeed();
          if (cachedFeed.isNotEmpty) {
            Logger.info(
              '📱 Repository: Returning cached emotion feed as fallback',
            );
            final entities = cachedFeed
                .map((data) => EmotionEntity.fromJson(data))
                .toList();
            return Right(entities);
          }
        }
      }

      Logger.warning(
        '. Repository: No emotion feed available (no cache, no network)',
      );
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get emotion feed', e);
      return Left(
        ServerFailure(message: 'Failed to get emotion feed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGlobalEmotionStats({
    String timeframe = '24h',
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('🌍 Repository: Getting global emotion stats...');

      if (!forceRefresh) {
        final cachedStats = await localDataSource.getCachedGlobalStats();
        if (cachedStats != null) {
          Logger.info('. Repository: Returning cached global emotion stats');
          return Right(cachedStats);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getGlobalEmotionStats(
            timeframe: timeframe,
          );

          await localDataSource.cacheGlobalStats(remoteStats);

          Logger.info(
            '. Repository: Global emotion stats fetched from remote and cached',
          );
          return Right(remoteStats);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch global stats from remote: $e',
          );

          final cachedStats = await localDataSource.getCachedGlobalStats();
          if (cachedStats != null) {
            Logger.info(
              '📱 Repository: Returning cached global stats as fallback',
            );
            return Right(cachedStats);
          }
        }
      }

      Logger.warning(
        '. Repository: No global stats available, returning defaults',
      );
      final defaultStats = {
        'totalUsers': 0,
        'totalEmotions': 0,
        'emotionDistribution': <String, double>{},
        'topEmotions': <String, int>{},
        'mostCommonEmotion': 'joy',
        'averageIntensity': 0.5,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      return Right(defaultStats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get global emotion stats', e);
      return Left(
        ServerFailure(
          message: 'Failed to get global emotion stats: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGlobalHeatmap({
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('🗺️ Repository: Getting global emotion heatmap...');

      if (!forceRefresh) {
        final cachedHeatmap = await localDataSource.getCachedHeatmapData();
        if (cachedHeatmap != null) {
          Logger.info('. Repository: Returning cached global heatmap');
          return Right(cachedHeatmap);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteHeatmap = await remoteDataSource.getGlobalHeatmap();

          await localDataSource.cacheHeatmapData(remoteHeatmap);

          Logger.info(
            '. Repository: Global heatmap fetched from remote and cached',
          );
          return Right(remoteHeatmap);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch heatmap from remote: $e',
          );

          final cachedHeatmap = await localDataSource.getCachedHeatmapData();
          if (cachedHeatmap != null) {
            Logger.info('📱 Repository: Returning cached heatmap as fallback');
            return Right(cachedHeatmap);
          }
        }
      }

      Logger.warning(
        '. Repository: No heatmap data available, returning empty',
      );
      final emptyHeatmap = {
        'locations': <Map<String, dynamic>>[],
        'summary': {
          'totalLocations': 0,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      };
      return Right(emptyHeatmap);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get global heatmap', e);
      return Left(
        ServerFailure(message: 'Failed to get global heatmap: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<EmotionEntity>>> getUserEmotionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('. Repository: Getting user emotion history...');

      final localHistory = await localDataSource.getUserEmotionHistory();

      if (!forceRefresh && localHistory.isNotEmpty) {
        Logger.info('. Repository: Returning local emotion history');
        final entities = localHistory
            .map((data) => EmotionEntity.fromJson(data))
            .toList();
        return Right(entities);
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteHistory = await remoteDataSource.getUserEmotions(
            userId: userId,
            limit: limit,
            offset: offset,
          );

          Logger.info('. Repository: User emotion history fetched from remote');
          final entities = remoteHistory
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch user emotions from remote: $e',
          );
        }
      }

      Logger.info('📱 Repository: Returning local emotion history as fallback');
      final entities = localHistory
          .map((data) => EmotionEntity.fromJson(data))
          .toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get user emotion history', e);
      return Left(
        ServerFailure(
          message: 'Failed to get user emotion history: ${e.toString()}',
        ),
      );
    }
  }


  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserEmotionStats({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📊 Repository: Getting user emotion stats...');

      if (!forceRefresh) {
        final cachedStats = await localDataSource.getCachedUserStats(userId);
        if (cachedStats.isNotEmpty) {
          Logger.info('. Repository: Returning cached user stats');
          return Right(cachedStats);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getUserEmotionStats(userId);

          await localDataSource.cacheUserStats(userId, remoteStats);

          Logger.info('. Repository: User stats fetched from remote and cached');
          return Right(remoteStats);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch user stats from remote: $e',
          );

          final cachedStats = await localDataSource.getCachedUserStats(userId);
          if (cachedStats.isNotEmpty) {
            Logger.info(
              '📱 Repository: Returning cached user stats as fallback',
            );
            return Right(cachedStats);
          }
        }
      }

      Logger.warning('. Repository: No cached user stats available');
      return Left(CacheFailure(message: 'No user stats available'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get user emotion stats', e);
      return Left(
        ServerFailure(message: 'Failed to get user emotion stats: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserInsights({
    required String userId,
    String timeframe = '30d',
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📊 Repository: Getting user insights...');

      if (!forceRefresh) {
        final cachedInsights = await localDataSource.getCachedUserInsights(userId);
        if (cachedInsights.isNotEmpty) {
          Logger.info('. Repository: Returning cached user insights');
          return Right(cachedInsights);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteInsights = await remoteDataSource.getUserInsights(
            userId: userId,
            timeframe: timeframe,
          );

          await localDataSource.cacheUserInsights(userId, remoteInsights);

          Logger.info('. Repository: User insights fetched from remote and cached');
          return Right(remoteInsights);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch user insights from remote: $e',
          );

          final cachedInsights = await localDataSource.getCachedUserInsights(userId);
          if (cachedInsights.isNotEmpty) {
            Logger.info(
              '📱 Repository: Returning cached user insights as fallback',
            );
            return Right(cachedInsights);
          }
        }
      }

      Logger.warning('. Repository: No cached user insights available');
      return Left(CacheFailure(message: 'No user insights available'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get user insights', e);
      return Left(
        ServerFailure(message: 'Failed to get user insights: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserAnalytics({
    required String userId,
    String timeframe = '7d',
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📈 Repository: Getting user analytics...');

      if (!forceRefresh) {
        final cachedAnalytics = await localDataSource.getCachedUserAnalytics(userId);
        if (cachedAnalytics.isNotEmpty) {
          Logger.info('. Repository: Returning cached user analytics');
          return Right(cachedAnalytics);
        }
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getUserAnalytics(
            userId: userId,
            timeframe: timeframe,
          );

          await localDataSource.cacheUserAnalytics(userId, remoteAnalytics);

          Logger.info('. Repository: User analytics fetched from remote and cached');
          return Right(remoteAnalytics);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch user analytics from remote: $e',
          );

          final cachedAnalytics = await localDataSource.getCachedUserAnalytics(userId);
          if (cachedAnalytics.isNotEmpty) {
            Logger.info(
              '📱 Repository: Returning cached user analytics as fallback',
            );
            return Right(cachedAnalytics);
          }
        }
      }

      Logger.warning('. Repository: No cached user analytics available');
      return Left(CacheFailure(message: 'No user analytics available'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get user analytics', e);
      return Left(
        ServerFailure(message: 'Failed to get user analytics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearEmotionCache() async {
    try {
      Logger.info('🧹 Repository: Clearing emotion cache...');
      await localDataSource.clearEmotionCache();
      Logger.info('. Repository: Emotion cache cleared successfully');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to clear emotion cache', e);
      return Left(
        CacheFailure(message: 'Failed to clear emotion cache: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      Logger.info('🕐 Repository: Checking cache staleness...');
      final isStale = await localDataSource.isCacheStale(maxAge: maxAge);
      Logger.info('. Repository: Cache staleness checked - isStale: $isStale');
      return Right(isStale);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to check cache staleness', e);
      return Left(
        CacheFailure(
          message: 'Failed to check cache staleness: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> syncLocalEmotions() async {
    try {
      Logger.info('🔄 Repository: Syncing local emotions...');

      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No internet connection for sync'));
      }

      final localEmotions = await localDataSource.getUserEmotionHistory();

      if (localEmotions.isEmpty) {
        Logger.info('. Repository: No local emotions to sync');
        return const Right(0);
      }

      final syncResult = await remoteDataSource.syncEmotions(
        emotions: localEmotions,
      );
      final syncedCount = syncResult['syncedCount'] ?? 0;

      Logger.info('. Repository: Synced $syncedCount emotions');
      return Right(syncedCount);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to sync local emotions', e);
      return Left(
        ServerFailure(
          message: 'Failed to sync local emotions: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getEmotionAnalytics({
    required String userId,
    String period = 'week',
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📈 Repository: Getting emotion analytics for $userId');

      if (await networkInfo.isConnected) {
        try {
          final analytics = await remoteDataSource.getUserEmotionAnalytics(
            userId: userId,
            period: period,
          );
          Logger.info('. Repository: Emotion analytics fetched from remote');
          return Right(analytics);
        } catch (e) {
          Logger.warning(
            '. Repository: Failed to fetch analytics from remote: $e',
          );
        }
      }

      final localEmotions = await localDataSource.getUserEmotionHistory();
      final basicAnalytics = {
        'userId': userId,
        'period': period,
        'totalEmotions': localEmotions.length,
        'generatedAt': DateTime.now().toIso8601String(),
        'source': 'local',
      };

      return Right(basicAnalytics);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('. Repository: Failed to get emotion analytics', e);
      return Left(
        ServerFailure(
          message: 'Failed to get emotion analytics: ${e.toString()}',
        ),
      );
    }
  }
}
