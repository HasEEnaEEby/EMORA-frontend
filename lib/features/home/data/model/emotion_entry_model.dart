import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class EmotionEntryModel extends Equatable {
  final String id;
  final String userId;
  final String emotion;
  final double intensity;
  final String? context;
  final String? memory;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? additionalData;
  final bool isAnonymous;
  final List<String>? tags;
  final String? character;

  const EmotionEntryModel({
    required this.id,
    required this.userId,
    required this.emotion,
    required this.intensity,
    this.context,
    this.memory,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.additionalData,
    this.isAnonymous = true,
    this.tags,
    this.character,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    emotion,
    intensity,
    context,
    memory,
    timestamp,
    latitude,
    longitude,
    additionalData,
    isAnonymous,
    tags,
    character,
  ];

  EmotionEntryModel copyWith({
    String? id,
    String? userId,
    String? emotion,
    double? intensity,
    String? context,
    String? memory,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
    bool? isAnonymous,
    List<String>? tags,
    String? character,
  }) {
    return EmotionEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      context: context ?? this.context,
      memory: memory ?? this.memory,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      additionalData: additionalData ?? this.additionalData,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      tags: tags ?? this.tags,
      character: character ?? this.character,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emotion': emotion,
      'intensity': intensity,
      'context': context,
      'memory': memory,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'additionalData': additionalData,
      'isAnonymous': isAnonymous,
      'tags': tags,
      'character': character,
    };
  }

  factory EmotionEntryModel.fromJson(Map<String, dynamic> json) {
    return EmotionEntryModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      emotion: json['emotion'] ?? json['coreEmotion'] ?? json['type'] ?? '',
      intensity: (json['intensity'] ?? 0.0).toDouble(),
      context: json['context']?.toString(),
      memory: json['memory']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
      isAnonymous: json['isAnonymous'] ?? json['is_anonymous'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      character: json['character'],
    );
  }

  // Helper methods
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasContext => context != null && context!.isNotEmpty;
  bool get hasMemory => memory != null && memory!.isNotEmpty;
  bool get hasTags => tags != null && tags!.isNotEmpty;

  String get intensityLabel {
    if (intensity <= 0.2) return 'Very Low';
    if (intensity <= 0.4) return 'Low';
    if (intensity <= 0.6) return 'Medium';
    if (intensity <= 0.8) return 'High';
    return 'Very High';
  }

  // Get mood color based on emotion type
  Color get moodColor {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
      case 'love':
      case 'gratitude':
      case 'contentment':
      case 'pride':
      case 'relief':
      case 'hope':
      case 'enthusiasm':
      case 'serenity':
      case 'bliss':
        return const Color(0xFF4CAF50); // Green for positive
      case 'sadness':
      case 'anger':
      case 'fear':
      case 'anxiety':
      case 'frustration':
      case 'disappointment':
      case 'loneliness':
      case 'stress':
      case 'guilt':
      case 'shame':
      case 'jealousy':
      case 'regret':
        return const Color(0xFFFF6B6B); // Red for negative
      case 'calm':
      case 'peaceful':
      case 'neutral':
      case 'focused':
      case 'curious':
      case 'thoughtful':
      case 'contemplative':
      case 'reflective':
      case 'alert':
      case 'balanced':
        return const Color(0xFFFFD700); // Yellow for neutral
      default:
        return const Color(0xFF8B5CF6); // Purple for unknown
    }
  }

  // Get emoji for emotion
  String get emotionEmoji {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
        return '😊';
      case 'excitement':
        return '🤩';
      case 'love':
        return '💝';
      case 'gratitude':
        return '🙏';
      case 'contentment':
        return '😌';
      case 'pride':
        return '😎';
      case 'relief':
        return '😮‍💨';
      case 'hope':
        return '✨';
      case 'enthusiasm':
        return '🔥';
      case 'serenity':
      case 'bliss':
        return '😇';
      case 'sadness':
        return '😢';
      case 'anger':
        return '😠';
      case 'fear':
        return '😨';
      case 'anxiety':
        return '😰';
      case 'frustration':
        return '😤';
      case 'disappointment':
        return '😞';
      case 'loneliness':
        return '🥺';
      case 'stress':
        return '😓';
      case 'guilt':
        return '😣';
      case 'shame':
        return '😳';
      case 'jealousy':
        return '😒';
      case 'regret':
        return '😔';
      case 'calm':
      case 'peaceful':
        return '😌';
      case 'neutral':
        return '😐';
      case 'focused':
        return '🤔';
      case 'curious':
        return '🤨';
      case 'thoughtful':
      case 'contemplative':
      case 'reflective':
        return '🧐';
      case 'alert':
        return '😳';
      case 'balanced':
        return '😊';
      default:
        return '😊';
    }
  }
}

// Weekly insights data model
class WeeklyInsightsModel extends Equatable {
  final String mostCommonMood;
  final double averageMoodScore;
  final int totalEntries;
  final int currentStreak;
  final Map<String, int> moodDistribution;
  final List<String> insights;
  final double weekProgress;

  const WeeklyInsightsModel({
    required this.mostCommonMood,
    required this.averageMoodScore,
    required this.totalEntries,
    required this.currentStreak,
    required this.moodDistribution,
    required this.insights,
    required this.weekProgress,
  });

  @override
  List<Object?> get props => [
    mostCommonMood,
    averageMoodScore,
    totalEntries,
    currentStreak,
    moodDistribution,
    insights,
    weekProgress,
  ];

  Map<String, dynamic> toJson() {
    return {
      'mostCommonMood': mostCommonMood,
      'averageMoodScore': averageMoodScore,
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'moodDistribution': moodDistribution,
      'insights': insights,
      'weekProgress': weekProgress,
    };
  }

  factory WeeklyInsightsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyInsightsModel(
      mostCommonMood: json['mostCommonMood'] ?? '',
      averageMoodScore: (json['averageMoodScore'] ?? 0.0).toDouble(),
      totalEntries: json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      moodDistribution: Map<String, int>.from(json['moodDistribution'] ?? {}),
      insights: List<String>.from(json['insights'] ?? []),
      weekProgress: (json['weekProgress'] ?? 0.0).toDouble(),
    );
  }
} 