
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/home_data_entity.dart';
import '../../domain/repository/home_repository.dart';
import '../data_source/local/home_local_data_source.dart';
import '../data_source/remote/home_remote_data_source.dart' as remote_source;
import '../model/home_data_model.dart' as local_model;
import '../model/user_stats_model.dart' as local_model;

class HomeRepositoryImpl implements HomeRepository {
  final remote_source.HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HomeDataEntity>> getHomeData() async {
    try {
      Logger.info('🏠 Getting home data...');

      if (await networkInfo.isConnected) {
        Logger.info('🌐 Network available - fetching fresh data');

        final remoteHomeData = await remoteDataSource.getHomeData();

        final localHomeData = _convertRemoteToLocalModel(remoteHomeData);

        await localDataSource.cacheHomeData(localHomeData);

        Logger.info('. Fresh home data retrieved and cached');
        return Right(localHomeData.toEntity());
      } else {
        Logger.info('📱 No network - attempting to get cached data');

        try {
          final cachedHomeData = await localDataSource.getLastHomeData();
          Logger.info('. Cached home data retrieved');
          return Right(cachedHomeData.toEntity());
        } catch (e) {
          Logger.error('. No cached data available and no network', e);
          return Left(
            CacheFailure(
              message: 'No cached data available and no network connection',
            ),
          );
        }
      }
    } on ServerException catch (e) {
      Logger.error('. Server error getting home data', e);

      try {
        final cachedHomeData = await localDataSource.getLastHomeData();
        Logger.info('. Using cached data as fallback');
        return Right(cachedHomeData.toEntity());
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      Logger.error('. Cache error getting home data', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error getting home data', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HomeDataEntity>> markFirstTimeLoginComplete() async {
    try {
      Logger.info('👋 Marking first-time login as complete...');

      if (await networkInfo.isConnected) {
        await remoteDataSource.markFirstTimeLoginComplete();
        Logger.info('. First-time login marked complete on server');
      }

      final updatedHomeData = await localDataSource
          .markFirstTimeLoginComplete();

      Logger.info('. First-time login marked complete locally');
      return Right(updatedHomeData.toEntity());
    } on ServerException catch (e) {
      Logger.error('. Server error marking first-time login complete', e);

      try {
        final updatedHomeData = await localDataSource
            .markFirstTimeLoginComplete();
        return Right(updatedHomeData.toEntity());
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      Logger.error('. Cache error marking first-time login complete', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error marking first-time login complete', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFirstTimeLogin() async {
    try {
      Logger.info('👋 Checking first-time login status...');

      if (await localDataSource.hasHomeData()) {
        final cachedHomeData = await localDataSource.getLastHomeData();
        final isFirstTime = cachedHomeData.isFirstTimeLogin;

        Logger.info('. First-time login status from cache: $isFirstTime');
        return Right(isFirstTime);
      }

      if (await networkInfo.isConnected) {
        final homeData = await getHomeData();
        return homeData.fold(
          (failure) => Left(failure),
          (entity) => Right(entity.isFirstTimeLogin),
        );
      }

      Logger.warning('. No cache and no network - assuming first time login');
      return const Right(true);
    } catch (e) {
      Logger.error('. Error checking first-time login status', e);
      return Left(
        ServerFailure(
          message: 'Error checking first-time login status: ${e.toString()}',
        ),
      );
    }
  }

  Future<Either<Failure, HomeDataEntity>> getMockHomeData() async {
    try {
      Logger.info('🧪 Creating mock home data...');

      final mockData = local_model.HomeDataModel(
        username: 'testuser',
        currentMood: 'neutral',
        streak: 0,
        isFirstTimeLogin: false,
        userStats: local_model.UserStatsModel.empty(),
        selectedAvatar: 'elephant',
        dashboardData: const {},
        lastUpdated: DateTime.now(),
      );

      Logger.info('. Mock home data created');
      return Right(mockData.toEntity());
    } catch (e) {
      Logger.error('. Error creating mock home data', e);
      return Left(
        ServerFailure(message: 'Error creating mock data: ${e.toString()}'),
      );
    }
  }

  local_model.HomeDataModel _convertRemoteToLocalModel(dynamic remoteModel) {
    try {
      if (remoteModel is local_model.HomeDataModel) {
        return remoteModel;
      }

      if (remoteModel is Map<String, dynamic>) {
        return local_model.HomeDataModel.fromJson(remoteModel);
      }

      if (remoteModel.runtimeType.toString().contains('HomeDataModel')) {
        final json = remoteModel.toJson();
        return local_model.HomeDataModel.fromJson(json);
      }

      return local_model.HomeDataModel(
        username: remoteModel.username ?? 'Unknown',
        currentMood: remoteModel.currentMood,
        streak: remoteModel.streak ?? 0,
        isFirstTimeLogin: remoteModel.isFirstTimeLogin ?? true,
        userStats: _convertRemoteUserStats(remoteModel.userStats),
        selectedAvatar: remoteModel.selectedAvatar,
        dashboardData: remoteModel.dashboardData ?? {},
        lastUpdated: remoteModel.lastUpdated ?? DateTime.now(),
      );
    } catch (e) {
      Logger.error('. Error converting remote model to local model', e);

      return local_model.HomeDataModel(
        username: 'Unknown',
        currentMood: 'neutral',
        streak: 0,
        isFirstTimeLogin: true,
        userStats: local_model.UserStatsModel.empty(),
        selectedAvatar: 'default',
        dashboardData: const {},
        lastUpdated: DateTime.now(),
      );
    }
  }

  local_model.UserStatsModel _convertRemoteUserStats(dynamic remoteUserStats) {
    try {
      if (remoteUserStats == null) {
        return local_model.UserStatsModel.empty();
      }

      if (remoteUserStats is local_model.UserStatsModel) {
        return remoteUserStats;
      }

      if (remoteUserStats is Map<String, dynamic>) {
        return local_model.UserStatsModel.fromJson(remoteUserStats);
      }

      if (remoteUserStats.runtimeType.toString().contains('UserStatsModel')) {
        final json = remoteUserStats.toJson();
        return local_model.UserStatsModel.fromJson(json);
      }

      return local_model.UserStatsModel.empty();
    } catch (e) {
      Logger.error('. Error converting remote user stats', e);
      return local_model.UserStatsModel.empty();
    }
  }


  Future<Either<Failure, HomeDataEntity>> refreshHomeData() async {
    try {
      Logger.info('🔄 Refreshing home data from server...');

      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure(message: 'No network connection'));
      }

      final remoteHomeData = await remoteDataSource.getHomeData();
      final localHomeData = _convertRemoteToLocalModel(remoteHomeData);

      await localDataSource.cacheHomeData(localHomeData);

      Logger.info('. Home data refreshed successfully');
      return Right(localHomeData.toEntity());
    } catch (e) {
      Logger.error('. Error refreshing home data', e);
      return Left(
        ServerFailure(message: 'Failed to refresh home data: ${e.toString()}'),
      );
    }
  }

  Future<Either<Failure, void>> clearCache() async {
    try {
      Logger.info('🗑️ Clearing home data cache...');
      await localDataSource.clearHomeData();
      Logger.info('. Cache cleared successfully');
      return const Right(null);
    } catch (e) {
      Logger.error('. Error clearing cache', e);
      return Left(
        CacheFailure(message: 'Failed to clear cache: ${e.toString()}'),
      );
    }
  }

  Future<bool> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    try {
      final hasData = await localDataSource.hasHomeData();
      if (!hasData) return true;

      final lastCacheTime = await localDataSource.getLastCacheTime();
      if (lastCacheTime == null) return true;

      final age = DateTime.now().difference(lastCacheTime);
      return age > maxAge;
    } catch (e) {
      Logger.error('. Error checking cache staleness', e);
return true; 
    }
  }
}
