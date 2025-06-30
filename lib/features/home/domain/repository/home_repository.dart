import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/home_data_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeDataEntity>> getHomeData();
  Future<Either<Failure, HomeDataEntity>> markFirstTimeLoginComplete();
  Future<Either<Failure, bool>> isFirstTimeLogin();
}
