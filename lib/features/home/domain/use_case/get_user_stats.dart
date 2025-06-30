import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/home_data_entity.dart';
import '../repository/home_repository.dart';

class GetUserStats implements UseCase<HomeDataEntity, NoParams> {
  final HomeRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, HomeDataEntity>> call(NoParams params) async {
    // Since your repository doesn't have a specific getUserStats method,
    // we'll use getHomeData for now. You can modify this later when you add
    // a specific method for user stats in your repository
    return await repository.getHomeData();
  }
}
