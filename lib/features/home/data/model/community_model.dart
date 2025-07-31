import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entity/community_entity.dart';

class CommunityPostModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String emoji;
  final String location;
  final String message;
  final DateTime timestamp;
  final List<ReactionModel> reactions;
  final List<CommentModel> comments;
  final int viewCount;
  final int shareCount;
  final String moodColor;
  final String activityType;
  final bool isFriend;
  final String privacy;
  final bool isAnonymous;

  const CommunityPostModel({
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

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    try {
      print('. DEBUG: Raw JSON data: $json');
      print('. DEBUG: ID field: ${json['id']} (type: ${json['id'].runtimeType})');
      print('. DEBUG: Message field: ${json['message']} (type: ${json['message']?.runtimeType})');
      print('. DEBUG: Name field: ${json['name']} (type: ${json['name']?.runtimeType})');
      
      List<dynamic> reactionsData = [];
      List<dynamic> commentsData = [];
      
      if (json['reactions'] != null) {
        if (json['reactions'] is List) {
          reactionsData = json['reactions'] as List;
        } else if (json['reactions'] is int) {
          reactionsData = [];
        }
      } else if (json['likes'] != null) {
        if (json['likes'] is List) {
          reactionsData = json['likes'] as List;
        } else if (json['likes'] is int) {
          reactionsData = [];
        }
      }
      
      if (json['comments'] != null) {
        if (json['comments'] is List) {
          commentsData = json['comments'] as List;
        } else if (json['comments'] is int) {
          commentsData = [];
        }
      }

      final result = CommunityPostModel(
        id: _safeString(json['id']),
        name: _safeString(json['name']),
        username: _safeString(json['username']),
        displayName: _safeString(json['displayName'] ?? json['name']),
        selectedAvatar: _safeString(
          json['selectedAvatar'] ?? json['avatar'] ?? 'U',
        ),
        emoji: _safeString(json['emoji']),
        location: _safeString(json['location']),
        message: _safeString(json['note'] ?? json['message']),
        timestamp:
            _parseDateTime(json['timestamp'] ?? json['createdAt']) ??
            DateTime.now(),
        reactions: reactionsData.map((r) => ReactionModel.fromJson(r)).toList(),
        comments: commentsData.map((c) => CommentModel.fromJson(c)).toList(),
        viewCount: _safeInt(json['viewCount'] ?? json['views']),
        shareCount: _safeInt(json['shareCount'] ?? json['shares']),
        moodColor: _safeString(json['moodColor']),
        activityType: _safeString(json['activityType']),
        isFriend: _safeBool(json['isFriend']),
        privacy: _safeString(json['privacy']),
        isAnonymous: _safeBool(json['isAnonymous']),
      );
      
      print('. DEBUG: Parsed result - ID: "${result.id}", Message: "${result.message}"');
      return result;
    } catch (e) {
      print('. DEBUG: Error parsing JSON: $e');
      return CommunityPostModel.empty();
    }
  }

  factory CommunityPostModel.empty() {
    return CommunityPostModel(
      id: '',
      name: '',
      username: '',
      displayName: '',
      selectedAvatar: 'U',
      emoji: '😊',
      location: '',
      message: '',
      timestamp: DateTime.now(),
      reactions: const [],
      comments: const [],
      viewCount: 0,
      shareCount: 0,
      moodColor: '#8B5CF6',
      activityType: 'General',
      isFriend: false,
      privacy: 'public',
      isAnonymous: false,
    );
  }

  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  static double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    try {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  factory CommunityPostModel.fromEntity(CommunityPostEntity entity) {
    return CommunityPostModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      displayName: entity.displayName,
      selectedAvatar: entity.selectedAvatar,
      emoji: entity.emoji,
      location: entity.location,
      message: entity.message,
      timestamp: entity.timestamp,
      reactions: entity.reactions
          .map((r) => ReactionModel.fromEntity(r))
          .toList(),
      comments: entity.comments.map((c) => CommentModel.fromEntity(c)).toList(),
      viewCount: entity.viewCount,
      shareCount: entity.shareCount,
      moodColor: entity.moodColor,
      activityType: entity.activityType,
      isFriend: entity.isFriend,
      privacy: entity.privacy,
      isAnonymous: entity.isAnonymous,
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
      'note': message,
      'timestamp': timestamp.toIso8601String(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'viewCount': viewCount,
      'shareCount': shareCount,
      'moodColor': moodColor,
      'activityType': activityType,
      'isFriend': isFriend,
      'privacy': privacy,
      'isAnonymous': isAnonymous,
    };
  }

  CommunityPostEntity toEntity() {
    return CommunityPostEntity(
      id: id,
      name: name,
      username: username,
      displayName: displayName,
      selectedAvatar: selectedAvatar,
      emoji: emoji,
      location: location,
      message: message,
      timestamp: timestamp,
      reactions: reactions.map((r) => r.toEntity()).toList(),
      comments: comments.map((c) => c.toEntity()).toList(),
      viewCount: viewCount,
      shareCount: shareCount,
      moodColor: moodColor,
      activityType: activityType,
      isFriend: isFriend,
      privacy: privacy,
      isAnonymous: isAnonymous,
    );
  }

  CommunityPostModel copyWith({
    String? id,
    String? name,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? emoji,
    String? location,
    String? note,
    DateTime? timestamp,
    List<ReactionModel>? reactions,
    List<CommentModel>? comments,
    int? viewCount,
    int? shareCount,
    String? moodColor,
    String? activityType,
    bool? isFriend,
    String? privacy,
    bool? isAnonymous,
  }) {
    return CommunityPostModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      emoji: emoji ?? this.emoji,
      location: location ?? this.location,
      message: note ?? message,
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

  Color get moodColorValue {
    try {
      return Color(int.parse(moodColor.replaceAll('#', '0xFF')));
    } catch (e) {
return const Color(0xFF8B5CF6); 
    }
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
}

class ReactionModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String emoji;
  final String type;
  final DateTime createdAt;

  const ReactionModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.emoji,
    required this.type,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      emoji: json['emoji'] ?? '❤️',
      type: json['type'] ?? 'like',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory ReactionModel.empty() {
    return ReactionModel(
      id: '',
      userId: '',
      username: '',
      displayName: '',
      emoji: '❤️',
      type: 'like',
      createdAt: DateTime.now(),
    );
  }

  factory ReactionModel.fromEntity(ReactionEntity entity) {
    return ReactionModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      displayName: entity.displayName,
      emoji: entity.emoji,
      type: entity.type,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'emoji': emoji,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReactionEntity toEntity() {
    return ReactionEntity(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      emoji: emoji,
      type: type,
      createdAt: createdAt,
    );
  }

  ReactionModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? emoji,
    String? type,
    DateTime? createdAt,
  }) {
    return ReactionModel(
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
  List<Object?> get props => [
    id,
    userId,
    username,
    displayName,
    emoji,
    type,
    createdAt,
  ];
}

class CommentModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String message;
  final bool isAnonymous;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    required this.message,
    this.isAnonymous = false,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      selectedAvatar: json['selectedAvatar'] ?? 'U',
      message: json['message'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory CommentModel.empty() {
    return CommentModel(
      id: '',
      userId: '',
      username: '',
      displayName: '',
      selectedAvatar: 'U',
      message: '',
      isAnonymous: false,
      createdAt: DateTime.now(),
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      displayName: entity.displayName,
      selectedAvatar: entity.selectedAvatar,
      message: entity.message,
      isAnonymous: entity.isAnonymous,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
      'message': message,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CommentEntity toEntity() {
    return CommentEntity(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      selectedAvatar: selectedAvatar,
      message: message,
      createdAt: createdAt,
      isAnonymous: isAnonymous,
    );
  }

  CommentModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? message,
    bool? isAnonymous,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      message: message ?? this.message,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
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
    isAnonymous,
    createdAt,
  ];
}

class GlobalMoodStatsModel extends Equatable {
  final String emotion;
  final int count;
  final double percentage;
  final double avgIntensity;
  final String emoji;
  final String color;

  const GlobalMoodStatsModel({
    required this.emotion,
    required this.count,
    required this.percentage,
    required this.avgIntensity,
    required this.emoji,
    required this.color,
  });

  factory GlobalMoodStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return GlobalMoodStatsModel(
        emotion: CommunityPostModel._safeString(json['emotion']),
        count: CommunityPostModel._safeInt(json['count']),
        percentage: CommunityPostModel._safeDouble(json['percentage']),
        avgIntensity: CommunityPostModel._safeDouble(json['avgIntensity']),
        emoji: CommunityPostModel._safeString(json['emoji']),
        color: CommunityPostModel._safeString(json['color']),
      );
    } catch (e) {
      return GlobalMoodStatsModel.empty();
    }
  }

  factory GlobalMoodStatsModel.empty() {
    return const GlobalMoodStatsModel(
      emotion: 'neutral',
      count: 0,
      percentage: 0.0,
      avgIntensity: 0.0,
      emoji: '😐',
      color: '#8B5CF6',
    );
  }

  factory GlobalMoodStatsModel.fromEntity(GlobalMoodStatsEntity entity) {
    return GlobalMoodStatsModel(
      emotion: entity.emotion,
      count: entity.count,
      percentage: entity.percentage,
      avgIntensity: entity.avgIntensity,
      emoji: entity.emoji,
      color: entity.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'count': count,
      'percentage': percentage,
      'avgIntensity': avgIntensity,
      'emoji': emoji,
      'color': color,
    };
  }

  GlobalMoodStatsEntity toEntity() {
    return GlobalMoodStatsEntity(
      emotion: emotion,
      count: count,
      percentage: percentage,
      avgIntensity: avgIntensity,
      emoji: emoji,
      color: color,
    );
  }

  GlobalMoodStatsModel copyWith({
    String? emotion,
    int? count,
    double? percentage,
    double? avgIntensity,
    String? emoji,
    String? color,
  }) {
    return GlobalMoodStatsModel(
      emotion: emotion ?? this.emotion,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
      avgIntensity: avgIntensity ?? this.avgIntensity,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
    emotion,
    count,
    percentage,
    avgIntensity,
    emoji,
    color,
  ];
}
