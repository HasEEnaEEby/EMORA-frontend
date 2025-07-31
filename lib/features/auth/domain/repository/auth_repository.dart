import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/auth_response_entity.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
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
  });

  Future<Either<Failure, AuthResponseEntity>> loginUser({
    required String username,
    required String password,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, Map<String, dynamic>>> checkUsernameAvailability(
    String username,
  );

  Future<Either<Failure, String>> refreshToken(String refreshToken);

  Future<Either<Failure, bool>> hasEverBeenLoggedIn();

  Future<Either<Failure, void>> clearAuthData();

  Future<Either<Failure, void>> saveAuthToken(String token);

  Future<Either<Failure, String?>> getAuthToken();

  Future<Either<Failure, void>> saveRefreshToken(String refreshToken);

  Future<Either<Failure, String?>> getRefreshToken();

  Future<Either<Failure, void>> saveUserData(UserEntity user);

  Future<Either<Failure, UserEntity?>> getSavedUserData();

  Future<Either<Failure, bool>> isAuthenticated();
}
