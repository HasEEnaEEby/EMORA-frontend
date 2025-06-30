import 'package:equatable/equatable.dart';

class EmotionEntity extends Equatable {
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
  final String? character; // For Inside Out style emotions

  const EmotionEntity({
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

  EmotionEntity copyWith({
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
    return EmotionEntity(
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

  factory EmotionEntity.fromJson(Map<String, dynamic> json) {
    return EmotionEntity(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      emotion: json['emotion'] ?? json['coreEmotion'] ?? '',
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

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}
