import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/user_preferences_entity.dart';
import '../repository/profile_repository.dart';

class UpdateUserPreferencesParams extends Equatable {
  final String userId;
  final UserPreferencesEntity preferences;

  const UpdateUserPreferencesParams({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, preferences];
}

class UpdateUserPreferences
    implements UseCase<UserPreferencesEntity, UpdateUserPreferencesParams> {
  final ProfileRepository repository;

  UpdateUserPreferences({required this.repository});

  @override
  Future<Either<Failure, UserPreferencesEntity>> call(
    UpdateUserPreferencesParams params,
  ) async {
    return await repository.updateUserPreferences(
      params.userId,
      params.preferences,
    );
  }
}
