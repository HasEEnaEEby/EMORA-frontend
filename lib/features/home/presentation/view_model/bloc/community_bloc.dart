import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../domain/entity/community_entity.dart';
import '../../../domain/use_case/community_use_cases.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetGlobalFeed getGlobalFeed;
  final GetFriendsFeed getFriendsFeed;
  final GetTrendingPosts getTrendingPosts;
  final ReactToPost reactToPost;
  final RemoveReaction removeReaction;
  final AddComment addComment;
  final GetComments getComments;
  final GetGlobalStats getGlobalStats;

  // Cache management
  bool _isLoadingGlobalFeed = false;
  bool _isLoadingFriendsFeed = false;
  bool _isLoadingTrendingPosts = false;
  bool _isLoadingStats = false;

  CommunityBloc({
    required this.getGlobalFeed,
    required this.getFriendsFeed,
    required this.getTrendingPosts,
    required this.reactToPost,
    required this.removeReaction,
    required this.addComment,
    required this.getComments,
    required this.getGlobalStats,
  }) : super(const CommunityInitial()) {
    // Register all event handlers
    on<LoadGlobalFeedEvent>(_onLoadGlobalFeed);
    on<LoadFriendsFeedEvent>(_onLoadFriendsFeed);
    on<LoadTrendingPostsEvent>(_onLoadTrendingPosts);
    on<SwitchFeedTypeEvent>(_onSwitchFeedType);
    on<ReactToPostEvent>(_onReactToPost);
    on<RemoveReactionEvent>(_onRemoveReaction);
    on<AddCommentEvent>(_onAddComment);
    on<LoadCommentsEvent>(_onLoadComments);
    on<LoadGlobalStatsEvent>(_onLoadGlobalStats);
    on<CreateCommunityPostEvent>(_onCreateCommunityPost);
    on<RefreshCommunityDataEvent>(_onRefreshCommunityData);
    on<RefreshCurrentFeedEvent>(_onRefreshCurrentFeed);
    on<ClearCommunityErrorEvent>(_onClearCommunityError);
    on<ResetCommunityStateEvent>(_onResetCommunityState);
  }

  // ============================================================================
  // FEED LOADING EVENT HANDLERS
  // ============================================================================

  Future<void> _onLoadGlobalFeed(
    LoadGlobalFeedEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (_isLoadingGlobalFeed && !event.forceRefresh) {
      Logger.info('🌍 Global feed already loading');
      return;
    }

    _isLoadingGlobalFeed = true;

    try {
      Logger.info('🌍 Loading global feed: page ${event.page}');

      // Show loading state if first page
      if (event.page == 1) {
        if (state is CommunityFeedLoaded) {
          final currentState = state as CommunityFeedLoaded;
          emit(CommunityFeedLoading(
            loadingFeedType: 'global',
            globalPosts: currentState.globalPosts,
            friendsPosts: currentState.friendsPosts,
            trendingPosts: currentState.trendingPosts,
            globalStats: currentState.globalStats,
            currentFeedType: currentState.currentFeedType,
            hasMorePosts: currentState.hasMorePosts,
            isRefreshing: event.forceRefresh,
            currentPage: currentState.currentPage,
          ));
        } else {
          emit(const CommunityLoading());
        }
      }

      final result = await getGlobalFeed(GetGlobalFeedParams(
        page: event.page,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Load global feed failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'load_global_feed',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          } else {
            emit(CommunityError(
              message: failure.message,
              errorType: 'load_global_feed',
            ));
          }
        },
        (globalPosts) {
          Logger.info('✅ Loaded ${globalPosts.length} global posts');
          _updateFeedWithGlobalPosts(globalPosts, event, emit);
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading global feed', e);
      emit(CommunityError(
        message: 'Failed to load global feed: ${e.toString()}',
        errorType: 'load_global_feed',
      ));
    } finally {
      _isLoadingGlobalFeed = false;
    }
  }

  Future<void> _onLoadFriendsFeed(
    LoadFriendsFeedEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (_isLoadingFriendsFeed && !event.forceRefresh) {
      Logger.info('👫 Friends feed already loading');
      return;
    }

    _isLoadingFriendsFeed = true;

    try {
      Logger.info('👫 Loading friends feed: page ${event.page}');

      // Show loading state if first page
      if (event.page == 1) {
        if (state is CommunityFeedLoaded) {
          final currentState = state as CommunityFeedLoaded;
          emit(CommunityFeedLoading(
            loadingFeedType: 'friends',
            globalPosts: currentState.globalPosts,
            friendsPosts: currentState.friendsPosts,
            trendingPosts: currentState.trendingPosts,
            globalStats: currentState.globalStats,
            currentFeedType: currentState.currentFeedType,
            hasMorePosts: currentState.hasMorePosts,
            isRefreshing: event.forceRefresh,
            currentPage: currentState.currentPage,
          ));
        } else {
          emit(const CommunityLoading());
        }
      }

      final result = await getFriendsFeed(GetFriendsFeedParams(
        page: event.page,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Load friends feed failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'load_friends_feed',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          } else {
            emit(CommunityError(
              message: failure.message,
              errorType: 'load_friends_feed',
            ));
          }
        },
        (friendsPosts) {
          Logger.info('✅ Loaded ${friendsPosts.length} friends posts');
          _updateFeedWithFriendsPosts(friendsPosts, event, emit);
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading friends feed', e);
      emit(CommunityError(
        message: 'Failed to load friends feed: ${e.toString()}',
        errorType: 'load_friends_feed',
      ));
    } finally {
      _isLoadingFriendsFeed = false;
    }
  }

  Future<void> _onLoadTrendingPosts(
    LoadTrendingPostsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (_isLoadingTrendingPosts && !event.forceRefresh) {
      Logger.info('🔥 Trending posts already loading');
      return;
    }

    _isLoadingTrendingPosts = true;

    try {
      Logger.info('🔥 Loading trending posts: timeRange ${event.timeRange}h');

      // Show loading state
      if (state is CommunityFeedLoaded) {
        final currentState = state as CommunityFeedLoaded;
        emit(CommunityFeedLoading(
          loadingFeedType: 'trending',
          globalPosts: currentState.globalPosts,
          friendsPosts: currentState.friendsPosts,
          trendingPosts: currentState.trendingPosts,
          globalStats: currentState.globalStats,
          currentFeedType: currentState.currentFeedType,
          hasMorePosts: currentState.hasMorePosts,
          isRefreshing: event.forceRefresh,
          currentPage: currentState.currentPage,
        ));
      } else {
        emit(const CommunityLoading());
      }

      final result = await getTrendingPosts(GetTrendingPostsParams(
        timeRange: event.timeRange,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Load trending posts failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'load_trending_posts',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          } else {
            emit(CommunityError(
              message: failure.message,
              errorType: 'load_trending_posts',
            ));
          }
        },
        (trendingPosts) {
          Logger.info('✅ Loaded ${trendingPosts.length} trending posts');
          _updateFeedWithTrendingPosts(trendingPosts, event, emit);
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading trending posts', e);
      emit(CommunityError(
        message: 'Failed to load trending posts: ${e.toString()}',
        errorType: 'load_trending_posts',
      ));
    } finally {
      _isLoadingTrendingPosts = false;
    }
  }

  Future<void> _onSwitchFeedType(
    SwitchFeedTypeEvent event,
    Emitter<CommunityState> emit,
  ) async {
    Logger.info('🔄 Switching feed type to: ${event.feedType}');

    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      // Update feed type immediately
      emit(currentState.copyWith(
        currentFeedType: event.feedType,
        isRefreshing: false,
      ));

      // Load data for the selected feed type if needed
      switch (event.feedType) {
        case 'global':
          if (currentState.globalPosts.isEmpty) {
            add(const LoadGlobalFeedEvent(forceRefresh: true));
          }
          break;
        case 'friends':
          if (currentState.friendsPosts.isEmpty) {
            add(const LoadFriendsFeedEvent(forceRefresh: true));
          }
          break;
        case 'trending':
          if (currentState.trendingPosts.isEmpty) {
            add(const LoadTrendingPostsEvent(forceRefresh: true));
          }
          break;
      }
    } else {
      // If no current state, load initial data for the requested feed type
      switch (event.feedType) {
        case 'global':
          add(const LoadGlobalFeedEvent());
          break;
        case 'friends':
          add(const LoadFriendsFeedEvent());
          break;
        case 'trending':
          add(const LoadTrendingPostsEvent());
          break;
      }
    }
  }

  // ============================================================================
  // INTERACTION EVENT HANDLERS
  // ============================================================================

  Future<void> _onReactToPost(
    ReactToPostEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      Logger.info('💖 Reacting to post: ${event.postId} with ${event.emoji}');

      // Show loading state while maintaining current data
      if (state is CommunityFeedLoaded) {
        final currentState = state as CommunityFeedLoaded;
        emit(PostInteractionLoading(
          interactionType: 'react',
          postId: event.postId,
          globalPosts: currentState.globalPosts,
          friendsPosts: currentState.friendsPosts,
          trendingPosts: currentState.trendingPosts,
          globalStats: currentState.globalStats,
          currentFeedType: currentState.currentFeedType,
          hasMorePosts: currentState.hasMorePosts,
          isRefreshing: currentState.isRefreshing,
          currentPage: currentState.currentPage,
        ));
      }

      final result = await reactToPost(ReactToPostParams(
        postId: event.postId,
        emoji: event.emoji,
        type: event.type,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ React to post failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'react_to_post',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          }
        },
        (success) {
          if (success) {
            Logger.info('✅ Successfully reacted to post');
            
            // Update the post with new reaction locally
            _updatePostReaction(event.postId, event.emoji, event.type, emit);
            
            if (state is CommunityFeedLoaded) {
              final currentState = state as CommunityFeedLoaded;
              emit(PostInteractionSuccess(
                message: 'Reaction added!',
                interactionType: 'react',
                postId: event.postId,
                globalPosts: currentState.globalPosts,
                friendsPosts: currentState.friendsPosts,
                trendingPosts: currentState.trendingPosts,
                globalStats: currentState.globalStats,
                currentFeedType: currentState.currentFeedType,
                hasMorePosts: currentState.hasMorePosts,
                isRefreshing: false,
                currentPage: currentState.currentPage,
              ));
            }
          } else {
            emit(const CommunityError(
              message: 'Failed to add reaction',
              errorType: 'react_to_post',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error reacting to post', e);
      emit(CommunityError(
        message: 'Failed to add reaction: ${e.toString()}',
        errorType: 'react_to_post',
      ));
    }
  }

  Future<void> _onRemoveReaction(
    RemoveReactionEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      Logger.info('💔 Removing reaction from post: ${event.postId}');

      // Show loading state
      if (state is CommunityFeedLoaded) {
        final currentState = state as CommunityFeedLoaded;
        emit(PostInteractionLoading(
          interactionType: 'remove_reaction',
          postId: event.postId,
          globalPosts: currentState.globalPosts,
          friendsPosts: currentState.friendsPosts,
          trendingPosts: currentState.trendingPosts,
          globalStats: currentState.globalStats,
          currentFeedType: currentState.currentFeedType,
          hasMorePosts: currentState.hasMorePosts,
          isRefreshing: currentState.isRefreshing,
          currentPage: currentState.currentPage,
        ));
      }

      final result = await removeReaction(RemoveReactionParams(
        postId: event.postId,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Remove reaction failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'remove_reaction',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          }
        },
        (success) {
          if (success) {
            Logger.info('✅ Successfully removed reaction from post');
            
            // Update the post locally by removing reaction
            _removePostReaction(event.postId, emit);
            
            if (state is CommunityFeedLoaded) {
              final currentState = state as CommunityFeedLoaded;
              emit(PostInteractionSuccess(
                message: 'Reaction removed',
                interactionType: 'remove_reaction',
                postId: event.postId,
                globalPosts: currentState.globalPosts,
                friendsPosts: currentState.friendsPosts,
                trendingPosts: currentState.trendingPosts,
                globalStats: currentState.globalStats,
                currentFeedType: currentState.currentFeedType,
                hasMorePosts: currentState.hasMorePosts,
                isRefreshing: false,
                currentPage: currentState.currentPage,
              ));
            }
          } else {
            emit(const CommunityError(
              message: 'Failed to remove reaction',
              errorType: 'remove_reaction',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error removing reaction', e);
      emit(CommunityError(
        message: 'Failed to remove reaction: ${e.toString()}',
        errorType: 'remove_reaction',
      ));
    }
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      Logger.info('💬 Adding comment to post: ${event.postId}');

      // Show loading state
      if (state is CommunityFeedLoaded) {
        final currentState = state as CommunityFeedLoaded;
        emit(PostInteractionLoading(
          interactionType: 'comment',
          postId: event.postId,
          globalPosts: currentState.globalPosts,
          friendsPosts: currentState.friendsPosts,
          trendingPosts: currentState.trendingPosts,
          globalStats: currentState.globalStats,
          currentFeedType: currentState.currentFeedType,
          hasMorePosts: currentState.hasMorePosts,
          isRefreshing: currentState.isRefreshing,
          currentPage: currentState.currentPage,
        ));
      }

      final result = await addComment(AddCommentParams(
        postId: event.postId,
        message: event.message,
        isAnonymous: event.isAnonymous,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Add comment failed: ${failure.message}');
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(CommunityFeedError(
              errorMessage: failure.message,
              errorType: 'add_comment',
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          }
        },
        (comment) {
          Logger.info('✅ Successfully added comment to post');
          
          // Update the post with new comment count locally
          _updatePostCommentCount(event.postId, emit);
          
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(PostInteractionSuccess(
              message: 'Comment added!',
              interactionType: 'comment',
              postId: event.postId,
              globalPosts: currentState.globalPosts,
              friendsPosts: currentState.friendsPosts,
              trendingPosts: currentState.trendingPosts,
              globalStats: currentState.globalStats,
              currentFeedType: currentState.currentFeedType,
              hasMorePosts: currentState.hasMorePosts,
              isRefreshing: false,
              currentPage: currentState.currentPage,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error adding comment', e);
      emit(CommunityError(
        message: 'Failed to add comment: ${e.toString()}',
        errorType: 'add_comment',
      ));
    }
  }

  Future<void> _onLoadComments(
    LoadCommentsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      Logger.info('💬 Loading comments for post: ${event.postId}');

      emit(CommentsLoading(postId: event.postId));

      final result = await getComments(GetCommentsParams(
        postId: event.postId,
        page: event.page,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Load comments failed: ${failure.message}');
          emit(CommentsError(
            postId: event.postId,
            message: failure.message,
          ));
        },
        (comments) {
          Logger.info('✅ Loaded ${comments.length} comments');
          emit(CommentsLoaded(
            postId: event.postId,
            comments: comments,
            hasMoreComments: comments.length >= event.limit,
            currentPage: event.page,
            isLoading: false,
          ));
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading comments', e);
      emit(CommentsError(
        postId: event.postId,
        message: 'Failed to load comments: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateCommunityPost(
    CreateCommunityPostEvent event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      Logger.info('🌍 Creating community post: ${event.emoji} - ${event.note}');

      // For now, we'll create a simple community post entity
      // In a real implementation, this would call a use case to create the post
      final newPost = CommunityPostEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: event.isAnonymous ? 'Anonymous User' : 'Current User',
        username: event.isAnonymous ? 'anonymous' : 'current_user',
        displayName: event.isAnonymous ? 'Anonymous' : 'Current User',
        selectedAvatar: 'avatar_1',
        emoji: event.emoji,
        location: 'Unknown',
        message: event.note,
        timestamp: DateTime.now(),
        reactions: const [],
        comments: const [],
        viewCount: 0,
        shareCount: 0,
        moodColor: '#8b5cf6', // Purple for emotion posts
        activityType: 'General',
        isFriend: false,
        privacy: 'public',
        isAnonymous: event.isAnonymous,
      );

      Logger.info('✅ Community post created successfully');
      
      // Add the new post to the current feed
      if (state is CommunityFeedLoaded) {
        final currentState = state as CommunityFeedLoaded;
        final updatedGlobalPosts = [newPost, ...currentState.globalPosts];
        
        emit(currentState.copyWith(
          globalPosts: updatedGlobalPosts,
          isRefreshing: false,
        ));
      }
      
    } catch (e) {
      Logger.error('❌ Unexpected error creating community post', e);
      emit(CommunityError(
        message: 'Failed to create community post: ${e.toString()}',
        errorType: 'create_post',
      ));
    }
  }

  Future<void> _onLoadGlobalStats(
    LoadGlobalStatsEvent event,
    Emitter<CommunityState> emit,
  ) async {
    if (_isLoadingStats && !event.forceRefresh) {
      Logger.info('📊 Global stats already loading');
      return;
    }

    _isLoadingStats = true;

    try {
      Logger.info('📊 Loading global mood statistics');

      final result = await getGlobalStats(GetGlobalStatsParams(
        timeRange: event.timeRange,
      ));

      result.fold(
        (failure) {
          Logger.error('❌ Load global stats failed: ${failure.message}');
          // Don't emit error state for stats - it's not critical
          Logger.warning('⚠️ Could not load global mood statistics');
        },
        (globalStats) {
          Logger.info('✅ Loaded global mood statistics: ${globalStats.length} emotions');
          
          // Update stats in current state
          if (state is CommunityFeedLoaded) {
            final currentState = state as CommunityFeedLoaded;
            emit(currentState.copyWith(
              globalStats: globalStats,
              isRefreshing: false,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('❌ Unexpected error loading global stats', e);
      // Don't emit error state for non-critical operation
    } finally {
      _isLoadingStats = false;
    }
  }

  // ============================================================================
  // REFRESH EVENT HANDLERS
  // ============================================================================

  Future<void> _onRefreshCommunityData(
    RefreshCommunityDataEvent event,
    Emitter<CommunityState> emit,
  ) async {
    Logger.info('🔄 Refreshing all community data');
    
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }
    
    // Load all feeds and stats in parallel
    add(const LoadGlobalFeedEvent(forceRefresh: true));
    add(const LoadFriendsFeedEvent(forceRefresh: true));
    add(const LoadTrendingPostsEvent(forceRefresh: true));
    add(const LoadGlobalStatsEvent(forceRefresh: true));
  }

  Future<void> _onRefreshCurrentFeed(
    RefreshCurrentFeedEvent event,
    Emitter<CommunityState> emit,
  ) async {
    Logger.info('🔄 Refreshing current feed');
    
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      emit(currentState.copyWith(isRefreshing: true));
      
      // Refresh the current active feed
      switch (currentState.currentFeedType) {
        case 'global':
          add(const LoadGlobalFeedEvent(forceRefresh: true));
          break;
        case 'friends':
          add(const LoadFriendsFeedEvent(forceRefresh: true));
          break;
        case 'trending':
          add(const LoadTrendingPostsEvent(forceRefresh: true));
          break;
      }
    } else {
      // Load initial data
      add(const LoadGlobalFeedEvent());
    }
  }

  // ============================================================================
  // ERROR HANDLING EVENT HANDLERS
  // ============================================================================

  Future<void> _onClearCommunityError(
    ClearCommunityErrorEvent event,
    Emitter<CommunityState> emit,
  ) async {
    Logger.info('🧹 Clearing community error state');
    
    // Return to previous valid state or load initial data
    add(const LoadGlobalFeedEvent());
  }

  Future<void> _onResetCommunityState(
    ResetCommunityStateEvent event,
    Emitter<CommunityState> emit,
  ) async {
    Logger.info('🔄 Resetting community state to initial');
    
    // Clear cache flags
    _isLoadingGlobalFeed = false;
    _isLoadingFriendsFeed = false;
    _isLoadingTrendingPosts = false;
    _isLoadingStats = false;
    
    emit(const CommunityInitial());
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  void _updateFeedWithGlobalPosts(
    List<CommunityPostEntity> globalPosts,
    LoadGlobalFeedEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      List<CommunityPostEntity> updatedGlobalPosts;
      if (event.page == 1) {
        updatedGlobalPosts = globalPosts;
      } else {
        updatedGlobalPosts = [...currentState.globalPosts, ...globalPosts];
      }
      
      emit(currentState.copyWith(
        globalPosts: updatedGlobalPosts,
        hasMorePosts: globalPosts.length >= event.limit,
        isRefreshing: false,
        currentPage: event.page,
      ));
    } else {
      // First time loading
      _emitInitialFeedState(
        globalPosts: globalPosts,
        hasMore: globalPosts.length >= event.limit,
        page: event.page,
        emit: emit,
      );
    }
  }

  void _updateFeedWithFriendsPosts(
    List<CommunityPostEntity> friendsPosts,
    LoadFriendsFeedEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      List<CommunityPostEntity> updatedFriendsPosts;
      if (event.page == 1) {
        updatedFriendsPosts = friendsPosts;
      } else {
        updatedFriendsPosts = [...currentState.friendsPosts, ...friendsPosts];
      }
      
      emit(currentState.copyWith(
        friendsPosts: updatedFriendsPosts,
        hasMorePosts: friendsPosts.length >= event.limit,
        isRefreshing: false,
        currentPage: event.page,
      ));
    } else {
      // First time loading
      _emitInitialFeedState(
        friendsPosts: friendsPosts,
        hasMore: friendsPosts.length >= event.limit,
        page: event.page,
        emit: emit,
      );
    }
  }

  void _updateFeedWithTrendingPosts(
    List<CommunityPostEntity> trendingPosts,
    LoadTrendingPostsEvent event,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      emit(currentState.copyWith(
        trendingPosts: trendingPosts,
        hasMorePosts: trendingPosts.length >= event.limit,
        isRefreshing: false,
        currentPage: 1, // Trending is usually a fresh load
      ));
    } else {
      // First time loading
      _emitInitialFeedState(
        trendingPosts: trendingPosts,
        hasMore: trendingPosts.length >= event.limit,
        page: 1,
        emit: emit,
      );
    }
  }

  void _emitInitialFeedState({
    List<CommunityPostEntity>? globalPosts,
    List<CommunityPostEntity>? friendsPosts,
    List<CommunityPostEntity>? trendingPosts,
    required bool hasMore,
    required int page,
    required Emitter<CommunityState> emit,
  }) {
    emit(CommunityFeedLoaded(
      globalPosts: globalPosts ?? [],
      friendsPosts: friendsPosts ?? [],
      trendingPosts: trendingPosts ?? [],
      globalStats: const [],
      currentFeedType: 'global',
      hasMorePosts: hasMore,
      isRefreshing: false,
      currentPage: page,
    ));
    
    // Also load global stats
    add(const LoadGlobalStatsEvent());
  }

  void _updatePostReaction(
    String postId,
    String emoji,
    String type,
    Emitter<CommunityState> emit,
  ) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      // Update global posts
      final updatedGlobalPosts = currentState.globalPosts.map((post) {
        if (post.id == postId) {
          final updatedReactions = [...post.reactions];
          // Add new reaction (in real implementation, this would come from the server)
          return post.copyWith(reactions: updatedReactions);
        }
        return post;
      }).toList();
      
      // Update friends posts similarly
      final updatedFriendsPosts = currentState.friendsPosts.map((post) {
        if (post.id == postId) {
          final updatedReactions = [...post.reactions];
          return post.copyWith(reactions: updatedReactions);
        }
        return post;
      }).toList();
      
      // Update trending posts similarly
      final updatedTrendingPosts = currentState.trendingPosts.map((post) {
        if (post.id == postId) {
          final updatedReactions = [...post.reactions];
          return post.copyWith(reactions: updatedReactions);
        }
        return post;
      }).toList();
      
      emit(currentState.copyWith(
        globalPosts: updatedGlobalPosts,
        friendsPosts: updatedFriendsPosts,
        trendingPosts: updatedTrendingPosts,
        isRefreshing: false,
      ));
    }
  }

  void _removePostReaction(String postId, Emitter<CommunityState> emit) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      // Similar logic to _updatePostReaction but removing reaction
      // In real implementation, this would be handled by server response
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  void _updatePostCommentCount(String postId, Emitter<CommunityState> emit) {
    if (state is CommunityFeedLoaded) {
      final currentState = state as CommunityFeedLoaded;
      
      // Similar logic to _updatePostReaction but updating comment count
      // In real implementation, this would be handled by server response
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  // Get current feed posts
  List<CommunityPostEntity> getCurrentFeedPosts() {
    if (state is CommunityFeedLoaded) {
      return (state as CommunityFeedLoaded).currentFeedPosts;
    }
    return [];
  }

  // Get global stats
  List<GlobalMoodStatsEntity> getGlobalMoodStats() {
    if (state is CommunityFeedLoaded) {
      return (state as CommunityFeedLoaded).globalStats;
    }
    return [];
  }

  @override
  void onTransition(Transition<CommunityEvent, CommunityState> transition) {
    super.onTransition(transition);
    Logger.info(
      '🌍 Community BLoC Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.error('🌍 Community BLoC Error: $error', error, stackTrace);
  }

  @override
  Future<void> close() {
    // Clear any ongoing operations
    _isLoadingGlobalFeed = false;
    _isLoadingFriendsFeed = false;
    _isLoadingTrendingPosts = false;
    _isLoadingStats = false;
    return super.close();
  }
} 