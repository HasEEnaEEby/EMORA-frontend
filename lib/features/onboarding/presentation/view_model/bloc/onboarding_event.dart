import 'package:equatable/equatable.dart';

import '../../../domain/entity/onboarding_entity.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOnboardingSteps extends OnboardingEvent {}

class NextStep extends OnboardingEvent {}

class PreviousStep extends OnboardingEvent {}

class GoToStep extends OnboardingEvent {
  final int stepIndex;

  const GoToStep(this.stepIndex);

  @override
  List<Object> get props => [stepIndex];
}

class ValidateCurrentStep extends OnboardingEvent {}

class SaveUsername extends OnboardingEvent {
  final String username;

  const SaveUsername(this.username);

  @override
  List<Object> get props => [username];
}

class SavePronouns extends OnboardingEvent {
  final String pronouns;

  const SavePronouns(this.pronouns);

  @override
  List<Object> get props => [pronouns];
}

class SaveAgeGroup extends OnboardingEvent {
  final String ageGroup;

  const SaveAgeGroup(this.ageGroup);

  @override
  List<Object> get props => [ageGroup];
}

class SaveAvatar extends OnboardingEvent {
  final String avatar;

  const SaveAvatar(this.avatar);

  @override
  List<Object> get props => [avatar];
}

class CompleteOnboardingEvent extends OnboardingEvent {
  final UserOnboardingEntity? userData;

  const CompleteOnboardingEvent([this.userData]);

  @override
  List<Object?> get props => [userData];
}

class SkipOnboarding extends OnboardingEvent {}

class ResetOnboarding extends OnboardingEvent {}

class UpdateUserData extends OnboardingEvent {
  final String? username;
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;

  const UpdateUserData({
    this.username,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
  });

  @override
  List<Object?> get props => [username, pronouns, ageGroup, selectedAvatar];
}

class SelectPronouns extends OnboardingEvent {
  final String pronouns;

  const SelectPronouns(this.pronouns);

  @override
  List<Object> get props => [pronouns];
}

class SelectAgeGroup extends OnboardingEvent {
  final String ageGroup;

  const SelectAgeGroup(this.ageGroup);

  @override
  List<Object> get props => [ageGroup];
}

class SelectAvatar extends OnboardingEvent {
  final String avatar;

  const SelectAvatar(this.avatar);

  @override
  List<Object> get props => [avatar];
}

class SaveUserDataLocal extends OnboardingEvent {
  final UserOnboardingEntity userData;

  const SaveUserDataLocal(this.userData);

  @override
  List<Object> get props => [userData];
}
