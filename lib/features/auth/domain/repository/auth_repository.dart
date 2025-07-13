// lib/features/auth/domain/repository/auth_repository.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_response_entity.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  /// Register a new user with required and optional data
  Future<Either<Failure, AuthResponseEntity>> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword, // ✅ Added confirmPassword parameter
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
  });

  /// Login user with username and password
  Future<Either<Failure, AuthResponseEntity>> loginUser({
    required String username,
    required String password,
  });

  /// Get current authenticated user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Check if username is available and get suggestions if not
  Future<Either<Failure, Map<String, dynamic>>> checkUsernameAvailability(
    String username,
  );

  /// Refresh authentication token
  Future<Either<Failure, String>> refreshToken(String refreshToken);

  /// Check if user has ever been logged in (for navigation logic)
  Future<Either<Failure, bool>> hasEverBeenLoggedIn();

  /// Clear all authentication data
  Future<Either<Failure, void>> clearAuthData();

  /// Save authentication token
  Future<Either<Failure, void>> saveAuthToken(String token);

  /// Get saved authentication token
  Future<Either<Failure, String?>> getAuthToken();

  /// Save refresh token
  Future<Either<Failure, void>> saveRefreshToken(String refreshToken);

  /// Get saved refresh token
  Future<Either<Failure, String?>> getRefreshToken();

  /// Save user data locally
  Future<Either<Failure, void>> saveUserData(UserEntity user);

  /// Get saved user data
  Future<Either<Failure, UserEntity?>> getSavedUserData();

  /// Check if user is currently authenticated
  Future<Either<Failure, bool>> isAuthenticated();
}
