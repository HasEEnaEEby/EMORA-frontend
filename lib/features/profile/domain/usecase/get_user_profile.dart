import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/get_current_user.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/repository/profile_repository.dart';
import 'package:equatable/equatable.dart';

class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetUserProfile implements UseCase<ProfileEntity, GetUserProfileParams> {
  final ProfileRepository repository;
  final GetCurrentUser getCurrentUser;

  GetUserProfile({required this.repository, required this.getCurrentUser});

  @override
  Future<Either<Failure, ProfileEntity>> call(
    GetUserProfileParams params,
  ) async {
    try {
      return await repository.getUserProfile(params.userId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ProfileEntity>> getCurrentUserProfile() async {
    try {
      final currentUserResult = await getCurrentUser(NoParams());

      return currentUserResult.fold(
        (failure) async {
          return await repository.getUserProfile('');
        },
        (user) async {
          return await repository.getUserProfile(user.id);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
