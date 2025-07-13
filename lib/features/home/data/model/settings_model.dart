// lib/features/home/data/models/settings_model.dart
import 'package:equatable/equatable.dart';

/// Model for user settings and preferences
class SettingsModel extends Equatable {
  final bool notificationsEnabled;
  final bool dataSharingEnabled;
  final String language;
  final String theme;
  final DateTime? updatedAt;

  const SettingsModel({
    this.notificationsEnabled = true,
    this.dataSharingEnabled = false,
    this.language = 'English',
    this.theme = 'Cosmic Purple',
    this.updatedAt,
  });

  /// Create from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dataSharingEnabled: json['dataSharingEnabled'] ?? false,
      language: json['language'] ?? 'English',
      theme: json['theme'] ?? 'Cosmic Purple',
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'dataSharingEnabled': dataSharingEnabled,
      'language': language,
      'theme': theme,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified values
  SettingsModel copyWith({
    bool? notificationsEnabled,
    bool? dataSharingEnabled,
    String? language,
    String? theme,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    notificationsEnabled,
    dataSharingEnabled,
    language,
    theme,
    updatedAt,
  ];
}
