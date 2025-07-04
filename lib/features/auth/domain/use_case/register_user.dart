// lib/features/auth/domain/use_case/register_user.dart - UPDATED RegisterUserParams
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../entity/auth_response_entity.dart';
import '../repository/auth_repository.dart';

class RegisterUser extends UseCase<AuthResponseEntity, RegisterUserParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthResponseEntity>> call(
    RegisterUserParams params,
  ) async {
    return await repository.register(
      username: params.username,
      password: params.password,
      pronouns: params.pronouns, // ✅ CAN BE NULL
      ageGroup: params.ageGroup, // ✅ CAN BE NULL
      selectedAvatar: params.selectedAvatar, // ✅ CAN BE NULL
      location: params.location,
      latitude: params.latitude,
      longitude: params.longitude,
      email: params.email, // ✅ REQUIRED
    );
  }
}

// ✅ UPDATED: RegisterUserParams with nullable onboarding fields
class RegisterUserParams extends Equatable {
  final String username;
  final String password;
  final String? pronouns; // ✅ NULLABLE - user can set later in profile
  final String? ageGroup; // ✅ NULLABLE - user can set later in profile
  final String? selectedAvatar; // ✅ NULLABLE - user can set later in profile
  final String? location;
  final double? latitude;
  final double? longitude;
  final String email; // ✅ REQUIRED

  const RegisterUserParams({
    required this.username,
    required this.password,
    this.pronouns, // ✅ NULLABLE
    this.ageGroup, // ✅ NULLABLE
    this.selectedAvatar, // ✅ NULLABLE
    this.location,
    this.latitude,
    this.longitude,
    required this.email, // ✅ REQUIRED
  });

  @override
  List<Object?> get props => [
    username,
    password,
    pronouns,
    ageGroup,
    selectedAvatar,
    location,
    latitude,
    longitude,
    email,
  ];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'email': email, // ✅ ALWAYS INCLUDE EMAIL
    };

    // ✅ ONLY ADD ONBOARDING DATA IF NOT NULL
    if (pronouns != null) data['pronouns'] = pronouns;
    if (ageGroup != null) data['ageGroup'] = ageGroup;
    if (selectedAvatar != null) data['selectedAvatar'] = selectedAvatar;
    if (location != null) data['location'] = location;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    return data;
  }
}