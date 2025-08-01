import 'package:equatable/equatable.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/achievement_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/user_preferences_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  String toString() => 'ProfileInitial';
}

class ProfileLoading extends ProfileState {
  final ProfileEntity? profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity>? achievements;

  const ProfileLoading({
    this.profile,
    this.preferences,
    this.achievements,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileLoading';
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileLoaded({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileLoaded { profile: ${profile.name}, achievements: ${achievements.length} }';

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    UserPreferencesEntity? preferences,
    List<AchievementEntity>? achievements,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      achievements: achievements ?? this.achievements,
    );
  }
}

class ProfileUpdating extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileUpdating({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileUpdating { profile: ${profile.name} }';
}

class ProfilePreferencesUpdating extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfilePreferencesUpdating({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfilePreferencesUpdating { profile: ${profile.name} }';
}

class ProfileAchievementsLoading extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileAchievementsLoading({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileAchievementsLoading { profile: ${profile.name} }';
}

class ProfileDataExporting extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileDataExporting({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileDataExporting { profile: ${profile.name} }';
}

class ProfileDataExported extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;
  final Map<String, dynamic> exportedData;

  const ProfileDataExported({
    required this.profile,
    this.preferences,
    this.achievements = const [],
    required this.exportedData,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements, exportedData];

  @override
  String toString() => 'ProfileDataExported { profile: ${profile.name}, exportedData: $exportedData }';
}

class ProfileAvatarUpdating extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;
  final String newAvatar;

  const ProfileAvatarUpdating({
    required this.profile,
    this.preferences,
    this.achievements = const [],
    required this.newAvatar,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements, newAvatar];

  @override
  String toString() => 'ProfileAvatarUpdating { profile: ${profile.name}, newAvatar: $newAvatar }';
}

class ProfileSyncing extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileSyncing({
    required this.profile,
    this.preferences,
    this.achievements = const [],
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];

  @override
  String toString() => 'ProfileSyncing { profile: ${profile.name} }';
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity? profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity>? achievements;
  final dynamic error;

  const ProfileError({
    required this.message,
    this.profile,
    this.preferences,
    this.achievements,
    this.error,
  });

  @override
  List<Object?> get props => [message, profile, preferences, achievements, error];

  @override
  String toString() => 'ProfileError { message: $message, error: $error }';

  bool get hasProfileData => profile != null;

  bool get canRetry => profile != null;
}

class ProfileAccountDeleting extends ProfileState {
  final ProfileEntity profile;

  const ProfileAccountDeleting({required this.profile});

  @override
  List<Object?> get props => [profile];

  @override
  String toString() => 'ProfileAccountDeleting { profile: ${profile.name} }';
}

class ProfileAccountDeleted extends ProfileState {
  final String message;

  const ProfileAccountDeleted({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'ProfileAccountDeleted { message: $message }';
}

class ProfileValidationError extends ProfileState {
  final String message;
  final Map<String, String> fieldErrors;
  final ProfileEntity? profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity>? achievements;

  const ProfileValidationError({
    required this.message,
    this.fieldErrors = const {},
    this.profile,
    this.preferences,
    this.achievements,
  });

  @override
  List<Object?> get props => [message, fieldErrors, profile, preferences, achievements];

  @override
  String toString() => 'ProfileValidationError { message: $message, fieldErrors: $fieldErrors }';

  String? getFieldError(String fieldName) => fieldErrors[fieldName];

  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
}

class ProfileNetworkError extends ProfileState {
  final String message;
  final ProfileEntity? profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity>? achievements;

  const ProfileNetworkError({
    required this.message,
    this.profile,
    this.preferences,
    this.achievements,
  });

  @override
  List<Object?> get props => [message, profile, preferences, achievements];

  @override
  String toString() => 'ProfileNetworkError { message: $message }';
}

extension ProfileStateExtensions on ProfileState {
  bool get isLoading {
    return this is ProfileLoading ||
           this is ProfileUpdating ||
           this is ProfilePreferencesUpdating ||
           this is ProfileAchievementsLoading ||
           this is ProfileDataExporting ||
           this is ProfileAvatarUpdating ||
           this is ProfileSyncing ||
           this is ProfileAccountDeleting;
  }

  bool get hasProfileData {
    if (this is ProfileLoaded) return true;
    if (this is ProfileUpdating) return true;
    if (this is ProfilePreferencesUpdating) return true;
    if (this is ProfileAchievementsLoading) return true;
    if (this is ProfileDataExporting) return true;
    if (this is ProfileAvatarUpdating) return true;
    if (this is ProfileSyncing) return true;
    if (this is ProfileError) return (this as ProfileError).hasProfileData;
    if (this is ProfileValidationError) return (this as ProfileValidationError).profile != null;
    if (this is ProfileNetworkError) return (this as ProfileNetworkError).profile != null;
    return false;
  }

  ProfileEntity? get profileData {
    if (this is ProfileLoaded) return (this as ProfileLoaded).profile;
    if (this is ProfileUpdating) return (this as ProfileUpdating).profile;
    if (this is ProfilePreferencesUpdating) return (this as ProfilePreferencesUpdating).profile;
    if (this is ProfileAchievementsLoading) return (this as ProfileAchievementsLoading).profile;
    if (this is ProfileDataExporting) return (this as ProfileDataExporting).profile;
    if (this is ProfileAvatarUpdating) return (this as ProfileAvatarUpdating).profile;
    if (this is ProfileSyncing) return (this as ProfileSyncing).profile;
    if (this is ProfileError) return (this as ProfileError).profile;
    if (this is ProfileValidationError) return (this as ProfileValidationError).profile;
    if (this is ProfileNetworkError) return (this as ProfileNetworkError).profile;
    return null;
  }

  UserPreferencesEntity? get preferencesData {
    if (this is ProfileLoaded) return (this as ProfileLoaded).preferences;
    if (this is ProfileUpdating) return (this as ProfileUpdating).preferences;
    if (this is ProfilePreferencesUpdating) return (this as ProfilePreferencesUpdating).preferences;
    if (this is ProfileAchievementsLoading) return (this as ProfileAchievementsLoading).preferences;
    if (this is ProfileDataExporting) return (this as ProfileDataExporting).preferences;
    if (this is ProfileSyncing) return (this as ProfileSyncing).preferences;
    if (this is ProfileError) return (this as ProfileError).preferences;
    if (this is ProfileValidationError) return (this as ProfileValidationError).preferences;
    if (this is ProfileNetworkError) return (this as ProfileNetworkError).preferences;
    return null;
  }

  List<AchievementEntity> get achievementsData {
    if (this is ProfileLoaded) return (this as ProfileLoaded).achievements;
    if (this is ProfileUpdating) return (this as ProfileUpdating).achievements;
    if (this is ProfilePreferencesUpdating) return (this as ProfilePreferencesUpdating).achievements;
    if (this is ProfileAchievementsLoading) return (this as ProfileAchievementsLoading).achievements;
    if (this is ProfileDataExporting) return (this as ProfileDataExporting).achievements;
    if (this is ProfileSyncing) return (this as ProfileSyncing).achievements;
    if (this is ProfileError) return (this as ProfileError).achievements ?? [];
    if (this is ProfileValidationError) return (this as ProfileValidationError).achievements ?? [];
    if (this is ProfileNetworkError) return (this as ProfileNetworkError).achievements ?? [];
    return [];
  }

  bool get isError {
    return this is ProfileError ||
           this is ProfileValidationError ||
           this is ProfileNetworkError;
  }

  String? get errorMessage {
    if (this is ProfileError) return (this as ProfileError).message;
    if (this is ProfileValidationError) return (this as ProfileValidationError).message;
    if (this is ProfileNetworkError) return (this as ProfileNetworkError).message;
    return null;
  }

  bool get allowsInteraction {
    return !isLoading && !isError;
  }

  bool get canUpdate {
    return hasProfileData && !isLoading;
  }
}