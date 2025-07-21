import 'package:equatable/equatable.dart';

import '../../domain/entity/friend_entity.dart';

class FriendModel extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final bool isOnline;
  final DateTime? lastActiveAt;
  final DateTime friendshipDate;
  final String status;
  final int mutualFriends;

  const FriendModel({
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
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    try {
      return FriendModel(
        id: _safeString(json['id']),
        username: _safeString(json['username']),
        displayName: _safeString(json['displayName'] ?? json['username']),
        selectedAvatar: _safeString(json['selectedAvatar']),
        location: _parseLocation(json['location']),
        isOnline: _safeBool(json['isOnline']),
        lastActiveAt: _parseDateTime(json['lastActiveAt']),
        friendshipDate: _parseDateTime(json['friendshipDate']) ?? DateTime.now(),
        status: _safeString(json['status']),
        mutualFriends: _safeInt(json['mutualFriends']),
      );
    } catch (e) {
      return FriendModel.empty();
    }
  }

  factory FriendModel.empty() {
    return FriendModel(
      id: '',
      username: '',
      displayName: '',
      selectedAvatar: 'panda',
      isOnline: false,
      friendshipDate: DateTime.now(),
      status: 'pending',
    );
  }

  // Safe type conversion methods
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

  static String? _parseLocation(dynamic location) {
    try {
      if (location == null) return null;
      if (location is String) return location;
      if (location is Map<String, dynamic>) {
        final locationObj = location as Map<String, dynamic>;
        return locationObj['name'] as String? ?? 
               locationObj['city'] as String? ?? 
               locationObj['country'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  factory FriendModel.fromEntity(FriendEntity entity) {
    return FriendModel(
      id: entity.id,
      username: entity.username,
      displayName: entity.displayName,
      selectedAvatar: entity.selectedAvatar,
      location: entity.location,
      isOnline: entity.isOnline,
      lastActiveAt: entity.lastActiveAt,
      friendshipDate: entity.friendshipDate,
      status: entity.status,
      mutualFriends: entity.mutualFriends,
    );
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
    };
  }

  FriendEntity toEntity() {
    return FriendEntity(
      id: id,
      username: username,
      displayName: displayName,
      selectedAvatar: selectedAvatar,
      location: location,
      isOnline: isOnline,
      lastActiveAt: lastActiveAt,
      friendshipDate: friendshipDate,
      status: status,
      mutualFriends: mutualFriends,
    );
  }

  FriendModel copyWith({
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
  }) {
    return FriendModel(
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
      ];
}

class FriendRequestModel extends Equatable {
  final String id;
  final String userId;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final DateTime createdAt;
  final String type;
  final int mutualFriends;

  const FriendRequestModel({
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

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    try {
      // Extract user data with better null safety
      final userData = json['user'] as Map<String, dynamic>?;
      
      // The backend returns user data nested under 'user' object
      // Try to get userId from user object first, then from top level, then use request ID as fallback
      String userId = FriendModel._safeString(userData?['id'] ?? json['userId']);
      
      // If userId is still empty, try using the request ID as a fallback
      if (userId.isEmpty) {
        userId = FriendModel._safeString(json['id']);
        print('. FriendRequestModel.fromJson - Using request ID as userId fallback: $userId');
      }
      
      final username = FriendModel._safeString(userData?['username'] ?? json['username']);
      final displayName = FriendModel._safeString(
        userData?['displayName'] ?? json['displayName'] ?? username,
      );
      
      // Handle location - can be string or object
      final locationString = FriendModel._parseLocation(userData?['location']) ?? 
                            FriendModel._parseLocation(json['location']);
      
      // Enhanced debug logging
      print('. FriendRequestModel.fromJson - Raw JSON: $json');
      print('. FriendRequestModel.fromJson - userData: $userData');
      print('. FriendRequestModel.fromJson - userData?[id]: ${userData?['id']}');
      print('. FriendRequestModel.fromJson - json[userId]: ${json['userId']}');
      print('. FriendRequestModel.fromJson - Final userId: $userId');
      print('. FriendRequestModel.fromJson - Final username: $username');
      print('. FriendRequestModel.fromJson - Final displayName: $displayName');
      print('. FriendRequestModel.fromJson - Final location: $locationString');
      
      // Additional validation
      if (userId.isEmpty) {
        print('. FriendRequestModel.fromJson - userId is empty after parsing');
        print('. FriendRequestModel.fromJson - This will cause issues with cancel requests');
      }
      
      // Final validation - ensure we have at least an ID and userId
      if (FriendModel._safeString(json['id']).isEmpty) {
        print('. FriendRequestModel.fromJson - Request ID is empty, cannot create valid model');
        return FriendRequestModel.empty();
      }
      
      return FriendRequestModel(
        id: FriendModel._safeString(json['id']),
        userId: userId,
        username: username,
        displayName: displayName,
        selectedAvatar: FriendModel._safeString(userData?['selectedAvatar'] ?? json['selectedAvatar']),
        location: locationString,
        createdAt: FriendModel._parseDateTime(json['createdAt']) ?? DateTime.now(),
        type: FriendModel._safeString(json['type']),
        mutualFriends: FriendModel._safeInt(json['mutualFriends']),
      );
    } catch (e) {
      print('. FriendRequestModel.fromJson - Error: $e');
      print('. FriendRequestModel.fromJson - Stack trace: ${StackTrace.current}');
      return FriendRequestModel.empty();
    }
  }

  factory FriendRequestModel.empty() {
    return FriendRequestModel(
      id: '',
      userId: '',
      username: '',
      displayName: '',
      selectedAvatar: 'panda',
      createdAt: DateTime.now(),
      type: 'received',
    );
  }

  factory FriendRequestModel.fromEntity(FriendRequestEntity entity) {
    return FriendRequestModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      displayName: entity.displayName,
      selectedAvatar: entity.selectedAvatar,
      location: entity.location,
      createdAt: entity.createdAt,
      type: entity.type,
      mutualFriends: entity.mutualFriends,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'selectedAvatar': selectedAvatar,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
      'mutualFriends': mutualFriends,
    };
  }

  FriendRequestEntity toEntity() {
    return FriendRequestEntity(
      id: id,
      userId: userId,
      username: username,
      displayName: displayName,
      selectedAvatar: selectedAvatar,
      location: location,
      createdAt: createdAt,
      type: type,
      mutualFriends: mutualFriends,
    );
  }

  FriendRequestModel copyWith({
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
    return FriendRequestModel(
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

class FriendSuggestionModel extends Equatable {
  final String id;
  final String username;
  final String displayName;
  final String selectedAvatar;
  final String? location;
  final int mutualFriends;
  final List<String> commonInterests;
  final bool isRequested;

  const FriendSuggestionModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.selectedAvatar,
    this.location,
    required this.mutualFriends,
    required this.commonInterests,
    required this.isRequested,
  });

  factory FriendSuggestionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Extract location name if location is an object
      String? locationString;
      final locationField = json['location'];
      if (locationField is Map<String, dynamic>) {
        locationString = locationField['name'] as String? ??
                        locationField['city'] as String? ??
                        locationField['country'] as String? ??
                        'Unknown';
      } else if (locationField is String) {
        locationString = locationField;
      } else {
        locationString = 'Unknown';
      }
      return FriendSuggestionModel(
        id: FriendModel._safeString(json['id']),
        username: FriendModel._safeString(json['username']),
        displayName: FriendModel._safeString(json['displayName'] ?? json['username']),
        selectedAvatar: FriendModel._safeString(json['selectedAvatar']),
        location: locationString,
        mutualFriends: FriendModel._safeInt(json['mutualFriends']),
        commonInterests: _safeListCast(json['commonInterests']),
        isRequested: FriendModel._safeBool(json['isRequested'] ?? false),
      );
    } catch (e) {
      return FriendSuggestionModel.empty();
    }
  }

  // Helper method for safe list casting
  static List<String> _safeListCast(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

  factory FriendSuggestionModel.empty() {
    return const FriendSuggestionModel(
      id: '',
      username: '',
      displayName: '',
      selectedAvatar: 'panda',
      mutualFriends: 0,
      commonInterests: [],
      isRequested: false,
    );
  }

  factory FriendSuggestionModel.fromEntity(FriendSuggestionEntity entity) {
    return FriendSuggestionModel(
      id: entity.id,
      username: entity.username,
      displayName: entity.displayName,
      selectedAvatar: entity.selectedAvatar,
      location: entity.location,
      mutualFriends: entity.mutualFriends,
      commonInterests: entity.commonInterests,
      isRequested: entity.isRequested,
    );
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

  FriendSuggestionEntity toEntity() {
    return FriendSuggestionEntity(
      id: id,
      username: username,
      displayName: displayName,
      selectedAvatar: selectedAvatar,
      location: location,
      mutualFriends: mutualFriends,
      commonInterests: commonInterests,
      isRequested: isRequested,
    );
  }

  FriendSuggestionModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? selectedAvatar,
    String? location,
    int? mutualFriends,
    List<String>? commonInterests,
    bool? isRequested,
  }) {
    return FriendSuggestionModel(
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