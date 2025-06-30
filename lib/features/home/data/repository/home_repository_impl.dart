import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';

import '../../domain/entity/home_data_entity.dart';
import '../../domain/repository/home_repository.dart';
import '../data_source/local/home_local_data_source.dart';
import '../data_source/remote/home_remote_data_source.dart';
import '../model/home_data_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
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
      if (await networkInfo.isConnected) {
        // Try to get from remote first
        final remoteHomeData = await remoteDataSource.getHomeData();

        // Convert Map to HomeDataModel
        final homeDataModel = HomeDataModel.fromJson(remoteHomeData);

        // Cache the data locally
        await localDataSource.cacheHomeData(homeDataModel);

        // Convert model to entity and return
        return Right(homeDataModel.toEntity());
      } else {
        // Get from local cache if no internet
        final localHomeData = await localDataSource.getLastHomeData();
        return Right(localHomeData.toEntity());
      }
    } on ServerException catch (e) {
      // Try local cache if server fails
      try {
        final localHomeData = await localDataSource.getLastHomeData();
        return Right(localHomeData.toEntity());
      } on CacheException {
        return Left(ServerFailure(message: e.message));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, HomeDataEntity>> markFirstTimeLoginComplete() async {
    try {
      if (await networkInfo.isConnected) {
        // Try to update on server first
        try {
          // Update locally first
          final updatedHomeData = await localDataSource
              .markFirstTimeLoginComplete();

          // Try to sync with server (if server has this endpoint)
          // For now, just return the local update
          return Right(updatedHomeData.toEntity());
        } catch (e) {
          // If server doesn't have this endpoint, just update locally
          final updatedHomeData = await localDataSource
              .markFirstTimeLoginComplete();
          return Right(updatedHomeData.toEntity());
        }
      } else {
        // Update locally only
        final updatedHomeData = await localDataSource
            .markFirstTimeLoginComplete();
        return Right(updatedHomeData.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isFirstTimeLogin() async {
    try {
      final homeData = await localDataSource.getLastHomeData();
      return Right(homeData.isFirstTimeLogin);
    } on CacheException {
      // If no local data, assume first time
      return const Right(true);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to check login status: ${e.toString()}'),
      );
    }
  }
}
