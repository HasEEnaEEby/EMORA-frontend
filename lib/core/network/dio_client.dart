// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api_service.dart';

class DioClient {
  late Dio _dio;
  SharedPreferences? _prefs;
  final ApiService _apiService = ApiService();

  // EMORA Backend Configuration
  static const String _baseUrl = 'http://localhost:8000';
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 30);

  DioClient._() {
    _dio = Dio();
    _initPrefs();
    _setupDio();
  }

  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  factory DioClient.create() => instance;

  Dio get dio => _dio;

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
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - clear stored token
          _clearStoredToken();
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
            print('🔍 QUERY: ${options.queryParameters}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          print('📥 DATA: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print(
            '❌ ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
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
              print('❌ Retry failed: $e');
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

  // Enhanced API Methods with ApiService integration

  // Auth endpoints
  Future<Response> checkUsernameAvailability(String username) async {
    return await _apiService.makeRequest(
      _dio,
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
    return await _apiService.makeRequest(
      _dio,
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
    return await _apiService.makeRequest(
      _dio,
      'POST',
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> logout() async {
    return await _apiService.makeRequest(_dio, 'POST', '/api/auth/logout');
  }

  Future<Response> getCurrentUser() async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/auth/me',
      cacheDuration: Duration(minutes: 5),
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
    return await _apiService.makeRequest(
      _dio,
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
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/users/$userId/journey',
      queryParameters: {'days': days, 'format': format},
      cacheDuration: Duration(minutes: 10),
    );
  }

  Future<Response> getGlobalEmotionStats({String timeframe = '24h'}) async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/global-stats',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: Duration(minutes: 5),
    );
  }

  Future<Response> getGlobalEmotionHeatmap({
    Map<String, dynamic>? bounds,
    String format = 'unified',
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/global-heatmap',
      queryParameters: {'format': format, if (bounds != null) ...bounds},
      cacheDuration: Duration(minutes: 10),
    );
  }

  Future<Response> getEmotionFeed({
    int limit = 10,
    int offset = 0,
    String? emotion,
    String format = 'unified',
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/feed',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'format': format,
        if (emotion != null) 'emotion': emotion,
      },
      cacheDuration: Duration(minutes: 3),
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
    return await _apiService.makeRequest(
      _dio,
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
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/users/$userId/insights',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: Duration(minutes: 5),
    );
  }

  Future<Response> getUserEmotionStats(
    String userId, {
    String timeframe = '30d',
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/emotions/users/$userId/stats',
      queryParameters: {'timeframe': timeframe},
      cacheDuration: Duration(minutes: 5),
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

    return await _apiService.makeRequest(
      _dio,
      'PUT',
      '/api/emotions/$emotionId',
      data: data,
    );
  }

  Future<Response> deleteEmotion(String emotionId) async {
    return await _apiService.makeRequest(
      _dio,
      'DELETE',
      '/api/emotions/$emotionId',
    );
  }

  // Health and monitoring endpoints
  Future<Response> healthCheck() async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/health',
      cacheDuration: Duration(minutes: 1),
    );
  }

  Future<Response> getSystemStatus() async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/status',
      cacheDuration: Duration(minutes: 2),
    );
  }

  Future<Response> getApiVersion() async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      '/api/version',
      cacheDuration: Duration(minutes: 30),
    );
  }

  // Enhanced Generic HTTP methods with ApiService
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'GET',
      path,
      queryParameters: queryParameters,
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
    return await _apiService.makeRequest(
      _dio,
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'PUT',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'DELETE',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _apiService.makeRequest(
      _dio,
      'PATCH',
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  // Token management
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

  void _clearStoredToken() {
    try {
      _prefs?.remove(AppConfig.authTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing stored token: $e');
      }
    }
  }

  void setAuthToken(String token) {
    try {
      _prefs?.setString(AppConfig.authTokenKey, token);
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

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _clearStoredToken();
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
    _apiService.clearCache();
    if (kDebugMode) {
      print('🗑️ DioClient cache cleared');
    }
  }

  void clearExpiredCache() {
    _apiService.clearExpiredCache();
    if (kDebugMode) {
      print('🧹 Expired cache cleared');
    }
  }

  Map<String, int> getCacheStats() {
    return _apiService.getCacheStats();
  }

  // Connection testing methods
  Future<bool> testConnection() async {
    try {
      final response = await healthCheck();
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Connection test failed: $e');
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
      print('🔧 Base URL updated to: $newBaseUrl');
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
      print('🔧 Timeout settings updated');
    }
  }

  void addCustomHeader(String key, String value) {
    _dio.options.headers[key] = value;
    if (kDebugMode) {
      print('🔧 Custom header added: $key');
    }
  }

  void removeCustomHeader(String key) {
    _dio.options.headers.remove(key);
    if (kDebugMode) {
      print('🔧 Custom header removed: $key');
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
      print('📊 DioClient Info: $info');
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
