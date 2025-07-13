import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/onboarding_entity.dart';
import '../repository/onboarding_repository.dart';

class GetOnboardingSteps
    implements UseCase<List<OnboardingStepEntity>, NoParams> {
  final OnboardingRepository repository;

  GetOnboardingSteps(this.repository);

  @override
  Future<Either<Failure, List<OnboardingStepEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getOnboardingSteps();
  }
}
