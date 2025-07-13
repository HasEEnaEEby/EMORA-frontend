import 'package:equatable/equatable.dart';

import '../../domain/entity/achievement_entity.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/entity/user_preferences_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;
  final Map<String, dynamic>? additionalData;

  const ProfileLoaded({
    required this.profile,
    this.preferences,
    required this.achievements,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    profile,
    preferences,
    achievements,
    additionalData,
  ];
}

class ProfileUpdating extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileUpdating({
    required this.profile,
    this.preferences,
    required this.achievements,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];
}

class ProfilePreferencesUpdating extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfilePreferencesUpdating({
    required this.profile,
    this.preferences,
    required this.achievements,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];
}

class ProfileAchievementsLoading extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileAchievementsLoading({
    required this.profile,
    this.preferences,
    required this.achievements,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];
}

class ProfileDataExporting extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;

  const ProfileDataExporting({
    required this.profile,
    this.preferences,
    required this.achievements,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements];
}

class ProfileDataExported extends ProfileState {
  final ProfileEntity profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity> achievements;
  final Map<String, dynamic> exportedData;

  const ProfileDataExported({
    required this.profile,
    this.preferences,
    required this.achievements,
    required this.exportedData,
  });

  @override
  List<Object?> get props => [profile, preferences, achievements, exportedData];
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity? profile;
  final UserPreferencesEntity? preferences;
  final List<AchievementEntity>? achievements;

  const ProfileError({
    required this.message,
    this.profile,
    this.preferences,
    this.achievements,
  });

  @override
  List<Object?> get props => [message, profile, preferences, achievements];
}
