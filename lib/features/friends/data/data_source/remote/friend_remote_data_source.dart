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
      
      if (e.response?.statusCode == 429) {
        throw RateLimitException(
          message: e.response?.data['message'] ?? 'Rate limit exceeded',
          retryAfter: e.response?.data['retryAfter'] ?? 300,
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: e.response?.data['message'] ?? 'Invalid request',
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(
          message: e.response?.data['message'] ?? 'User not found',
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Server error',
        );
      } else {
        throw NetworkException(
          message: 'Network error: ${e.message}',
        );
      }
    } catch (e) {
      Logger.error('❌ Unexpected error in friend request', e);
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  /// Accept friend request
  Future<Map<String, dynamic>> acceptFriendRequest({
    required String requestUserId,
  }) async {
    try {
      Logger.info('✅ Accepting friend request from: $requestUserId');
      
      final response = await _apiService.postData(
        '/api/friends/respond',
        data: {
          'requestUserId': requestUserId,
          'action': 'accept',
        },
      );

      Logger.info('✅ Friend request accepted successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Accept friend request failed', e);
      throw _handleDioException(e, 'accept friend request');
    }
  }

  /// Decline friend request
  Future<Map<String, dynamic>> declineFriendRequest({
    required String requestUserId,
  }) async {
    try {
      Logger.info('❌ Declining friend request from: $requestUserId');
      
      final response = await _apiService.postData(
        '/api/friends/respond',
        data: {
          'requestUserId': requestUserId,
          'action': 'reject',
        },
      );

      Logger.info('✅ Friend request declined successfully');
      return response;
      
    } on DioException catch (e) {
      Logger.error('❌ Decline friend request failed', e);
      throw _handleDioException(e, 'decline friend request');
    }
  }

  /// Get pending friend requests
  Future<Map<String, dynamic>> getPendingRequests() async {
    try {
      Logger.info('📋 Fetching pending friend requests');
      
      final response = await _apiService.getData('/api/friends/requests');
      
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
      Logger.info('👥 Fetching friends list');
      
      final response = await _apiService.getData(
        '/api/friends',
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
      Logger.info('💡 Fetching friend suggestions');
      
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
      Logger.info('🔍 Searching users: $query');
      
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

  /// Cancel sent friend request
  Future<Map<String, dynamic>> cancelFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('❌ Cancelling friend request to: $userId');
      
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

  /// Handle DioException with proper error mapping
  Exception _handleDioException(DioException error, String operation) {
    Logger.error('❌ Dio error during $operation', error);

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
} 