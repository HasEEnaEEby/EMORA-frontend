import 'package:equatable/equatable.dart';

import '../../../domain/entity/onboarding_entity.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingDataSaving extends OnboardingState {}

class OnboardingStepsLoaded extends OnboardingState {
  final List<OnboardingStepEntity> steps;
  final int currentStepIndex;
  final UserOnboardingEntity userData;
  final bool canGoNext;
  final bool canGoPrevious;

  const OnboardingStepsLoaded({
    required this.steps,
    required this.currentStepIndex,
    required this.userData,
    required this.canGoNext,
    required this.canGoPrevious,
  });

  // Convenience getters
  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex >= steps.length - 1;
  OnboardingStepEntity get currentStep => steps[currentStepIndex];

  OnboardingStepsLoaded copyWith({
    List<OnboardingStepEntity>? steps,
    int? currentStepIndex,
    UserOnboardingEntity? userData,
    bool? canGoNext,
    bool? canGoPrevious,
  }) {
    return OnboardingStepsLoaded(
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      userData: userData ?? this.userData,
      canGoNext: canGoNext ?? this.canGoNext,
      canGoPrevious: canGoPrevious ?? this.canGoPrevious,
    );
  }

  @override
  List<Object> get props => [
    steps,
    currentStepIndex,
    userData,
    canGoNext,
    canGoPrevious,
  ];

  @override
  String toString() {
    return 'OnboardingStepsLoaded(steps: ${steps.length}, '
        'currentStepIndex: $currentStepIndex, '
        'userData: $userData, '
        'canGoNext: $canGoNext, '
        'canGoPrevious: $canGoPrevious)';
  }
}

class OnboardingCompleted extends OnboardingState {
  final UserOnboardingEntity userData;
  final bool remoteSync; // FIXED: Track if remote sync was successful

  const OnboardingCompleted(this.userData, [this.remoteSync = false]);

  @override
  List<Object> get props => [userData, remoteSync];

  @override
  String toString() {
    return 'OnboardingCompleted(userData: $userData, remoteSync: $remoteSync)';
  }
}

class OnboardingError extends OnboardingState {
  final String message;
  final String? errorCode;

  const OnboardingError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];

  @override
  String toString() {
    return 'OnboardingError(message: $message, errorCode: $errorCode)';
  }
}
