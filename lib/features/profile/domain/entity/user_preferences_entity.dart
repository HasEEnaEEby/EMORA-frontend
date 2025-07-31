import 'package:equatable/equatable.dart';

class UserPreferencesEntity extends Equatable {
  final bool notificationsEnabled;
  final bool sharingEnabled;
  final String language;
  final String theme;
  final bool darkModeEnabled;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> customSettings;

  const UserPreferencesEntity({
    this.notificationsEnabled = true,
    this.sharingEnabled = false,
    this.language = 'English',
    this.theme = 'Cosmic Purple',
    this.darkModeEnabled = true,
    this.privacySettings = const {},
    this.customSettings = const {},
  });

  factory UserPreferencesEntity.fromBackendResponse(Map<String, dynamic> data) {
    return UserPreferencesEntity(
      notificationsEnabled:
          data['notificationsEnabled'] as bool? ??
          data['notifications']?['dailyReminder'] as bool? ??
          true,
      sharingEnabled:
          data['sharingEnabled'] as bool? ??
          data['shareEmotions'] as bool? ??
          false,
      language: data['language'] as String? ?? 'English',
      theme: data['theme'] as String? ?? 'Cosmic Purple',
      darkModeEnabled: data['darkModeEnabled'] as bool? ?? true,
      privacySettings: data['privacySettings'] as Map<String, dynamic>? ?? {},
      customSettings: data['customSettings'] as Map<String, dynamic>? ?? {},
    );
  }

  UserPreferencesEntity copyWith({
    bool? notificationsEnabled,
    bool? sharingEnabled,
    String? language,
    String? theme,
    bool? darkModeEnabled,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferencesEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      sharingEnabled: sharingEnabled ?? this.sharingEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      privacySettings: privacySettings ?? this.privacySettings,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  Map<String, dynamic> toBackendMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dataSharingEnabled': sharingEnabled,
      'language': language,
      'theme': theme,
      'darkModeEnabled': darkModeEnabled,
      'privacySettings': privacySettings,
      'customSettings': customSettings,
      'notifications': {
        'dailyReminder': notificationsEnabled,
        'friendRequests': notificationsEnabled,
        'comfortReactions': notificationsEnabled,
      },
      'shareLocation': false,
      'shareEmotions': sharingEnabled,
      'anonymousMode': false,
      'moodPrivacy': 'friends',
    };
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    sharingEnabled,
    language,
    theme,
    darkModeEnabled,
    privacySettings,
    customSettings,
  ];
}
