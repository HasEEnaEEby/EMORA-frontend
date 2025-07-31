import 'dart:developer' as developer;

import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/use_case/use_case.dart';
import '../../../domain/entity/onboarding_entity.dart';
import '../../../domain/use_case/complete_onboarding.dart';
import '../../../domain/use_case/get_onboarding_steps.dart';
import '../../../domain/use_case/save_user_data.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingSteps getOnboardingSteps;
  final SaveUserData saveUserData;
  final CompleteOnboarding completeOnboarding;

  OnboardingBloc({
    required this.getOnboardingSteps,
    required this.saveUserData,
    required this.completeOnboarding,
  }) : super(OnboardingInitial()) {
    on<LoadOnboardingSteps>(_onLoadOnboardingSteps);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SaveUsername>(_onSaveUsername);
    on<SavePronouns>(_onSavePronouns);
    on<SaveAgeGroup>(_onSaveAgeGroup);
    on<SaveAvatar>(_onSaveAvatar);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<SkipOnboarding>(_onSkipOnboarding);
    on<GoToStep>(_onGoToStep);
    on<ValidateCurrentStep>(_onValidateCurrentStep);
    on<SelectPronouns>(_onSelectPronouns);
    on<SelectAgeGroup>(_onSelectAgeGroup);
    on<SelectAvatar>(_onSelectAvatar);
    on<UpdateUserData>(_onUpdateUserData);
    on<SaveUserDataLocal>(_onSaveUserDataLocal);
    on<ResetOnboarding>(_onResetOnboarding);
  }

  List<OnboardingStepEntity> _getDefaultSteps() {
    return [
      const OnboardingStepEntity(
        stepNumber: 1,
        title: 'Welcome to',
        subtitle: 'Emora!',
        description: 'What do you want us to call you?',
        type: OnboardingStepType.welcome,
      ),
      const OnboardingStepEntity(
        stepNumber: 2,
        title: 'Hey there! What pronouns do you',
        subtitle: 'go by?',
        description:
            'We want everyone to feel seen and respected. Pick the pronouns you\'re most comfortable with.',
        type: OnboardingStepType.pronouns,
        data: {'options': AppConfig.availablePronouns},
      ),
      const OnboardingStepEntity(
        stepNumber: 3,
        title: 'Awesome! How',
        subtitle: 'old are you?',
        description:
            'What\'s your age group? This helps us show the most relevant content for you.',
        type: OnboardingStepType.age,
        data: {'options': AppConfig.availableAgeGroups},
      ),
      const OnboardingStepEntity(
        stepNumber: 4,
        title: 'Lastly, pick',
        subtitle: 'your avatar!',
        description:
            'Choose an avatar that feels like you — it\'s all about personality.',
        type: OnboardingStepType.avatar,
        data: {'avatars': AppConfig.availableAvatars},
      ),
      const OnboardingStepEntity(
        stepNumber: 5,
        title: 'Congrats,',
        subtitle: 'User!',
        description: 'You\'re free to express yourself',
        type: OnboardingStepType.completion,
      ),
    ];
  }

  Future<void> _onLoadOnboardingSteps(
    LoadOnboardingSteps event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('. Loading onboarding steps...');
    emit(OnboardingLoading());

    try {
      final result = await getOnboardingSteps(NoParams());

      result.fold(
        (failure) {
          developer.log(
            'Failed to load steps: ${failure.message}',
            name: 'OnboardingBloc',
          );

          final defaultSteps = _getDefaultSteps();
          final initialUserData = const UserOnboardingEntity();

          Logger.info('Using default steps due to: ${failure.message}');

          print('. DEBUG: Default steps count: ${defaultSteps.length}');
          for (int i = 0; i < defaultSteps.length; i++) {
            print(
              '  Default Step $i: ${defaultSteps[i].type} - "${defaultSteps[i].title}"',
            );
          }

          emit(
            OnboardingStepsLoaded(
              steps: defaultSteps,
currentStepIndex: 0, 
              userData: initialUserData,
              canGoNext: true,
              canGoPrevious: false,
            ),
          );
        },
        (steps) {
          final stepsToUse = (steps.isEmpty) ? _getDefaultSteps() : steps;
          final initialUserData = const UserOnboardingEntity();

          print('. DEBUG: Received ${steps.length} steps from API');
          for (int i = 0; i < steps.length; i++) {
            print('  API Step $i: ${steps[i].type} - "${steps[i].title}"');
          }

          print('. DEBUG: Using ${stepsToUse.length} steps total');
          for (int i = 0; i < stepsToUse.length; i++) {
            print(
              '  Final Step $i: ${stepsToUse[i].type} - "${stepsToUse[i].title}"',
            );
          }

          Logger.info('Loaded ${stepsToUse.length} onboarding steps');

          emit(
            OnboardingStepsLoaded(
              steps: stepsToUse,
currentStepIndex: 0, 
              userData: initialUserData,
              canGoNext: true,
              canGoPrevious: false,
            ),
          );
        },
      );
    } catch (e) {
      developer.log(
        'Unexpected error loading steps: $e',
        name: 'OnboardingBloc',
      );

      final defaultSteps = _getDefaultSteps();
      final initialUserData = const UserOnboardingEntity();

      emit(
        OnboardingStepsLoaded(
          steps: defaultSteps,
currentStepIndex: 0, 
          userData: initialUserData,
          canGoNext: true,
          canGoPrevious: false,
        ),
      );
    }
  }

  int _mapToDisplayIndex(
    int fullStepIndex,
    List<OnboardingStepEntity> allSteps,
  ) {
    if (fullStepIndex < 0 || fullStepIndex >= allSteps.length) return 0;

    final currentStep = allSteps[fullStepIndex];

    switch (currentStep.type) {
      case OnboardingStepType.welcome:
return 0; 
      case OnboardingStepType.pronouns:
return 0; 
      case OnboardingStepType.age:
return 1; 
      case OnboardingStepType.avatar:
return 2; 
      case OnboardingStepType.completion:
return 2; 
    }
  }

  void _onNextStep(NextStep event, Emitter<OnboardingState> emit) {
    Logger.info('🔄 Processing NextStep event...');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;

      Logger.info('Current step index: ${currentState.currentStepIndex}');
      Logger.info('Total steps: ${currentState.steps.length}');

      if (currentState.currentStepIndex < currentState.steps.length - 1) {
        final newIndex = currentState.currentStepIndex + 1;
        final nextStep = currentState.steps[newIndex];

        Logger.info('Next step type: ${nextStep.type}');

        if (nextStep.type == OnboardingStepType.completion) {
          Logger.info('🎯 Reached completion step - completing onboarding');
          add(CompleteOnboardingEvent(currentState.userData));
        } else {
          Logger.info('Moving to step index: $newIndex');

          emit(
            currentState.copyWith(
              currentStepIndex: newIndex,
              canGoNext: newIndex < currentState.steps.length - 1,
              canGoPrevious:
newIndex > 1, 
            ),
          );

          Logger.info('. State updated - moved to step $newIndex');
        }
      } else {
        Logger.info('🎯 Reached final step - completing onboarding');
        add(CompleteOnboardingEvent(currentState.userData));
      }
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter<OnboardingState> emit) {
    Logger.info('🔄 Processing PreviousStep event...');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;

      if (currentState.currentStepIndex > 1) {
        final newIndex = currentState.currentStepIndex - 1;

        Logger.info('Moving back to step index: $newIndex');

        emit(
          currentState.copyWith(
            currentStepIndex: newIndex,
            canGoNext: true,
canGoPrevious: newIndex > 1, 
          ),
        );

        Logger.info('. State updated - moved back to step $newIndex');
      } else {
        Logger.info('Cannot go back - already at first displayable step');
      }
    }
  }

  Future<void> _onSavePronouns(
    SavePronouns event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('. Saving pronouns: ${event.pronouns}');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        pronouns: event.pronouns,
      );

      await _saveUserDataGracefully(updatedUserData);

      Logger.info('Updated userData: ${updatedUserData.toString()}');

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));

      Logger.info('. Pronouns saved and state updated');
    }
  }

  Future<void> _onSaveAgeGroup(
    SaveAgeGroup event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('. Saving age group: ${event.ageGroup}');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        ageGroup: event.ageGroup,
      );

      await _saveUserDataGracefully(updatedUserData);

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));

      Logger.info('. Age group saved and state updated');
    }
  }

  Future<void> _onSaveAvatar(
    SaveAvatar event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('. Saving avatar: ${event.avatar}');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        selectedAvatar: event.avatar,
      );

      await _saveUserDataGracefully(updatedUserData);

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));

      Logger.info('. Avatar saved and state updated');
    }
  }

  Future<void> _saveUserDataGracefully(UserOnboardingEntity userData) async {
    try {
      final result = await saveUserData(SaveUserDataParams(userData: userData));
      result.fold(
        (failure) {
          if (AppConfig.shouldHandleErrorGracefully(
            failure is NotFoundFailure ? 404 : null,
            failure.message,
          )) {
            Logger.info(
              '. Data saved locally (server not available in dev mode)',
            );
          } else {
            Logger.warning('Non-critical save error: ${failure.message}');
          }
        },
        (_) {
          Logger.info('. User data saved successfully to server');
        },
      );
    } catch (e) {
      if (AppConfig.isDevelopmentMode) {
        Logger.info('. Save handled gracefully in development: $e');
      } else {
        developer.log('Save error: $e', name: 'OnboardingBloc');
        rethrow;
      }
    }
  }

  Future<void> _onSaveUsername(
    SaveUsername event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('. Saving username: ${event.username}');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        username: event.username.trim(),
      );

      await _saveUserDataGracefully(updatedUserData);

      const canGoNext = true;

      emit(
        currentState.copyWith(userData: updatedUserData, canGoNext: canGoNext),
      );

      Logger.info('. Username saved and state updated');
    }
  }

  void _onGoToStep(GoToStep event, Emitter<OnboardingState> emit) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;

      int targetIndex = event.stepIndex;
if (targetIndex < 1) targetIndex = 1; 
      if (targetIndex >= currentState.steps.length) {
        targetIndex = currentState.steps.length - 1;
      }

      if (targetIndex >= 1 && targetIndex < currentState.steps.length) {
        emit(
          currentState.copyWith(
            currentStepIndex: targetIndex,
            canGoNext: targetIndex < currentState.steps.length - 1,
            canGoPrevious: targetIndex > 1,
          ),
        );
      }
    }
  }

  void _onSelectPronouns(SelectPronouns event, Emitter<OnboardingState> emit) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        pronouns: event.pronouns,
      );

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));
    }
  }

  void _onSelectAgeGroup(SelectAgeGroup event, Emitter<OnboardingState> emit) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        ageGroup: event.ageGroup,
      );

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));
    }
  }

  void _onSelectAvatar(SelectAvatar event, Emitter<OnboardingState> emit) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        selectedAvatar: event.avatar,
      );

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));
    }
  }

  void _onUpdateUserData(UpdateUserData event, Emitter<OnboardingState> emit) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final updatedUserData = currentState.userData.copyWith(
        username: event.username,
        pronouns: event.pronouns,
        ageGroup: event.ageGroup,
        selectedAvatar: event.selectedAvatar,
      );

      emit(currentState.copyWith(userData: updatedUserData, canGoNext: true));
    }
  }

  Future<void> _onSaveUserDataLocal(
    SaveUserDataLocal event,
    Emitter<OnboardingState> emit,
  ) async {
    await _saveUserDataGracefully(event.userData);

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      emit(currentState.copyWith(userData: event.userData));
    }
  }

  void _onResetOnboarding(
    ResetOnboarding event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingInitial());
    add(LoadOnboardingSteps());
  }

  void _onValidateCurrentStep(
    ValidateCurrentStep event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;

      const canGoNext = true;

      if (canGoNext != currentState.canGoNext) {
        emit(currentState.copyWith(canGoNext: canGoNext));
      }
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('🎯 Starting onboarding completion...');

    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final finalUserData = event.userData ?? currentState.userData;

      emit(OnboardingDataSaving());

      final completedUserData = finalUserData.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        selectedAvatar:
            finalUserData.selectedAvatar ??
            currentState.userData.selectedAvatar ??
            AppConfig.defaultAvatar,
        pronouns: finalUserData.pronouns ?? AppConfig.defaultPronoun,
        ageGroup: finalUserData.ageGroup ?? AppConfig.defaultAgeGroup,
      );

      developer.log(
        'Completing onboarding with data: ${completedUserData.toString()}',
        name: 'OnboardingBloc',
      );

      try {
        await _saveUserDataGracefully(completedUserData);

        if (emit.isDone) return;

        final completeResult = await completeOnboarding(NoParams());

        if (emit.isDone) return;

        bool remoteSync = false;

        completeResult.fold(
          (failure) {
            if (AppConfig.shouldHandleErrorGracefully(
              failure is NotFoundFailure ? 404 : null,
              failure.message,
            )) {
              developer.log(
                'Server completion not available: ${failure.message}',
                name: 'OnboardingBloc',
              );
              Logger.info(
                'Onboarding completed locally - will sync after registration',
              );
              remoteSync = false;
            } else {
              Logger.warning('Server completion failed: ${failure.message}');
              remoteSync = false;
            }
          },
          (success) {
            Logger.info('. Onboarding completed on server');
            remoteSync = true;
          },
        );

        if (!emit.isDone) {
          emit(OnboardingCompleted(completedUserData, remoteSync));
        }
      } catch (e) {
        developer.log(
          'Onboarding completed offline: $e',
          name: 'OnboardingBloc',
        );

        if (!emit.isDone) {
          emit(OnboardingCompleted(completedUserData, false));
        }
      }
    }
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    Logger.info('🚀 Skipping onboarding...');

    emit(OnboardingDataSaving());

    final skippedUserData = UserOnboardingEntity(
      isCompleted: true,
      completedAt: DateTime.now(),
      pronouns: AppConfig.defaultPronoun,
      ageGroup: AppConfig.defaultAgeGroup,
      selectedAvatar: AppConfig.defaultAvatar,
    );

    developer.log(
      'Skipping onboarding with default data: ${skippedUserData.toString()}',
      name: 'OnboardingBloc',
    );

    try {
      await _saveUserDataGracefully(skippedUserData);

      if (emit.isDone) return;

      final completeResult = await completeOnboarding(NoParams());

      if (emit.isDone) return;

      bool remoteSync = false;

      completeResult.fold(
        (failure) {
          if (AppConfig.shouldHandleErrorGracefully(
            failure is NotFoundFailure ? 404 : null,
            failure.message,
          )) {
            developer.log(
              'Server completion not available for skip: ${failure.message}',
              name: 'OnboardingBloc',
            );
            remoteSync = false;
          } else {
            Logger.warning('Server skip completion failed: ${failure.message}');
            remoteSync = false;
          }
        },
        (success) {
          Logger.info('. Onboarding skip completed on server');
          remoteSync = true;
        },
      );

      if (!emit.isDone) {
        emit(OnboardingCompleted(skippedUserData, remoteSync));
      }
    } catch (e) {
      developer.log('Onboarding skipped offline: $e', name: 'OnboardingBloc');

      if (!emit.isDone) {
        emit(OnboardingCompleted(skippedUserData, false));
      }
    }
  }

  UserOnboardingEntity? getCurrentUserData() {
    if (state is OnboardingStepsLoaded) {
      return (state as OnboardingStepsLoaded).userData;
    }
    return null;
  }

  bool isOnboardingDataValid() {
    final userData = getCurrentUserData();
    if (userData == null) return false;

    return userData.pronouns != null &&
        userData.ageGroup != null &&
        userData.selectedAvatar != null;
  }

  double getCompletionProgress() {
    final userData = getCurrentUserData();
    if (userData == null) return 0.0;

    int completedFields = 0;
const int totalOptionalFields = 4; 

    if (userData.username != null && userData.username!.isNotEmpty) {
      completedFields++;
    }
    if (userData.pronouns != null && userData.pronouns!.isNotEmpty) {
      completedFields++;
    }
    if (userData.ageGroup != null && userData.ageGroup!.isNotEmpty) {
      completedFields++;
    }
    if (userData.selectedAvatar != null &&
        userData.selectedAvatar!.isNotEmpty) {
      completedFields++;
    }

    return completedFields / totalOptionalFields;
  }

  OnboardingStepType? getCurrentStepType() {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      if (currentState.currentStepIndex >= 0 &&
          currentState.currentStepIndex < currentState.steps.length) {
        return currentState.steps[currentState.currentStepIndex].type;
      }
    }
    return null;
  }

  bool isOnLastDisplayableStep() {
    if (state is OnboardingStepsLoaded) {
      final currentState = state as OnboardingStepsLoaded;
      final currentStep = currentState.steps[currentState.currentStepIndex];

      if (currentStep.type == OnboardingStepType.avatar) {
        return true;
      }

      final nextIndex = currentState.currentStepIndex + 1;
      if (nextIndex < currentState.steps.length) {
        final nextStep = currentState.steps[nextIndex];
        return nextStep.type == OnboardingStepType.completion;
      }
    }
    return false;
  }

  @override
  void onTransition(Transition<OnboardingEvent, OnboardingState> transition) {
    super.onTransition(transition);
    developer.log(
      'OnboardingBloc Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
      name: 'OnboardingBloc',
    );
  }
}
