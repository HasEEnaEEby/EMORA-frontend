import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/achievement_entity.dart';
import '../entity/profile_entity.dart';
import '../entity/user_preferences_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId);
  Future<Either<Failure, ProfileEntity>> updateUserProfile(
    ProfileEntity profile,
  );
  Future<Either<Failure, UserPreferencesEntity>> getUserPreferences(
    String userId,
  );
  Future<Either<Failure, UserPreferencesEntity>> updateUserPreferences(
    String userId,
    UserPreferencesEntity preferences,
  );
  Future<Either<Failure, List<AchievementEntity>>> getAchievements(
    String userId,
  );
  Future<Either<Failure, String>> exportUserData(String userId);
}
