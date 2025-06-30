// features/onboarding/domain/use_case/save_user_data.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/onboarding_entity.dart';
import '../repository/onboarding_repository.dart';

class SaveUserData implements UseCase<bool, SaveUserDataParams> {
  final OnboardingRepository repository;

  SaveUserData(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveUserDataParams params) async {
    // FIXED: Use the correct method name from your repository
    return await repository.saveUserOnboardingData(params.userData);
  }
}

class SaveUserDataParams extends Equatable {
  final UserOnboardingEntity userData;

  const SaveUserDataParams({required this.userData});

  @override
  List<Object?> get props => [userData];
}