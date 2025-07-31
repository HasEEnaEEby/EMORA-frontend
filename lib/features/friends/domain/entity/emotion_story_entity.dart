
import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';

class EmotionStoryEntity {
  final String id;
  final String title;
  final String description;
  final FriendEntity creator;
  final List<StoryParticipantEntity> participants;
  final String privacy;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> tags;
  final String? coverImage;
  final StorySettingsEntity settings;
  final StoryAnalyticsEntity analytics;
  final DateTime createdAt;

  EmotionStoryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.participants,
    required this.privacy,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.tags,
    this.coverImage,
    required this.settings,
    required this.analytics,
    required this.createdAt,
  });

  factory EmotionStoryEntity.fromJson(Map<String, dynamic> json) {
    return EmotionStoryEntity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      creator: FriendEntity.fromJson(json['creator'] ?? {}),
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((participant) => StoryParticipantEntity.fromJson(participant))
              .toList()
          : [],
      privacy: json['privacy'] ?? 'friends',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      coverImage: json['coverImage'],
      settings: StorySettingsEntity.fromJson(json['settings'] ?? {}),
      analytics: StoryAnalyticsEntity.fromJson(json['analytics'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator': creator.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'privacy': privacy,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'tags': tags,
      'coverImage': coverImage,
      'settings': settings.toJson(),
      'analytics': analytics.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  int get participantCount => participants.where((p) => p.status == 'accepted').length;
}

class StoryParticipantEntity {
  final FriendEntity user;
final String status; 
  final DateTime? joinedAt;

  StoryParticipantEntity({
    required this.user,
    required this.status,
    this.joinedAt,
  });

  factory StoryParticipantEntity.fromJson(Map<String, dynamic> json) {
    return StoryParticipantEntity(
      user: FriendEntity.fromJson(json['user'] ?? {}),
      status: json['status'] ?? 'invited',
      joinedAt: json['joinedAt'] != null 
          ? DateTime.parse(json['joinedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'status': status,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }
}

class StorySettingsEntity {
  final bool allowAnonymousContributions;
  final bool requireApproval;
  final int maxParticipants;

  StorySettingsEntity({
    required this.allowAnonymousContributions,
    required this.requireApproval,
    required this.maxParticipants,
  });

  factory StorySettingsEntity.fromJson(Map<String, dynamic> json) {
    return StorySettingsEntity(
      allowAnonymousContributions: json['allowAnonymousContributions'] ?? false,
      requireApproval: json['requireApproval'] ?? false,
      maxParticipants: json['maxParticipants'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowAnonymousContributions': allowAnonymousContributions,
      'requireApproval': requireApproval,
      'maxParticipants': maxParticipants,
    };
  }
}

class StoryAnalyticsEntity {
  final int totalContributions;
  final double averageMood;
  final String? mostCommonEmotion;
  final DateTime? lastActivity;

  StoryAnalyticsEntity({
    required this.totalContributions,
    required this.averageMood,
    this.mostCommonEmotion,
    this.lastActivity,
  });

  factory StoryAnalyticsEntity.fromJson(Map<String, dynamic> json) {
    return StoryAnalyticsEntity(
      totalContributions: json['totalContributions'] ?? 0,
      averageMood: (json['averageMood'] ?? 0.0).toDouble(),
      mostCommonEmotion: json['mostCommonEmotion'],
      lastActivity: json['lastActivity'] != null 
          ? DateTime.parse(json['lastActivity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalContributions': totalContributions,
      'averageMood': averageMood,
      'mostCommonEmotion': mostCommonEmotion,
      'lastActivity': lastActivity?.toIso8601String(),
    };
  }
}

class StoryContributionEntity {
  final String id;
  final String storyId;
  final FriendEntity contributor;
  final String emotion;
  final int intensity;
  final String? message;
  final bool isAnonymous;
  final Map<String, dynamic>? context;
  final List<String> tags;
  final Map<String, dynamic>? media;
  final List<ContributionReactionEntity> reactions;
  final bool isApproved;
  final DateTime createdAt;

  StoryContributionEntity({
    required this.id,
    required this.storyId,
    required this.contributor,
    required this.emotion,
    required this.intensity,
    this.message,
    required this.isAnonymous,
    this.context,
    required this.tags,
    this.media,
    required this.reactions,
    required this.isApproved,
    required this.createdAt,
  });

  factory StoryContributionEntity.fromJson(Map<String, dynamic> json) {
    return StoryContributionEntity(
      id: json['id'] ?? '',
      storyId: json['storyId'] ?? '',
      contributor: FriendEntity.fromJson(json['contributor'] ?? {}),
      emotion: json['emotion'] ?? '',
      intensity: json['intensity'] ?? 3,
      message: json['message'],
      isAnonymous: json['isAnonymous'] ?? false,
      context: json['context'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      media: json['media'],
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
              .map((reaction) => ContributionReactionEntity.fromJson(reaction))
              .toList()
          : [],
      isApproved: json['isApproved'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storyId': storyId,
      'contributor': contributor.toJson(),
      'emotion': emotion,
      'intensity': intensity,
      'message': message,
      'isAnonymous': isAnonymous,
      'context': context,
      'tags': tags,
      'media': media,
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ContributionReactionEntity {
  final String id;
  final String type;
  final String? message;
  final FriendEntity? fromUser;
  final DateTime timestamp;
  final bool isAnonymous;

  ContributionReactionEntity({
    required this.id,
    required this.type,
    this.message,
    this.fromUser,
    required this.timestamp,
    required this.isAnonymous,
  });

  factory ContributionReactionEntity.fromJson(Map<String, dynamic> json) {
    return ContributionReactionEntity(
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