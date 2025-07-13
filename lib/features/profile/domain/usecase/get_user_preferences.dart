import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/user_preferences_entity.dart';
import '../repository/profile_repository.dart';

class GetUserPreferencesParams extends Equatable {
  final String userId;

  const GetUserPreferencesParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserPreferences
    implements UseCase<UserPreferencesEntity, GetUserPreferencesParams> {
  final ProfileRepository repository;

  GetUserPreferences({required this.repository});

  @override
  Future<Either<Failure, UserPreferencesEntity>> call(
    GetUserPreferencesParams params,
  ) async {
    return await repository.getUserPreferences(params.userId);
  }
}
