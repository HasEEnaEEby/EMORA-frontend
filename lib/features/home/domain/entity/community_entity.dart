import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CommunityPostEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String emoji;
  final String location;
  final String message;
  final DateTime timestamp;
  final List<ReactionEntity> reactions;
  final List<CommentEntity> comments;
  final int viewCount;
  final int shareCount;
  final String moodColor;
  final String activityType;
  final bool isFriend;
final String privacy; 
  final bool isAnonymous;

  const CommunityPostEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    required this.emoji,
    required this.location,
    required this.message,
    required this.timestamp,
    this.reactions = const [],
    this.comments = const [],
    this.viewCount = 0,
    this.shareCount = 0,
    required this.moodColor,
    required this.activityType,
    this.isFriend = false,
    this.privacy = 'public',
    this.isAnonymous = false,
  });

  CommunityPostEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? emoji,
    String? location,
    String? note,
    DateTime? timestamp,
    List<ReactionEntity>? reactions,
    List<CommentEntity>? comments,
    int? viewCount,
    int? shareCount,
    String? moodColor,
    String? activityType,
    bool? isFriend,
    String? privacy,
    bool? isAnonymous,
  }) {
    return CommunityPostEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      emoji: emoji ?? this.emoji,
      location: location ?? this.location,
      message: note ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      comments: comments ?? this.comments,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      moodColor: moodColor ?? this.moodColor,
      activityType: activityType ?? this.activityType,
      isFriend: isFriend ?? this.isFriend,
      privacy: privacy ?? this.privacy,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  factory CommunityPostEntity.fromJson(Map<String, dynamic> json) {
    return CommunityPostEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      selectedAvatar: json['selectedAvatar']?.toString() ?? 'panda',
      emoji: json['emoji']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      message: json['message']?.toString() ?? json['content']?.toString() ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      moodColor: json['moodColor']?.toString() ?? '#8B5CF6',
      activityType: json['activityType']?.toString() ?? 'General',
      privacy: json['privacy']?.toString() ?? 'public',
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
      'emoji': emoji,
      'location': location,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'moodColor': moodColor,
      'activityType': activityType,
      'privacy': privacy,
      'isAnonymous': isAnonymous,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        displayName,
        selectedAvatar,
        emoji,
        location,
        message,
        timestamp,
        reactions,
        comments,
        viewCount,
        shareCount,
        moodColor,
        activityType,
        isFriend,
        privacy,
        isAnonymous,
      ];

  Color get color {
    switch (moodColor.toLowerCase()) {
      case '#4caf50':
      case 'green':
        return const Color(0xFF4CAF50);
      case '#ffeb3b':
      case 'yellow':
        return const Color(0xFFFFEB3B);
      case '#f44336':
      case 'red':
        return const Color(0xFFF44336);
      case '#2196f3':
      case 'blue':
        return const Color(0xFF2196F3);
      case '#8b5cf6':
      case 'purple':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}

class ReactionEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String emoji;
final String type; 
  final DateTime createdAt;

  const ReactionEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.emoji,
    required this.type,
    required this.createdAt,
  });

  ReactionEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? emoji,
    String? type,
    DateTime? createdAt,
  }) {
    return ReactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, username, displayName, emoji, type, createdAt];
}

class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String message;
  final DateTime createdAt;
  final bool isAnonymous;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    required this.message,
    required this.createdAt,
    this.isAnonymous = false,
  });

  CommentEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? message,
    DateTime? createdAt,
    bool? isAnonymous,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        displayName,
        selectedAvatar,
        message,
        createdAt,
        isAnonymous,
      ];
}

class GlobalMoodStatsEntity extends Equatable {
  final String emotion;
  final int count;
  final double percentage;
  final double avgIntensity;
  final String emoji;
  final String color;

  const GlobalMoodStatsEntity({
    required this.emotion,
    required this.count,
    required this.percentage,
    required this.avgIntensity,
    required this.emoji,
    required this.color,
  });

  GlobalMoodStatsEntity copyWith({
    String? emotion,
    int? count,
    double? percentage,
    double? avgIntensity,
    String? emoji,
    String? color,
  }) {
    return GlobalMoodStatsEntity(
      emotion: emotion ?? this.emotion,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
      avgIntensity: avgIntensity ?? this.avgIntensity,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [emotion, count, percentage, avgIntensity, emoji, color];
} 