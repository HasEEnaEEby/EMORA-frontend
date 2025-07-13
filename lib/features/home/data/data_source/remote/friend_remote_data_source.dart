import 'package:emora_mobile_app/core/network/dio_client.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/friend_model.dart';
import '../../../presentation/view_model/bloc/friend_state.dart' as friend_exceptions;

abstract class FriendRemoteDataSource {
  Future<List<FriendSuggestionModel>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<bool> sendFriendRequest({
    required String userId,
  });

  Future<bool> respondToFriendRequest({
    required String requestUserId,
    required String action,
  });

  Future<List<FriendModel>> getFriends({
    int page = 1,
    int limit = 20,
  });

  Future<Map<String, List<FriendRequestModel>>> getPendingRequests();

  Future<bool> cancelFriendRequest({
    required String userId,
  });

  Future<bool> removeFriend({
    required String friendUserId,
  });

  Future<List<FriendSuggestionModel>> getFriendSuggestions({
    int limit = 10,
  });
}

class FriendRemoteDataSourceImpl implements FriendRemoteDataSource {
  final ApiService apiService;

  FriendRemoteDataSourceImpl({
    required this.apiService,
    required DioClient dioClient,
  });

  @override
  Future<List<FriendSuggestionModel>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🌐 Searching users: $query');

      final response = await apiService.get(
        '/api/friends/search',
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final usersData = dataObject['users'] as List? ?? [];
          final users = usersData
              .map((userData) => FriendSuggestionModel.fromJson(userData))
              .toList();

          Logger.info('✅ Found ${users.length} users');
          return users;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to search users',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Search endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error searching users', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> sendFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('🌐 Sending friend request to: $userId');

      final response = await apiService.post(
        '/api/friends/request/$userId',
        data: {}, // Always send at least an empty JSON object
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Friend request sent successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 400) {
        final errorMessage = response.data['message'] ?? 'Bad request';
        if (errorMessage.contains('already sent')) {
          throw friend_exceptions.DuplicateFriendRequestException(message: 'Friend request already sent');
        } else if (errorMessage.contains('Already friends')) {
          throw friend_exceptions.FriendRequestException(message: 'Already friends with this user');
        } else {
          throw ServerException(message: errorMessage);
        }
      } else if (response.statusCode == 429) {
        throw friend_exceptions.RateLimitException(message: response.data['message'] ?? 'Too many requests');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Friend request endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for sending friend request',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on friend_exceptions.RateLimitException {
      rethrow;
    } on friend_exceptions.TimeoutException {
      rethrow;
    } catch (e) {
      Logger.error('❌ Error sending friend request', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      if (e.toString().contains('TimeoutException')) {
        throw friend_exceptions.TimeoutException(message: 'Request timed out. Please try again.');
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> respondToFriendRequest({
    required String requestUserId,
    required String action,
  }) async {
    try {
      Logger.info('🌐 Responding to friend request: $action');

      final endpoint = action == 'accept' 
          ? '/api/friends/accept/$requestUserId'
          : '/api/friends/decline/$requestUserId';

      final response = await apiService.post(endpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Friend request response sent successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 429) {
        throw friend_exceptions.RateLimitException(message: response.data['message'] ?? 'Too many requests');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Friend response endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for responding to friend request',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on friend_exceptions.RateLimitException {
      rethrow;
    } on friend_exceptions.TimeoutException {
      rethrow;
    } catch (e) {
      Logger.error('❌ Error responding to friend request', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      if (e.toString().contains('TimeoutException')) {
        throw friend_exceptions.TimeoutException(message: 'Request timed out. Please try again.');
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<FriendModel>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('🌐 Fetching friends list');

      final response = await apiService.get(
        '/api/friends/list',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final friendsData = dataObject['friends'] as List? ?? [];
          // Always return a typed list, even if empty
          final friends = (friendsData as List)
              .map((friendData) => FriendModel.fromJson(friendData))
              .whereType<FriendModel>()
              .toList();
          Logger.info('✅ Found  ${friends.length} friends');
          return friends;
        } else {
          // Return an empty typed list if no data
          return <FriendModel>[];
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Friends list endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching friends', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, List<FriendRequestModel>>> getPendingRequests() async {
    try {
      Logger.info('🌐 Fetching pending friend requests');

      final response = await apiService.get('/api/friends/pending');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final requestsData = responseData['data'] as Map<String, dynamic>;
          
          final sentRequests = <FriendRequestModel>[];
          final receivedRequests = <FriendRequestModel>[];
          
          // Parse sent requests with error handling
          if (requestsData['sent'] is List) {
            for (final reqData in requestsData['sent'] as List) {
              try {
                final request = FriendRequestModel.fromJson(reqData as Map<String, dynamic>);
                if (request.userId.isNotEmpty) {
                  sentRequests.add(request);
                } else {
                  Logger.warning('⚠️ Skipping sent request with empty userId');
                }
              } catch (e) {
                Logger.warning('⚠️ Failed to parse sent request: $e');
              }
            }
          }
          
          // Parse received requests with error handling
          if (requestsData['received'] is List) {
            for (final reqData in requestsData['received'] as List) {
              try {
                final request = FriendRequestModel.fromJson(reqData as Map<String, dynamic>);
                if (request.userId.isNotEmpty) {
                  receivedRequests.add(request);
                } else {
                  Logger.warning('⚠️ Skipping received request with empty userId');
                }
              } catch (e) {
                Logger.warning('⚠️ Failed to parse received request: $e');
              }
            }
          }

          Logger.info('✅ Found ${sentRequests.length} sent, ${receivedRequests.length} received requests');
          
          return {
            'sent': sentRequests,
            'received': receivedRequests,
          };
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get pending requests',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Pending requests endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching pending requests', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> cancelFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('🌐 Cancelling friend request to: $userId');
      print('🔍 cancelFriendRequest - userId: $userId');
      print('🔍 cancelFriendRequest - userId length: ${userId.length}');
      print('🔍 cancelFriendRequest - userId isEmpty: ${userId.isEmpty}');

      // Validate userId
      if (userId.isEmpty) {
        throw ServerException(message: 'User ID cannot be empty for friend request cancellation');
      }

      final response = await apiService.delete(
        '/api/friends/request/$userId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Friend request cancelled successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Cancel friend request endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for cancelling friend request',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error cancelling friend request', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> removeFriend({
    required String friendUserId,
  }) async {
    try {
      Logger.info('🌐 Removing friend: $friendUserId');

      final response = await apiService.delete(
        '/api/friends/$friendUserId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('✅ Friend removed successfully');
          return true;
        } else {
          Logger.warning(
            '⚠️ Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Remove friend endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for removing friend',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error removing friend', e);
      if (e is ServerException || e is NotFoundException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<FriendSuggestionModel>> getFriendSuggestions({
    int limit = 10,
  }) async {
    try {
      Logger.info('🌐 Fetching friend suggestions');

      final response = await apiService.get(
        '/api/friends/suggestions',
        queryParameters: {
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final dataObject = responseData['data'] as Map<String, dynamic>;
          final suggestionsData = dataObject['suggestions'] as List? ?? [];
          final suggestions = suggestionsData
              .map((suggestionData) => FriendSuggestionModel.fromJson(suggestionData))
              .toList();

          Logger.info('✅ Found ${suggestions.length} friend suggestions');
          return suggestions;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get friend suggestions',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Friend suggestions endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching friend suggestions', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
} 