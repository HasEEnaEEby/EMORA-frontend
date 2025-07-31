import 'dart:async';

import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../utils/logger.dart';
import '../utils/app_config.dart';

class EnhancedApiService {
  
  late final Dio _dio;
  late final InternetConnectionChecker _connectionChecker;
  
  String? _authToken;
  bool _isInitialized = false;
  
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _timeout = Duration(seconds: 60);
  
  final Map<String, int> _requestRetryCount = {};
  final Map<String, DateTime> _lastRequestTime = {};

  EnhancedApiService() {
    _initializeDio();
    _connectionChecker = InternetConnectionChecker.createInstance();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: AppConfig.getDefaultHeaders(),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));


    _isInitialized = true;
    Logger.info('🚀 EnhancedApiService initialized');
  }

  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final requestId = _generateRequestId();
    final startTime = DateTime.now();
    
    if (_authToken != null && !options.path.contains('/auth/')) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }

    options.extra['requestId'] = requestId;
    options.extra['startTime'] = startTime;

    Logger.http(
      method: options.method,
      url: options.path,
      headers: options.headers,
      body: options.data,
      isRequest: true,
    );

    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final requestId = response.requestOptions.extra['requestId'] as String?;
    final startTime = response.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null 
        ? DateTime.now().difference(startTime) 
        : null;

    Logger.http(
      method: response.requestOptions.method,
      url: response.requestOptions.path,
      statusCode: response.statusCode,
      duration: duration,
      isRequest: false,
    );

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      Logger.info(
        '. API Success: ${response.requestOptions.method} ${response.requestOptions.path}',
        {
          'statusCode': response.statusCode,
          'duration_ms': duration?.inMilliseconds,
          'requestId': requestId,
        },
      );
    }

    handler.next(response);
  }

  void _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final requestId = error.requestOptions.extra['requestId'] as String?;
    final startTime = error.requestOptions.extra['startTime'] as DateTime?;
    final duration = startTime != null 
        ? DateTime.now().difference(startTime) 
        : null;

    Logger.error(
      '. API Error: ${error.requestOptions.method} ${error.requestOptions.path}',
      {
        'statusCode': error.response?.statusCode,
        'errorType': error.type.name,
        'errorMessage': error.message,
        'duration_ms': duration?.inMilliseconds,
        'requestId': requestId,
        'responseData': error.response?.data,
      },
    );

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _handleTimeoutError(error, handler);
        break;
      
      case DioExceptionType.connectionError:
        _handleConnectionError(error, handler);
        break;
      
      case DioExceptionType.badResponse:
        _handleBadResponseError(error, handler);
        break;
      
      default:
        handler.next(error);
    }
  }

  void _handleTimeoutError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final requestId = error.requestOptions.extra['requestId'] as String?;
    final retryCount = _requestRetryCount[requestId] ?? 0;

    if (retryCount < _maxRetries) {
      _requestRetryCount[requestId!] = retryCount + 1;
      
      Logger.warning('⏰ Timeout retry ${retryCount + 1}/$_maxRetries for request $requestId');

    } else {
      Logger.error('⏰ Max retries exceeded for request $requestId');
      handler.next(error);
    }
  }

  void _handleConnectionError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    Logger.error('🌐 Connection error: ${error.message}');
    
    _connectionChecker.hasConnection.then((hasConnection) {
      if (!hasConnection) {
        Logger.warning('📡 No internet connection detected');
      }
    });

    handler.next(error);
  }

  void _handleBadResponseError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) {
    final statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      Logger.warning('🔐 Authentication error - token may be expired');
    }

    if (statusCode == 429) {
      Logger.warning('⏳ Rate limit exceeded');
    }

    if (statusCode! >= 500) {
      Logger.error('🖥️ Server error: $statusCode');
    }

    handler.next(error);
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    Logger.info('🔑 Auth token set');
  }

  void clearAuthToken() {
    _authToken = null;
    Logger.info('🔑 Auth token cleared');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _makeRequest(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      'GET',
      path,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _makeRequest(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      'POST',
      path,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _makeRequest(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      'PUT',
      path,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _makeRequest(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      'DELETE',
      path,
    );
  }

  Future<Response> _makeRequest(
    Future<Response> Function() requestFunction,
    String method,
    String path,
  ) async {
    if (!_isInitialized) {
      throw Exception('EnhancedApiService not initialized');
    }

    final hasConnection = await _connectionChecker.hasConnection;
    if (!hasConnection) {
      throw NetworkException('No internet connection available');
    }

    if (_isRateLimited(path)) {
      throw NetworkException('Rate limit exceeded for $path');
    }

    try {
      final response = await requestFunction();
      _updateRequestTracking(path);
      return response;
    } on DioException catch (e) {
      _handleDioError(e, method, path);
      rethrow;
    } catch (e) {
      Logger.error('. Unexpected error in $method $path', e);
      rethrow;
    }
  }

  void _handleDioError(DioException error, String method, String path) {
    final statusCode = error.response?.statusCode;
    final errorMessage = _extractErrorMessage(error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException('Request timeout: $errorMessage');
      
      case DioExceptionType.connectionError:
        throw NetworkException('Connection error: $errorMessage');
      
      case DioExceptionType.badResponse:
        if (statusCode == 401) {
          throw AuthException('Authentication failed: $errorMessage');
        } else if (statusCode == 403) {
          throw AuthException('Access denied: $errorMessage');
        } else if (statusCode == 404) {
          throw ServerException('Resource not found: $errorMessage');
        } else if (statusCode! >= 500) {
          throw ServerException('Server error: $errorMessage');
        } else {
          throw ServerException('Request failed: $errorMessage');
        }
      
      default:
        throw NetworkException('Network error: $errorMessage');
    }
  }

  String _extractErrorMessage(DioException error) {
    try {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] ?? 
               responseData['error'] ?? 
               error.message ?? 
               'Unknown error';
      }
      return error.message ?? 'Unknown error';
    } catch (e) {
      return error.message ?? 'Unknown error';
    }
  }

  bool _isRateLimited(String path) {
    final lastRequest = _lastRequestTime[path];
    if (lastRequest == null) return false;
    
    final timeSinceLastRequest = DateTime.now().difference(lastRequest);
    return timeSinceLastRequest < const Duration(milliseconds: 100);
  }

  void _updateRequestTracking(String path) {
    _lastRequestTime[path] = DateTime.now();
  }

  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<bool> healthCheck() async {
    try {
      final response = await get('/api/health');
      return response.statusCode == 200;
    } catch (e) {
      Logger.error('. API health check failed', e);
      return false;
    }
  }

  Future<bool> hasConnection() async {
    return await _connectionChecker.hasConnection;
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => 'ServerException: $message';
} 