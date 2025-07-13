import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool isOnboardingCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    this.location,
    this.latitude,
    this.longitude,
    required this.isOnboardingCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        pronouns,
        ageGroup,
        selectedAvatar,
        location,
        latitude,
        longitude,
        isOnboardingCompleted,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserEntity(id: $id, username: $username, email: $email, '
        'pronouns: $pronouns, ageGroup: $ageGroup, avatar: $selectedAvatar, '
        'onboardingCompleted: $isOnboardingCompleted)';
  }

  UserEntity copyWith({
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
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
