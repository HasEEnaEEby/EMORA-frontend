import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

class NavigateToMainFlow implements UseCase<void, NoParams> {
  NavigateToMainFlow();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return const Right(null);
  }
}
