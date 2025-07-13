// lib/core/network/api_service.dart - Fixed with PATCH method
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/network/api_response_handler.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;
  String? _authToken;

  // Cache for ongoing requests to prevent duplicates
  static final Map<String, Future<Response>> _ongoingRequests = {};

  // Cache for completed requests
  static final Map<String, CachedResponse> _responseCache = {};

  // Default cache duration
  static const Duration _defaultCacheDuration = Duration(minutes: 2);

  // In-memory mock profile storage for development
  static Map<String, dynamic> _mockProfileData = {
    'id': '1752133689047',
    'username': 'jois',
    'email': 'jois@gmail.com',
    'selectedAvatar': 'fox',
    'profile': {
      'displayName': 'jois',
      'bio': '',
      'isPrivate': false,
    },
    'stats': {
      'totalEntries': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'totalFriends': 0,
      'helpedFriends': 0,
      'level': 'New Explorer',
      'badgesEarned': 0,
      'favoriteEmotion': null,
      'emotionDiversity': 0,
    },
    'preferences': {
      'notificationsEnabled': true,
      'sharingEnabled': false,
      'language': 'English',
      'theme': 'Cosmic Purple',
      'darkModeEnabled': true,
      'privacySettings': {'shareLocation': false, 'anonymousMode': false, 'moodPrivacy': 'private'},
      'customSettings': {'reminderTime': '20:00', 'autoBackup': true},
    },
  };
  
  // Flag to track if mock data has been loaded from persistence
  static bool _mockDataLoaded = false;

  ApiService({required Dio dio}) {
    _dio = dio;
    _setupInterceptors();
    _loadMockDataFromStorage();
    
    // ✅ UPDATED: Optimized timeout configuration
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
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          Logger.error('❌ API Error: ${error.requestOptions.path}', error);

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

  // Load mock profile data from SharedPreferences
  Future<void> _loadMockDataFromStorage() async {
    if (_mockDataLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProfile = prefs.getString('mock_profile_data');
      
      if (savedProfile != null) {
        final Map<String, dynamic> savedData = Map<String, dynamic>.from(
          jsonDecode(savedProfile) as Map
        );
        _mockProfileData = savedData;
        Logger.info('🔧 Mock profile data loaded from storage: displayName=${_mockProfileData['profile']['displayName']}');
      } else {
        Logger.info('🔧 No saved mock profile data found, using defaults');
      }
      
      _mockDataLoaded = true;
    } catch (e) {
      Logger.error('❌ Error loading mock profile data', e);
      _mockDataLoaded = true; // Mark as loaded to avoid retrying
    }
  }

  // Save mock profile data to SharedPreferences
  Future<void> _saveMockDataToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_mockProfileData);
      await prefs.setString('mock_profile_data', jsonString);
      Logger.info('🔧 Mock profile data saved to storage: displayName=${_mockProfileData['profile']['displayName']}');
    } catch (e) {
      Logger.error('❌ Error saving mock profile data', e);
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      Logger.info('👤 Fetching user profile from backend...');

      final data = await getData('/api/user/profile');

      Logger.info('✅ Profile data received successfully');
      return data;
    } catch (e) {
      Logger.error('❌ Failed to fetch user profile', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      Logger.info('📝 Updating user profile...', profileData);

      final data = await putData('/api/user/profile', data: profileData);

      Logger.info('✅ Profile updated successfully');
      return data;
    } catch (e) {
      Logger.error('❌ Failed to update user profile', e);
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

      Logger.info('✅ Preferences updated successfully');
      return data;
    } catch (e) {
      Logger.error('❌ Failed to update user preferences', e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      Logger.info('🏆 Fetching user achievements...');

      final data = await getData('/api/user/achievements');

      // Simple fallback for development
      return <Map<String, dynamic>>[];
    } catch (e) {
      Logger.error('❌ Failed to fetch achievements', e);
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

      Logger.info('✅ Data export initiated successfully');
      return data;
    } catch (e) {
      Logger.error('❌ Failed to export user data', e);
      rethrow;
    }
  }

  /// Logout user - CRITICAL: This calls your backend logout endpoint
  Future<Map<String, dynamic>> logoutUser() async {
    try {
      Logger.info('🚪 Logging out user...');

      final data = await postData('/auth/logout');

      // Clear the auth token after successful logout
      clearAuthToken();

      Logger.info('✅ User logged out successfully');
      return data;
    } catch (e) {
      Logger.error('❌ Logout failed', e);
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

    // ✅ REMOVED: Mock fallback logic that was intercepting real errors
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
      // ✅ CRITICAL FIX: Always propagate real errors to auth layer
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
    // ✅ CRITICAL FIX: Never mock authentication registration or login
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
      '/auth/logout',
      '/auth/refresh',
      '/api/auth/logout', 
      '/onboarding/check-username',
      '/onboarding/steps',
      '/onboarding/user-data',
      '/onboarding/complete',
      '/api/user/profile', 
      '/api/user/preferences', 
      '/api/user/achievements', 
      '/api/user/export-data', 
      '/api/health',
      // ✅ CRITICAL: NEVER mock these endpoints - they must use real database data
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
      if (path.contains('/api/user/profile') && method.toUpperCase() == 'GET') {
        // Use stored mock profile data
        mockData = {
          'status': 'success',
          'message': 'Profile retrieved successfully',
          'data': {
            ..._mockProfileData,
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
            'joinDate': DateTime.now()
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'lastActive': DateTime.now().toIso8601String(),
          },
        };
      } else if (path.contains('/api/user/profile') &&
          method.toUpperCase() == 'PUT') {
        final requestData = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};
        
        // Update stored mock profile data
        if (requestData['name'] != null) {
          _mockProfileData['profile']['displayName'] = requestData['name'];
        }
        if (requestData['email'] != null) {
          _mockProfileData['email'] = requestData['email'];
        }
        if (requestData['avatar'] != null) {
          _mockProfileData['selectedAvatar'] = requestData['avatar'];
        }
        if (requestData['isPrivate'] != null) {
          _mockProfileData['profile']['isPrivate'] = requestData['isPrivate'];
        }
        
        // Save the updated data to storage (fire and forget)
        _saveMockDataToStorage().catchError((e) {
          Logger.error('❌ Failed to save mock data to storage', e);
        });
        
        mockData = {
          'status': 'success',
          'message': 'Profile updated successfully',
          'data': {
            ..._mockProfileData,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        };
      } else if (path.contains('/api/user/preferences') &&
          method.toUpperCase() == 'PUT') {
        final requestData = data is Map<String, dynamic>
            ? data
            : <String, dynamic>{};

        mockData = {
          'status': 'success',
          'message': 'Preferences updated successfully',
          'data': {
            'notificationsEnabled': requestData['notificationsEnabled'] ?? true,
            'sharingEnabled':
                requestData['dataSharingEnabled'] ??
                requestData['sharingEnabled'] ??
                false,
            'language': requestData['language'] ?? 'English',
            'theme': requestData['theme'] ?? 'Cosmic Purple',
            'darkModeEnabled': requestData['darkModeEnabled'] ?? true,
            'privacySettings':
                requestData['privacySettings'] ?? <String, dynamic>{},
            'customSettings':
                requestData['customSettings'] ?? <String, dynamic>{},
            'notifications': {
              'dailyReminder': requestData['notificationsEnabled'] ?? true,
              'friendRequests': requestData['notificationsEnabled'] ?? true,
              'comfortReactions': requestData['notificationsEnabled'] ?? true,
            },
            'shareLocation': false,
            'shareEmotions':
                requestData['dataSharingEnabled'] ??
                requestData['sharingEnabled'] ??
                false,
            'anonymousMode': false,
            'moodPrivacy': 'friends',
          },
        };
      } else if (path.contains('/api/user/achievements')) {
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
      } else if (path.contains('/auth/logout')) {
        mockData = {
          'status': 'success',
          'message': 'Logout successful',
          'data': {'timestamp': DateTime.now().toIso8601String()},
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

      Logger.info('🔧 Generated mock response for: $path');

      return Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    } catch (e) {
      Logger.error('❌ Error generating mock response', e);

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
}

class CachedResponse {
  final Response response;
  final DateTime timestamp;

  CachedResponse(this.response, this.timestamp);
}
