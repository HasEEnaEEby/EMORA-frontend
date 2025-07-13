import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
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
  final Map<String, dynamic>? preferences;
  final DateTime? lastActive;
  final bool isPrivate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.avatar,
    required this.joinDate,
    this.totalEntries = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.favoriteEmotion,
    this.totalFriends = 0,
    this.helpedFriends = 0,
    this.level = 'Explorer',
    this.badgesEarned = 0,
    this.preferences,
    this.lastActive,
    this.isPrivate = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
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
    Map<String, dynamic>? preferences,
    DateTime? lastActive,
    bool? isPrivate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
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
      preferences: preferences ?? this.preferences,
      lastActive: lastActive ?? this.lastActive,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
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
    preferences,
    lastActive,
    isPrivate,
  ];

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, username: $username, level: $level)';
  }
}
