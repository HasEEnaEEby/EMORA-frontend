// lib/features/onboarding/domain/use_case/complete_onboarding.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repository/onboarding_repository.dart';

class CompleteOnboarding implements UseCase<bool, NoParams> {
  final OnboardingRepository repository;

  CompleteOnboarding(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.completeOnboarding();
  }
}
