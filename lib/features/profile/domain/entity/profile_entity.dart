import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? bio;
  final String? avatar;
  final String? selectedAvatar; 
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
  
  final String pronouns;
  final String ageGroup;
  final String themeColor;
  
  final String? displayName;
  final bool? isOnboardingCompleted;
  final bool? isActive;
  final bool? isOnline;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? preferences;
  final int? daysSinceJoined;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.bio,
    this.avatar,
    this.selectedAvatar,
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
    this.pronouns = 'They / Them',
    this.ageGroup = '18-24',
    this.themeColor = '#8B5CF6',
    this.displayName,
    this.isOnboardingCompleted,
    this.isActive,
    this.isOnline,
    this.location,
    this.preferences,
    this.daysSinceJoined,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileEntity.fromBackendResponse(Map<String, dynamic> data) {
    print('[DEBUG] ProfileEntity.fromBackendResponse - Input data: $data');
    
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    
    final userData = responseData;
    final stats = userData['stats'] as Map<String, dynamic>? ?? {};
    final profileData = userData['profile'] as Map<String, dynamic>? ?? {};
    final preferencesData = userData['preferences'] as Map<String, dynamic>? ?? {};
    
    print('[DEBUG] ProfileEntity.fromBackendResponse - responseData: $responseData');
    print('[DEBUG] ProfileEntity.fromBackendResponse - userData: $userData');
    print('[DEBUG] ProfileEntity.fromBackendResponse - stats: $stats');
    print('[DEBUG] ProfileEntity.fromBackendResponse - profileData: $profileData');
    
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        return null;
      } catch (e) {
        print('[DEBUG] Error parsing date: $dateValue - $e');
        return null;
      }
    }

    String getEffectiveAvatar() {
      final selected = userData['selectedAvatar'] as String?;
      final fallback = userData['avatar'] as String?;
      final result = selected ?? fallback ?? 'fox';
      print('[DEBUG] Avatar selection - selectedAvatar: $selected, fallback: $fallback, result: $result');
      return result;
    }

    String getEffectiveName() {
      final profileDisplayName = profileData['displayName'] as String?;
      final userDisplayName = userData['displayName'] as String?;
      final userName = userData['name'] as String?;
      final username = userData['username'] as String?;
      
      final result = profileDisplayName ?? userDisplayName ?? userName ?? username ?? 'Unknown User';
      
      print('[DEBUG] Name selection:');
      print('  - profileDisplayName: $profileDisplayName');
      print('  - userDisplayName: $userDisplayName');
      print('  - userName: $userName');
      print('  - username: $username');
      print('  - result: $result');
      
      return result;
    }

    String? getEffectiveBio() {
      final profileBio = profileData['bio'] as String?;
      final userBio = userData['bio'] as String?;
      final result = profileBio ?? userBio;
      
      if (result != null && result.trim().isEmpty) {
        return null;
      }
      
      print('[DEBUG] Bio selection - profileBio: "$profileBio", userBio: "$userBio", result: "$result"');
      return result;
    }

    String getEffectiveEmail() {
      final email = userData['email'] as String?;
      final result = email ?? 'No email available';
      print('[DEBUG] Email selection - email: $email, result: $result');
      return result;
    }

    String getEffectiveThemeColor() {
      final profileTheme = profileData['themeColor'] as String?;
      final userTheme = userData['themeColor'] as String?;
      final result = profileTheme ?? userTheme ?? '#8B5CF6';
      print('[DEBUG] Theme color selection - profileTheme: $profileTheme, userTheme: $userTheme, result: $result');
      return result;
    }

    final totalEntries = stats['totalEntries'] as int? ?? 0;
    final currentStreak = stats['currentStreak'] as int? ?? 0;
    final longestStreak = stats['longestStreak'] as int? ?? 0;
    final favoriteEmotion = stats['favoriteEmotion'] as String?;
    final totalFriends = stats['totalFriends'] as int? ?? 0;
    final helpedFriends = stats['helpedFriends'] as int? ?? 0;
    final level = stats['level'] as String? ?? 'New Explorer';
    final badgesEarned = stats['badgesEarned'] as int? ?? 0;

    print('[DEBUG] Stats extraction:');
    print('  - totalEntries: $totalEntries');
    print('  - currentStreak: $currentStreak');
    print('  - longestStreak: $longestStreak');
    print('  - favoriteEmotion: $favoriteEmotion');
    print('  - totalFriends: $totalFriends');
    print('  - helpedFriends: $helpedFriends');
    print('  - level: $level');
    print('  - badgesEarned: $badgesEarned');

    final entity = ProfileEntity(
      id: userData['id'] as String? ?? '',
      name: getEffectiveName(),
      displayName: profileData['displayName'] as String?,
      username: userData['username'] as String? ?? '',
      email: getEffectiveEmail(),
      bio: getEffectiveBio(),
      avatar: getEffectiveAvatar(),
      selectedAvatar: userData['selectedAvatar'] as String?,
      
      pronouns: userData['pronouns'] as String? ?? 'They / Them',
      ageGroup: userData['ageGroup'] as String? ?? '18-24',
      themeColor: getEffectiveThemeColor(),
      
      joinDate: parseDate(userData['joinDate']) ?? 
                parseDate(userData['createdAt']) ?? 
                DateTime.now(),
      createdAt: parseDate(userData['createdAt']),
      updatedAt: parseDate(userData['updatedAt']),
      lastActive: parseDate(userData['lastActive']),
      
      totalEntries: totalEntries,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      favoriteEmotion: favoriteEmotion,
      totalFriends: totalFriends,
      helpedFriends: helpedFriends,
      level: level,
      badgesEarned: badgesEarned,
      
      isPrivate: preferencesData['moodPrivacy'] == 'private' || 
                profileData['isPrivate'] == true ||
                userData['isPrivate'] == true,
      isOnboardingCompleted: userData['isOnboardingCompleted'] as bool?,
      isActive: userData['isActive'] as bool?,
      isOnline: userData['isOnline'] as bool?,
      
      location: userData['location'] as Map<String, dynamic>?,
      preferences: userData['preferences'] as Map<String, dynamic>?,
      daysSinceJoined: userData['daysSinceJoined'] as int?,
    );

    print('[DEBUG] ProfileEntity.fromBackendResponse - Final entity: $entity');
    return entity;
  }

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? displayName,
    String? username,
    String? email,
    String? bio,
    String? avatar,
    String? selectedAvatar,
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
    String? pronouns,
    String? ageGroup,
    String? themeColor,
    bool? isOnboardingCompleted,
    bool? isActive,
    bool? isOnline,
    Map<String, dynamic>? location,
    Map<String, dynamic>? preferences,
    int? daysSinceJoined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
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
      pronouns: pronouns ?? this.pronouns,
      ageGroup: ageGroup ?? this.ageGroup,
      themeColor: themeColor ?? this.themeColor,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      preferences: preferences ?? this.preferences,
      daysSinceJoined: daysSinceJoined ?? this.daysSinceJoined,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toBackendMap() {
    return {
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar ?? avatar,
      'profile': {
        'displayName': displayName ?? name,
        'bio': bio ?? '',
        'themeColor': themeColor,
      },
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'username': username,
      'email': email,
      'bio': bio,
      'avatar': avatar,
      'selectedAvatar': selectedAvatar,
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
      'isOnboardingCompleted': isOnboardingCompleted,
      'isActive': isActive,
      'isOnline': isOnline,
      'location': location,
      'preferences': preferences,
      'daysSinceJoined': daysSinceJoined,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        username,
        email,
        bio,
        avatar,
        selectedAvatar,
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
        pronouns,
        ageGroup,
        themeColor,
        isOnboardingCompleted,
        isActive,
        isOnline,
        location,
        preferences,
        daysSinceJoined,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ProfileEntity(id: $id, name: $name, displayName: $displayName, username: $username, level: $level, pronouns: $pronouns, ageGroup: $ageGroup, themeColor: $themeColor)';
  }

  
  String get effectiveDisplayName {
    print('[DEBUG] ProfileEntity.effectiveDisplayName - displayName: \'$displayName\', name: \'$name\'');
    final result = displayName?.isNotEmpty == true ? displayName! : name;
    print('[DEBUG] ProfileEntity.effectiveDisplayName - result: \'$result\'');
    return result;
  }

  String get effectiveAvatar {
    final result = selectedAvatar?.isNotEmpty == true ? selectedAvatar! : (avatar ?? 'fox');
    print('[DEBUG] ProfileEntity.effectiveAvatar - selectedAvatar: \'$selectedAvatar\', avatar: \'$avatar\', result: \'$result\'');
    return result;
  }

  bool get isComplete {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           username.isNotEmpty &&
           effectiveAvatar.isNotEmpty &&
           pronouns.isNotEmpty &&
           ageGroup.isNotEmpty;
  }

  double get completionPercentage {
    int completedFields = 0;
int totalFields = 8; 

    if (name.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (username.isNotEmpty) completedFields++;
    if (effectiveAvatar.isNotEmpty) completedFields++;
    if (bio?.isNotEmpty == true) completedFields++;
    if (pronouns.isNotEmpty) completedFields++;
    if (ageGroup.isNotEmpty) completedFields++;
    if (themeColor.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  Color get themeColorAsColor {
    try {
      return Color(int.parse(themeColor.replaceAll('#', '0xFF')));
    } catch (e) {
return const Color(0xFF8B5CF6); 
    }
  }

  bool get isProfilePrivate {
    if (preferences != null) {
      final moodPrivacy = preferences!['moodPrivacy'];
      if (moodPrivacy == 'private') return true;
    }
    return isPrivate;
  }

  int get tenureInDays {
    return daysSinceJoined ?? DateTime.now().difference(joinDate).inDays;
  }

  bool get isNewMember => tenureInDays < 7;

  bool get isRecentlyActive {
    if (lastActive == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActive!).inDays;
    return daysSinceActive <= 7;
  }

  String get calculatedLevel {
    if (totalEntries >= 1000) return 'Emotion Master';
    if (totalEntries >= 500) return 'Mindful Guide';
    if (totalEntries >= 200) return 'Feeling Expert';
    if (totalEntries >= 100) return 'Emotion Tracker';
    if (totalEntries >= 50) return 'Mood Explorer';
    if (totalEntries >= 10) return 'Feeling Finder';
    return 'New Explorer';
  }

  double get achievementProgress {
    if (badgesEarned == 0) return 0.0;
    const totalBadges = 50;
    return (badgesEarned / totalBadges * 100).clamp(0.0, 100.0);
  }
}