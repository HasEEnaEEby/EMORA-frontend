import '../../domain/entity/auth_response_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    required super.token,
    required super.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      expiresIn: json['expiresIn'] ?? '7d',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user as UserModel).toJson(),
      'token': token,
      'expiresIn': expiresIn,
    };
  }

  factory AuthResponseModel.fromEntity(AuthResponseEntity entity) {
    return AuthResponseModel(
      user: entity.user,
      token: entity.token,
      expiresIn: entity.expiresIn,
    );
  }

  AuthResponseEntity toEntity() {
    return AuthResponseEntity(user: user, token: token, expiresIn: expiresIn);
  }
}
