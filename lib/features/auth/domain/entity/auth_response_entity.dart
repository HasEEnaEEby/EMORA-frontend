import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class AuthResponseEntity extends Equatable {
  final UserEntity user;
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthResponseEntity({
    required this.user,
    required this.token,
    this.refreshToken,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [user, token, refreshToken, expiresAt];

  @override
  String toString() {
    return 'AuthResponseEntity(user: $user, token: ${token.substring(0, 10)}..., '
        'refreshToken: ${refreshToken?.substring(0, 10)}..., expiresAt: $expiresAt)';
  }

  AuthResponseEntity copyWith({
    UserEntity? user,
    String? token,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResponseEntity(
      user: user ?? this.user,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
