import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();

  @override
  String toString() => 'LoadProfile()';
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();

  @override
  String toString() => 'RefreshProfile()';
}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile({required this.profileData});

  @override
  List<Object?> get props => [profileData];

  @override
  String toString() => 'UpdateProfile(profileData: $profileData)';
}

class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;

  const UpdatePreferences({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdatePreferences(preferences: $preferences)';
}

// CRITICAL: This was missing and causing the error
class UpdateSettings extends ProfileEvent {
  final Map<String, dynamic> settings;

  const UpdateSettings({required this.settings});

  @override
  List<Object?> get props => [settings];

  @override
  String toString() => 'UpdateSettings(settings: $settings)';
}

class LoadAchievements extends ProfileEvent {
  const LoadAchievements();

  @override
  String toString() => 'LoadAchievements()';
}

class ExportData extends ProfileEvent {
  const ExportData();

  @override
  String toString() => 'ExportData()';
}

class DeleteAccount extends ProfileEvent {
  const DeleteAccount();

  @override
  String toString() => 'DeleteAccount()';
}

class ClearProfileError extends ProfileEvent {
  const ClearProfileError();

  @override
  String toString() => 'ClearProfileError()';
}
