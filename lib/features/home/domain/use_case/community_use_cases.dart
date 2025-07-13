import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/community_entity.dart';
import '../repository/community_repository.dart';

// ============================================================================
// GET GLOBAL FEED USE CASE
// ============================================================================
class GetGlobalFeedParams {
  final int page;
  final int limit;

  const GetGlobalFeedParams({
    this.page = 1,
    this.limit = 20,
  });
}

class GetGlobalFeed implements UseCase<List<CommunityPostEntity>, GetGlobalFeedParams> {
  final CommunityRepository repository;

  GetGlobalFeed(this.repository);

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> call(GetGlobalFeedParams params) async {
    return await repository.getGlobalFeed(
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// GET FRIENDS FEED USE CASE
// ============================================================================
class GetFriendsFeedParams {
  final int page;
  final int limit;

  const GetFriendsFeedParams({
    this.page = 1,
    this.limit = 20,
  });
}

class GetFriendsFeed implements UseCase<List<CommunityPostEntity>, GetFriendsFeedParams> {
  final CommunityRepository repository;

  GetFriendsFeed(this.repository);

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> call(GetFriendsFeedParams params) async {
    return await repository.getFriendsFeed(
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// REACT TO POST USE CASE
// ============================================================================
class ReactToPostParams {
  final String postId;
  final String emoji;
  final String type;

  const ReactToPostParams({
    required this.postId,
    required this.emoji,
    this.type = 'comfort',
  });
}

class ReactToPost implements UseCase<bool, ReactToPostParams> {
  final CommunityRepository repository;

  ReactToPost(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReactToPostParams params) async {
    return await repository.reactToPost(
      postId: params.postId,
      emoji: params.emoji,
      type: params.type,
    );
  }
}

// ============================================================================
// REMOVE REACTION USE CASE
// ============================================================================
class RemoveReactionParams {
  final String postId;

  const RemoveReactionParams({required this.postId});
}

class RemoveReaction implements UseCase<bool, RemoveReactionParams> {
  final CommunityRepository repository;

  RemoveReaction(this.repository);

  @override
  Future<Either<Failure, bool>> call(RemoveReactionParams params) async {
    return await repository.removeReaction(postId: params.postId);
  }
}

// ============================================================================
// ADD COMMENT USE CASE
// ============================================================================
class AddCommentParams {
  final String postId;
  final String message;
  final bool isAnonymous;

  const AddCommentParams({
    required this.postId,
    required this.message,
    this.isAnonymous = false,
  });
}

class AddComment implements UseCase<bool, AddCommentParams> {
  final CommunityRepository repository;

  AddComment(this.repository);

  @override
  Future<Either<Failure, bool>> call(AddCommentParams params) async {
    return await repository.addComment(
      postId: params.postId,
      message: params.message,
      isAnonymous: params.isAnonymous,
    );
  }
}

// ============================================================================
// GET COMMENTS USE CASE
// ============================================================================
class GetCommentsParams {
  final String postId;
  final int page;
  final int limit;

  const GetCommentsParams({
    required this.postId,
    this.page = 1,
    this.limit = 10,
  });
}

class GetComments implements UseCase<List<CommentEntity>, GetCommentsParams> {
  final CommunityRepository repository;

  GetComments(this.repository);

  @override
  Future<Either<Failure, List<CommentEntity>>> call(GetCommentsParams params) async {
    return await repository.getComments(
      postId: params.postId,
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// GET GLOBAL STATS USE CASE
// ============================================================================
class GetGlobalStatsParams {
  final String timeRange;

  const GetGlobalStatsParams({this.timeRange = '24h'});
}

class GetGlobalStats implements UseCase<List<GlobalMoodStatsEntity>, GetGlobalStatsParams> {
  final CommunityRepository repository;

  GetGlobalStats(this.repository);

  @override
  Future<Either<Failure, List<GlobalMoodStatsEntity>>> call(GetGlobalStatsParams params) async {
    return await repository.getGlobalStats(timeRange: params.timeRange);
  }
}

// ============================================================================
// GET TRENDING POSTS USE CASE
// ============================================================================
class GetTrendingPostsParams {
  final int timeRange;
  final int limit;

  const GetTrendingPostsParams({
    this.timeRange = 24,
    this.limit = 20,
  });
}

class GetTrendingPosts implements UseCase<List<CommunityPostEntity>, GetTrendingPostsParams> {
  final CommunityRepository repository;

  GetTrendingPosts(this.repository);

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> call(GetTrendingPostsParams params) async {
    return await repository.getTrendingPosts(
      timeRange: params.timeRange,
      limit: params.limit,
    );
  }
} 