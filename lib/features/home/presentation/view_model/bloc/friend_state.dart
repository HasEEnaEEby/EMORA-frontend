import 'package:equatable/equatable.dart';

import '../../../domain/entity/friend_entity.dart';

abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}


class FriendInitial extends FriendState {
  const FriendInitial();
}

class FriendLoading extends FriendState {
  const FriendLoading();
}


class FriendSearchLoading extends FriendState {
  const FriendSearchLoading();

  @override
  List<Object?> get props => [];
}

class FriendSearchLoaded extends FriendState {
  final List<FriendSuggestionEntity> searchResults;
  final int totalResults;
  final int currentPage;

  const FriendSearchLoaded({
    required this.searchResults,
    required this.totalResults,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [searchResults, totalResults, currentPage];

  FriendSearchLoaded copyWith({
    List<FriendSuggestionEntity>? searchResults,
    int? totalResults,
    int? currentPage,
  }) {
    return FriendSearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      totalResults: totalResults ?? this.totalResults,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class FriendSearchEmpty extends FriendState {
  final String query;

  const FriendSearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}


class FriendsLoaded extends FriendState {
  final List<FriendEntity> friends;
  final List<FriendSuggestionEntity> suggestions;
  final Map<String, List<FriendRequestEntity>> pendingRequests;
  final bool hasMoreFriends;
  final bool isRefreshing;

  const FriendsLoaded({
    required this.friends,
    required this.suggestions,
    required this.pendingRequests,
    this.hasMoreFriends = false,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
        friends,
        suggestions,
        pendingRequests,
        hasMoreFriends,
        isRefreshing,
      ];

  FriendsLoaded copyWith({
    List<FriendEntity>? friends,
    List<FriendSuggestionEntity>? suggestions,
    Map<String, List<FriendRequestEntity>>? pendingRequests,
    bool? hasMoreFriends,
    bool? isRefreshing,
  }) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      suggestions: suggestions ?? this.suggestions,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      hasMoreFriends: hasMoreFriends ?? this.hasMoreFriends,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  List<FriendRequestEntity> get sentRequests => pendingRequests['sent'] ?? [];
  List<FriendRequestEntity> get receivedRequests => pendingRequests['received'] ?? [];
  int get totalFriends => friends.length;
  int get totalSuggestions => suggestions.length;
  int get totalPendingRequests => sentRequests.length + receivedRequests.length;
}


class FriendRequestActionLoading extends FriendsLoaded {
final String actionType; 
  final String targetUserId;

  const FriendRequestActionLoading({
    required this.actionType,
    required this.targetUserId,
    required super.friends,
    required super.suggestions,
    required super.pendingRequests,
    super.hasMoreFriends,
    super.isRefreshing,
  });

  @override
  List<Object?> get props => [
        actionType,
        targetUserId,
        friends,
        suggestions,
        pendingRequests,
        hasMoreFriends,
        isRefreshing,
      ];
}

class FriendRequestActionSuccess extends FriendsLoaded {
  final String message;
  final String actionType;
  final String targetUserId;

  const FriendRequestActionSuccess({
    required this.message,
    required this.actionType,
    required this.targetUserId,
    required super.friends,
    required super.suggestions,
    required super.pendingRequests,
    super.hasMoreFriends,
    super.isRefreshing,
  });

  @override
  List<Object?> get props => [
    message,
    actionType,
    targetUserId,
    friends,
    suggestions,
    pendingRequests,
    hasMoreFriends,
    isRefreshing,
  ];
}


class FriendError extends FriendState {
  final String message;
  final String? errorType;
  final bool canRetry;

  const FriendError({
    required this.message,
    this.errorType,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorType, canRetry];

  FriendError copyWith({
    String? message,
    String? errorType,
    bool? canRetry,
  }) {
    return FriendError(
      message: message ?? this.message,
      errorType: errorType ?? this.errorType,
      canRetry: canRetry ?? this.canRetry,
    );
  }
}

class FriendSearchError extends FriendState {
  final String message;
  final String query;

  const FriendSearchError({
    required this.message,
    required this.query,
  });

  @override
  List<Object?> get props => [message, query];
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException({required this.message});
  @override
  String toString() => 'RateLimitException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException({required this.message});
  @override
  String toString() => 'TimeoutException: $message';
}

class DuplicateFriendRequestException implements Exception {
  final String message;
  DuplicateFriendRequestException({required this.message});
  @override
  String toString() => 'DuplicateFriendRequestException: $message';
}

class FriendRequestException implements Exception {
  final String message;
  FriendRequestException({required this.message});
  @override
  String toString() => 'FriendRequestException: $message';
} 