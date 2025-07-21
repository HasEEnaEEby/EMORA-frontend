// lib/features/profile/presentation/view_model/profile_event.dart - COMPLETE VERSION
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load user profile data
class LoadProfile extends ProfileEvent {
  const LoadProfile();

  @override
  String toString() => 'LoadProfile';
}

/// Refresh profile data (force reload)
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();

  @override
  String toString() => 'RefreshProfile';
}

/// Update user profile with new data
class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateProfile({required this.profileData});

  @override
  List<Object?> get props => [profileData];

  @override
  String toString() => 'UpdateProfile { profileData: $profileData }';
}

/// Update user preferences
class UpdatePreferences extends ProfileEvent {
  final Map<String, dynamic> preferences;

  const UpdatePreferences({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdatePreferences { preferences: $preferences }';
}

/// Update user settings (similar to preferences but different use case)
class UpdateSettings extends ProfileEvent {
  final Map<String, dynamic> settings;

  const UpdateSettings({required this.settings});

  @override
  List<Object?> get props => [settings];

  @override
  String toString() => 'UpdateSettings { settings: $settings }';
}

/// Update user avatar specifically
class UpdateAvatar extends ProfileEvent {
  final String avatarName;

  const UpdateAvatar({required this.avatarName});

  @override
  List<Object?> get props => [avatarName];

  @override
  String toString() => 'UpdateAvatar { avatarName: $avatarName }';
}

/// Load user achievements
class LoadAchievements extends ProfileEvent {
  const LoadAchievements();

  @override
  String toString() => 'LoadAchievements';
}

/// Export user data
class ExportData extends ProfileEvent {
  final List<String> dataTypes;

  const ExportData({this.dataTypes = const []});

  @override
  List<Object?> get props => [dataTypes];

  @override
  String toString() => 'ExportData { dataTypes: $dataTypes }';
}

/// Clear profile error state
class ClearProfileError extends ProfileEvent {
  const ClearProfileError();

  @override
  String toString() => 'ClearProfileError';
}

/// Clear profile cache
class ClearProfileCache extends ProfileEvent {
  const ClearProfileCache();

  @override
  String toString() => 'ClearProfileCache';
}

/// Update specific profile field
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

/// Toggle privacy setting
class TogglePrivacy extends ProfileEvent {
  final bool isPrivate;

  const TogglePrivacy({required this.isPrivate});

  @override
  List<Object?> get props => [isPrivate];

  @override
  String toString() => 'TogglePrivacy { isPrivate: $isPrivate }';
}

/// Update theme color
class UpdateThemeColor extends ProfileEvent {
  final String themeColor;

  const UpdateThemeColor({required this.themeColor});

  @override
  List<Object?> get props => [themeColor];

  @override
  String toString() => 'UpdateThemeColor { themeColor: $themeColor }';
}

/// Delete user account
class DeleteAccount extends ProfileEvent {
  final String confirmationText;

  const DeleteAccount({required this.confirmationText});

  @override
  List<Object?> get props => [confirmationText];

  @override
  String toString() => 'DeleteAccount { confirmationText: $confirmationText }';
}

/// Sync profile with server
class SyncProfile extends ProfileEvent {
  const SyncProfile();

  @override
  String toString() => 'SyncProfile';
}