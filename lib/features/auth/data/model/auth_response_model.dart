
import '../../domain/entity/auth_response_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    required super.token,
    required super.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    final userJson = json['user'] ?? json;
    final token = json['token'] ?? json['access_token'] ?? '';
    final expiresIn = json['expiresIn'] ?? json['expires_in'] ?? '7d';
    
    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      token: token,
      expiresIn: expiresIn,
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
