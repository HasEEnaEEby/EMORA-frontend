import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/network/api_service.dart'; 
import 'package:emora_mobile_app/core/network/dio_client.dart'; 
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:emora_mobile_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:emora_mobile_app/features/auth/data/model/user_model.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/auth_response_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/user_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
final ApiService apiService; 
final DioClient dioClient; 

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
required this.apiService, 
required this.dioClient, 
  });

  @override
  Future<Either<Failure, AuthResponseEntity>> registerUser({
    required String username,
    required String email,
    required String password,
required String confirmPassword, 
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Logger.info('🔐 Starting user registration: $username');

      if (await networkInfo.isConnected) {
        final authResponse = await remoteDataSource.registerUser(
          username: username,
          email: email,
          password: password,
confirmPassword: confirmPassword, 
          pronouns: pronouns,
          ageGroup: ageGroup,
          selectedAvatar: selectedAvatar,
          location: location,
          latitude: latitude,
          longitude: longitude,
        );

        await localDataSource.saveAuthToken(authResponse.token);
        if (authResponse.refreshToken != null) {
          await localDataSource.saveRefreshToken(authResponse.refreshToken!);
        }
        await localDataSource.saveUserData(
          UserModel.fromEntity(authResponse.user),
        );
        await localDataSource.markAsLoggedIn();

        await _synchronizeAuthToken(authResponse.token);

        Logger.info('. Registration successful and data saved locally');
        return Right(authResponse);
      } else {
        Logger.warning('. No internet connection for registration');
        return Left(NetworkFailure(message: AppConfig.networkErrorMessage));
      }
    } on ServerException catch (e) {
      Logger.error('. Server error during registration', e);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      Logger.error('. Cache error during registration', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error during registration', e);
      return Left(ServerFailure(message: AppConfig.serverErrorMessage));
    }
  }

  @override
  Future<Either<Failure, AuthResponseEntity>> loginUser({
    required String username,
    required String password,
  }) async {
    try {
      Logger.info('🔑 Starting user login: $username');

      if (await networkInfo.isConnected) {
        final authResponse = await remoteDataSource.loginUser(
          username: username,
          password: password,
        );

        await localDataSource.saveAuthToken(authResponse.token);
        if (authResponse.refreshToken != null) {
          await localDataSource.saveRefreshToken(authResponse.refreshToken!);
        }
        await localDataSource.saveUserData(
          UserModel.fromEntity(authResponse.user),
        );
        await localDataSource.markAsLoggedIn();

        await _synchronizeAuthToken(authResponse.token);

        Logger.info('. Login successful and data saved locally');
        return Right(authResponse);
      } else {
        Logger.warning('. No internet connection for login');
        return Left(NetworkFailure(message: AppConfig.networkErrorMessage));
      }
    } on ServerException catch (e) {
      Logger.error('. Server error during login', e);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      Logger.error('. Cache error during login', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error during login', e);
      return Left(ServerFailure(message: AppConfig.serverErrorMessage));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      Logger.info('. Getting current user');

      try {
        final cachedUser = await localDataSource.getUserData();
        if (cachedUser != null) {
          Logger.info('. User found in cache');
          return Right(cachedUser.toEntity());
        }
      } catch (e) {
        Logger.warning('. No cached user found');
      }

      if (await networkInfo.isConnected) {
        final token = await localDataSource.getAuthToken();
        if (token != null) {
          final user = await remoteDataSource.getCurrentUser();
          await localDataSource.saveUserData(UserModel.fromEntity(user));
          Logger.info('. User fetched from server and cached');
          return Right(user);
        } else {
          Logger.warning('. No auth token found');
          return Left(AuthFailure(message: AppConfig.unauthorizedErrorMessage));
        }
      } else {
        Logger.warning('. No internet connection and no cached user');
        return Left(NetworkFailure(message: AppConfig.networkErrorMessage));
      }
    } on ServerException catch (e) {
      Logger.error('. Server error getting current user', e);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      Logger.error('. Cache error getting current user', e);
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error getting current user', e);
      return Left(ServerFailure(message: AppConfig.serverErrorMessage));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      Logger.info('👋 Starting logout');

      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
          Logger.info('. Logout successful on server');
        } catch (e) {
          Logger.warning(
            '. Server logout failed, continuing with local logout: $e',
          );
        }
      }

      await clearAuthData();
      
      await _clearAuthTokens();
      
      Logger.info('. Local auth data cleared');
      return const Right(null);
    } catch (e) {
      Logger.error('. Error during logout', e);
      try {
        await clearAuthData();
      } catch (clearError) {
        Logger.error('. Failed to clear local data during logout', clearError);
      }
      return Left(CacheFailure(message: 'Logout completed with errors'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkUsernameAvailability(
    String username,
  ) async {
    try {
      Logger.info('. Checking username availability: $username');

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.checkUsernameAvailability(
          username,
        );
        Logger.info('. Username availability check completed');
        return Right(result);
      } else {
        Logger.warning(
          '. No internet connection, returning mock availability check',
        );
        final isAvailable = !AppConfig.reservedUsernames.contains(
          username.toLowerCase(),
        );
        return Right(
          AppConfig.getMockUsernameCheckResponse(
            username: username,
            isAvailable: isAvailable,
          )['data'],
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Server error checking username', e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error checking username', e);
      final isAvailable = !AppConfig.reservedUsernames.contains(
        username.toLowerCase(),
      );
      return Right(
        AppConfig.getMockUsernameCheckResponse(
          username: username,
          isAvailable: isAvailable,
        )['data'],
      );
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken(String refreshToken) async {
    try {
      Logger.info('🔄 Refreshing auth token');

      if (await networkInfo.isConnected) {
        final newToken = await remoteDataSource.refreshToken(refreshToken);
        await localDataSource.saveAuthToken(newToken);
        Logger.info('. Token refreshed successfully');
        return Right(newToken);
      } else {
        Logger.warning('. No internet connection for token refresh');
        return Left(NetworkFailure(message: AppConfig.networkErrorMessage));
      }
    } on ServerException catch (e) {
      Logger.error('. Server error refreshing token', e);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      Logger.error('. Unexpected error refreshing token', e);
      return Left(ServerFailure(message: AppConfig.serverErrorMessage));
    }
  }

  @override
  Future<Either<Failure, bool>> hasEverBeenLoggedIn() async {
    try {
      final hasBeenLoggedIn = await localDataSource.hasEverBeenLoggedIn();
      return Right(hasBeenLoggedIn);
    } catch (e) {
      Logger.error('. Error checking login history', e);
      return Left(CacheFailure(message: 'Failed to check login history'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthData() async {
    try {
      Logger.info('🗑️ Clearing all auth data');
      await localDataSource.clearAuthData();
      
      await _clearAuthTokens();
      
      Logger.info('. Auth data cleared successfully');
      return const Right(null);
    } catch (e) {
      Logger.error('. Error clearing auth data', e);
      return Left(CacheFailure(message: 'Failed to clear auth data'));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(String token) async {
    try {
      await localDataSource.saveAuthToken(token);
      return const Right(null);
    } catch (e) {
      Logger.error('. Error saving auth token', e);
      return Left(CacheFailure(message: 'Failed to save auth token'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = await localDataSource.getAuthToken();
      return Right(token);
    } catch (e) {
      Logger.error('. Error getting auth token', e);
      return Left(CacheFailure(message: 'Failed to get auth token'));
    }
  }

  @override
  Future<Either<Failure, void>> saveRefreshToken(String refreshToken) async {
    try {
      await localDataSource.saveRefreshToken(refreshToken);
      return const Right(null);
    } catch (e) {
      Logger.error('. Error saving refresh token', e);
      return Left(CacheFailure(message: 'Failed to save refresh token'));
    }
  }

  @override
  Future<Either<Failure, String?>> getRefreshToken() async {
    try {
      final token = await localDataSource.getRefreshToken();
      return Right(token);
    } catch (e) {
      Logger.error('. Error getting refresh token', e);
      return Left(CacheFailure(message: 'Failed to get refresh token'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserData(UserEntity user) async {
    try {
      await localDataSource.saveUserData(UserModel.fromEntity(user));
      return const Right(null);
    } catch (e) {
      Logger.error('. Error saving user data', e);
      return Left(CacheFailure(message: 'Failed to save user data'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getSavedUserData() async {
    try {
      final userModel = await localDataSource.getUserData();
      return Right(userModel?.toEntity());
    } catch (e) {
      Logger.error('. Error getting saved user data', e);
      return Left(CacheFailure(message: 'Failed to get saved user data'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        Logger.info('🔑 No auth token found - user not authenticated');
        return const Right(false);
      }

      if (AppConfig.isTokenExpired(token)) {
        Logger.info('🔑 Token expired locally, attempting refresh...');
        
        final refreshToken = await localDataSource.getRefreshToken();
        if (refreshToken != null) {
          final result = await this.refreshToken(refreshToken);
          return result.fold(
            (failure) async {
              Logger.warning('🔄 Token refresh failed, clearing auth data: ${failure.message}');
              await clearAuthData();
return const Right(false); 
            },
            (newToken) async {
              await _synchronizeAuthToken(newToken);
              Logger.info('. Token refreshed successfully');
              return const Right(true);
            },
          );
        } else {
          Logger.warning('🔄 No refresh token available, clearing auth data');
          await clearAuthData();
          return const Right(false);
        }
      }

      Logger.info('🔑 Token valid locally, validating with server...');
      
      await _synchronizeAuthToken(token);
      
      if (await networkInfo.isConnected) {
        try {
          final userResult = await getCurrentUser();
          return userResult.fold(
            (failure) async {
              if (failure is AuthFailure && failure.statusCode == 401) {
                Logger.warning('🔑 Token invalid on server (401), clearing auth data');
                await clearAuthData();
                return const Right(false);
              } else if (failure is ServerFailure || failure is NetworkFailure) {
                Logger.warning('. Server/network error during token validation, assuming valid: ${failure.message}');
                return const Right(true);
              } else {
                Logger.warning('🔑 Token validation failed, clearing auth data: ${failure.message}');
                await clearAuthData();
                return const Right(false);
              }
            },
            (user) {
              Logger.info('. Token validated successfully with server');
              return const Right(true);
            },
          );
        } catch (e) {
          Logger.warning('. Exception during token validation, assuming valid: $e');
          return const Right(true);
        }
      } else {
        Logger.info('📱 No network, assuming token valid based on local check');
        return const Right(true);
      }
    } catch (e) {
      Logger.error('. Error checking authentication status', e);
      try {
        await clearAuthData();
      } catch (clearError) {
        Logger.error('. Failed to clear auth data after error', clearError);
      }
      return const Right(false);
    }
  }

  Future<void> _synchronizeAuthToken(String token) async {
    try {
      apiService.setAuthToken(token);
      
      await dioClient.setAuthToken(token);
      
      Logger.info('🔑 Auth token synchronized successfully in both ApiService and DioClient');
    } catch (e) {
      Logger.error('. Failed to synchronize auth tokens', e);
      try {
        apiService.setAuthToken(token);
        Logger.warning('. Fallback: Token set only in ApiService');
      } catch (fallbackError) {
        Logger.error('. Critical: Failed to set token in any client', fallbackError);
      }
    }
  }

  Future<void> _clearAuthTokens() async {
    try {
      apiService.clearAuthToken();
      
      await dioClient.clearAuthToken();
      
      Logger.info('🔑 Auth tokens cleared successfully from both ApiService and DioClient');
    } catch (e) {
      Logger.error('. Failed to clear auth tokens from both clients', e);
      try {
        apiService.clearAuthToken();
        Logger.warning('. Fallback: Token cleared only from ApiService');
      } catch (fallbackError) {
        Logger.error('. Critical: Failed to clear token from any client', fallbackError);
      }
    }
  }
}
