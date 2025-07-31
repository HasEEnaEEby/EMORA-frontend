
import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';

class FriendMoodEntity {
  final String id;
  final String emotion;
  final int intensity;
  final String? note;
  final DateTime timestamp;
  final String privacy;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? context;
  final List<String>? triggers;
  final List<String>? copingStrategies;
  final List<MoodReactionEntity> reactions;
  final FriendEntity friend;

  FriendMoodEntity({
    required this.id,
    required this.emotion,
    required this.intensity,
    this.note,
    required this.timestamp,
    required this.privacy,
    this.location,
    this.context,
    this.triggers,
    this.copingStrategies,
    required this.reactions,
    required this.friend,
  });

  factory FriendMoodEntity.fromJson(Map<String, dynamic> json) {
    return FriendMoodEntity(
      id: json['id'] ?? '',
      emotion: json['emotion'] ?? '',
      intensity: json['intensity'] ?? 3,
      note: json['note'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      privacy: json['privacy'] ?? 'private',
      location: json['location'],
      context: json['context'],
      triggers: json['triggers'] != null 
          ? List<String>.from(json['triggers'])
          : null,
      copingStrategies: json['coping_strategies'] != null 
          ? List<String>.from(json['coping_strategies'])
          : null,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((reaction) => MoodReactionEntity.fromJson(reaction))
              .toList()
          : [],
      friend: FriendEntity.fromJson(json['friend'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emotion': emotion,
      'intensity': intensity,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'privacy': privacy,
      'location': location,
      'context': context,
      'triggers': triggers,
      'coping_strategies': copingStrategies,
      'reactions': reactions.map((reaction) => reaction.toJson()).toList(),
      'friend': friend.toJson(),
    };
  }

  FriendMoodEntity copyWith({
    String? id,
    String? emotion,
    int? intensity,
    String? note,
    DateTime? timestamp,
    String? privacy,
    Map<String, dynamic>? location,
    Map<String, dynamic>? context,
    List<String>? triggers,
    List<String>? copingStrategies,
    List<MoodReactionEntity>? reactions,
    FriendEntity? friend,
  }) {
    return FriendMoodEntity(
      id: id ?? this.id,
      emotion: emotion ?? this.emotion,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      privacy: privacy ?? this.privacy,
      location: location ?? this.location,
      context: context ?? this.context,
      triggers: triggers ?? this.triggers,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      reactions: reactions ?? this.reactions,
      friend: friend ?? this.friend,
    );
  }
}

class MoodReactionEntity {
  final String id;
  final String type;
  final String? message;
  final FriendEntity? fromUser;
  final DateTime timestamp;
  final bool isAnonymous;

  MoodReactionEntity({
    required this.id,
    required this.type,
    this.message,
    this.fromUser,
    required this.timestamp,
    required this.isAnonymous,
  });

  factory MoodReactionEntity.fromJson(Map<String, dynamic> json) {
    return MoodReactionEntity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'],
      fromUser: json['fromUser'] != null 
          ? FriendEntity.fromJson(json['fromUser'])
          : null,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'fromUser': fromUser?.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }
} 