import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/home_data_entity.dart';
import '../repository/home_repository.dart';

class LoadHomeData implements UseCase<HomeDataEntity, NoParams> {
  final HomeRepository repository;

  LoadHomeData(this.repository);

  @override
  Future<Either<Failure, HomeDataEntity>> call(NoParams params) async {
    return await repository.getHomeData();
  }
}
