import 'package:emora_mobile_app/features/auth/domain/entity/emotion_context_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/emotion_memory_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/secondary_emotion_entity.dart';

class EmotionEntryEntity {
  final String id;
  final String userId;
  final String emotion;
  final String? coreEmotion;
  final double intensity;
  final DateTime timestamp;
  final EmotionContextEntity? context;
  final EmotionMemoryEntity? memory;
  final List<SecondaryEmotionEntity>? secondaryEmotions;
  final bool isPrivate;
  final String? source;

  const EmotionEntryEntity({
    required this.id,
    required this.userId,
    required this.emotion,
    this.coreEmotion,
    required this.intensity,
    required this.timestamp,
    this.context,
    this.memory,
    this.secondaryEmotions,
    this.isPrivate = false,
    this.source,
  });

  factory EmotionEntryEntity.fromJson(Map<String, dynamic> json) {
    return EmotionEntryEntity(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      emotion: json['emotion'] ?? json['coreEmotion'] ?? '',
      coreEmotion: json['coreEmotion'],
      intensity: (json['intensity'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      context: json['context'] != null
          ? EmotionContextEntity.fromJson(json['context'])
          : null,
      memory: json['memory'] != null
          ? EmotionMemoryEntity.fromJson(json['memory'])
          : null,
      secondaryEmotions: json['secondaryEmotions'] != null
          ? (json['secondaryEmotions'] as List)
                .map((e) => SecondaryEmotionEntity.fromJson(e))
                .toList()
          : null,
      isPrivate: json['memory']?['isPrivate'] ?? false,
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'emotion': emotion,
      'coreEmotion': coreEmotion,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'context': context?.toJson(),
      'memory': memory?.toJson(),
      'secondaryEmotions': secondaryEmotions?.map((e) => e.toJson()).toList(),
      'source': source,
    };
  }
}
