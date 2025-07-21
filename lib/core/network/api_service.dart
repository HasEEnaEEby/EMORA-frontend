// lib/core/network/api_service.dart - Fixed with PATCH method
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/network/api_response_handler.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class ApiService {
  late Dio _dio;
  String? _authToken;

  // Cache for ongoing requests to prevent duplicates
  static final Map<String, Future<Response>> _ongoingRequests = {};

  // Cache for completed requests
  static final Map<String, CachedResponse> _responseCache = {};

  // Default cache duration
  static const Duration _defaultCacheDuration = Duration(minutes: 2);

  ApiService({required Dio dio}) {
    _dio = dio;
    _setupInterceptors();
    
    // . UPDATED: Optimized timeout configuration
    _dio.options.connectTimeout = Duration(seconds: 10);
    _dio.options.receiveTimeout = Duration(seconds: 45); // Increased for friend requests
    _dio.options.sendTimeout = Duration(seconds: 30);
  }

  void _setupInterceptors() {
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          if (AppConfig.enableNetworkLogging) {
            Logger.info('🌐 API Request: ${options.method} ${options.path}');
            if (options.data != null) {
              Logger.info('📤 Request Data: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (AppConfig.enableNetworkLogging) {
            Logger.info(
              '. API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          Logger.error('. API Error: ${error.requestOptions.path}', error);

          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            _authToken = null;
            Logger.warning('🔑 Token expired, user needs to re-authenticate');
          }

          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
    Logger.info('🔑 Auth token set');
  }

  void clearAuthToken() {
    _authToken = null;
    Logger.info('🔑 Auth token cleared');
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      Logger.info('. Fetching user profile from backend...');

      final data = await getData('/api/user/profile', forceRefresh: true);

      Logger.info('. Profile data received successfully');
      Logger.info('📊 Profile response structure: ${data.keys}');
      
      // Log the actual data structure for debugging
      if (data['data'] != null) {
        final profileData = data['data'] as Map<String, dynamic>;
        Logger.info('📊 Profile data keys: ${profileData.keys}');
        if (profileData['stats'] != null) {
          final stats = profileData['stats'] as Map<String, dynamic>;
          Logger.info('📊 Stats data: $stats');
        }
      }
      
      return data;
    } catch (e) {
      Logger.error('. Failed to fetch user profile', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      Logger.info('📝 Updating user profile...', profileData);

      final data = await patchData('/api/user/profile', data: profileData);

      Logger.info('. Profile updated successfully');
      return data;
    } catch (e) {
      Logger.error('. Failed to update user profile', e);
      rethrow;
    }
  }

  /// Update user preferences - CRITICAL: This matches your backend endpoint
  Future<Map<String, dynamic>> updateUserPreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      Logger.info('⚙️ Updating user preferences...', preferences);

      // Use PUT method as per your backend route
      final data = await putData('/api/user/preferences', data: preferences);

      Logger.info('. Preferences updated successfully');
      return data;
    } catch (e) {
      Logger.error('. Failed to update user preferences', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      Logger.info('🏆 Fetching user achievements...');

      final data = await getData('/api/user/achievements');
      
      if (data['success'] == true && data['data'] != null) {
        final achievements = data['data']['achievements'] as List<dynamic>?;
        return achievements?.cast<Map<String, dynamic>>() ?? [];
      }
      
      return <Map<String, dynamic>>[];
    } catch (e) {
      Logger.error('. Failed to fetch achievements', e);
      return <Map<String, dynamic>>[];
    }
  }

  String _generateCacheKey(
    String method,
    String path,
    Map<String, dynamic>? params,
  ) {
    if (params == null || params.isEmpty) {
      return '$method:$path';
    }

    final paramPairs = <String>[];
    params.forEach((key, value) {
      paramPairs.add('$key=$value');
    });

    final paramString = paramPairs.join('&');
    return '$method:$path?$paramString';
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData([List<String>? dataTypes]) async {
    try {
      Logger.info('📤 Exporting user data...', {'dataTypes': dataTypes});

      final requestData = {
        'dataTypes':
            dataTypes ?? ['profile', 'emotions', 'analytics', 'achievements'],
      };

      final data = await postData('/api/user/export-data', data: requestData);

      Logger.info('. Data export initiated successfully');
      return data;
    } catch (e) {
      Logger.error('. Failed to export user data', e);
      rethrow;
    }
  }

  /// Logout user - CRITICAL: This calls your backend logout endpoint
  Future<Map<String, dynamic>> logoutUser() async {
    try {
      Logger.info('🚪 Logging out user...');

      // Send empty JSON object to satisfy the backend's JSON validation
      final data = await postData('/api/auth/logout', data: {});

      // Clear the auth token after successful logout
      clearAuthToken();

      Logger.info('. User logged out successfully');
      return data;
    } catch (e) {
      Logger.error('. Logout failed', e);
      // Even if logout fails on server, clear local token
      clearAuthToken();
      rethrow;
    }
  }

  /// GET request with proper response handling and data extraction
  Future<Map<String, dynamic>> getData(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await get(
        path,
        queryParameters: queryParameters,
        cacheDuration: cacheDuration,
        forceRefresh: forceRefresh,
      );
      return ApiResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      throw ApiResponseHandler.handleDioException(e);
    }
  }

  /// POST request with proper response handling and data extraction
  Future<Map<String, dynamic>> postData(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      throw ApiResponseHandler.handleDioException(e);
    }
  }

  /// PUT request with proper response handling and data extraction
  Future<Map<String, dynamic>> putData(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      throw ApiResponseHandler.handleDioException(e);
    }
  }

  /// PATCH request with proper response handling and data extraction
  Future<Map<String, dynamic>> patchData(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return ApiResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      throw ApiResponseHandler.handleDioException(e);
    }
  }

  /// DELETE request with proper response handling and data extraction
  Future<Map<String, dynamic>> deleteData(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await delete(path, queryParameters: queryParameters);
      return ApiResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      throw ApiResponseHandler.handleDioException(e);
    }
  }

  // RAW HTTP METHODS (return Response objects directly)

  /// Raw GET request (returns Response directly)
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    return makeRequest(
      'GET',
      path,
      queryParameters: queryParameters,
      cacheDuration: cacheDuration,
      forceRefresh: forceRefresh,
    );
  }

  /// Raw POST request (returns Response directly)
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return makeRequest(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Raw PUT request (returns Response directly)
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return makeRequest(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Raw PATCH request (returns Response directly) - ADDED THIS METHOD
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return makeRequest(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Raw DELETE request (returns Response directly)
  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return makeRequest('DELETE', path, queryParameters: queryParameters);
  }

  Future<Response> makeRequest(
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(method, path, queryParameters);

    // Check cache first (unless force refresh or not GET request)
    if (method.toUpperCase() == 'GET' &&
        !forceRefresh &&
        _responseCache.containsKey(cacheKey)) {
      final cached = _responseCache[cacheKey]!;
      final maxAge = cacheDuration ?? _defaultCacheDuration;

      if (DateTime.now().difference(cached.timestamp) < maxAge) {
        Logger.info('📱 Using cached response for: $path');
        return cached.response;
      } else {
        // Remove expired cache
        _responseCache.remove(cacheKey);
      }
    }

    // Check if request is already in progress
    if (_ongoingRequests.containsKey(cacheKey)) {
      Logger.info('🔄 Request already in progress for: $path');
      return await _ongoingRequests[cacheKey]!;
    }

    // . REMOVED: Mock fallback logic that was intercepting real errors
    // Real authentication errors must propagate to the auth layer

    // Make new request
    final requestFuture = _performRequest(method, path, queryParameters, data);
    _ongoingRequests[cacheKey] = requestFuture;

    try {
      final response = await requestFuture;

      // Cache successful GET responses
      if (method.toUpperCase() == 'GET' && response.statusCode == 200) {
        _responseCache[cacheKey] = CachedResponse(response, DateTime.now());
      }

      return response;
    } catch (e) {
      // . CRITICAL FIX: Always propagate real errors to auth layer
      // No more mock fallback that hides 401 authentication errors
      rethrow;
    } finally {
      _ongoingRequests.remove(cacheKey);
    }
  }

  Future<Response> _performRequest(
    String method,
    String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await _dio.get(path, queryParameters: queryParameters);
      case 'POST':
        return await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
        );
      case 'PUT':
        return await _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
        );
      case 'PATCH': // ADDED PATCH SUPPORT
        return await _dio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
        );
      case 'DELETE':
        return await _dio.delete(path, queryParameters: queryParameters);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  bool _shouldMockEndpoint(String path) {
    // . CRITICAL FIX: Never mock authentication registration or login
    // These must show real errors to users for proper UX
    final criticalEndpoints = [
      '/api/auth/register',
      '/api/auth/login', 
      '/auth/register',
      '/auth/login',
      '/onboarding/register',
    ];
    
    // If it's a critical auth endpoint, never mock it
    if (criticalEndpoints.any((endpoint) => path.contains(endpoint))) {
      return false;
    }
    
    final mockEndpoints = [
      '/onboarding/check-username',
      '/onboarding/steps',
      '/onboarding/user-data',
      '/onboarding/complete',
      // . CRITICAL: Remove profile endpoints from mock list
      // '/api/user/profile', 
      // '/api/user/preferences', 
      '/api/user/achievements', 
      '/api/user/export-data', 
      '/api/health',
      // . CRITICAL: NEVER mock these endpoints - they must use real database data
      // '/api/user/home-data',
      // '/api/user/statistics', 
      // '/api/emotions/global-stats',
      // '/api/emotions/insights',
    ];

    return mockEndpoints.any((endpoint) => path.contains(endpoint));
  }

  Response _getMockResponse(String method, String path, dynamic data) {
    Map<String, dynamic> mockData = {};

    try {
      // . CRITICAL: Remove profile mock data - always use real API calls
      if (path.contains('/api/user/achievements')) {
        mockData = {
          'status': 'success',
          'message': 'Achievements retrieved successfully',
          'data': {
            'achievements': [
              {
                'id': 'first_steps',
                'title': 'First Steps',
                'description': 'Logged your first emotion',
                'icon': 'emoji_emotions',
                'color': '#10B981',
                'earned': false,
                'earnedDate': null,
                'requirement': 1,
                'progress': 0,
                'category': 'milestone',
              },
            ],
            'totalEarned': 0,
            'totalAvailable': 1,
          },
        };
      } else if (path.contains('/api/user/export-data')) {
        final dataTypes =
            data is Map<String, dynamic> && data['dataTypes'] is List
            ? data['dataTypes'] as List<String>
            : <String>['profile', 'emotions', 'analytics', 'achievements'];

        mockData = {
          'status': 'success',
          'message':
              'Data export generated successfully. Processing will complete within 24 hours.',
          'data': {
            'exportId': 'export_test_${DateTime.now().millisecondsSinceEpoch}',
            'estimatedSize': 5,
            'estimatedCompletion': DateTime.now()
                .add(const Duration(hours: 24))
                .toIso8601String(),
            'dataTypes': dataTypes,
          },
        };
      } else if (path.contains('/onboarding/check-username')) {
        // Extract username from path
        final usernameMatch = RegExp(r'/onboarding/check-username/(.+)').firstMatch(path);
        final username = usernameMatch?.group(1) ?? 'unknown';
        
        // Check if username is in reserved list or matches common test patterns
        final reservedUsernames = [
          'admin', 'administrator', 'root', 'moderator', 'support', 'help',
          'api', 'www', 'mail', 'email', 'system', 'service', 'emora',
          'official', 'staff', 'team', 'bot', 'null', 'undefined', 'test', 'demo'
        ];
        
        final isReserved = reservedUsernames.contains(username.toLowerCase());
        final isAvailable = !isReserved;
        
        mockData = {
          'status': 'success',
          'message': 'Username availability checked',
          'data': {
            'username': username,
            'isAvailable': isAvailable,
            'suggestions': isAvailable ? [] : [
              '${username}_${DateTime.now().millisecondsSinceEpoch % 1000}',
              '${username}${DateTime.now().year}',
              'user_${username}',
            ],
            'message': isAvailable 
                ? 'Username is available' 
                : 'Username is already taken',
          },
        };
      } else {
        // Call existing mock logic for other endpoints
        mockData = {
          'status': 'success',
          'message': 'Mock response for development',
          'data': <String, dynamic>{},
        };
      }

      Logger.info('. Generated mock response for: $path');

      return Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    } catch (e) {
      Logger.error('. Error generating mock response', e);

      final fallbackData = {
        'status': 'success',
        'message': 'Fallback mock response',
        'data': <String, dynamic>{},
      };

      return Response(
        data: fallbackData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    }
  }

  void clearCache() {
    _responseCache.clear();
    _ongoingRequests.clear();
    Logger.info('🗑️ API cache cleared');
  }

  void clearExpiredCache() {
    final now = DateTime.now();
    _responseCache.removeWhere(
      (key, cached) => now.difference(cached.timestamp) > _defaultCacheDuration,
    );
  }

  // Get cache statistics
  Map<String, int> getCacheStats() {
    return {
      'cachedResponses': _responseCache.length,
      'ongoingRequests': _ongoingRequests.length,
    };
  }

  /// 🔧 NEW: Get user's emotion entries for stats calculation
  Future<Map<String, dynamic>> getUserEmotionEntries(String userId) async {
    try {
      final response = await _dio.get(
        '/api/user/emotions',
        queryParameters: {
          'userId': userId,
          'limit': 1000,
          'includeDeleted': false,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('❌ Error fetching user emotion entries: $e');
      return {'entries': [], 'total': 0};
    }
  }

  /// 🔧 NEW: Get user's friends for stats calculation
  Future<Map<String, dynamic>> getUserFriends(String userId) async {
    try {
      final response = await _dio.get(
        '/api/user/friends',
        queryParameters: {
          'userId': userId,
          'status': 'accepted',
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('❌ Error fetching user friends: $e');
      return {'friends': [], 'total': 0};
    }
  }

  /// 🔧 NEW: Get support given by user for stats calculation
  Future<Map<String, dynamic>> getUserSupportGiven(String userId) async {
    try {
      final response = await _dio.get(
        '/api/user/support-given',
        queryParameters: {
          'userId': userId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('❌ Error fetching user support data: $e');
      return {
        'helpedFriendsCount': 0,
        'comfortReactionsGiven': 0,
        'supportMessagesCount': 0,
      };
    }
  }

  /// 🔧 NEW: Get comprehensive user stats in a single call
  Future<Map<String, dynamic>> getUserComprehensiveStats(String userId) async {
    try {
      final response = await _dio.get(
        '/api/user/stats/comprehensive',
        queryParameters: {
          'userId': userId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.error('❌ Error fetching comprehensive user stats: $e');
      return {
        'totalEntries': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'favoriteEmotion': null,
        'totalFriends': 0,
        'helpedFriends': 0,
        'badgesEarned': 0,
        'level': 'New Explorer',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 🔧 NEW: Get user profile with comprehensive stats
  Future<Map<String, dynamic>> getUserProfileWithStats() async {
    try {
      Logger.info('🔄 Fetching user profile with stats from backend...');

      // Use the same endpoint as getUserProfile since the backend already includes stats
      final data = await getData('/api/user/profile', forceRefresh: true);

      Logger.info('✅ Profile with stats data received successfully');
      Logger.info('📊 Full response structure: ${data.keys}');
      
      // Log the stats data for debugging
      if (data['data'] != null) {
        final profileData = data['data'] as Map<String, dynamic>;
        Logger.info('📊 Profile data keys: ${profileData.keys}');
        
        if (profileData['stats'] != null) {
          final stats = profileData['stats'] as Map<String, dynamic>;
          Logger.info('📊 Stats data: $stats');
          Logger.info('📊 Total entries: ${stats['totalEntries']}');
          Logger.info('📊 Current streak: ${stats['currentStreak']}');
          Logger.info('📊 Longest streak: ${stats['longestStreak']}');
        } else {
          Logger.warning('⚠️ No stats data found in profile response');
        }
      }
      
      return data;
    } catch (e) {
      Logger.error('❌ Failed to fetch user profile with stats', e);
      rethrow;
    }
  }

  /// 🔧 NEW: Get comprehensive user stats
  Future<Map<String, dynamic>> getComprehensiveStats() async {
    try {
      Logger.info('🔄 Fetching comprehensive stats from backend...');

      final data = await getData('/api/user/stats/comprehensive', forceRefresh: true);

      Logger.info('✅ Comprehensive stats data received successfully');
      Logger.info('📊 Stats response: $data');
      
      return data;
    } catch (e) {
      Logger.error('❌ Failed to fetch comprehensive stats', e);
      rethrow;
    }
  }
}

class CachedResponse {
  final Response response;
  final DateTime timestamp;

  CachedResponse(this.response, this.timestamp);
}
