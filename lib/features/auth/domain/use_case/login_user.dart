import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/auth_response_entity.dart';
import '../repository/auth_repository.dart';

class LoginUser extends UseCase<AuthResponseEntity, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(LoginParams params) async {
    return await repository.loginUser(
      username: params.username,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
