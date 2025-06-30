import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entity/auth_response_entity.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_source/local/auth_local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';
import '../model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> checkUsernameAvailability({
    required String username,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final isAvailable = await remoteDataSource.checkUsernameAvailability(
          username,
        );
        return Right(isAvailable);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      // Handle 404 errors gracefully for development
      if (e.message.contains('not available') || e.message.contains('404')) {
        return const Left(
          ServerFailure(
            message: 'Username check unavailable in development mode',
          ),
        );
      }
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to check username availability: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> register({
    required String username,
    required String password,
    required String pronouns,
    required String ageGroup,
    required String selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final authResponse = await remoteDataSource.register(
          username: username,
          password: password,
          pronouns: pronouns,
          ageGroup: ageGroup,
          selectedAvatar: selectedAvatar,
          location: location,
          latitude: latitude,
          longitude: longitude,
        );

        // Save auth data locally
        await localDataSource.saveToken(authResponse.token);
        await localDataSource.saveUser(UserModel.fromEntity(authResponse.user));

        return Right(authResponse.toEntity());
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      // Handle 404 errors gracefully for development
      if (e.message.contains('not available') || e.message.contains('404')) {
        return const Left(
          ServerFailure(
            message: 'Registration unavailable in development mode',
          ),
        );
      }
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final authResponse = await remoteDataSource.login(
          username: username,
          password: password,
        );

        // Save auth data locally
        await localDataSource.saveToken(authResponse.token);
        await localDataSource.saveUser(UserModel.fromEntity(authResponse.user));

        return Right(authResponse.toEntity());
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on ServerException catch (e) {
      // Handle 404 errors gracefully for development
      if (e.message.contains('not available') || e.message.contains('404')) {
        return const Left(
          ServerFailure(message: 'Login unavailable in development mode'),
        );
      }
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Check if we have a token first
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return const Left(UnauthorizedFailure(message: 'No auth token found'));
      }

      // Try to get user from local storage first
      final localUser = await localDataSource.getUser();

      if (localUser != null) {
        // If we have network, try to sync with server
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();
            // Update local cache with fresh data
            await localDataSource.saveUser(remoteUser);
            return Right(remoteUser.toEntity());
          } on UnauthorizedException {
            // Token is expired/invalid - clear it and return unauthorized failure
            await localDataSource.clearAuthData();
            return const Left(UnauthorizedFailure(message: 'Session expired'));
          } on ServerException catch (e) {
            // Handle 404 errors gracefully for development
            if (e.message.contains('not available') ||
                e.message.contains('404')) {
              // Return cached data when API is not available
              return Right(localUser.toEntity());
            }

            // Server error - return cached data if available
            if (e.message.contains('500')) {
              return Right(localUser.toEntity());
            }
            rethrow;
          } catch (e) {
            // If server call fails for other reasons, return cached data
            return Right(localUser.toEntity());
          }
        } else {
          // No network, return cached data
          return Right(localUser.toEntity());
        }
      } else {
        // No local user data but we have a token - try server
        if (await networkInfo.isConnected) {
          try {
            final remoteUser = await remoteDataSource.getCurrentUser();
            await localDataSource.saveUser(remoteUser);
            return Right(remoteUser.toEntity());
          } on UnauthorizedException {
            // Token is invalid - clear it
            await localDataSource.clearAuthData();
            return const Left(UnauthorizedFailure(message: 'Session expired'));
          } on ServerException catch (e) {
            // Handle 404 errors gracefully for development
            if (e.message.contains('not available') ||
                e.message.contains('404')) {
              // Clear auth data since we can't verify the token
              await localDataSource.clearAuthData();
              return const Left(
                UnauthorizedFailure(message: 'Session expired'),
              );
            }
            rethrow;
          }
        } else {
          return const Left(NetworkFailure(message: 'No internet connection'));
        }
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          developer.log('Remote logout failed: $e', name: 'AuthRepository');
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasEverBeenLoggedIn() async {
    try {
      final hasBeenLoggedIn = await localDataSource.hasEverBeenLoggedIn();
      return Right(hasBeenLoggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check login history: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> refreshToken() async {
    try {
      if (await networkInfo.isConnected) {
        // For now, we'll implement a simple token refresh
        // You can enhance this when you add refresh token functionality to your backend
        final token = await localDataSource.getToken();
        if (token == null || token.isEmpty) {
          return const Left(
            UnauthorizedFailure(message: 'No token to refresh'),
          );
        }

        // Try to get current user to verify token is still valid
        final result = await getCurrentUser();
        return result.fold((failure) => Left(failure), (user) {
          // Create a mock auth response with existing token
          // In a real implementation, you'd call a refresh endpoint
          final authResponse = AuthResponseEntity(
            user: user,
            token: token,
            expiresIn: '7d',
          );
          return Right(authResponse);
        });
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required Map<String, dynamic> updates,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // For now, implement a basic update that modifies local data
        final localUser = await localDataSource.getUser();
        if (localUser == null) {
          return const Left(UnauthorizedFailure(message: 'No user data found'));
        }

        // Create updated user model
        final updatedUser = localUser.copyWith(
          pronouns: updates['pronouns'] as String?,
          ageGroup: updates['ageGroup'] as String?,
          selectedAvatar: updates['selectedAvatar'] as String?,
        );

        // Save updated user locally
        await localDataSource.saveUser(updatedUser);

        return Right(updatedUser.toEntity());
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // For now, implement a placeholder
        // You can enhance this when you add password change functionality to your backend
        developer.log('Password change requested', name: 'AuthRepository');

        // In a real implementation, you'd call the remote data source
        // await remoteDataSource.changePassword(currentPassword, newPassword);

        return const Right(null);
      } else {
        return const Left(NetworkFailure(message: 'No internet connection'));
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to change password: $e'));
    }
  }

  // Keep your existing clearAuthData method for backward compatibility
  Future<Either<Failure, void>> clearAuthData() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to clear auth data: $e'));
    }
  }
}
