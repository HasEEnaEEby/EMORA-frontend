import '../../domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.pronouns,
    super.ageGroup,
    super.selectedAvatar,
    super.location,
    super.latitude,
    super.longitude,
    required super.isOnboardingCompleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      pronouns: json['pronouns'] as String?,
      ageGroup: json['ageGroup'] as String?,
      selectedAvatar: json['selectedAvatar'] as String?,
      location: json['location'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'isOnboardingCompleted': isOnboardingCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      email: email,
      pronouns: pronouns,
      ageGroup: ageGroup,
      selectedAvatar: selectedAvatar,
      location: location,
      latitude: latitude,
      longitude: longitude,
      isOnboardingCompleted: isOnboardingCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      pronouns: entity.pronouns,
      ageGroup: entity.ageGroup,
      selectedAvatar: entity.selectedAvatar,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isOnboardingCompleted: entity.isOnboardingCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
    bool? isOnboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
