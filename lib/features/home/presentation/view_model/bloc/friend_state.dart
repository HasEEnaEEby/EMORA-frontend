import 'package:equatable/equatable.dart';

import '../../../domain/entity/friend_entity.dart';

abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL AND LOADING STATES
// ============================================================================

/// Initial state
class FriendInitial extends FriendState {
  const FriendInitial();
}

/// General loading state
class FriendLoading extends FriendState {
  const FriendLoading();
}

// ============================================================================
// SEARCH STATES
// ============================================================================

/// Search loading state
class FriendSearchLoading extends FriendState {
  const FriendSearchLoading();
}

/// Search results state
class FriendSearchLoaded extends FriendState {
  final List<FriendSuggestionEntity> searchResults;
  final String query;
  final bool hasMore;

  const FriendSearchLoaded({
    required this.searchResults,
    required this.query,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [searchResults, query, hasMore];

  FriendSearchLoaded copyWith({
    List<FriendSuggestionEntity>? searchResults,
    String? query,
    bool? hasMore,
  }) {
    return FriendSearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Search empty state
class FriendSearchEmpty extends FriendState {
  final String query;

  const FriendSearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

// ============================================================================
// FRIENDS DATA STATES
// ============================================================================

/// Friends loaded state
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

  // Helper getters
  List<FriendRequestEntity> get sentRequests => pendingRequests['sent'] ?? [];
  List<FriendRequestEntity> get receivedRequests => pendingRequests['received'] ?? [];
  int get totalFriends => friends.length;
  int get totalSuggestions => suggestions.length;
  int get totalPendingRequests => sentRequests.length + receivedRequests.length;
}

// ============================================================================
// ACTION STATES
// ============================================================================

/// Friend request action loading
class FriendRequestActionLoading extends FriendsLoaded {
  final String actionType; // 'send', 'accept', 'reject', 'remove'
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

/// Friend request action success
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

// ============================================================================
// ERROR STATES
// ============================================================================

/// Friend error state
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

/// Search error state
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