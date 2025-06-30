import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/auth_response_entity.dart';
import '../repository/auth_repository.dart';

class LoginUser extends UseCase<AuthResponseEntity, LoginUserParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(
    LoginUserParams params,
  ) async {
    return await repository.login(
      username: params.username,
      password: params.password,
    );
  }
}

class LoginUserParams {
  final String username;
  final String password;

  LoginUserParams({required this.username, required this.password});
}
