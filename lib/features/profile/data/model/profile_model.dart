import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final String pronouns;
  final String ageGroup;
  final String themeColor;
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
    this.bio,
    this.pronouns = 'They / Them',
    this.ageGroup = '18-24',
    this.themeColor = '#8B5CF6',
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] UserProfileModel.fromJson input: $json');
    
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    final profileData = userData['profile'] as Map<String, dynamic>? ?? {};
    
    print('[DEBUG] userData keys: ${userData.keys.toList()}');
    print('[DEBUG] profileData keys: ${profileData.keys.toList()}');
    
    final username = userData['username']?.toString() ?? '';
    print('[DEBUG] Extracted username: "$username"');
    
    print('[DEBUG] profileData["displayName"]: \'${profileData['displayName']}\'');
    final computedName = profileData['displayName']?.toString() ?? 
          userData['name']?.toString() ?? 
username; 
    print('[DEBUG] Computed name for UserProfileModel: \'$computedName\'');

    return UserProfileModel(
      id: userData['id']?.toString() ?? '',
      name: computedName,
username: username, 
      email: userData['email']?.toString() ?? '',
      avatar: userData['selectedAvatar']?.toString() ?? 
              userData['avatar']?.toString(),
      bio: profileData['bio']?.toString() ?? userData['bio']?.toString(),
      pronouns: userData['pronouns']?.toString() ?? 'They / Them',
      ageGroup: userData['ageGroup']?.toString() ?? '18-24',
      themeColor: profileData['themeColor']?.toString() ?? 
                  userData['themeColor']?.toString() ?? 
                  '#8B5CF6',
      joinDate: userData['joinDate'] != null
          ? DateTime.parse(userData['joinDate'])
          : userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
      totalEntries: userData['totalEntries'] ?? 0,
      currentStreak: userData['currentStreak'] ?? 0,
      longestStreak: userData['longestStreak'] ?? 0,
      favoriteEmotion: userData['favoriteEmotion']?.toString(),
      totalFriends: userData['totalFriends'] ?? 0,
      helpedFriends: userData['helpedFriends'] ?? 0,
      level: userData['level']?.toString() ?? 'Explorer',
      badgesEarned: userData['badgesEarned'] ?? 0,
      lastActive: userData['lastActive'] != null
          ? DateTime.parse(userData['lastActive'])
          : null,
      isPrivate: profileData['isPrivate'] ?? userData['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'themeColor': themeColor,
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

  ProfileEntity toEntity() {
    print('[DEBUG] UserProfileModel.toEntity() - name: \'$name\', username: \'$username\'');
    return ProfileEntity(
      id: id,
      name: name,
displayName: name, 
      username: username,
      email: email,
      bio: bio,
      avatar: avatar,
      selectedAvatar: avatar,
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
      pronouns: pronouns,
      ageGroup: ageGroup,
      themeColor: themeColor,
    );
  }

  factory UserProfileModel.fromEntity(ProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      username: entity.username,
      email: entity.email,
      avatar: entity.avatar,
      bio: entity.bio,
      pronouns: entity.pronouns,
      ageGroup: entity.ageGroup,
      themeColor: entity.themeColor,
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
    String? bio,
    String? pronouns,
    String? ageGroup,
    String? themeColor,
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
      bio: bio ?? this.bio,
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      themeColor: themeColor ?? this.themeColor,
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
