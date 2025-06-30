import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/auth_repository.dart';

class CheckUsernameAvailability extends UseCase<bool, CheckUsernameParams> {
  final AuthRepository repository;

  CheckUsernameAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckUsernameParams params) async {
    return await repository.checkUsernameAvailability(
      username: params.username,
    );
  }
}

class CheckUsernameParams extends Equatable {
  final String username;

  const CheckUsernameParams({required this.username});

  @override
  List<Object> get props => [username];
}
