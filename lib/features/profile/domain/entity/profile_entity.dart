// ============================================================================
// 4. COMPLETE PROFILE ENTITIES - lib/features/profile/domain/entity/profile_entity.dart
// ============================================================================

import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? bio;
  final String? avatar;
  final DateTime joinDate;
  final int totalEntries;
  final int currentStreak;
  final int longestStreak;
  final String? favoriteEmotion;
  final int totalFriends;
  final int helpedFriends;
  final String level;
  final int badgesEarned;
  final DateTime? lastActive;
  final bool isPrivate;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.bio,
    this.avatar,
    required this.joinDate,
    this.totalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.favoriteEmotion,
    this.totalFriends = 0,
    this.helpedFriends = 0,
    this.level = 'New Explorer',
    this.badgesEarned = 0,
    this.lastActive,
    this.isPrivate = false,
  });

  // Factory constructor to create ProfileEntity from backend API response
  factory ProfileEntity.fromBackendResponse(Map<String, dynamic> data) {
    final stats = data['stats'] as Map<String, dynamic>? ?? {};
    
    return ProfileEntity(
      id: data['id'] as String,
      name: data['profile']?['displayName'] as String? ?? data['username'] as String,
      username: data['username'] as String,
      email: data['email'] as String? ?? '',
      bio: data['profile']?['bio'] as String?,
      avatar: data['selectedAvatar'] as String?,
      joinDate: DateTime.parse(data['joinDate'] as String),
      totalEntries: stats['totalEntries'] as int? ?? 0,
      currentStreak: stats['currentStreak'] as int? ?? 0,
      longestStreak: stats['longestStreak'] as int? ?? 0,
      favoriteEmotion: stats['favoriteEmotion'] as String?,
      totalFriends: stats['totalFriends'] as int? ?? 0,
      helpedFriends: stats['helpedFriends'] as int? ?? 0,
      level: stats['level'] as String? ?? 'New Explorer',
      badgesEarned: stats['badgesEarned'] as int? ?? 0,
      lastActive: data['lastActive'] != null 
          ? DateTime.parse(data['lastActive'] as String) 
          : null,
      isPrivate: data['profile']?['isPrivate'] as bool? ?? false,
    );
  }

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatar,
    DateTime? joinDate,
    int? totalEntries,
    int? currentStreak,
    int? longestStreak,
    String? favoriteEmotion,
    int? totalFriends,
    int? helpedFriends,
    String? level,
    int? badgesEarned,
    DateTime? lastActive,
    bool? isPrivate,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      joinDate: joinDate ?? this.joinDate,
      totalEntries: totalEntries ?? this.totalEntries,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      favoriteEmotion: favoriteEmotion ?? this.favoriteEmotion,
      totalFriends: totalFriends ?? this.totalFriends,
      helpedFriends: helpedFriends ?? this.helpedFriends,
      level: level ?? this.level,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      lastActive: lastActive ?? this.lastActive,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  // Convert to map for API calls
  Map<String, dynamic> toBackendMap() {
    return {
      'displayName': name,
      'bio': '',
      'pronouns': null,
      'ageGroup': null,
      'selectedAvatar': avatar,
      'themeColor': '#6366f1',
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        username,
        email,
        bio,
        avatar,
        joinDate,
        totalEntries,
        currentStreak,
        longestStreak,
        favoriteEmotion,
        totalFriends,
        helpedFriends,
        level,
        badgesEarned,
        lastActive,
        isPrivate,
      ];

  @override
  String toString() {
    return 'ProfileEntity(id: $id, name: $name, username: $username, level: $level)';
  }
}
