import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/community_entity.dart';
import '../../domain/repository/community_repository.dart';
import '../data_source/remote/community_remote_data_source.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CommunityRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> getGlobalFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info(
        '🌍 Repository: Fetching global community feed (page: $page, limit: $limit)',
      );

      if (await networkInfo.isConnected) {
        final posts = await remoteDataSource.getGlobalFeed(
          page: page,
          limit: limit,
        );

        final entities = posts.map((post) => post.toEntity()).toList();
        Logger.info('. Repository: Found ${entities.length} global posts');

        // Log sample data for debugging
        if (entities.isNotEmpty) {
          final firstPost = entities.first;
          Logger.info(
            '. Sample post - ID: ${firstPost.id}, Note: "${firstPost.message}", Emoji: ${firstPost.emoji}',
          );
        }

        return Right(entities);
      } else {
        Logger.warning('. Repository: No network connection for global feed');
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error fetching global feed', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Global feed endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error('. Repository: Unauthorized request for global feed', e);
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error fetching global feed', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> getFriendsFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info(
        '👫 Repository: Fetching friends community feed (page: $page, limit: $limit)',
      );

      if (await networkInfo.isConnected) {
        final posts = await remoteDataSource.getFriendsFeed(
          page: page,
          limit: limit,
        );

        final entities = posts.map((post) => post.toEntity()).toList();
        Logger.info('. Repository: Found ${entities.length} friends posts');
        return Right(entities);
      } else {
        Logger.warning('. Repository: No network connection for friends feed');
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error fetching friends feed', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Friends feed endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error('. Repository: Unauthorized request for friends feed', e);
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error fetching friends feed', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CommunityPostEntity>>> getTrendingPosts({
    int timeRange = 24,
    int limit = 20,
  }) async {
    try {
      Logger.info(
        '🔥 Repository: Fetching trending posts (timeRange: ${timeRange}h, limit: $limit)',
      );

      if (await networkInfo.isConnected) {
        final posts = await remoteDataSource.getTrendingPosts(
          timeRange: timeRange,
          limit: limit,
        );

        final entities = posts.map((post) => post.toEntity()).toList();
        Logger.info('. Repository: Found ${entities.length} trending posts');
        return Right(entities);
      } else {
        Logger.warning(
          '. Repository: No network connection for trending posts',
        );
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error fetching trending posts', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Trending posts endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error('. Repository: Unauthorized request for trending posts', e);
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error fetching trending posts', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> reactToPost({
    required String postId,
    required String emoji,
    String type = 'comfort',
  }) async {
    try {
      Logger.info(
        '❤️ Repository: Reacting to post $postId with $emoji (type: $type)',
      );

      // Validate input parameters
      if (postId.isEmpty) {
        Logger.error('. Repository: Invalid post ID for reaction');
        return Left(
          ValidationFailure(message: 'Invalid post ID. Please try again.'),
        );
      }

      if (emoji.isEmpty) {
        Logger.error('. Repository: Invalid emoji for reaction');
        return Left(
          ValidationFailure(message: 'Invalid reaction. Please try again.'),
        );
      }

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.reactToPost(
          postId: postId,
          emoji: emoji,
          type: type,
        );

        if (success) {
          Logger.info('. Repository: Successfully reacted to post $postId');
          return Right(true);
        } else {
          Logger.warning('. Repository: Failed to react to post $postId');
          return Left(
            ServerFailure(message: 'Failed to add reaction. Please try again.'),
          );
        }
      } else {
        Logger.warning(
          '. Repository: No network connection for reacting to post',
        );
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error reacting to post', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: React endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error(
        '. Repository: Unauthorized request for reacting to post',
        e,
      );
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error reacting to post', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> removeReaction({required String postId}) async {
    try {
      Logger.info('🗑️ Repository: Removing reaction from post $postId');

      // Validate input parameters
      if (postId.isEmpty) {
        Logger.error('. Repository: Invalid post ID for removing reaction');
        return Left(
          ValidationFailure(message: 'Invalid post ID. Please try again.'),
        );
      }

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.removeReaction(postId: postId);

        if (success) {
          Logger.info(
            '. Repository: Successfully removed reaction from post $postId',
          );
          return Right(true);
        } else {
          Logger.warning(
            '. Repository: Failed to remove reaction from post $postId',
          );
          return Left(
            ServerFailure(
              message: 'Failed to remove reaction. Please try again.',
            ),
          );
        }
      } else {
        Logger.warning(
          '. Repository: No network connection for removing reaction',
        );
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error removing reaction', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Remove reaction endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error(
        '. Repository: Unauthorized request for removing reaction',
        e,
      );
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error removing reaction', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> addComment({
    required String postId,
    required String message,
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info(
        '💬 Repository: Adding comment to post $postId (anonymous: $isAnonymous)',
      );

      // Validate input parameters
      if (postId.isEmpty) {
        Logger.error('. Repository: Invalid post ID for adding comment');
        return Left(
          ValidationFailure(message: 'Invalid post ID. Please try again.'),
        );
      }

      if (message.trim().isEmpty) {
        Logger.error('. Repository: Empty message for comment');
        return Left(
          ValidationFailure(
            message: 'Comment cannot be empty. Please write something.',
          ),
        );
      }

      if (message.length > 500) {
        Logger.error('. Repository: Comment message too long');
        return Left(
          ValidationFailure(
            message:
                'Comment is too long. Please keep it under 500 characters.',
          ),
        );
      }

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.addComment(
          postId: postId,
          message: message.trim(),
          isAnonymous: isAnonymous,
        );

        if (success) {
          Logger.info(
            '. Repository: Successfully added comment to post $postId',
          );
          return Right(true);
        } else {
          Logger.warning(
            '. Repository: Failed to add comment to post $postId',
          );
          return Left(
            ServerFailure(message: 'Failed to add comment. Please try again.'),
          );
        }
      } else {
        Logger.warning(
          '. Repository: No network connection for adding comment',
        );
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error adding comment', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Add comment endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error('. Repository: Unauthorized request for adding comment', e);
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error adding comment', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<CommentEntity>>> getComments({
    required String postId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info(
        '💬 Repository: Fetching comments for post $postId (page: $page, limit: $limit)',
      );

      // Validate input parameters
      if (postId.isEmpty) {
        Logger.error('. Repository: Invalid post ID for fetching comments');
        return Left(
          ValidationFailure(message: 'Invalid post ID. Please try again.'),
        );
      }

      if (await networkInfo.isConnected) {
        final comments = await remoteDataSource.getComments(
          postId: postId,
          page: page,
          limit: limit,
        );

        final entities = comments.map((comment) => comment.toEntity()).toList();
        Logger.info(
          '. Repository: Found ${entities.length} comments for post $postId',
        );
        return Right(entities);
      } else {
        Logger.warning(
          '. Repository: No network connection for fetching comments',
        );
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error fetching comments', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Comments endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error(
        '. Repository: Unauthorized request for fetching comments',
        e,
      );
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error fetching comments', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, List<GlobalMoodStatsEntity>>> getGlobalStats({
    String timeRange = '24h',
  }) async {
    try {
      Logger.info(
        '. Repository: Fetching global mood statistics (timeRange: $timeRange)',
      );

      if (await networkInfo.isConnected) {
        final stats = await remoteDataSource.getGlobalStats(
          timeRange: timeRange,
        );

        final entities = stats.map((stat) => stat.toEntity()).toList();
        Logger.info('. Repository: Found ${entities.length} mood statistics');
        return Right(entities);
      } else {
        Logger.warning('. Repository: No network connection for global stats');
        return Left(
          NetworkFailure(
            message:
                'No internet connection. Please check your network and try again.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('. Repository: Server error fetching global stats', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('. Repository: Global stats endpoint not found', e);
      return Left(
        ServerFailure(
          message: 'Service temporarily unavailable. Please try again later.',
        ),
      );
    } on UnauthorizedException catch (e) {
      Logger.error('. Repository: Unauthorized request for global stats', e);
      return Left(
        AuthFailure(message: 'Authentication expired. Please login again.'),
      );
    } catch (e) {
      Logger.error('. Repository: Unexpected error fetching global stats', e);
      return Left(
        ServerFailure(message: 'Something went wrong. Please try again.'),
      );
    }
  }

  // Helper method to validate network connectivity with retry logic
  Future<bool> _checkNetworkWithRetry({int retries = 2}) async {
    for (int i = 0; i < retries; i++) {
      if (await networkInfo.isConnected) {
        return true;
      }
      if (i < retries - 1) {
        Logger.info(
          '🔄 Repository: Network check failed, retrying... (${i + 1}/$retries)',
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    return false;
  }

  // Helper method to get user-friendly error messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error is ServerException) {
      if (error.message.toLowerCase().contains('timeout')) {
        return 'Request timed out. Please check your connection and try again.';
      }
      if (error.message.toLowerCase().contains('not found')) {
        return 'Service temporarily unavailable. Please try again later.';
      }
      return error.message.isNotEmpty
          ? error.message
          : 'Server error occurred. Please try again.';
    }

    if (error is NotFoundException) {
      return 'Service temporarily unavailable. Please try again later.';
    }

    if (error is UnauthorizedException) {
      return 'Authentication expired. Please login again.';
    }

    return 'Something went wrong. Please try again.';
  }
}

// Custom validation failure class
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});

  @override
  List<Object?> get props => [message];
}
