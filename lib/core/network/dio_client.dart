// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class DioClient {
  late Dio _dio;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // EMORA Backend Configuration
  static const String _baseUrl = 'http://localhost:8000';
  static const Duration _connectTimeout = Duration(seconds: 60);
  static const Duration _receiveTimeout = Duration(seconds: 60);
  static const Duration _sendTimeout = Duration(seconds: 60);

  // Cache for responses
  final Map<String, CachedResponse> _cache = {};
  static const Duration _defaultCacheDuration = Duration(minutes: 5);

  DioClient._() {
    _dio = Dio();
    _initializeAsync();
  }

  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  factory DioClient.create() => instance;

  Dio get dio => _dio;

  // . FIXED: Ensure proper async initialization
  Future<void> _initializeAsync() async {
    try {
      await _initPrefs();
      _setupDio();
      _isInitialized = true;
      if (kDebugMode) {
        print('. DioClient initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('. DioClient initialization failed: $e');
      }
    }
  }

  // . FIXED: Wait for initialization before any operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initializeAsync();
    }
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      sendTimeout: _sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _createAuthInterceptor(),
      _createLoggingInterceptor(),
      _createErrorInterceptor(),
      _createRetryInterceptor(),
    ]);
  }

  // Auth Interceptor - adds JWT token to requests
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // . FIXED: Ensure initialization before token operations
        await _ensureInitialized();
        
        // Add auth token if available
        final token = _getStoredToken();
        if (kDebugMode) {
          print('🔑 Auth interceptor - Token available: ${token != null}');
          if (token != null) {
            print('🔑 Token: ${token.substring(0, 20)}...');
          }
        }
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - clear stored token
          await _clearStoredToken();
          if (kDebugMode) {
            print('🔑 Token expired or invalid, cleared stored token');
          }
        }
        handler.next(error);
      },
    );
  }

  // Logging Interceptor - logs requests and responses in debug mode
  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🚀 REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📤 DATA: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            print('. QUERY: ${options.queryParameters}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
            '. RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          print('📥 DATA: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print(
            '. ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          print('💥 MESSAGE: ${error.message}');
          if (error.response?.data != null) {
            print('📥 ERROR DATA: ${error.response?.data}');
          }
        }
        handler.next(error);
      },
    );
  }

  // Error Interceptor - handles common errors
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Handle common errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          error = error.copyWith(
            message:
                'Connection timeout. Please check your internet connection.',
          );
        } else if (error.type == DioExceptionType.connectionError) {
          error = error.copyWith(
            message: 'No internet connection. Please check your network.',
          );
        } else if (error.response?.statusCode == 404) {
          error = error.copyWith(message: 'Resource not found on server.');
        } else if (error.response?.statusCode == 500) {
          error = error.copyWith(
            message: 'Server error. Please try again later.',
          );
        }
        handler.next(error);
      },
    );
  }

  // Retry Interceptor - retries failed requests
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          if (kDebugMode) {
            print('🔄 Retrying request: ${error.requestOptions.uri}');
          }

          try {
            // Wait before retry
            await Future.delayed(const Duration(milliseconds: 1000));

            // Retry the request
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
            if (kDebugMode) {
              print('. Retry failed: $e');
            }
          }
        }
        handler.next(error);
      },
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.response?.statusCode == 502 ||
        error.response?.statusCode == 503 ||
        error.response?.statusCode == 504;
  }

  // Cache management methods
  String _getCacheKey(
    String method,
    String path,
    Map<String, dynamic>? queryParams,
  ) {
    final query =
        queryParams?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return '$method:$path:$query';
  }

  bool _isCacheValid(CachedResponse cachedResponse) {
    return DateTime.now().isBefore(cachedResponse.expiresAt);
  }

  void _setCacheResponse(
    String cacheKey,
    Response response,
    Duration cacheDuration,
  ) {
    _cache[cacheKey] = CachedResponse(
      response: response,
      expiresAt: DateTime.now().add(cacheDuration),
    );
  }

  Response? _getCachedResponse(String cacheKey, bool forceRefresh) {
    if (forceRefresh) return null;

    final cachedResponse = _cache[cacheKey];
    if (cachedResponse != null && _isCacheValid(cachedResponse)) {
      if (kDebugMode) {
        print('📦 Using cached response for: $cacheKey');
      }
      return cachedResponse.response;
    }
    return null;
  }

  // Enhanced API Methods

  // Auth endpoints
  Future<Response> checkUsernameAvailability(String username) async {
    return await _makeRequest(
      'POST',
      '/api/auth/check-username',
      data: {'username': username},
    );
  }

  Future<Response> register({
    required String email,
    required String password,
    required String name,
    Map<String, dynamic>? deviceInfo,
  }) async {
    return await _makeRequest(
      'POST',
      '/api/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'deviceInfo': deviceInfo,
      },
    );
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _makeRequest(
      'POST',
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> logout() async {
    return await _makeRequest('POST', '/api/auth/logout');
  }

  Future<Response> getCurrentUser() async {
    return await _makeRequest(
      'GET',
      '/api/auth/me',
      cacheDuration: const Duration(minutes: 5),
    );
  }

  // Emotion endpoints with caching
  Future<Response> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    Map<String, dynamic>? context,
    Map<String, dynamic>? memory,
    Map<String, dynamic>? location,
    Map<String, dynamic>? globalSharing,
    String source = 'mobile',
    Map<String, dynamic>? emotionData,
  }) async {
    return await _makeRequest(
      'POST',
      '/api/emotions/users/$userId/log',
      data: {
        'emotion': emotion,
        'intensity': intensity,
        'context': context,
        'memory': memory,
        'location': location,
        'globalSharing': globalSharing,
        'source': source,
        'timestamp': DateTime.now().toIso8601String(),
        if (emotionData != null) ...emotionData,
      },
    );
  }

  Future<Response> getEmotionJourney({
    required String userId,
    int days = 30,
    String format = 'unified',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/journey',
      queryParameters: {'days': days, 'format': format},
      cacheDuration: const Duration(minutes: 10),
    );
  }

  Future<Response> getGlobalEmotionStats({String timeframe = '24h'}) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/global-stats',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> getGlobalEmotionHeatmap({
    Map<String, dynamic>? bounds,
    String format = 'unified',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/global-heatmap',
      queryParameters: {'format': format, if (bounds != null) ...bounds},
      cacheDuration: const Duration(minutes: 10),
    );
  }

  Future<Response> getEmotionFeed({
    int limit = 10,
    int offset = 0,
    String? emotion,
    String format = 'unified',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/feed',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'format': format,
        if (emotion != null) 'emotion': emotion,
      },
      cacheDuration: const Duration(minutes: 3),
    );
  }

  Future<Response> submitVentingSession({
    required String sessionId,
    required int duration,
    required String emotionBefore,
    String? emotionAfter,
    Map<String, double>? intensity,
    String? thoughts,
  }) async {
    return await _makeRequest(
      'POST',
      '/api/emotions/vent',
      data: {
        'sessionId': sessionId,
        'duration': duration,
        'emotionBefore': emotionBefore,
        'emotionAfter': emotionAfter,
        'intensity': intensity,
        'thoughts': thoughts,
      },
    );
  }

  Future<Response> getUserEmotionInsights({
    required String userId,
    String timeframe = '30d',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/insights',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> getUserInsights({
    required String userId,
    String timeframe = '30d',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/insights',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> getUserAnalytics({
    required String userId,
    String timeframe = '7d',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/analytics',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> getUserEmotionAnalytics({
    required String userId,
    String timeframe = '30d',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/analytics',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> getUserMusicRecommendations({
    required String userId,
    String? mood,
    String? time,
    String? weather,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (mood != null) queryParameters['mood'] = mood;
    if (time != null) queryParameters['time'] = time;
    if (weather != null) queryParameters['weather'] = weather;
    return await _makeRequest(
      'GET',
      '/api/recommendations/users/$userId/music',
      queryParameters: queryParameters,
      cacheDuration: const Duration(minutes: 3),
    );
  }

  Future<Response> getUserEmotionStats(
    String userId, {
    String timeframe = '30d',
  }) async {
    return await _makeRequest(
      'GET',
      '/api/emotions/users/$userId/stats',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: const Duration(minutes: 5),
    );
  }

  Future<Response> updateEmotion({
    required String emotionId,
    String? emotion,
    double? intensity,
    Map<String, dynamic>? memory,
  }) async {
    final data = <String, dynamic>{};
    if (emotion != null) data['emotion'] = emotion;
    if (intensity != null) data['intensity'] = intensity;
    if (memory != null) data['memory'] = memory;

    return await _makeRequest('PUT', '/api/emotions/$emotionId', data: data);
  }

  Future<Response> deleteEmotion(String emotionId) async {
    return await _makeRequest('DELETE', '/api/emotions/$emotionId');
  }

  // Health and monitoring endpoints
  Future<Response> healthCheck() async {
    return await _makeRequest(
      'GET',
      '/api/health',
      cacheDuration: const Duration(minutes: 1),
    );
  }

  Future<Response> getSystemStatus() async {
    return await _makeRequest(
      'GET',
      '/api/status',
      cacheDuration: const Duration(minutes: 2),
    );
  }

  Future<Response> getApiVersion() async {
    return await _makeRequest(
      'GET',
      '/api/version',
      cacheDuration: const Duration(minutes: 30),
    );
  }

  // Core request method
  Future<Response> _makeRequest(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Duration? cacheDuration,
    bool forceRefresh = false,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    // Check cache for GET requests
    if (method.toUpperCase() == 'GET' && cacheDuration != null) {
      final cacheKey = _getCacheKey(method, path, queryParameters);
      final cachedResponse = _getCachedResponse(cacheKey, forceRefresh);
      if (cachedResponse != null) {
        return cachedResponse;
      }
    }

    // Make the request
    late Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case 'POST':
        response = await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case 'PUT':
        response = await _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case 'DELETE':
        response = await _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case 'PATCH':
        response = await _dio.patch(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    // Cache successful GET responses
    if (method.toUpperCase() == 'GET' &&
        cacheDuration != null &&
        response.statusCode == 200) {
      final cacheKey = _getCacheKey(method, path, queryParameters);
      _setCacheResponse(cacheKey, response, cacheDuration);
    }

    return response;
  }

  // Enhanced Generic HTTP methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    return await _makeRequest(
      'GET',
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      cacheDuration: cacheDuration,
      forceRefresh: forceRefresh,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _makeRequest(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _makeRequest(
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _makeRequest(
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _makeRequest(
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Token management
  // . FIXED: Make token operations async and wait for initialization
  String? _getStoredToken() {
    try {
      return _prefs?.getString(AppConfig.authTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting stored token: $e');
      }
      return null;
    }
  }

  Future<void> _clearStoredToken() async {
    try {
      await _ensureInitialized();
      await _prefs?.remove(AppConfig.authTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing stored token: $e');
      }
    }
  }

  Future<void> setAuthToken(String token) async {
    try {
      await _ensureInitialized();
      await _prefs?.setString(AppConfig.authTokenKey, token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        print('🔑 Auth token set successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting auth token: $e');
      }
    }
  }

  Future<void> clearAuthToken() async {
    _dio.options.headers.remove('Authorization');
    await _clearStoredToken();
    if (kDebugMode) {
      print('🔑 Auth token cleared');
    }
  }

  String? getAuthToken() {
    return _getStoredToken();
  }

  bool get hasAuthToken {
    return _getStoredToken() != null;
  }

  // Cache management methods
  void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      print('🗑️ DioClient cache cleared');
    }
  }

  void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => now.isAfter(value.expiresAt));
    if (kDebugMode) {
      print('🧹 Expired cache cleared');
    }
  }

  Map<String, int> getCacheStats() {
    final now = DateTime.now();
    final valid = _cache.values.where((v) => now.isBefore(v.expiresAt)).length;
    final expired = _cache.length - valid;

    return {'total': _cache.length, 'valid': valid, 'expired': expired};
  }

  // Connection testing methods
  Future<bool> testConnection() async {
    try {
      final response = await healthCheck();
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('. Connection test failed: $e');
      }
      return false;
    }
  }

  Future<Map<String, dynamic>> getConnectionInfo() async {
    try {
      final response = await healthCheck();
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'connected': true,
          'status': data['data']?['status'] ?? 'unknown',
          'environment': data['data']?['environment'] ?? 'unknown',
          'version': data['data']?['version'] ?? 'unknown',
          'uptime': data['data']?['uptime'] ?? 0,
          'responseTime': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        return {
          'connected': false,
          'statusCode': response.statusCode,
          'error': 'Unexpected status code',
        };
      }
    } catch (e) {
      return {
        'connected': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Configuration methods
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    if (kDebugMode) {
      print('. Base URL updated to: $newBaseUrl');
    }
  }

  void updateTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = sendTimeout;
    }
    if (kDebugMode) {
      print('. Timeout settings updated');
    }
  }

  void addCustomHeader(String key, String value) {
    _dio.options.headers[key] = value;
    if (kDebugMode) {
      print('. Custom header added: $key');
    }
  }

  void removeCustomHeader(String key) {
    _dio.options.headers.remove(key);
    if (kDebugMode) {
      print('. Custom header removed: $key');
    }
  }

  // Debug and monitoring methods
  Map<String, dynamic> getClientInfo() {
    return {
      'baseUrl': _dio.options.baseUrl,
      'connectTimeout': _dio.options.connectTimeout?.inMilliseconds,
      'receiveTimeout': _dio.options.receiveTimeout?.inMilliseconds,
      'sendTimeout': _dio.options.sendTimeout?.inMilliseconds,
      'hasAuthToken': hasAuthToken,
      'headers': _dio.options.headers,
      'cacheStats': getCacheStats(),
    };
  }

  void logClientInfo() {
    if (kDebugMode) {
      final info = getClientInfo();
      print('. DioClient Info: $info');
    }
  }

  // Cleanup method
  void dispose() {
    _dio.close();
    clearCache();
    if (kDebugMode) {
      print('🗑️ DioClient disposed');
    }
  }

  // Singleton cleanup for testing
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

// Helper class for caching responses
class CachedResponse {
  final Response response;
  final DateTime expiresAt;

  CachedResponse({required this.response, required this.expiresAt});
}
