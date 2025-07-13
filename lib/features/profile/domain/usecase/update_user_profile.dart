import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/profile_entity.dart';
import '../repository/profile_repository.dart';

class UpdateUserProfileParams extends Equatable {
  final ProfileEntity profile;

  const UpdateUserProfileParams({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class UpdateUserProfile
    implements UseCase<ProfileEntity, UpdateUserProfileParams> {
  final ProfileRepository repository;

  UpdateUserProfile({required this.repository});

  @override
  Future<Either<Failure, ProfileEntity>> call(
    UpdateUserProfileParams params,
  ) async {
    return await repository.updateUserProfile(params.profile);
  }
}
