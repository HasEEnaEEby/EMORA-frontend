import 'package:equatable/equatable.dart';

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
  });

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