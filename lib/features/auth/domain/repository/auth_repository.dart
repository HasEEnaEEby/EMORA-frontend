import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_response_entity.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseEntity>> register({
    required String username,
    required String password,
    required String pronouns,
    required String ageGroup,
    required String selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
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
