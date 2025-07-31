import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/user_stats_entity.dart'; 
import '../repository/home_repository.dart';

class GetUserStats implements UseCase<UserStatsEntity, NoParams> {
  final HomeRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStatsEntity>> call(NoParams params) async {
    final result = await repository.getHomeData();

    return result.fold((failure) => Left(failure), (homeDataEntity) {
      return Right(homeDataEntity.userStats);
    });
  }
}
