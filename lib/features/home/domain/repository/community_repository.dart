import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/community_entity.dart';

abstract class CommunityRepository {
  // Get global community feed
  Future<Either<Failure, List<CommunityPostEntity>>> getGlobalFeed({
    int page = 1,
    int limit = 20,
  });

  // Get friends' mood feed
  Future<Either<Failure, List<CommunityPostEntity>>> getFriendsFeed({
    int page = 1,
    int limit = 20,
  });

  // React to a mood post
  Future<Either<Failure, bool>> reactToPost({
    required String postId,
    required String emoji,
    String type = 'comfort',
  });

  // Remove reaction from post
  Future<Either<Failure, bool>> removeReaction({
    required String postId,
  });

  // Add comment to a mood post
  Future<Either<Failure, bool>> addComment({
    required String postId,
    required String message,
    bool isAnonymous = false,
  });

  // Get comments for a post
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 10,
  });

  // Get global mood statistics
  Future<Either<Failure, List<GlobalMoodStatsEntity>>> getGlobalStats({
    String timeRange = '24h',
  });

  // Get trending posts
  Future<Either<Failure, List<CommunityPostEntity>>> getTrendingPosts({
    int timeRange = 24,
    int limit = 20,
  });
} 