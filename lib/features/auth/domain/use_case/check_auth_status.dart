import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

class CheckAuthStatus extends UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}