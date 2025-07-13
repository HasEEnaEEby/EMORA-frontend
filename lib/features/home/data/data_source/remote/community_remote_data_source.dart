import 'package:emora_mobile_app/core/network/dio_client.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/community_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<CommunityPostModel>> getGlobalFeed({
    int page = 1,
    int limit = 20,
  });

  Future<List<CommunityPostModel>> getFriendsFeed({
    int page = 1,
    int limit = 20,
  });

  Future<bool> reactToPost({
    required String postId,
    required String emoji,
    String type = 'comfort',
  });

  Future<bool> removeReaction({
    required String postId,
  });

  Future<bool> addComment({
    required String postId,
    required String message,
    bool isAnonymous = false,
  });

  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int limit = 10,
  });

  Future<List<GlobalMoodStatsModel>> getGlobalStats({
    String timeRange = '24h',
  });

  Future<List<CommunityPostModel>> getTrendingPosts({
    int timeRange = 24,
    int limit = 20,
  });
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final ApiService apiService;

  CommunityRemoteDataSourceImpl({
    required this.apiService,
    required DioClient dioClient,
  });

  @override
  Future<List<CommunityPostModel>> getGlobalFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('🌐 Fetching global community feed');

      final response = await apiService.get(
        '/api/community/global-feed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final postsData = dataObject['posts'] as List? ?? [];
          final posts = postsData
              .map((postData) => CommunityPostModel.fromJson(postData))
              .toList();

          Logger.info('✅ Found ${posts.length} global posts');
          return posts;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get global feed',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Global feed endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching global feed', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<CommunityPostModel>> getFriendsFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('🌐 Fetching friends community feed');

      final response = await apiService.get(
        '/api/community/friends-feed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final postsData = dataObject['posts'] as List? ?? [];
          final posts = postsData
              .map((postData) => CommunityPostModel.fromJson(postData))
              .toList();

          Logger.info('✅ Found ${posts.length} friends posts');
          return posts;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get friends feed',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Friends feed endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching friends feed', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> reactToPost({
    required String postId,
    required String emoji,
    String type = 'comfort',
  }) async {
    try {
      Logger.info('🌐 Reacting to post: $postId');

      final response = await apiService.post(
        '/api/community/react',
        data: {
          'postId': postId,
          'emoji': emoji,
          'type': type,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Reaction added successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'React endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for reacting to post',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error reacting to post', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> removeReaction({
    required String postId,
  }) async {
    try {
      Logger.info('🌐 Removing reaction from post: $postId');

      final response = await apiService.delete(
        '/api/community/react',
        queryParameters: {
          'postId': postId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Reaction removed successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Remove reaction endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for removing reaction',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error removing reaction', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> addComment({
    required String postId,
    required String message,
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info('🌐 Adding comment to post: $postId');

      final response = await apiService.post(
        '/api/community/comment',
        data: {
          'postId': postId,
          'message': message,
          'isAnonymous': isAnonymous,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Comment added successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Comment endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for adding comment',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error adding comment', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<CommentModel>> getComments({
    required String postId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🌐 Fetching comments for post: $postId');

      final response = await apiService.get(
        '/api/community/comments',
        queryParameters: {
          'postId': postId,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final commentsData = dataObject['comments'] as List? ?? [];
          final comments = commentsData
              .map((commentData) => CommentModel.fromJson(commentData))
              .toList();

          Logger.info('✅ Found ${comments.length} comments');
          return comments;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get comments',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Comments endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching comments', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<GlobalMoodStatsModel>> getGlobalStats({
    String timeRange = '24h',
  }) async {
    try {
      Logger.info('🌐 Fetching global mood stats');

      final response = await apiService.get(
        '/api/community/global-stats',
        queryParameters: {
          'timeRange': timeRange,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final statsData = dataObject['emotionBreakdown'] as List? ?? [];
          final stats = statsData
              .map((statData) => GlobalMoodStatsModel.fromJson(statData))
              .toList();

          Logger.info('✅ Found ${stats.length} mood stats');
          return stats;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get global stats',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Global stats endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching global stats', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<CommunityPostModel>> getTrendingPosts({
    int timeRange = 24,
    int limit = 20,
  }) async {
    try {
      Logger.info('🌐 Fetching trending posts');

      final response = await apiService.get(
        '/api/community/trending',
        queryParameters: {
          'timeRange': timeRange,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final postsData = dataObject['posts'] as List? ?? [];
          final posts = postsData
              .map((postData) => CommunityPostModel.fromJson(postData))
              .toList();

          Logger.info('✅ Found ${posts.length} trending posts');
          return posts;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get trending posts',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Trending posts endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching trending posts', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
} 