import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class AuthResponseEntity extends Equatable {
  final UserEntity user;
  final String token;
  final String expiresIn;

  const AuthResponseEntity({
    required this.user,
    required this.token,
    required this.expiresIn,
  });

  @override
  List<Object> get props => [user, token, expiresIn];
}
