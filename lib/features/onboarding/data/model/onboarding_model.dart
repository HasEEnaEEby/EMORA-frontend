import '../../../../core/constants/backend_mapping.dart';
import '../../domain/entity/onboarding_entity.dart';

class OnboardingStepModel {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String description;
  final String type;
  final bool isRequired;
  final Map<String, dynamic>? data;

  OnboardingStepModel({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.type,
    this.isRequired = false,
    this.data,
  });

  factory OnboardingStepModel.fromJson(Map<String, dynamic> json) {
    return OnboardingStepModel(
      stepNumber: json['stepNumber'] ?? json['step_number'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'welcome',
      isRequired: json['isRequired'] ?? json['is_required'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'type': type,
      'isRequired': isRequired,
      'data': data,
    };
  }

  OnboardingStepEntity toEntity() {
    OnboardingStepType stepType;
    switch (type.toLowerCase()) {
      case 'welcome':
        stepType = OnboardingStepType.welcome;
        break;
      case 'pronouns':
        stepType = OnboardingStepType.pronouns;
        break;
      case 'age':
        stepType = OnboardingStepType.age;
        break;
      case 'avatar':
        stepType = OnboardingStepType.avatar;
        break;
      case 'completion':
        stepType = OnboardingStepType.completion;
        break;
      default:
        stepType = OnboardingStepType.welcome;
    }

    return OnboardingStepEntity(
      stepNumber: stepNumber,
      title: title,
      subtitle: subtitle,
      description: description,
      type: stepType,
      isRequired: isRequired,
      data: data,
    );
  }

  factory OnboardingStepModel.fromEntity(OnboardingStepEntity entity) {
    String typeString;
    switch (entity.type) {
      case OnboardingStepType.welcome:
        typeString = 'welcome';
        break;
      case OnboardingStepType.pronouns:
        typeString = 'pronouns';
        break;
      case OnboardingStepType.age:
        typeString = 'age';
        break;
      case OnboardingStepType.avatar:
        typeString = 'avatar';
        break;
      case OnboardingStepType.completion:
        typeString = 'completion';
        break;
    }

    return OnboardingStepModel(
      stepNumber: entity.stepNumber,
      title: entity.title,
      subtitle: entity.subtitle,
      description: entity.description,
      type: typeString,
      isRequired: entity.isRequired,
      data: entity.data,
    );
  }
}

class UserOnboardingModel {
  final String? username;
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic>? additionalData;

  static const List<String> validBackendAgeGroups = [
    'Under 18',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
  ];

  static const List<String> validFrontendAgeGroups = [
    'less than 20s',
    '20s',
    '30s',
    '40s',
    '50s and above',
  ];

  UserOnboardingModel({
    this.username,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    this.isCompleted = false,
    this.completedAt,
    this.additionalData,
  }) {
    if (ageGroup != null && !validBackendAgeGroups.contains(ageGroup)) {
      print(
        '. Warning: Invalid age group "$ageGroup". Valid backend options: $validBackendAgeGroups',
      );
    }
  }

  factory UserOnboardingModel.fromJson(Map<String, dynamic> json) {
    String? normalizedAgeGroup;
    final rawAgeGroup = json['ageGroup'] ?? json['age_group'];
    if (rawAgeGroup != null) {
      normalizedAgeGroup = BackendValues.normalizeAgeGroupFromApi(rawAgeGroup);
      if (rawAgeGroup != normalizedAgeGroup) {
        print(
          '🔄 Age group normalized: "$rawAgeGroup" -> "$normalizedAgeGroup"',
        );
      }
    }

    return UserOnboardingModel(
      username: json['username'],
      pronouns: json['pronouns'],
      ageGroup: normalizedAgeGroup,
      selectedAvatar: json['selectedAvatar'] ?? json['selected_avatar'],
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt']) ??
                DateTime.tryParse(json['completed_at'])
          : null,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    if (ageGroup != null) {
      final isValidBackendValue = validBackendAgeGroups.contains(ageGroup);
      if (!isValidBackendValue) {
        print(
          '. Warning: Invalid age group "$ageGroup". Converting to backend value...',
        );
        final convertedValue = BackendValues.getBackendAgeGroup(ageGroup);
        print('🔄 Converted: "$ageGroup" -> "$convertedValue"');
      } else {
        print('. Sending valid backend age group: "$ageGroup"');
      }
    }

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

  bool get isAgeGroupValid =>
      ageGroup == null || validBackendAgeGroups.contains(ageGroup);

  String? get ageGroupValidationError {
    if (ageGroup == null) return null;
    if (!validBackendAgeGroups.contains(ageGroup)) {
      return 'Invalid age group "$ageGroup". Must be one of: ${validBackendAgeGroups.join(", ")}';
    }
    return null;
  }

  String? get ageGroupDisplayValue {
    if (ageGroup == null) return null;
    return BackendValues.getFrontendAgeGroup(ageGroup);
  }

  factory UserOnboardingModel.fromFrontendValues({
    String? username,
    String? frontendPronouns,
    String? frontendAgeGroup,
    String? frontendAvatar,
    bool isCompleted = false,
    DateTime? completedAt,
    Map<String, dynamic>? additionalData,
  }) {
    return UserOnboardingModel(
      username: username,
      pronouns: BackendValues.getBackendPronouns(frontendPronouns),
      ageGroup: BackendValues.getBackendAgeGroup(frontendAgeGroup),
      selectedAvatar: BackendValues.getBackendAvatar(frontendAvatar),
      isCompleted: isCompleted,
      completedAt: completedAt,
      additionalData: additionalData,
    );
  }

  Map<String, String?> get frontendDisplayValues {
    return {
      'username': username,
      'pronouns': BackendValues.getFrontendPronouns(pronouns),
      'ageGroup': BackendValues.getFrontendAgeGroup(ageGroup),
      'selectedAvatar': BackendValues.getFrontendAvatar(selectedAvatar),
    };
  }

  @override
  String toString() {
    return 'UserOnboardingModel(username: $username, pronouns: $pronouns, '
        'ageGroup: $ageGroup, selectedAvatar: $selectedAvatar, '
        'isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  Map<String, bool> get validationStatus {
    return {
      'ageGroup': isAgeGroupValid,
      'pronouns': pronouns == null || BackendValues.isValidPronouns(pronouns),
      'avatar':
          selectedAvatar == null || BackendValues.isValidAvatar(selectedAvatar),
    };
  }
}
