import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_data.dart';

class FriendEntity extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final bool isOnline;
  final DateTime? lastActiveAt;
  final DateTime friendshipDate;
  final String status; // 'pending', 'accepted', 'blocked'
  final int mutualFriends;
  final FriendMoodData? recentMood; // Real mood data from backend

  const FriendEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    this.location,
    required this.isOnline,
    this.lastActiveAt,
    required this.friendshipDate,
    required this.status,
    this.mutualFriends = 0,
    this.recentMood,
  });

  factory FriendEntity.fromJson(Map<String, dynamic> json) {
    return FriendEntity(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['username']?.toString() ?? '',
      selectedAvatar: json['selectedAvatar']?.toString() ?? json['avatar']?.toString() ?? 'panda',
      location: _parseLocation(json['location']),
      isOnline: json['isOnline'] ?? false,
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt'])
          : null,
      friendshipDate: json['friendshipDate'] != null 
          ? DateTime.parse(json['friendshipDate'])
          : DateTime.now(),
      status: json['status']?.toString() ?? 'accepted',
      mutualFriends: _safeIntCast(json['mutualFriends']),
      recentMood: json['recentMood'] != null 
          ? FriendMoodData.fromJson(json['recentMood'])
          : null,
    );
  }

  // Helper methods for safe parsing
  static String? _parseLocation(dynamic location) {
    if (location == null) return null;
    if (location is String) return location;
    if (location is Map<String, dynamic>) {
      return location['name']?.toString() ?? 
             location['city']?.toString() ?? 
             location['country']?.toString();
    }
    return null;
  }

  static int _safeIntCast(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
      'location': location,
      'isOnline': isOnline,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'friendshipDate': friendshipDate.toIso8601String(),
      'status': status,
      'mutualFriends': mutualFriends,
      'recentMood': recentMood?.toJson(),
    };
  }

  FriendEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? location,
    bool? isOnline,
    DateTime? lastActiveAt,
    DateTime? friendshipDate,
    String? status,
    int? mutualFriends,
    FriendMoodData? recentMood,
  }) {
    return FriendEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      friendshipDate: friendshipDate ?? this.friendshipDate,
      status: status ?? this.status,
      mutualFriends: mutualFriends ?? this.mutualFriends,
      recentMood: recentMood ?? this.recentMood,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        selectedAvatar,
        location,
        isOnline,
        lastActiveAt,
        friendshipDate,
        status,
        mutualFriends,
        recentMood,
      ];
}

class FriendRequestEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final DateTime createdAt;
  final String type; // 'sent', 'received'
  final int mutualFriends;

  const FriendRequestEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    this.location,
    required this.createdAt,
    required this.type,
    this.mutualFriends = 0,
  });

  FriendRequestEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? location,
    DateTime? createdAt,
    String? type,
    int? mutualFriends,
  }) {
    return FriendRequestEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      mutualFriends: mutualFriends ?? this.mutualFriends,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        username,
        displayName,
        selectedAvatar,
        location,
        createdAt,
        type,
        mutualFriends,
      ];
}

class FriendSuggestionEntity extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final int mutualFriends;
  final List<String> commonInterests;
  final bool isRequested;

  const FriendSuggestionEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    this.location,
    required this.mutualFriends,
    required this.commonInterests,
    required this.isRequested,
  });

  factory FriendSuggestionEntity.fromJson(Map<String, dynamic> json) {
    return FriendSuggestionEntity(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['username']?.toString() ?? '',
      selectedAvatar: json['selectedAvatar']?.toString() ?? 'panda',
      location: _parseLocation(json['location']),
      mutualFriends: _safeIntCast(json['mutualFriends']),
      commonInterests: _safeListCast(json['commonInterests']),
      isRequested: json['isRequested'] ?? false,
    );
  }

  // Helper methods for safe parsing
  static String? _parseLocation(dynamic location) {
    if (location == null) return null;
    if (location is String) return location;
    if (location is Map<String, dynamic>) {
      return location['name']?.toString() ?? 
             location['city']?.toString() ?? 
             location['country']?.toString();
    }
    return null;
  }

  static int _safeIntCast(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static List<String> _safeListCast(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
      'location': location,
      'mutualFriends': mutualFriends,
      'commonInterests': commonInterests,
      'isRequested': isRequested,
    };
  }

  FriendSuggestionEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? location,
    int? mutualFriends,
    List<String>? commonInterests,
    bool? isRequested,
  }) {
    return FriendSuggestionEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      location: location ?? this.location,
      mutualFriends: mutualFriends ?? this.mutualFriends,
      commonInterests: commonInterests ?? this.commonInterests,
      isRequested: isRequested ?? this.isRequested,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        displayName,
        selectedAvatar,
        location,
        mutualFriends,
        commonInterests,
        isRequested,
      ];
} 