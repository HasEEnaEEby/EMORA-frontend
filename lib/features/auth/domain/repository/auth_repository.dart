// lib/features/auth/domain/repository/auth_repository.dart - UPDATED with nullable fields
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_response_entity.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> register({
    required String username,
    required String password,
    String? pronouns, // ✅ NULLABLE
    String? ageGroup, // ✅ NULLABLE
    String? selectedAvatar, // ✅ NULLABLE
    String? location,
    double? latitude,
    double? longitude,
    required String email, // ✅ REQUIRED
  });

  Future<Either<Failure, AuthResponseEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, bool>> checkUsernameAvailability({
    required String username,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, bool>> hasEverBeenLoggedIn();

  Future<Either<Failure, AuthResponseEntity>> refreshToken();

  Future<Either<Failure, UserEntity>> updateProfile({
    required Map<String, dynamic> updates,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
