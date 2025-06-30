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

      // Always try to cache locally first
      await localDataSource.cacheUserEmotion(emotionData);

      // Try to sync with remote if network is available
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

          // Create emotion entity from result
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
            '✅ Repository: Emotion logged successfully to remote and local',
          );
          return Right(emotionEntity);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to sync emotion to remote, saved locally: $e',
          );

          // Create emotion entity for local storage
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

        // Create emotion entity for local storage
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
      Logger.error('❌ Repository: Failed to log emotion', e);
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

      // Try to get from cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedFeed = await localDataSource.getCachedEmotionFeed();
        if (cachedFeed.isNotEmpty) {
          Logger.info('✅ Repository: Returning cached emotion feed');
          final entities = cachedFeed
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        }
      }

      // Try to get from remote if network is available
      if (await networkInfo.isConnected) {
        try {
          final remoteFeed = await remoteDataSource.getEmotionFeed(
            limit: limit,
            offset: offset,
          );

          // Cache the result
          await localDataSource.cacheEmotionFeed(remoteFeed);

          Logger.info(
            '✅ Repository: Emotion feed fetched from remote and cached',
          );
          final entities = remoteFeed
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch emotion feed from remote: $e',
          );

          // Fall back to cache
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

      // No cache and no network
      Logger.warning(
        '⚠️ Repository: No emotion feed available (no cache, no network)',
      );
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Repository: Failed to get emotion feed', e);
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

      // Try to get from cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedStats = await localDataSource.getCachedGlobalStats();
        if (cachedStats != null) {
          Logger.info('✅ Repository: Returning cached global emotion stats');
          return Right(cachedStats);
        }
      }

      // Try to get from remote if network is available
      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getGlobalEmotionStats(
            timeframe: timeframe,
          );

          // Cache the result
          await localDataSource.cacheGlobalStats(remoteStats);

          Logger.info(
            '✅ Repository: Global emotion stats fetched from remote and cached',
          );
          return Right(remoteStats);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch global stats from remote: $e',
          );

          // Fall back to cache
          final cachedStats = await localDataSource.getCachedGlobalStats();
          if (cachedStats != null) {
            Logger.info(
              '📱 Repository: Returning cached global stats as fallback',
            );
            return Right(cachedStats);
          }
        }
      }

      // No cache and no network - return default stats
      Logger.warning(
        '⚠️ Repository: No global stats available, returning defaults',
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
      Logger.error('❌ Repository: Failed to get global emotion stats', e);
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

      // Try to get from cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedHeatmap = await localDataSource.getCachedHeatmapData();
        if (cachedHeatmap != null) {
          Logger.info('✅ Repository: Returning cached global heatmap');
          return Right(cachedHeatmap);
        }
      }

      // Try to get from remote if network is available
      if (await networkInfo.isConnected) {
        try {
          final remoteHeatmap = await remoteDataSource.getGlobalHeatmap();

          // Cache the result
          await localDataSource.cacheHeatmapData(remoteHeatmap);

          Logger.info(
            '✅ Repository: Global heatmap fetched from remote and cached',
          );
          return Right(remoteHeatmap);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch heatmap from remote: $e',
          );

          // Fall back to cache
          final cachedHeatmap = await localDataSource.getCachedHeatmapData();
          if (cachedHeatmap != null) {
            Logger.info('📱 Repository: Returning cached heatmap as fallback');
            return Right(cachedHeatmap);
          }
        }
      }

      // No cache and no network - return empty heatmap
      Logger.warning(
        '⚠️ Repository: No heatmap data available, returning empty',
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
      Logger.error('❌ Repository: Failed to get global heatmap', e);
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
      Logger.info('👤 Repository: Getting user emotion history...');

      // Always get local history first
      final localHistory = await localDataSource.getUserEmotionHistory();

      // If not forcing refresh and we have local data, return it
      if (!forceRefresh && localHistory.isNotEmpty) {
        Logger.info('✅ Repository: Returning local emotion history');
        final entities = localHistory
            .map((data) => EmotionEntity.fromJson(data))
            .toList();
        return Right(entities);
      }

      // Try to get from remote if network is available
      if (await networkInfo.isConnected) {
        try {
          final remoteHistory = await remoteDataSource.getUserEmotions(
            userId: userId,
            limit: limit,
            offset: offset,
          );

          Logger.info('✅ Repository: User emotion history fetched from remote');
          final entities = remoteHistory
              .map((data) => EmotionEntity.fromJson(data))
              .toList();
          return Right(entities);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch user emotions from remote: $e',
          );
        }
      }

      // Return local history as fallback
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
      Logger.error('❌ Repository: Failed to get user emotion history', e);
      return Left(
        ServerFailure(
          message: 'Failed to get user emotion history: ${e.toString()}',
        ),
      );
    }
  }

  // FIX: ADD MISSING METHOD IMPLEMENTATIONS

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserEmotionStats({
    required String userId,
    bool forceRefresh = false,
  }) async {
    try {
      Logger.info('📊 Repository: Getting user emotion stats for $userId');

      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getUserEmotionStats(
            userId,
          );
          Logger.info('✅ Repository: User emotion stats fetched from remote');
          return Right(remoteStats);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch user stats from remote: $e',
          );
        }
      }

      // Return default stats if remote fails
      final defaultStats = {
        'userId': userId,
        'totalEmotions': 0,
        'averageIntensity': 0.0,
        'emotionDistribution': <String, double>{},
        'mostCommonEmotion': null,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      return Right(defaultStats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Repository: Failed to get user emotion stats', e);
      return Left(
        ServerFailure(
          message: 'Failed to get user emotion stats: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearEmotionCache() async {
    try {
      Logger.info('🧹 Repository: Clearing emotion cache...');
      await localDataSource.clearEmotionCache();
      Logger.info('✅ Repository: Emotion cache cleared successfully');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Repository: Failed to clear emotion cache', e);
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
      Logger.info('✅ Repository: Cache staleness checked - isStale: $isStale');
      return Right(isStale);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Repository: Failed to check cache staleness', e);
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
        Logger.info('✅ Repository: No local emotions to sync');
        return const Right(0);
      }

      final syncResult = await remoteDataSource.syncEmotions(
        emotions: localEmotions,
      );
      final syncedCount = syncResult['syncedCount'] ?? 0;

      Logger.info('✅ Repository: Synced $syncedCount emotions');
      return Right(syncedCount);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Repository: Failed to sync local emotions', e);
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
          Logger.info('✅ Repository: Emotion analytics fetched from remote');
          return Right(analytics);
        } catch (e) {
          Logger.warning(
            '⚠️ Repository: Failed to fetch analytics from remote: $e',
          );
        }
      }

      // Generate basic analytics from local data
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
      Logger.error('❌ Repository: Failed to get emotion analytics', e);
      return Left(
        ServerFailure(
          message: 'Failed to get emotion analytics: ${e.toString()}',
        ),
      );
    }
  }
}
