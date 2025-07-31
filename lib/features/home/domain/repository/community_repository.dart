import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/community_entity.dart';

abstract class CommunityRepository {
  Future<Either<Failure, List<CommunityPostEntity>>> getGlobalFeed({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<CommunityPostEntity>>> getFriendsFeed({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, bool>> reactToPost({
    required String postId,
    required String emoji,
    String type = 'comfort',
  });

  Future<Either<Failure, bool>> removeReaction({
    required String postId,
  });

  Future<Either<Failure, bool>> addComment({
    required String postId,
    required String message,
    bool isAnonymous = false,
  });

  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<GlobalMoodStatsEntity>>> getGlobalStats({
    String timeRange = '24h',
  });

  Future<Either<Failure, List<CommunityPostEntity>>> getTrendingPosts({
    int timeRange = 24,
    int limit = 20,
  });
} 