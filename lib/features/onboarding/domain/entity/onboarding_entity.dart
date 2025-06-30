// features/onboarding/domain/entity/onboarding_entity.dart

import 'package:equatable/equatable.dart';

enum OnboardingStepType { welcome, pronouns, age, avatar, completion }

class OnboardingStepEntity extends Equatable {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String description;
  final OnboardingStepType type;
  final bool isRequired;
  final Map<String, dynamic>? data;

  const OnboardingStepEntity({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.isRequired = false,
    this.data,
  });

  String get id => stepNumber.toString();
  Map<String, dynamic>? get metadata => data;

  @override
  List<Object?> get props => [
    stepNumber,
    title,
    subtitle,
    description,
    type,
    isRequired,
    data,
  ];

  @override
  String toString() {
    return 'OnboardingStepEntity(stepNumber: $stepNumber, title: $title, '
        'subtitle: $subtitle, type: $type)';
  }
}

class UserOnboardingEntity extends Equatable {
  final String? username;
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic>? additionalData;

  const UserOnboardingEntity({
    this.username,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    this.isCompleted = false,
    this.completedAt,
    this.additionalData,
  });

  UserOnboardingEntity copyWith({
    String? username,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return UserOnboardingEntity(
      username: username ?? this.username,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  @override
  List<Object?> get props => [
    username,
    pronouns,
    ageGroup,
    selectedAvatar,
    isCompleted,
    completedAt,
    additionalData,
  ];

  @override
  String toString() {
    return 'UserOnboardingEntity(username: $username, pronouns: $pronouns, '
        'ageGroup: $ageGroup, selectedAvatar: $selectedAvatar, '
        'isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}
