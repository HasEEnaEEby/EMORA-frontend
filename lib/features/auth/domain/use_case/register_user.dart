import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/auth_response_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUser extends UseCase<AuthResponseEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(
    RegisterParams params,
  ) async {
    return await repository.registerUser(
      username: params.username,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword, // ✅ Added confirmPassword parameter
      pronouns: params.pronouns,
      ageGroup: params.ageGroup,
      selectedAvatar: params.selectedAvatar,
      location: params.location,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String confirmPassword; // ✅ Added confirmPassword field
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool? termsAccepted;
  final bool? privacyAccepted;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword, // ✅ Added confirmPassword to constructor
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    this.location,
    this.latitude,
    this.longitude,
    this.termsAccepted,
    this.privacyAccepted,
  });

  @override
  List<Object?> get props => [
    username,
    email,
    password,
    confirmPassword, // ✅ Added confirmPassword to props
    pronouns,
    ageGroup,
    selectedAvatar,
    location,
    latitude,
    longitude,
    termsAccepted,
    privacyAccepted,
  ];
}
