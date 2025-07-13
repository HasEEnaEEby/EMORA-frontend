// lib/features/onboarding/data/repository/onboarding_repository_impl.dart
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/onboarding_entity.dart';
import '../../domain/repository/onboarding_repository.dart';
import '../data_source/local/onboarding_local_data_source.dart';
import '../data_source/remote/onboarding_remote_data_source.dart';
import '../model/onboarding_model.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;
  final OnboardingLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OnboardingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<OnboardingStepEntity>>>
  getOnboardingSteps() async {
    try {
      Logger.info('📋 Getting onboarding steps with offline-first strategy...');

      // **OFFLINE-FIRST STRATEGY**
      // 1. Always get local data first for immediate response
      final localSteps = await localDataSource.getCachedOnboardingSteps();

      // 2. Check if we should try to fetch fresh data
      final isConnected = await networkInfo.isConnected;
      final isCacheFresh = localDataSource.isCacheFresh();

      Logger.info('🔍 Network: $isConnected, Cache fresh: $isCacheFresh');

      // 3. If online and cache is stale, try to get fresh data
      if (isConnected && !isCacheFresh) {
        try {
          Logger.info('🌐 Fetching fresh onboarding steps...');
          final remoteSteps = await remoteDataSource.getOnboardingSteps();

          // 4. Cache the fresh data
          if (remoteSteps.isNotEmpty) {
            await localDataSource.cacheOnboardingSteps(remoteSteps);
            Logger.info('✅ Using fresh onboarding steps from server');
            return Right(remoteSteps.map((step) => step.toEntity()).toList());
          }
        } on NotFoundException catch (e) {
          // FIXED: Handle 404 gracefully in development
          developer.log(
            'Onboarding steps endpoint not available in development mode: ${e.message}',
            name: 'OnboardingRepository',
          );
          // Continue to use cached data
        } on ServerException catch (e) {
          // FIXED: Handle server errors gracefully
          if (e.message.contains('404')) {
            developer.log(
              'Onboarding steps endpoint not available: ${e.message}',
              name: 'OnboardingRepository',
            );
          } else {
            Logger.warning('⚠️ Failed to fetch fresh steps, using cached: $e');
          }
          // Continue to use cached data
        } catch (e) {
          Logger.warning('⚠️ Failed to fetch fresh steps, using cached: $e');
          // Continue to use cached data
        }
      }

      // 5. Return cached data (either because offline, cache is fresh, or remote failed)
      Logger.info('📱 Using cached onboarding steps');
      return Right(localSteps.map((step) => step.toEntity()).toList());
    } on CacheException catch (e) {
      Logger.error('Cache error getting onboarding steps', e);
      return Left(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      Logger.error('Network error getting onboarding steps', e);
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      Logger.error('Unexpected error getting onboarding steps', e);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserOnboardingEntity>> getUserOnboardingData() async {
    try {
      Logger.info('👤 Getting user onboarding data...');
      final userData = await localDataSource.getUserOnboardingData();
      Logger.info('✅ Retrieved user onboarding data');
      return Right(userData.toEntity());
    } on CacheException catch (e) {
      Logger.error('Cache error getting user data', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('Unexpected error getting user data', e);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveUserOnboardingData(
    UserOnboardingEntity userData,
  ) async {
    try {
      Logger.info(
        '💾 Saving user onboarding data with offline-first approach...',
      );

      final userDataModel = UserOnboardingModel.fromEntity(userData);

      // **OFFLINE-FIRST STRATEGY**
      // 1. Always save locally first
      final localSaved = await localDataSource.saveUserOnboardingData(
        userDataModel,
      );

      if (!localSaved) {
        return const Left(CacheFailure(message: 'Failed to save data locally'));
      }

      Logger.info('✅ Saved user onboarding data locally');

      // 2. Try to sync with remote if connected (don't block user flow)
      if (await networkInfo.isConnected) {
        try {
          Logger.info('🌐 Attempting to sync user data with server...');
          final syncSuccess = await remoteDataSource.saveUserData(
            userDataModel,
          );

          if (syncSuccess) {
            Logger.info('✅ User data synced with server successfully');
          } else {
            Logger.info('⚠️ Server sync returned false, will retry later');
          }
        } on NotFoundException catch (e) {
          // FIXED: Handle 404 gracefully for development
          developer.log(
            'User data endpoint not available in development mode: ${e.message}',
            name: 'OnboardingRepository',
          );
        } on ServerException catch (e) {
          // FIXED: Handle server errors gracefully
          if (e.message.contains('404')) {
            developer.log(
              'User data endpoint not available: ${e.message}',
              name: 'OnboardingRepository',
            );
          } else {
            Logger.warning('⚠️ Remote sync failed (data saved locally): $e');
          }
        } catch (e) {
          Logger.warning('⚠️ Remote sync failed (data saved locally): $e');
          // TODO: Add to sync queue for later retry
        }
      } else {
        Logger.info(
          '📴 Offline - data saved locally, will sync when connected',
        );
      }

      return const Right(true);
    } on CacheException catch (e) {
      Logger.error('Cache error saving user data', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('Unexpected error saving user data', e);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> completeOnboarding() async {
    try {
      Logger.info('🎯 Completing onboarding with offline-first approach...');

      // **OFFLINE-FIRST STRATEGY**
      // 1. Always complete locally first
      final localCompleted = await localDataSource.completeOnboarding();

      if (!localCompleted) {
        return const Left(
          CacheFailure(message: 'Failed to complete onboarding locally'),
        );
      }

      Logger.info('✅ Onboarding marked as completed locally');

      // 2. Get the completed user data for remote sync
      final userData = await localDataSource.getUserOnboardingData();

      // 3. Try to sync completion with remote if connected
      if (await networkInfo.isConnected) {
        try {
          Logger.info('🌐 Attempting to complete onboarding on server...');
          final syncSuccess = await remoteDataSource.completeOnboarding(
            userData,
          );

          if (syncSuccess) {
            Logger.info('✅ Onboarding completed on server successfully');
          } else {
            Logger.info(
              '⚠️ Server completion returned false, will retry later',
            );
          }
        } on NotFoundException catch (e) {
          // FIXED: Handle 404 gracefully for development
          developer.log(
            'Onboarding completion endpoint not available in development mode: ${e.message}',
            name: 'OnboardingRepository',
          );
        } on UnauthorizedException catch (e) {
          // FIXED: Handle 401 gracefully - expected during onboarding
          developer.log(
            'Onboarding completion requires authentication - will sync after registration: ${e.message}',
            name: 'OnboardingRepository',
          );
        } on ServerException catch (e) {
          // FIXED: Handle server errors gracefully
          if (e.message.contains('404')) {
            developer.log(
              'Onboarding completion endpoint not available: ${e.message}',
              name: 'OnboardingRepository',
            );
          } else if (e.message.contains('401')) {
            developer.log(
              'Onboarding completion requires authentication: ${e.message}',
              name: 'OnboardingRepository',
            );
          } else {
            Logger.warning(
              '⚠️ Remote completion failed (completed locally): $e',
            );
          }
        } catch (e) {
          Logger.warning('⚠️ Remote completion failed (completed locally): $e');
          // TODO: Add to sync queue for later retry
        }
      } else {
        Logger.info(
          '📴 Offline - onboarding completed locally, will sync when connected',
        );
      }

      return const Right(true);
    } on CacheException catch (e) {
      Logger.error('Cache error completing onboarding', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('Unexpected error completing onboarding', e);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async {
    try {
      Logger.info('🔍 Checking if onboarding is completed...');
      final isCompleted = await localDataSource.isOnboardingCompleted();
      Logger.info('ℹ️ Onboarding completed: $isCompleted');
      return Right(isCompleted);
    } on CacheException catch (e) {
      Logger.error('Cache error checking onboarding completion', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('Unexpected error checking onboarding completion', e);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // FIXED: Add method to get user data with proper error handling
  @override
  Future<Either<Failure, UserOnboardingEntity>> getCurrentUserData() async {
    try {
      final userData = await localDataSource.getUserOnboardingData();
      return Right(userData.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // FIXED: Add method to clear onboarding data
  @override
  Future<Either<Failure, bool>> clearOnboardingData() async {
    try {
      await localDataSource.clearOnboardingData();
      Logger.info('🧹 Cleared all onboarding data from cache');
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // FIXED: Add method to clear only pronouns data (for debugging)
  Future<Either<Failure, bool>> clearPronounsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_pronouns');
      await prefs.remove('user_onboarding_data');
      Logger.info('🧹 Cleared pronouns data from cache');
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  // FIXED: Add method to validate user data
  @override
  Future<Either<Failure, bool>> validateUserData(
    UserOnboardingEntity userData,
  ) async {
    try {
      // Basic validation
      if (userData.pronouns == null || userData.pronouns!.isEmpty) {
        return const Left(ValidationFailure(message: 'Pronouns are required'));
      }

      if (userData.ageGroup == null || userData.ageGroup!.isEmpty) {
        return const Left(ValidationFailure(message: 'Age group is required'));
      }

      if (userData.selectedAvatar == null || userData.selectedAvatar!.isEmpty) {
        return const Left(
          ValidationFailure(message: 'Avatar selection is required'),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

// FIXED: Add the missing UnexpectedFailure class
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

// FIXED: Add the missing ValidationFailure class
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
