
import '../../domain/entity/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    super.pronouns,
    super.ageGroup,
    super.selectedAvatar,
    required super.isOnboardingCompleted,
    required super.isActive,
    required super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _extractId(json),
      username: json['username'] ?? '',
      pronouns: json['pronouns'],
      ageGroup: json['ageGroup'] ?? json['age_group'],
      selectedAvatar: json['selectedAvatar'] ?? json['selected_avatar'] ?? json['avatar'],
      isOnboardingCompleted: _extractOnboardingStatus(json),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt: _extractDateTime(json['createdAt'] ?? json['created_at']),
      lastLoginAt: _extractDateTime(json['lastLoginAt'] ?? json['last_login_at']),
    );
  }

  static String _extractId(Map<String, dynamic> json) {
    return (json['id'] ?? json['_id'] ?? json['userId'] ?? '').toString();
  }

  static bool _extractOnboardingStatus(Map<String, dynamic> json) {
    // Check multiple possible field names and default to true for existing users
    return json['isOnboardingCompleted'] ?? 
           json['onboardingCompleted'] ?? 
           json['onboarding_completed'] ?? 
           true; // Default to true since user exists in system
  }

  static DateTime _extractDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar,
      'isOnboardingCompleted': isOnboardingCompleted,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      pronouns: entity.pronouns,
      ageGroup: entity.ageGroup,
      selectedAvatar: entity.selectedAvatar,
      isOnboardingCompleted: entity.isOnboardingCompleted,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      pronouns: pronouns,
      ageGroup: ageGroup,
      selectedAvatar: selectedAvatar,
      isOnboardingCompleted: isOnboardingCompleted,
      isActive: isActive,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    bool? isOnboardingCompleted,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}