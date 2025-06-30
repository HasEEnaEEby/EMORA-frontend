// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  late Dio _dio;

  // EMORA Backend Configuration
  static const String _baseUrl = 'http://localhost:8000';
  static const Duration _connectTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 30);

  DioClient._() {
    _dio = Dio();
    _setupDio();
  }

  static DioClient? _instance;

  static DioClient get instance {
    _instance ??= DioClient._();
    return _instance!;
  }

  factory DioClient.create() => instance;

  Dio get dio => _dio;

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
        }
        handler.next(error);
      },
    );
  }

  // API Methods for EMORA Backend

  // Auth endpoints
  Future<Response> checkUsernameAvailability(String username) async {
    return await _dio.post(
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
    return await _dio.post(
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
    return await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
  }

  Future<Response> logout() async {
    return await _dio.post('/api/auth/logout');
  }

  Future<Response> getCurrentUser() async {
    return await _dio.get('/api/auth/me');
  }

  Future<Response> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    Map<String, dynamic>? context,
    Map<String, dynamic>? memory,
    Map<String, dynamic>? location,
    Map<String, dynamic>? globalSharing,
    String source = 'mobile', required Map<String, dynamic> emotionData,
  }) async {
    return await _dio.post(
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
      },
    );
  }

  Future<Response> getEmotionJourney({
    required String userId,
    int days = 30,
    String format = 'unified',
  }) async {
    return await _dio.get(
      '/api/emotions/users/$userId/journey',
      queryParameters: {'days': days, 'format': format},
    );
  }

  Future<Response> getGlobalEmotionStats({String timeframe = '24h'}) async {
    return await _dio.get(
      '/api/emotions/global-stats',
      queryParameters: {'timeframe': timeframe},
    );
  }

  Future<Response> getGlobalEmotionHeatmap({
    Map<String, dynamic>? bounds,
    String format = 'unified',
  }) async {
    return await _dio.get(
      '/api/emotions/global-heatmap',
      queryParameters: {'format': format, if (bounds != null) ...bounds},
    );
  }

  Future<Response> getEmotionFeed({
    int limit = 10,
    int offset = 0,
    String? emotion,
    String format = 'unified',
  }) async {
    return await _dio.get(
      '/api/emotions/feed',
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'format': format,
        if (emotion != null) 'emotion': emotion,
      },
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
    return await _dio.post(
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
    return await _dio.get(
      '/api/emotions/users/$userId/insights',
      queryParameters: {'timeframe': timeframe},
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

    return await _dio.put('/api/emotions/$emotionId', data: data);
  }

  Future<Response> deleteEmotion(String emotionId) async {
    return await _dio.delete('/api/emotions/$emotionId');
  }

  // Health check
  Future<Response> healthCheck() async {
    return await _dio.get('/api/health');
  }

  // Generic HTTP methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post(
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
    return await _dio.put(
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
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Token management (you'll need to implement based on your storage solution)
  String? _getStoredToken() {
    // TODO: Implement token retrieval from SharedPreferences or secure storage
    return null;
  }

  void _clearStoredToken() {
    // TODO: Implement token clearing from storage
  }

  void setAuthToken(String token) {
    // TODO: Store token and update headers
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _clearStoredToken();
  }

  Future getUserEmotionStats(String userId) async {}
}
