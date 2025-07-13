// lib/features/profile/domain/entity/profile_entity.dart - COMPLETE VERSION
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
  
  // ✅ CRITICAL: Added missing properties that were causing errors
  final String pronouns;        // This was missing and causing NoSuchMethodError
  final String ageGroup;        // This was missing and causing NoSuchMethodError  
  final String themeColor;      // This was missing and causing NoSuchMethodError
  
  // ✅ Additional properties from your API structure
  final String? displayName;    // From nested profile object
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
    // ✅ CRITICAL: Default values for missing properties
    this.pronouns = '',
    this.ageGroup = '',
    this.themeColor = '',
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

  // ✅ ENHANCED: Factory constructor to handle your complete API response
  factory ProfileEntity.fromBackendResponse(Map<String, dynamic> data) {
    // Handle nested user object if present
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    final stats = userData['stats'] as Map<String, dynamic>? ?? {};
    final profileData = userData['profile'] as Map<String, dynamic>? ?? {};
    
    // Helper function to safely parse dates
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        return null;
      } catch (e) {
        print('Error parsing date: $dateValue - $e');
        return null;
      }
    }

    // Helper function to get effective avatar
    String? getEffectiveAvatar() {
      return userData['selectedAvatar'] as String? ?? 
             userData['avatar'] as String? ??
             profileData['avatar'] as String?;
    }

    // Helper function to get effective display name
    String getEffectiveName() {
      return profileData['displayName'] as String? ?? 
             userData['displayName'] as String? ??
             userData['name'] as String? ??
             userData['username'] as String? ??
             'Unknown User';
    }

    return ProfileEntity(
      id: userData['id'] as String? ?? '',
      name: getEffectiveName(),
      displayName: profileData['displayName'] as String?,
      username: userData['username'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      bio: profileData['bio'] as String? ?? userData['bio'] as String?,
      avatar: getEffectiveAvatar(),
      selectedAvatar: userData['selectedAvatar'] as String?,
      
      // ✅ CRITICAL: Handle the missing properties from API
      pronouns: userData['pronouns'] as String? ?? 'They / Them',
      ageGroup: userData['ageGroup'] as String? ?? '18-24',
      themeColor: profileData['themeColor'] as String? ?? 
                  userData['themeColor'] as String? ?? 
                  '#8B5CF6',
      
      // Date handling with fallbacks
      joinDate: parseDate(userData['joinDate']) ?? 
                parseDate(userData['createdAt']) ?? 
                DateTime.now(),
      createdAt: parseDate(userData['createdAt']),
      updatedAt: parseDate(userData['updatedAt']),
      lastActive: parseDate(userData['lastActive']),
      
      // Stats with safe defaults
      totalEntries: stats['totalEntries'] as int? ?? 0,
      currentStreak: stats['currentStreak'] as int? ?? 0,
      longestStreak: stats['longestStreak'] as int? ?? 0,
      favoriteEmotion: stats['favoriteEmotion'] as String? ?? userData['favoriteEmotion'] as String?,
      totalFriends: stats['totalFriends'] as int? ?? 0,
      helpedFriends: stats['helpedFriends'] as int? ?? 0,
      level: stats['level'] as String? ?? 'New Explorer',
      badgesEarned: stats['badgesEarned'] as int? ?? 0,
      
      // Boolean flags with safe defaults
      isPrivate: profileData['isPrivate'] as bool? ?? 
                userData['isPrivate'] as bool? ?? 
                false,
      isOnboardingCompleted: userData['isOnboardingCompleted'] as bool?,
      isActive: userData['isActive'] as bool?,
      isOnline: userData['isOnline'] as bool?,
      
      // Complex objects
      location: userData['location'] as Map<String, dynamic>?,
      preferences: userData['preferences'] as Map<String, dynamic>?,
      daysSinceJoined: userData['daysSinceJoined'] as int?,
    );
  }

  // ✅ ENHANCED: Copy method with all properties
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
    String? pronouns,        // ✅ Added missing properties
    String? ageGroup,        // ✅ Added missing properties
    String? themeColor,      // ✅ Added missing properties
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
      pronouns: pronouns ?? this.pronouns,           // ✅ Added
      ageGroup: ageGroup ?? this.ageGroup,           // ✅ Added
      themeColor: themeColor ?? this.themeColor,     // ✅ Added
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

  // ✅ ENHANCED: Convert to map for API calls (matching your backend structure)
  Map<String, dynamic> toBackendMap() {
    return {
      'displayName': displayName ?? name,
      'bio': bio ?? '',
      'pronouns': pronouns,
      'ageGroup': ageGroup,
      'selectedAvatar': selectedAvatar ?? avatar,
      'themeColor': themeColor,
      'isPrivate': isPrivate,
      'favoriteEmotion': favoriteEmotion,
    };
  }

  // ✅ NEW: Convert to full map for complete serialization
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

  // ✅ ENHANCED: Equatable props with all properties
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
        pronouns,        // ✅ Added missing properties
        ageGroup,        // ✅ Added missing properties
        themeColor,      // ✅ Added missing properties
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
    return 'ProfileEntity(id: $id, name: $name, username: $username, level: $level, pronouns: $pronouns, ageGroup: $ageGroup, themeColor: $themeColor)';
  }

  // ✅ HELPER METHODS for common operations
  
  /// Get the effective display name (displayName or fallback to name)
  String get effectiveDisplayName {
    print('[DEBUG] ProfileEntity.effectiveDisplayName - displayName: \'$displayName\', name: \'$name\'');
    final result = displayName?.isNotEmpty == true ? displayName! : name;
    print('[DEBUG] ProfileEntity.effectiveDisplayName - result: \'$result\'');
    return result;
  }

  /// Get the effective avatar (selectedAvatar or fallback to avatar)
  String get effectiveAvatar => selectedAvatar?.isNotEmpty == true ? selectedAvatar! : (avatar ?? 'fox');

  /// Check if profile is complete
  bool get isComplete {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           username.isNotEmpty &&
           effectiveAvatar.isNotEmpty &&
           pronouns.isNotEmpty &&
           ageGroup.isNotEmpty;
  }

  /// Get profile completion percentage
  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 8; // name, email, username, avatar, bio, pronouns, ageGroup, themeColor

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

  /// Get theme color as Flutter Color object
  Color get themeColorAsColor {
    try {
      return Color(int.parse(themeColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF8B5CF6); // Default purple
    }
  }

  /// Check if user is actually private (considering preferences)
  bool get isProfilePrivate {
    // Check preferences for more granular privacy settings
    if (preferences != null) {
      final moodPrivacy = preferences!['moodPrivacy'];
      if (moodPrivacy == 'private') return true;
    }
    return isPrivate;
  }

  /// Get user's tenure in days
  int get tenureInDays {
    return daysSinceJoined ?? DateTime.now().difference(joinDate).inDays;
  }

  /// Check if user is a new member (less than 7 days)
  bool get isNewMember => tenureInDays < 7;

  /// Check if user is active (based on lastActive)
  bool get isRecentlyActive {
    if (lastActive == null) return false;
    final daysSinceActive = DateTime.now().difference(lastActive!).inDays;
    return daysSinceActive <= 7;
  }

  /// Get user level based on total entries
  String get calculatedLevel {
    if (totalEntries >= 1000) return 'Emotion Master';
    if (totalEntries >= 500) return 'Mindful Guide';
    if (totalEntries >= 200) return 'Feeling Expert';
    if (totalEntries >= 100) return 'Emotion Tracker';
    if (totalEntries >= 50) return 'Mood Explorer';
    if (totalEntries >= 10) return 'Feeling Finder';
    return 'New Explorer';
  }

  /// Get achievement progress percentage
  double get achievementProgress {
    if (badgesEarned == 0) return 0.0;
    // Assuming there are around 50 total badges available
    const totalBadges = 50;
    return (badgesEarned / totalBadges * 100).clamp(0.0, 100.0);
  }
}