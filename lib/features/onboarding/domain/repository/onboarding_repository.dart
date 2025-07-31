import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingStepEntity>>> getOnboardingSteps();
  Future<Either<Failure, UserOnboardingEntity>> getUserOnboardingData();
  Future<Either<Failure, bool>> saveUserOnboardingData(
    UserOnboardingEntity userData,
  );
  Future<Either<Failure, bool>> completeOnboarding();
  Future<Either<Failure, bool>> isOnboardingCompleted();
  Future<Either<Failure, UserOnboardingEntity>> getCurrentUserData();
  Future<Either<Failure, bool>> clearOnboardingData();
  Future<Either<Failure, bool>> validateUserData(UserOnboardingEntity userData);
}
