import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';

class UserProfileModel {
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
  final DateTime? lastActive;
  final bool isPrivate;

  const UserProfileModel({
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
    this.lastActive,
    this.isPrivate = false,
  });

  // Factory constructor from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      totalEntries: json['totalEntries'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      favoriteEmotion: json['favoriteEmotion']?.toString(),
      totalFriends: json['totalFriends'] ?? 0,
      helpedFriends: json['helpedFriends'] ?? 0,
      level: json['level']?.toString() ?? 'Explorer',
      badgesEarned: json['badgesEarned'] ?? 0,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'joinDate': joinDate.toIso8601String(),
      'totalEntries': totalEntries,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'favoriteEmotion': favoriteEmotion,
      'totalFriends': totalFriends,
      'helpedFriends': helpedFriends,
      'level': level,
      'badgesEarned': badgesEarned,
      'lastActive': lastActive?.toIso8601String(),
      'isPrivate': isPrivate,
    };
  }

  // Convert to Entity
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      name: name,
      username: username,
      email: email,
      avatar: avatar,
      joinDate: joinDate,
      totalEntries: totalEntries,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      favoriteEmotion: favoriteEmotion,
      totalFriends: totalFriends,
      helpedFriends: helpedFriends,
      level: level,
      badgesEarned: badgesEarned,
      lastActive: lastActive,
      isPrivate: isPrivate,
    );
  }

  // Create from Entity
  factory UserProfileModel.fromEntity(ProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      email: entity.email,
      avatar: entity.avatar,
      joinDate: entity.joinDate,
      totalEntries: entity.totalEntries,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      favoriteEmotion: entity.favoriteEmotion,
      totalFriends: entity.totalFriends,
      helpedFriends: entity.helpedFriends,
      level: entity.level,
      badgesEarned: entity.badgesEarned,
      lastActive: entity.lastActive,
      isPrivate: entity.isPrivate,
    );
  }

  UserProfileModel copyWith({
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
    DateTime? lastActive,
    bool? isPrivate,
  }) {
    return UserProfileModel(
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
      lastActive: lastActive ?? this.lastActive,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
