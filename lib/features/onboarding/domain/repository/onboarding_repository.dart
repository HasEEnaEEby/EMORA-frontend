import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/features/onboarding/domain/entity/onboarding_entity.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, List<OnboardingStepEntity>>> getOnboardingSteps();
  Future<Either<Failure, UserOnboardingEntity>> getUserOnboardingData();
  Future<Either<Failure, bool>> saveUserOnboardingData(
    UserOnboardingEntity userData,
  );
  Future<Either<Failure, bool>> completeOnboarding();
  Future<Either<Failure, bool>> isOnboardingCompleted();
}
