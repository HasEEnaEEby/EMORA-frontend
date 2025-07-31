import '../../domain/entity/auth_response_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    required super.token,
    super.refreshToken,
    super.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user']),
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory AuthResponseModel.fromEntity(AuthResponseEntity entity) {
    return AuthResponseModel(
      user: entity.user,
      token: entity.token,
      refreshToken: entity.refreshToken,
      expiresAt: entity.expiresAt,
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }
}
