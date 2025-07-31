
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class FriendMoodData extends Equatable {
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
  final List<MoodReactionData> reactions;
  final FriendMoodUserData friend;

  const FriendMoodData({
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

  factory FriendMoodData.fromJson(Map<String, dynamic> json) {
    return FriendMoodData(
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
              .map((reaction) => MoodReactionData.fromJson(reaction))
              .toList()
          : [],
      friend: FriendMoodUserData.fromJson(json['friend'] ?? {}),
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
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'friend': friend.toJson(),
    };
  }

  String get emoji {
    const emotionEmojis = {
      'happy': '😊',
      'sad': '😢',
      'angry': '😠',
      'anxious': '😰',
      'excited': '🎉',
      'calm': '😌',
      'stressed': '😤',
      'grateful': '🙏',
      'lonely': '😔',
      'confident': '😎',
      'tired': '😴',
      'energetic': '⚡',
      'peaceful': '🕊️',
      'frustrated': '😤',
      'joyful': '😄',
      'worried': '😟',
      'content': '😊',
      'overwhelmed': '😵',
      'hopeful': '✨',
      'disappointed': '😞',
    };
    return emotionEmojis[emotion.toLowerCase()] ?? '😊';
  }

  Color get color {
    const emotionColors = {
'happy': Color(0xFF10B981), 
'sad': Color(0xFF6366F1),   
'angry': Color(0xFFEF4444), 
'anxious': Color(0xFFF59E0B), 
'excited': Color(0xFFFFD700), 
'calm': Color(0xFF8B5CF6),   
'stressed': Color(0xFFF97316), 
'grateful': Color(0xFF10B981), 
'lonely': Color(0xFF6366F1),  
'confident': Color(0xFF10B981), 
'tired': Color(0xFF6B7280),   
'energetic': Color(0xFFFFD700), 
'peaceful': Color(0xFF8B5CF6), 
'frustrated': Color(0xFFEF4444), 
'joyful': Color(0xFF10B981),   
'worried': Color(0xFFF59E0B),  
'content': Color(0xFF10B981),  
'overwhelmed': Color(0xFFEF4444), 
'hopeful': Color(0xFF8B5CF6),  
'disappointed': Color(0xFF6B7280), 
    };
    return emotionColors[emotion.toLowerCase()] ?? const Color(0xFF8B5CF6);
  }

  String get locationDisplay {
    if (location == null) return 'Unknown Location';
    
    final locationData = location!;
    if (locationData['city'] != null) {
      return locationData['city'];
    } else if (locationData['name'] != null) {
      return locationData['name'];
    } else if (locationData['country'] != null) {
      return locationData['country'];
    }
    return 'Unknown Location';
  }

  @override
  List<Object?> get props => [
    id,
    emotion,
    intensity,
    note,
    timestamp,
    privacy,
    location,
    context,
    triggers,
    copingStrategies,
    reactions,
    friend,
  ];
}

class MoodReactionData extends Equatable {
  final String id;
  final String type;
  final String? message;
  final FriendMoodUserData? fromUser;
  final DateTime timestamp;
  final bool isAnonymous;

  const MoodReactionData({
    required this.id,
    required this.type,
    this.message,
    this.fromUser,
    required this.timestamp,
    required this.isAnonymous,
  });

  factory MoodReactionData.fromJson(Map<String, dynamic> json) {
    return MoodReactionData(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'],
      fromUser: json['fromUser'] != null 
          ? FriendMoodUserData.fromJson(json['fromUser'])
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

  @override
  List<Object?> get props => [
    id,
    type,
    message,
    fromUser,
    timestamp,
    isAnonymous,
  ];
}

class FriendMoodUserData extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String selectedAvatar;

  const FriendMoodUserData({
    required this.id,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
  });

  factory FriendMoodUserData.fromJson(Map<String, dynamic> json) {
    return FriendMoodUserData(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      selectedAvatar: json['selectedAvatar'] ?? json['avatar'] ?? 'panda',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
    };
  }

  @override
  List<Object?> get props => [
    id,
    username,
    displayName,
    selectedAvatar,
  ];
} 