import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/features/onboarding/domain/entity/onboarding_entity.dart';
import 'package:emora_mobile_app/features/onboarding/domain/repository/onboarding_repository.dart';

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
