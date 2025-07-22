// lib/features/friends/data/data_source/remote/friend_remote_data_source.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';

class FriendRemoteDataSource {
  final ApiService _apiService;

  FriendRemoteDataSource({required ApiService apiService}) 
      : _apiService = apiService;

  /// Send friend request with proper error handling
  Future<Map<String, dynamic>> sendFriendRequest({
    required String recipientId,
    String? message,
  }) async {
    try {
      Logger.info('📤 Sending friend request to: $recipientId');
      
      final response = await _apiService.postData(
        '/api/friends/request/$recipientId',
        data: message != null ? {'message': message} : {},
      );

      Logger.info('✅ Friend request sent successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Friend request failed', e);
      throw _handleDioException(e, 'send friend request');
    }
  }

  /// FIXED: Accept friend request - Updated to match your backend API
  Future<Map<String, dynamic>> acceptFriendRequest({
    required String requestUserId,
  }) async {
    try {
      Logger.info('✅ Accepting friend request from: $requestUserId');
      
      // CRITICAL FIX: Use the correct endpoint that matches your logs
      final response = await _apiService.postData(
        '/api/friends/accept/$requestUserId',
        data: {
          'action': 'accept',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      Logger.info('✅ Friend request accepted successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Accept friend request failed', e);
      
      // ALTERNATIVE METHOD: If the above fails, try with different endpoint
      if (e.response?.statusCode == 400) {
        Logger.info('🔄 Trying alternative accept method...');
        return await _acceptFriendRequestAlternative(requestUserId);
      }
      
      throw _handleDioException(e, 'accept friend request');
    }
  }

  /// ALTERNATIVE: Accept friend request using different approach
  Future<Map<String, dynamic>> _acceptFriendRequestAlternative(String requestUserId) async {
    try {
      // Method 1: Try with /respond endpoint
      Logger.info('🔄 Method 1: Using /api/friends/respond endpoint');
      final response = await _apiService.postData(
        '/api/friends/respond',
        data: {
          'requestUserId': requestUserId,
          'action': 'accept',
        },
      );
      
      Logger.info('✅ Alternative accept method successful');
      return response;
      
    } on DioException catch (e1) {
      Logger.warning('⚠️ Method 1 failed, trying Method 2...');
      
      try {
        // Method 2: Try with empty body
        Logger.info('🔄 Method 2: Using empty JSON body');
        final response = await _apiService.postData(
          '/api/friends/accept/$requestUserId',
          data: {}, // Empty JSON object
        );
        
        Logger.info('✅ Method 2 successful');
        return response;
        
      } on DioException catch (e2) {
        Logger.warning('⚠️ Method 2 failed, trying Method 3...');
        
        try {
          // Method 3: Try without any data
          Logger.info('🔄 Method 3: Using no body');
          final response = await _apiService.postData(
            '/api/friends/accept/$requestUserId',
          );
          
          Logger.info('✅ Method 3 successful');
          return response;
          
        } on DioException catch (e3) {
          Logger.error('❌ All methods failed');
          throw _handleDioException(e3, 'accept friend request (all methods)');
        }
      }
    }
  }

  /// FIXED: Decline friend request - Updated to match your backend API
  Future<Map<String, dynamic>> declineFriendRequest({
    required String requestUserId,
  }) async {
    try {
      Logger.info('❌ Declining friend request from: $requestUserId');
      
      // CRITICAL FIX: Use the correct endpoint
      final response = await _apiService.postData(
        '/api/friends/reject/$requestUserId',
        data: {
          'action': 'reject',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      Logger.info('✅ Friend request declined successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Decline friend request failed', e);
      
      // ALTERNATIVE METHOD: If the above fails, try with /respond endpoint
      if (e.response?.statusCode == 400) {
        Logger.info('🔄 Trying alternative decline method...');
        return await _declineFriendRequestAlternative(requestUserId);
      }
      
      throw _handleDioException(e, 'decline friend request');
    }
  }

  /// ALTERNATIVE: Decline friend request using /respond endpoint
  Future<Map<String, dynamic>> _declineFriendRequestAlternative(String requestUserId) async {
    try {
      final response = await _apiService.postData(
        '/api/friends/respond',
        data: {
          'requestUserId': requestUserId,
          'action': 'reject',
        },
      );

      Logger.info('✅ Alternative decline method successful');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Alternative decline method failed', e);
      throw _handleDioException(e, 'decline friend request (alternative)');
    }
  }

  /// Get pending friend requests
  Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      Logger.info('📋 Fetching pending friend requests');
      
      final response = await _apiService.getData('/api/friends/pending');
      
      Logger.info('✅ Pending requests fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get pending requests failed', e);
      throw _handleDioException(e, 'get pending requests');
    }
  }

  /// Get friends list
  Future<Map<String, dynamic>> getFriendsList({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('👥 Fetching friends list (page: $page, limit: $limit)');
      
      final response = await _apiService.getData(
        '/api/friends/list',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      Logger.info('✅ Friends list fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friends list failed', e);
      throw _handleDioException(e, 'get friends list');
    }
  }

  /// Get friend suggestions
  Future<Map<String, dynamic>> getFriendSuggestions({
    int limit = 10,
    String criteria = 'all',
  }) async {
    try {
      Logger.info('💡 Fetching friend suggestions (limit: $limit)');
      
      final response = await _apiService.getData(
        '/api/friends/suggestions',
        queryParameters: {
          'limit': limit,
          'criteria': criteria,
        },
      );
      
      Logger.info('✅ Friend suggestions fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friend suggestions failed', e);
      throw _handleDioException(e, 'get friend suggestions');
    }
  }

  /// Search users
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🔍 Searching users: "$query" (page: $page, limit: $limit)');
      
      final response = await _apiService.getData(
        '/api/friends/search',
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );
      
      Logger.info('✅ User search completed successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Search users failed', e);
      throw _handleDioException(e, 'search users');
    }
  }

  /// Search all users globally (including friends, excluding self)
  Future<Map<String, dynamic>> searchAllUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🔍 Searching all users globally: "$query" (page: $page, limit: $limit)');
      
      final response = await _apiService.getData(
        '/api/friends/search-all',
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );

      // Robust null/empty check for users list
      final data = response['data'] ?? {};
      final usersList = data['users'];
      final users = (usersList is List ? usersList : []) as List;

      Logger.info('✅ Global user search completed successfully, users found: ${users.length}');
      return {
        'users': users,
        'total': data['total'] ?? users.length,
        'page': data['page'] ?? page,
        'totalPages': data['totalPages'] ?? 1,
      };
    } on DioException catch (e) {
      Logger.error('❌ Global search users failed', e);
      throw _handleDioException(e, 'search all users');
    }
  }

  /// Cancel sent friend request
  Future<Map<String, dynamic>> cancelFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('🚫 Cancelling friend request to: $userId');
      
      final response = await _apiService.deleteData(
        '/api/friends/request/$userId',
      );
      
      Logger.info('✅ Friend request cancelled successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Cancel friend request failed', e);
      throw _handleDioException(e, 'cancel friend request');
    }
  }

  /// Remove friend
  Future<Map<String, dynamic>> removeFriend({
    required String friendId,
  }) async {
    try {
      Logger.info('🗑️ Removing friend: $friendId');
      
      final response = await _apiService.deleteData(
        '/api/friends/$friendId',
      );
      
      Logger.info('✅ Friend removed successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Remove friend failed', e);
      throw _handleDioException(e, 'remove friend');
    }
  }

  /// Block user
  Future<Map<String, dynamic>> blockUser({
    required String userId,
  }) async {
    try {
      Logger.info('🚫 Blocking user: $userId');
      
      final response = await _apiService.postData(
        '/api/friends/block/$userId',
        data: {
          'action': 'block',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      Logger.info('✅ User blocked successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Block user failed', e);
      throw _handleDioException(e, 'block user');
    }
  }

  /// Get friendship statistics
  Future<Map<String, dynamic>> getFriendshipStats() async {
    try {
      Logger.info('📊 Fetching friendship statistics');
      
      final response = await _apiService.getData(
        '/api/friends/stats/overview',
      );
      
      Logger.info('✅ Friendship stats fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friendship stats failed', e);
      throw _handleDioException(e, 'get friendship stats');
    }
  }

  // ============================================================================
  // ENHANCED FRIEND MOOD ACTIVITY APIs
  // ============================================================================

  /// Get friend's moods with reactions
  Future<Map<String, dynamic>> getFriendMoods({
    required String friendId,
    int limit = 10,
    bool includeReactions = true,
  }) async {
    try {
      Logger.info('😊 Fetching moods for friend: $friendId');
      
      final response = await _apiService.getData(
        '/api/friends/$friendId/moods',
        queryParameters: {
          'limit': limit,
          'includeReactions': includeReactions,
        },
      );
      
      Logger.info('✅ Friend moods fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friend moods failed', e);
      throw _handleDioException(e, 'get friend moods');
    }
  }

  /// Get friend mood activity feed
  Future<Map<String, dynamic>> getFriendMoodActivityFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('📰 Fetching friend mood activity feed (page: $page)');
      
      final response = await _apiService.getData(
        '/api/friends/activity/feed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      Logger.info('✅ Friend mood activity feed fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friend mood activity feed failed', e);
      throw _handleDioException(e, 'get friend mood activity feed');
    }
  }

  /// Send mood reaction (hug, music, message, anonymous support)
  Future<Map<String, dynamic>> sendMoodReaction({
    required String moodId,
    required String reactionType,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info('💝 Sending $reactionType reaction to mood: $moodId');
      
      final response = await _apiService.postData(
        '/api/friends/moods/$moodId/reactions',
        data: {
          'reactionType': reactionType,
          if (message != null) 'message': message,
          'isAnonymous': isAnonymous,
        },
      );
      
      Logger.info('✅ Mood reaction sent successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Send mood reaction failed', e);
      throw _handleDioException(e, 'send mood reaction');
    }
  }

  /// Get friend mood insights and patterns
  Future<Map<String, dynamic>> getFriendMoodInsights({
    required String friendId,
    int days = 30,
  }) async {
    try {
      Logger.info('🧠 Fetching mood insights for friend: $friendId (${days} days)');
      
      final response = await _apiService.getData(
        '/api/friends/$friendId/insights',
        queryParameters: {
          'days': days,
        },
      );
      
      Logger.info('✅ Friend mood insights fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get friend mood insights failed', e);
      throw _handleDioException(e, 'get friend mood insights');
    }
  }

  // ============================================================================
  // EMOTION STORY SHARING APIs
  // ============================================================================

  /// Create emotion story
  Future<Map<String, dynamic>> createEmotionStory({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String privacy = 'friends',
    List<String>? tags,
    Map<String, dynamic>? settings,
  }) async {
    try {
      Logger.info('📖 Creating emotion story: $title');
      
      final response = await _apiService.postData(
        '/api/emotion-stories/',
        data: {
          'title': title,
          'description': description,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'privacy': privacy,
          if (tags != null) 'tags': tags,
          if (settings != null) 'settings': settings,
        },
      );
      
      Logger.info('✅ Emotion story created successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Create emotion story failed', e);
      throw _handleDioException(e, 'create emotion story');
    }
  }

  /// Get user's emotion stories
  Future<Map<String, dynamic>> getEmotionStories({
    int page = 1,
    int limit = 10,
    String status = 'all',
  }) async {
    try {
      Logger.info('📚 Fetching emotion stories (page: $page, status: $status)');
      
      final response = await _apiService.getData(
        '/api/emotion-stories/',
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': status,
        },
      );
      
      Logger.info('✅ Emotion stories fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get emotion stories failed', e);
      throw _handleDioException(e, 'get emotion stories');
    }
  }

  /// Invite friends to emotion story
  Future<Map<String, dynamic>> inviteToEmotionStory({
    required String storyId,
    required List<String> friendIds,
  }) async {
    try {
      Logger.info('📨 Inviting friends to emotion story: $storyId');
      
      final response = await _apiService.postData(
        '/api/emotion-stories/$storyId/invite',
        data: {
          'friendIds': friendIds,
        },
      );
      
      Logger.info('✅ Friends invited to emotion story successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Invite to emotion story failed', e);
      throw _handleDioException(e, 'invite to emotion story');
    }
  }

  /// Respond to emotion story invitation
  Future<Map<String, dynamic>> respondToEmotionStoryInvitation({
    required String storyId,
    required String action, // 'accept' or 'decline'
  }) async {
    try {
      Logger.info('📝 Responding to emotion story invitation: $storyId ($action)');
      
      final response = await _apiService.postData(
        '/api/emotion-stories/$storyId/respond',
        data: {
          'action': action,
        },
      );
      
      Logger.info('✅ Emotion story invitation response sent successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Respond to emotion story invitation failed', e);
      throw _handleDioException(e, 'respond to emotion story invitation');
    }
  }

  /// Add contribution to emotion story
  Future<Map<String, dynamic>> addEmotionStoryContribution({
    required String storyId,
    required String emotion,
    required int intensity,
    String? message,
    bool isAnonymous = false,
    Map<String, dynamic>? context,
    List<String>? tags,
    Map<String, dynamic>? media,
  }) async {
    try {
      Logger.info('✍️ Adding contribution to emotion story: $storyId');
      
      final response = await _apiService.postData(
        '/api/emotion-stories/$storyId/contributions',
        data: {
          'emotion': emotion,
          'intensity': intensity,
          if (message != null) 'message': message,
          'isAnonymous': isAnonymous,
          if (context != null) 'context': context,
          if (tags != null) 'tags': tags,
          if (media != null) 'media': media,
        },
      );
      
      Logger.info('✅ Emotion story contribution added successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Add emotion story contribution failed', e);
      throw _handleDioException(e, 'add emotion story contribution');
    }
  }

  /// Get emotion story contributions
  Future<Map<String, dynamic>> getEmotionStoryContributions({
    required String storyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('📖 Fetching contributions for emotion story: $storyId');
      
      final response = await _apiService.getData(
        '/api/emotion-stories/$storyId/contributions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      Logger.info('✅ Emotion story contributions fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get emotion story contributions failed', e);
      throw _handleDioException(e, 'get emotion story contributions');
    }
  }

  // ============================================================================
  // COMFORT REACTION APIs
  // ============================================================================

  /// Send comfort reaction to emotion
  Future<Map<String, dynamic>> sendComfortReaction({
    required String emotionId,
    required String reactionType,
    String? message,
  }) async {
    try {
      Logger.info('💝 Sending comfort reaction: $reactionType to emotion: $emotionId');
      
      final response = await _apiService.postData(
        '/api/comfort-reactions/emotions/$emotionId/reactions',
        data: {
          'reactionType': reactionType,
          if (message != null) 'message': message,
        },
      );
      
      Logger.info('✅ Comfort reaction sent successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Send comfort reaction failed', e);
      throw _handleDioException(e, 'send comfort reaction');
    }
  }

  /// Get reactions for emotion
  Future<Map<String, dynamic>> getEmotionReactions({
    required String emotionId,
  }) async {
    try {
      Logger.info('💝 Fetching reactions for emotion: $emotionId');
      
      final response = await _apiService.getData(
        '/api/comfort-reactions/emotions/$emotionId/reactions',
      );
      
      Logger.info('✅ Emotion reactions fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get emotion reactions failed', e);
      throw _handleDioException(e, 'get emotion reactions');
    }
  }

  /// Get user's reactions
  Future<Map<String, dynamic>> getUserReactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('💝 Fetching user reactions (page: $page)');
      
      final response = await _apiService.getData(
        '/api/comfort-reactions/my-reactions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      Logger.info('✅ User reactions fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get user reactions failed', e);
      throw _handleDioException(e, 'get user reactions');
    }
  }

  /// Mark reactions as read
  Future<Map<String, dynamic>> markReactionsAsRead({
    required List<String> reactionIds,
  }) async {
    try {
      Logger.info('✅ Marking reactions as read: ${reactionIds.length} reactions');
      
      final response = await _apiService.patchData(
        '/api/comfort-reactions/reactions/mark-read',
        data: {
          'reactionIds': reactionIds,
        },
      );
      
      Logger.info('✅ Reactions marked as read successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Mark reactions as read failed', e);
      throw _handleDioException(e, 'mark reactions as read');
    }
  }

  /// Get unread reactions count
  Future<Map<String, dynamic>> getUnreadReactionsCount() async {
    try {
      Logger.info('📊 Fetching unread reactions count');
      
      final response = await _apiService.getData(
        '/api/comfort-reactions/reactions/unread-count',
      );
      
      Logger.info('✅ Unread reactions count fetched successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Get unread reactions count failed', e);
      throw _handleDioException(e, 'get unread reactions count');
    }
  }

  /// DEBUGGING: Get detailed request info (for troubleshooting)
  Future<void> debugAcceptRequest(String requestUserId) async {
    try {
      Logger.info('🔍 DEBUG: Testing accept request for: $requestUserId');
      
      // Test different approaches
      final approaches = [
        {
          'method': 'POST',
          'url': '/api/friends/accept/$requestUserId',
          'data': {'action': 'accept', 'timestamp': DateTime.now().toIso8601String()},
        },
        {
          'method': 'POST',
          'url': '/api/friends/accept/$requestUserId',
          'data': {},
        },
        {
          'method': 'POST',
          'url': '/api/friends/respond',
          'data': {'requestUserId': requestUserId, 'action': 'accept'},
        },
      ];

      for (int i = 0; i < approaches.length; i++) {
        final approach = approaches[i];
        Logger.info('🧪 Testing approach ${i + 1}: ${approach['url']}');
        Logger.info('📦 Data: ${approach['data']}');
        
        try {
          final response = await _apiService.postData(
            approach['url'] as String,
            data: approach['data'] as Map<String, dynamic>?,
          );
          
          Logger.info('✅ Approach ${i + 1} SUCCESS: $response');
          return; // Success, stop testing
          
        } catch (e) {
          Logger.warning('❌ Approach ${i + 1} FAILED: $e');
        }
      }
      
      Logger.error('❌ All debugging approaches failed');
      
    } catch (e) {
      Logger.error('❌ Debug accept request failed', e);
    }
  }

  /// Handle DioException with proper error mapping
  Exception _handleDioException(DioException error, String operation) {
    Logger.error('💥 Dio error during $operation', error);
    Logger.error('📊 Status Code: ${error.response?.statusCode}');
    Logger.error('📄 Response Data: ${error.response?.data}');
    Logger.error('📤 Request Data: ${error.requestOptions.data}');
    Logger.error('🌐 Request URL: ${error.requestOptions.uri}');
    Logger.error('🔧 Request Headers: ${error.requestOptions.headers}');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          message: 'Request timeout during $operation: ${error.message}',
        );

      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Connection error during $operation: ${error.message}',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final responseData = error.response?.data;
        
        if (statusCode >= 500) {
          throw ServerException(
            message: 'Server error during $operation: HTTP $statusCode',
          );
        } else if (statusCode == 401) {
          throw UnauthorizedException(
            message: 'Unauthorized access during $operation',
          );
        } else if (statusCode == 403) {
          throw UnauthorizedException(
            message: 'Forbidden access during $operation',
          );
        } else if (statusCode == 400) {
          // Enhanced 400 error handling
          String errorMessage = 'Bad request during $operation';
          
          if (responseData is Map && responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          }
          
          throw ValidationException(
            message: errorMessage,
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            message: 'Resource not found during $operation',
          );
        } else {
          throw ServerException(
            message: 'HTTP error during $operation: $statusCode',
          );
        }

      case DioExceptionType.cancel:
        throw NetworkException(message: 'Request cancelled during $operation');

      case DioExceptionType.unknown:
      default:
        throw ServerException(
          message: 'Unknown error during $operation: ${error.message}',
        );
    }
  }

  /// Get friend's profile
  Future<Map<String, dynamic>> getFriendProfile({required String friendId}) async {
    try {
      Logger.info('👤 Fetching profile for friend: $friendId');
      final response = await _apiService.getData(
        '/api/user/profile',
        queryParameters: {'userId': friendId},
      );
      Logger.info('✅ Friend profile fetched successfully');
      return response;
    } on DioException catch (e) {
      Logger.error('❌ Get friend profile failed', e);
      throw _handleDioException(e, 'get friend profile');
    }
  }

  /// Get friend's last known location (from moods)
  Future<Map<String, dynamic>?> getFriendLocation({required String friendId}) async {
    try {
      Logger.info('📍 Fetching last known location for friend: $friendId');
      final response = await _apiService.getData(
        '/api/friends/$friendId/moods',
        queryParameters: {'limit': 1},
      );
      Logger.info('✅ Friend moods fetched for location');
      final moods = response['data']?['moods'] as List?;
      if (moods != null && moods.isNotEmpty) {
        final mood = moods.first as Map<String, dynamic>;
        return mood['location'] as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      Logger.error('❌ Get friend location failed', e);
      throw _handleDioException(e, 'get friend location');
    }
  }

  /// Send a message to a friend (if messaging API exists)
  Future<Map<String, dynamic>> sendMessageToFriend({required String friendId, required String message}) async {
    try {
      Logger.info('💬 Sending message to friend: $friendId');
      // If you have a messaging API, use it here. Example:
      final response = await _apiService.postData(
        '/api/messages/send',
        data: {
          'recipientId': friendId,
          'message': message,
        },
      );
      Logger.info('✅ Message sent successfully');
      return response;
    } on DioException catch (e) {
      Logger.error('❌ Send message to friend failed', e);
      throw _handleDioException(e, 'send message to friend');
    }
  }
}