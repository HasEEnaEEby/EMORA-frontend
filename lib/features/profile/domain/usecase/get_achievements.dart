import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/achievement_entity.dart';
import '../repository/profile_repository.dart';

class GetAchievementsParams extends Equatable {
  final String userId;

  const GetAchievementsParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GetAchievements
    implements UseCase<List<AchievementEntity>, GetAchievementsParams> {
  final ProfileRepository repository;

  GetAchievements({required this.repository});

  @override
  Future<Either<Failure, List<AchievementEntity>>> call(
    GetAchievementsParams params,
  ) async {
    return await repository.getAchievements(params.userId);
  }
}
