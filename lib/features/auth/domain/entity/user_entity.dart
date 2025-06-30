import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final bool isOnboardingCompleted;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.username,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    required this.isOnboardingCompleted,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    pronouns,
    ageGroup,
    selectedAvatar,
    isOnboardingCompleted,
    isActive,
    createdAt,
    lastLoginAt,
  ];
}
