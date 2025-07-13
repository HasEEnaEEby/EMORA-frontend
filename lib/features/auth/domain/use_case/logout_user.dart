import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}