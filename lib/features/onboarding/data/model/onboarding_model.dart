// features/onboarding/data/model/onboarding_model.dart

import '../../domain/entity/onboarding_entity.dart';

class OnboardingStepModel extends OnboardingStepEntity {
  const OnboardingStepModel({
    required super.stepNumber,
    required super.title,
    required super.subtitle,
    required super.description,
    required super.type,
    super.isRequired = false,
    super.data,
  });

  factory OnboardingStepModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStepModel(
      stepNumber: json['stepNumber'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: OnboardingStepType.values.firstWhere(
        (e) => e.toString() == 'OnboardingStepType.${json['type']}',
        orElse: () => OnboardingStepType.welcome,
      ),
      isRequired: json['isRequired'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type.toString().split('.').last,
      'isRequired': isRequired,
      'data': data,
    };
  }

  factory OnboardingStepModel.fromEntity(OnboardingStepEntity entity) {
    return OnboardingStepModel(
      stepNumber: entity.stepNumber,
      title: entity.title,
      subtitle: entity.subtitle,
      description: entity.description,
      type: entity.type,
      isRequired: entity.isRequired,
      data: entity.data,
    );
  }

  OnboardingStepEntity toEntity() {
    return OnboardingStepEntity(
      stepNumber: stepNumber,
      title: title,
      subtitle: subtitle,
      description: description,
      type: type,
      isRequired: isRequired,
      data: data,
    );
  }
}

class UserOnboardingModel extends UserOnboardingEntity {
  const UserOnboardingModel({
    super.username,
    super.pronouns,
    super.ageGroup,
    super.selectedAvatar,
    super.isCompleted = false,
    super.completedAt,
    super.additionalData,
  });

  factory UserOnboardingModel.fromJson(Map<String, dynamic> json) {
    return UserOnboardingModel(
      username: json['username'] as String?,
      pronouns: json['pronouns'] as String?,
      ageGroup: json['ageGroup'] as String?,
      selectedAvatar: json['selectedAvatar'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  factory UserOnboardingModel.fromEntity(UserOnboardingEntity entity) {
    return UserOnboardingModel(
      username: entity.username,
      pronouns: entity.pronouns,
      ageGroup: entity.ageGroup,
      selectedAvatar: entity.selectedAvatar,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      additionalData: entity.additionalData,
    );
  }

  UserOnboardingEntity toEntity() {
    return UserOnboardingEntity(
      username: username,
      pronouns: pronouns,
      ageGroup: ageGroup,
      selectedAvatar: selectedAvatar,
      isCompleted: isCompleted,
      completedAt: completedAt,
      additionalData: additionalData,
    );
  }

  @override
  UserOnboardingModel copyWith({
    String? username,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    bool? isCompleted,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return UserOnboardingModel(
      username: username ?? this.username,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Helper methods for easier data manipulation
  static UserOnboardingModel empty() {
    return const UserOnboardingModel();
  }

  bool get hasBasicInfo =>
      username != null &&
      username!.isNotEmpty &&
      pronouns != null &&
      pronouns!.isNotEmpty;

  bool get hasFullProfile =>
      hasBasicInfo &&
      ageGroup != null &&
      ageGroup!.isNotEmpty &&
      selectedAvatar != null &&
      selectedAvatar!.isNotEmpty;

  double get completionPercentage {
    int completedFields = 0;
    const int totalFields = 4; // username, pronouns, ageGroup, selectedAvatar

    if (username != null && username!.isNotEmpty) completedFields++;
    if (pronouns != null && pronouns!.isNotEmpty) completedFields++;
    if (ageGroup != null && ageGroup!.isNotEmpty) completedFields++;
    if (selectedAvatar != null && selectedAvatar!.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  @override
  String toString() {
    return 'UserOnboardingModel(username: $username, pronouns: $pronouns, '
        'ageGroup: $ageGroup, selectedAvatar: $selectedAvatar, '
        'isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}
