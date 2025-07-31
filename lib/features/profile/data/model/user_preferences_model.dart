import 'dart:convert';

import '../../domain/entity/user_preferences_entity.dart';

class UserPreferencesModel {
  final bool notificationsEnabled;
  final bool sharingEnabled;
  final String language;
  final String theme;
  final bool darkModeEnabled;
  final Map<String, dynamic> privacySettings;
  final Map<String, dynamic> customSettings;

  const UserPreferencesModel({
    this.notificationsEnabled = true,
    this.sharingEnabled = false,
    this.language = 'English',
    this.theme = 'Cosmic Purple',
    this.darkModeEnabled = true,
    this.privacySettings = const {},
    this.customSettings = const {},
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      sharingEnabled: json['sharingEnabled'] ?? false,
      language: json['language'] ?? 'English',
      theme: json['theme'] ?? 'Cosmic Purple',
      darkModeEnabled: json['darkModeEnabled'] ?? true,
      privacySettings: Map<String, dynamic>.from(json['privacySettings'] ?? {}),
      customSettings: Map<String, dynamic>.from(json['customSettings'] ?? {}),
    );
  }

  factory UserPreferencesModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserPreferencesModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'sharingEnabled': sharingEnabled,
      'language': language,
      'theme': theme,
      'darkModeEnabled': darkModeEnabled,
      'privacySettings': privacySettings,
      'customSettings': customSettings,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  UserPreferencesEntity toEntity() {
    return UserPreferencesEntity(
      notificationsEnabled: notificationsEnabled,
      sharingEnabled: sharingEnabled,
      language: language,
      theme: theme,
      darkModeEnabled: darkModeEnabled,
      privacySettings: privacySettings,
      customSettings: customSettings,
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferencesEntity entity) {
    return UserPreferencesModel(
      notificationsEnabled: entity.notificationsEnabled,
      sharingEnabled: entity.sharingEnabled,
      language: entity.language,
      theme: entity.theme,
      darkModeEnabled: entity.darkModeEnabled,
      privacySettings: entity.privacySettings,
      customSettings: entity.customSettings,
    );
  }

  UserPreferencesModel copyWith({
    bool? notificationsEnabled,
    bool? sharingEnabled,
    String? language,
    String? theme,
    bool? darkModeEnabled,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferencesModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      sharingEnabled: sharingEnabled ?? this.sharingEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      privacySettings: privacySettings ?? this.privacySettings,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
