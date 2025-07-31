import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();

  @override
  String toString() => 'LoadProfile';
}

class RefreshProfile extends ProfileEvent {
  const RefreshProfile();

  @override
  String toString() => 'RefreshProfile';
}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile({required this.profileData});

  @override
  List<Object?> get props => [profileData];

  @override
  String toString() => 'UpdateProfile { profileData: $profileData }';
}

class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;

  const UpdatePreferences({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdatePreferences { preferences: $preferences }';
}

class UpdateSettings extends ProfileEvent {
  final Map<String, dynamic> settings;

  const UpdateSettings({required this.settings});

  @override
  List<Object?> get props => [settings];

  @override
  String toString() => 'UpdateSettings { settings: $settings }';
}

class UpdateAvatar extends ProfileEvent {
  final String avatarName;

  const UpdateAvatar({required this.avatarName});

  @override
  List<Object?> get props => [avatarName];

  @override
  String toString() => 'UpdateAvatar { avatarName: $avatarName }';
}

class LoadAchievements extends ProfileEvent {
  const LoadAchievements();

  @override
  String toString() => 'LoadAchievements';
}

class ExportData extends ProfileEvent {
  final List<String> dataTypes;

  const ExportData({this.dataTypes = const []});

  @override
  List<Object?> get props => [dataTypes];

  @override
  String toString() => 'ExportData { dataTypes: $dataTypes }';
}

class ClearProfileError extends ProfileEvent {
  const ClearProfileError();

  @override
  String toString() => 'ClearProfileError';
}

class ClearProfileCache extends ProfileEvent {
  const ClearProfileCache();

  @override
  String toString() => 'ClearProfileCache';
}

class UpdateProfileField extends ProfileEvent {
  final String fieldName;
  final dynamic value;

  const UpdateProfileField({
    required this.fieldName,
    required this.value,
  });

  @override
  List<Object?> get props => [fieldName, value];

  @override
  String toString() => 'UpdateProfileField { fieldName: $fieldName, value: $value }';
}

class TogglePrivacy extends ProfileEvent {
  final bool isPrivate;

  const TogglePrivacy({required this.isPrivate});

  @override
  List<Object?> get props => [isPrivate];

  @override
  String toString() => 'TogglePrivacy { isPrivate: $isPrivate }';
}

class UpdateThemeColor extends ProfileEvent {
  final String themeColor;

  const UpdateThemeColor({required this.themeColor});

  @override
  List<Object?> get props => [themeColor];

  @override
  String toString() => 'UpdateThemeColor { themeColor: $themeColor }';
}

class DeleteAccount extends ProfileEvent {
  final String confirmationText;

  const DeleteAccount({required this.confirmationText});

  @override
  List<Object?> get props => [confirmationText];

  @override
  String toString() => 'DeleteAccount { confirmationText: $confirmationText }';
}

class SyncProfile extends ProfileEvent {
  const SyncProfile();

  @override
  String toString() => 'SyncProfile';
}