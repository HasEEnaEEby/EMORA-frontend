import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:emora_mobile_app/features/profile/data/model/profile_model.dart';
import 'package:emora_mobile_app/features/profile/data/model/user_preferences_model.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/achievement_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/user_preferences_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/repository/profile_repository.dart';

import '../datasource/profile_local_datasource.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId) async {
    try {
      // If userId is empty, try to get current user
      if (userId.isEmpty) {
        final currentUser = await authLocalDataSource.getCurrentUser();
        if (currentUser != null) {
          userId = currentUser.id;
          Logger.info('. Using current user ID: $userId');
        } else {
          Logger.warning('. No logged in user found');
          return Left(AuthFailure(message: 'No logged in user found'));
        }
      }

      Logger.info('📡 Fetching profile for user: $userId');
      final result = await remoteDataSource.getUserProfile(userId);

      // Cache the result
      await localDataSource.cacheUserProfile(result);
      Logger.info('. Profile cached successfully');

      return Right(result.toEntity());
    } on ServerException catch (e) {
      Logger.warning('. Server error, trying cache: ${e.message}');
      try {
        final cachedProfile = await localDataSource.getLastUserProfile();
        if (cachedProfile != null) {
          Logger.info('📱 Using cached profile');
          return Right(cachedProfile.toEntity());
        } else {
          Logger.warning('. No cached profile available');
          return Left(ServerFailure(message: e.message));
        }
      } catch (_) {
        return Left(ServerFailure(message: e.message));
      }
    } catch (e) {
      Logger.error('. Unexpected error getting profile: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateUserProfile(
    ProfileEntity profile,
  ) async {
    try {
      Logger.info('📝 Updating profile for: ${profile.username}');
      final profileModel = UserProfileModel.fromEntity(profile);

      if (await networkInfo.isConnected) {
        final updatedProfile = await remoteDataSource.updateUserProfile(
          profileModel,
        );
        await localDataSource.cacheUserProfile(updatedProfile);
        Logger.info('. Profile updated and cached');
        return Right(updatedProfile.toEntity());
      } else {
        // Offline: cache locally and return
        await localDataSource.cacheUserProfile(profileModel);
        Logger.info('📱 Profile cached offline');
        return Right(profile);
      }
    } on ServerException catch (e) {
      Logger.error('. Server error updating profile: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('. Error updating profile: $e');
      return Left(
        ServerFailure(message: 'Failed to update profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> getUserPreferences(
    String userId,
  ) async {
    Logger.info('. Getting preferences for user: $userId');

    if (await networkInfo.isConnected) {
      try {
        final remotePreferences = await remoteDataSource.getUserPreferences(
          userId,
        );
        await localDataSource.cacheUserPreferences(remotePreferences);
        Logger.info('. Preferences fetched and cached');
        return Right(remotePreferences.toEntity());
      } on ServerException catch (e) {
        Logger.warning('. Server error, trying cache: ${e.message}');
        try {
          final cachedPreferences = await localDataSource
              .getCachedUserPreferences();
          if (cachedPreferences != null) {
            Logger.info('📱 Using cached preferences');
            return Right(cachedPreferences.toEntity());
          }
          return Left(ServerFailure(message: e.message));
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        Logger.error('. Error fetching preferences: $e');
        return Left(
          ServerFailure(
            message: 'Failed to fetch preferences: ${e.toString()}',
          ),
        );
      }
    } else {
      Logger.info('📱 Offline mode: checking cache');
      try {
        final cachedPreferences = await localDataSource
            .getCachedUserPreferences();
        if (cachedPreferences != null) {
          Logger.info('📱 Using cached preferences (offline)');
          return Right(cachedPreferences.toEntity());
        }
        Logger.info('📱 No cached preferences, using defaults');
        return const Right(
          UserPreferencesEntity(),
        ); // Return default preferences
      } on CacheException {
        Logger.info('📱 Cache error, using defaults');
        return const Right(
          UserPreferencesEntity(),
        ); // Return default preferences
      } catch (e) {
        Logger.warning('. Offline error: $e');
        return Left(NetworkFailure(message: 'No internet connection'));
      }
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updateUserPreferences(
    String userId,
    UserPreferencesEntity preferences,
  ) async {
    try {
      Logger.info('📝 Updating preferences for user: $userId');
      final preferencesModel = UserPreferencesModel.fromEntity(preferences);

      if (await networkInfo.isConnected) {
        final updatedPreferences = await remoteDataSource.updateUserPreferences(
          userId,
          preferencesModel,
        );
        await localDataSource.cacheUserPreferences(updatedPreferences);
        Logger.info('. Preferences updated and cached');
        return Right(updatedPreferences.toEntity());
      } else {
        // Offline: cache locally and return
        await localDataSource.cacheUserPreferences(preferencesModel);
        Logger.info('📱 Preferences cached offline');
        return Right(preferences);
      }
    } on ServerException catch (e) {
      Logger.error('. Server error updating preferences: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('. Error updating preferences: $e');
      return Left(
        ServerFailure(message: 'Failed to update preferences: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getAchievements(
    String userId,
  ) async {
    Logger.info('🏆 Getting achievements for user: $userId');

    if (await networkInfo.isConnected) {
      try {
        final remoteAchievements = await remoteDataSource.getAchievements(
          userId,
        );
        await localDataSource.cacheAchievements(remoteAchievements);
        Logger.info(
          '. ${remoteAchievements.length} achievements fetched and cached',
        );

        // FIXED: Use the toEntity() method instead of manual mapping
        return Right(
          remoteAchievements
              .map((achievement) => achievement.toEntity())
              .toList(),
        );
      } on ServerException catch (e) {
        Logger.warning('. Server error, trying cache: ${e.message}');
        try {
          final cachedAchievements = await localDataSource
              .getCachedAchievements();
          if (cachedAchievements != null) {
            Logger.info(
              '📱 Using ${cachedAchievements.length} cached achievements',
            );
            // FIXED: Use the toEntity() method instead of manual mapping
            return Right(
              cachedAchievements
                  .map((achievement) => achievement.toEntity())
                  .toList(),
            );
          }
          return Left(ServerFailure(message: e.message));
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        Logger.error('. Error fetching achievements: $e');
        return Left(
          ServerFailure(
            message: 'Failed to fetch achievements: ${e.toString()}',
          ),
        );
      }
    } else {
      Logger.info('📱 Offline mode: checking cached achievements');
      try {
        final cachedAchievements = await localDataSource
            .getCachedAchievements();
        if (cachedAchievements != null) {
          Logger.info(
            '📱 Using ${cachedAchievements.length} cached achievements (offline)',
          );
          // FIXED: Use the toEntity() method instead of manual mapping
          return Right(
            cachedAchievements
                .map((achievement) => achievement.toEntity())
                .toList(),
          );
        }
        Logger.info('📱 No cached achievements available');
        return Left(CacheFailure(message: 'No cached achievements available'));
      } on CacheException {
        Logger.warning('. Cache error for achievements');
        return Left(CacheFailure(message: 'No cached achievements available'));
      } catch (e) {
        Logger.error('. Offline achievements error: $e');
        return Left(
          NetworkFailure(
            message:
                'No internet connection and no cached achievements available',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, String>> exportUserData(String userId) async {
    Logger.info('📤 Exporting data for user: $userId');

    if (await networkInfo.isConnected) {
      try {
        final exportResult = await remoteDataSource.exportUserData(userId, [
          'profile',
          'achievements',
          'preferences',
          'activity_history',
        ]);
        Logger.info('. Data export initiated successfully');
        return Right(exportResult);
      } on ServerException catch (e) {
        Logger.error('. Server error during export: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('. Error exporting data: $e');
        return Left(
          ServerFailure(message: 'Failed to export data: ${e.toString()}'),
        );
      }
    } else {
      Logger.warning('. Export requires internet connection');
      return Left(
        NetworkFailure(
          message: 'No internet connection. Data export requires connection.',
        ),
      );
    }
  }

  /// Additional method for account deletion (if needed)
  Future<Either<Failure, bool>> deleteUserAccount(String userId) async {
    Logger.info('🗑️ Deleting account for user: $userId');

    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteUserAccount(userId);
        if (result) {
          await localDataSource.clearCache();
          Logger.info('. Account deleted and cache cleared');
        }
        return Right(result);
      } on ServerException catch (e) {
        Logger.error('. Server error during deletion: ${e.message}');
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        Logger.error('. Error deleting account: $e');
        return Left(
          ServerFailure(message: 'Failed to delete account: ${e.toString()}'),
        );
      }
    } else {
      Logger.warning('. Account deletion requires internet connection');
      return Left(
        NetworkFailure(
          message:
              'No internet connection. Account deletion requires connection.',
        ),
      );
    }
  }
}
