import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/user_stats_entity.dart'; 
import '../repository/home_repository.dart';

// . FIX: Change return type to UserStatsEntity
class GetUserStats implements UseCase<UserStatsEntity, NoParams> {
  final HomeRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStatsEntity>> call(NoParams params) async {
    // . FIX: Get home data and extract user stats from it
    final result = await repository.getHomeData();

    return result.fold((failure) => Left(failure), (homeDataEntity) {
      // Extract user stats from home data
      return Right(homeDataEntity.userStats);
    });
  }
}
