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
  Future<Either<Failure, AuthResponseEntity>> call(RegisterUserParams params) async {
    return await repository.register(
      username: params.username,
      password: params.password,
      pronouns: params.pronouns,
      ageGroup: params.ageGroup,
      selectedAvatar: params.selectedAvatar,
      location: params.location,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String username;
  final String password;
  final String pronouns;
  final String ageGroup;
  final String selectedAvatar;
  final String? location;
  final double? latitude;
  final double? longitude;

  const RegisterUserParams({
    required this.username,
    required this.password,
    required this.pronouns,
    required this.ageGroup,
    required this.selectedAvatar,
    this.location,
    this.latitude,
    this.longitude,
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
  ];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar,
    };

    if (location != null) data['location'] = location;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;

    return data;
  }
}