import 'package:equatable/equatable.dart';

import '../../../domain/entity/community_entity.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL AND LOADING STATES
// ============================================================================

/// Initial state
class CommunityInitial extends CommunityState {
  const CommunityInitial();
}

/// General loading state
class CommunityLoading extends CommunityState {
  const CommunityLoading();
}

// ============================================================================
// FEED STATES
// ============================================================================

/// Community feed loaded state
class CommunityFeedLoaded extends CommunityState {
  final List<CommunityPostEntity> globalPosts;
  final List<CommunityPostEntity> friendsPosts;
  final List<CommunityPostEntity> trendingPosts;
  final List<GlobalMoodStatsEntity> globalStats;
  final String currentFeedType; // 'global', 'friends', 'trending'
  final bool hasMorePosts;
  final bool isRefreshing;
  final int currentPage;

  const CommunityFeedLoaded({
    required this.globalPosts,
    required this.friendsPosts,
    required this.trendingPosts,
    required this.globalStats,
    this.currentFeedType = 'global',
    this.hasMorePosts = false,
    this.isRefreshing = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [
        globalPosts,
        friendsPosts,
        trendingPosts,
        globalStats,
        currentFeedType,
        hasMorePosts,
        isRefreshing,
        currentPage,
      ];

  CommunityFeedLoaded copyWith({
    List<CommunityPostEntity>? globalPosts,
    List<CommunityPostEntity>? friendsPosts,
    List<CommunityPostEntity>? trendingPosts,
    List<GlobalMoodStatsEntity>? globalStats,
    String? currentFeedType,
    bool? hasMorePosts,
    bool? isRefreshing,
    int? currentPage,
  }) {
    return CommunityFeedLoaded(
      globalPosts: globalPosts ?? this.globalPosts,
      friendsPosts: friendsPosts ?? this.friendsPosts,
      trendingPosts: trendingPosts ?? this.trendingPosts,
      globalStats: globalStats ?? this.globalStats,
      currentFeedType: currentFeedType ?? this.currentFeedType,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  // Helper getters
  List<CommunityPostEntity> get currentFeedPosts {
    switch (currentFeedType) {
      case 'friends':
        return friendsPosts;
      case 'trending':
        return trendingPosts;
      case 'global':
      default:
        return globalPosts;
    }
  }

  int get totalGlobalPosts => globalPosts.length;
  int get totalFriendsPosts => friendsPosts.length;
  int get totalTrendingPosts => trendingPosts.length;
}

/// Feed loading state (when switching feed types)
class CommunityFeedLoading extends CommunityFeedLoaded {
  final String loadingFeedType;

  const CommunityFeedLoading({
    required this.loadingFeedType,
    required super.globalPosts,
    required super.friendsPosts,
    required super.trendingPosts,
    required super.globalStats,
    super.currentFeedType,
    super.hasMorePosts,
    super.isRefreshing,
    super.currentPage,
  });

  @override
  List<Object?> get props => [
        loadingFeedType,
        globalPosts,
        friendsPosts,
        trendingPosts,
        globalStats,
        currentFeedType,
        hasMorePosts,
        isRefreshing,
        currentPage,
      ];
}

// ============================================================================
// INTERACTION STATES
// ============================================================================

/// Post interaction loading state
class PostInteractionLoading extends CommunityFeedLoaded {
  final String interactionType; // 'react', 'comment', 'remove_reaction'
  final String postId;

  const PostInteractionLoading({
    required this.interactionType,
    required this.postId,
    required super.globalPosts,
    required super.friendsPosts,
    required super.trendingPosts,
    required super.globalStats,
    super.currentFeedType,
    super.hasMorePosts,
    super.isRefreshing,
    super.currentPage,
  });

  @override
  List<Object?> get props => [
        interactionType,
        postId,
        globalPosts,
        friendsPosts,
        trendingPosts,
        globalStats,
        currentFeedType,
        hasMorePosts,
        isRefreshing,
        currentPage,
      ];
}

/// Post interaction success state
class PostInteractionSuccess extends CommunityFeedLoaded {
  final String message;
  final String interactionType;
  final String postId;

  const PostInteractionSuccess({
    required this.message,
    required this.interactionType,
    required this.postId,
    required super.globalPosts,
    required super.friendsPosts,
    required super.trendingPosts,
    required super.globalStats,
    super.currentFeedType,
    super.hasMorePosts,
    super.isRefreshing,
    super.currentPage,
  });

  @override
  List<Object?> get props => [
        message,
        interactionType,
        postId,
        globalPosts,
        friendsPosts,
        trendingPosts,
        globalStats,
        currentFeedType,
        hasMorePosts,
        isRefreshing,
        currentPage,
      ];
}

// ============================================================================
// COMMENTS STATES
// ============================================================================

/// Comments loaded state
class CommentsLoaded extends CommunityState {
  final String postId;
  final List<CommentEntity> comments;
  final bool hasMoreComments;
  final int currentPage;
  final bool isLoading;

  const CommentsLoaded({
    required this.postId,
    required this.comments,
    this.hasMoreComments = false,
    this.currentPage = 1,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [
        postId,
        comments,
        hasMoreComments,
        currentPage,
        isLoading,
      ];

  CommentsLoaded copyWith({
    String? postId,
    List<CommentEntity>? comments,
    bool? hasMoreComments,
    int? currentPage,
    bool? isLoading,
  }) {
    return CommentsLoaded(
      postId: postId ?? this.postId,
      comments: comments ?? this.comments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalComments => comments.length;
}

/// Comments loading state
class CommentsLoading extends CommunityState {
  final String postId;

  const CommentsLoading({required this.postId});

  @override
  List<Object?> get props => [postId];
}

// ============================================================================
// ERROR STATES
// ============================================================================

/// Community error state
class CommunityError extends CommunityState {
  final String message;
  final String? errorType;
  final bool canRetry;

  const CommunityError({
    required this.message,
    this.errorType,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorType, canRetry];

  CommunityError copyWith({
    String? message,
    String? errorType,
    bool? canRetry,
  }) {
    return CommunityError(
      message: message ?? this.message,
      errorType: errorType ?? this.errorType,
      canRetry: canRetry ?? this.canRetry,
    );
  }
}

/// Feed error state (maintains current data)
class CommunityFeedError extends CommunityFeedLoaded {
  final String errorMessage;
  final String? errorType;

  const CommunityFeedError({
    required this.errorMessage,
    this.errorType,
    required super.globalPosts,
    required super.friendsPosts,
    required super.trendingPosts,
    required super.globalStats,
    super.currentFeedType,
    super.hasMorePosts,
    super.isRefreshing,
    super.currentPage,
  });

  @override
  List<Object?> get props => [
        errorMessage,
        errorType,
        globalPosts,
        friendsPosts,
        trendingPosts,
        globalStats,
        currentFeedType,
        hasMorePosts,
        isRefreshing,
        currentPage,
      ];
}

/// Comments error state
class CommentsError extends CommunityState {
  final String postId;
  final String message;

  const CommentsError({
    required this.postId,
    required this.message,
  });

  @override
  List<Object?> get props => [postId, message];
} 