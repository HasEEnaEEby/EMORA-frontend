import 'package:emora_mobile_app/core/network/dio_client.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/friend_model.dart';
import '../../../presentation/view_model/bloc/friend_state.dart' as friend_exceptions;

abstract class FriendRemoteDataSource {
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<Map<String, dynamic>> searchAllUsers({
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
  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🔍 Searching users: "$query"');

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
          final suggestionsData = dataObject['suggestions'] as List? ?? [];
          final total = dataObject['total'] as int? ?? suggestionsData.length;
          final suggestions = suggestionsData
              .map((userData) => FriendSuggestionModel.fromJson(userData))
              .toList();

          Logger.info('✅ Found ${suggestions.length} users');
          return {
            'suggestions': suggestions,
            'total': total,
          };
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to search users',
          );
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error searching users', e);
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> searchAllUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🔍 Searching all users: "$query"');

      final response = await apiService.get(
        '/api/friends/search-all',
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
          final total = dataObject['total'] as int? ?? usersData.length;
          final suggestions = usersData
              .map((userData) => FriendSuggestionModel.fromJson(userData))
              .toList();

          Logger.info('✅ Found ${suggestions.length} users');
          return {
            'suggestions': suggestions,
            'total': total,
          };
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to search all users',
          );
        }
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error searching all users', e);
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> sendFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('📤 Sending friend request to: $userId');

      final response = await apiService.post(
        '/api/friends/request/$userId',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          Logger.info('✅ Friend request sent successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('❌ Error sending friend request', e);
      throw ServerException(message: 'Failed to send friend request');
    }
  }

  @override
  Future<bool> respondToFriendRequest({
    required String requestUserId,
    required String action,
  }) async {
    try {
      Logger.info('📨 Responding to friend request: $action for $requestUserId');

      // FIXED: Use the correct endpoint that works
      final response = await apiService.post(
        '/api/friends/respond',
        data: {
          'requestUserId': requestUserId,
          'action': action,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          Logger.info('✅ Friend request $action successful');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('❌ Error responding to friend request', e);
      throw ServerException(message: 'Failed to respond to friend request');
    }
  }

  @override
  Future<List<FriendModel>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('👥 Fetching friends list');

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
          final friends = (friendsData as List)
              .map((friendData) => FriendModel.fromJson(friendData))
              .whereType<FriendModel>()
              .toList();
          Logger.info('✅ Found ${friends.length} friends');
          return friends;
        }
      }
      return <FriendModel>[];
    } catch (e) {
      Logger.error('❌ Error fetching friends', e);
      return <FriendModel>[];
    }
  }

  @override
  Future<Map<String, List<FriendRequestModel>>> getPendingRequests() async {
    try {
      Logger.info('📋 Fetching pending friend requests');

      final response = await apiService.get('/api/friends/pending');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final requestsData = responseData['data'] as Map<String, dynamic>;
          
          final sentRequests = <FriendRequestModel>[];
          final receivedRequests = <FriendRequestModel>[];
          
          // Parse sent requests
          if (requestsData['sent'] is List) {
            for (final reqData in requestsData['sent'] as List) {
              try {
                final request = FriendRequestModel.fromJson(reqData as Map<String, dynamic>);
                if (request.userId.isNotEmpty) {
                  sentRequests.add(request);
                }
              } catch (e) {
                Logger.warning('⚠️ Failed to parse sent request: $e');
              }
            }
          }
          
          // Parse received requests
          if (requestsData['received'] is List) {
            for (final reqData in requestsData['received'] as List) {
              try {
                final request = FriendRequestModel.fromJson(reqData as Map<String, dynamic>);
                if (request.userId.isNotEmpty) {
                  receivedRequests.add(request);
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
        }
      }
      return {
        'sent': <FriendRequestModel>[],
        'received': <FriendRequestModel>[],
      };
    } catch (e) {
      Logger.error('❌ Error fetching pending requests', e);
      return {
        'sent': <FriendRequestModel>[],
        'received': <FriendRequestModel>[],
      };
    }
  }

  @override
  Future<bool> cancelFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('🚫 Cancelling friend request to: $userId');

      if (userId.isEmpty) {
        throw ServerException(message: 'User ID cannot be empty');
      }

      final response = await apiService.delete(
        '/api/friends/request/$userId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          Logger.info('✅ Friend request cancelled successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('❌ Error cancelling friend request', e);
      throw ServerException(message: 'Failed to cancel friend request');
    }
  }

  @override
  Future<bool> removeFriend({
    required String friendUserId,
  }) async {
    try {
      Logger.info('🗑️ Removing friend: $friendUserId');

      final response = await apiService.delete(
        '/api/friends/$friendUserId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          Logger.info('✅ Friend removed successfully');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('❌ Error removing friend', e);
      throw ServerException(message: 'Failed to remove friend');
    }
  }

  @override
  Future<List<FriendSuggestionModel>> getFriendSuggestions({
    int limit = 10,
  }) async {
    try {
      Logger.info('💡 Fetching friend suggestions');

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
        }
      }
      return <FriendSuggestionModel>[];
    } catch (e) {
      Logger.error('❌ Error fetching friend suggestions', e);
      return <FriendSuggestionModel>[];
    }
  }
}