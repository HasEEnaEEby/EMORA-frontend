// lib/core/network/api_service.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Cache for ongoing requests to prevent duplicates
  static final Map<String, Future<Response>> _ongoingRequests = {};

  // Cache for completed requests
  static final Map<String, CachedResponse> _responseCache = {};

  // Default cache duration
  static const Duration _defaultCacheDuration = Duration(minutes: 2);

  Future<Response> makeRequest(
    Dio dio,
    String method,
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(method, path, queryParameters);

    // Check cache first (unless force refresh)
    if (!forceRefresh && _responseCache.containsKey(cacheKey)) {
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

    // Make new request
    final requestFuture = _performRequest(
      dio,
      method,
      path,
      queryParameters,
      data,
    );
    _ongoingRequests[cacheKey] = requestFuture;

    try {
      final response = await requestFuture;

      // Cache successful responses
      if (response.statusCode == 200) {
        _responseCache[cacheKey] = CachedResponse(response, DateTime.now());
      }

      return response;
    } finally {
      _ongoingRequests.remove(cacheKey);
    }
  }

  Future<Response> _performRequest(
    Dio dio,
    String method,
    String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await dio.get(path, queryParameters: queryParameters);
      case 'POST':
        return await dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
        );
      case 'PUT':
        return await dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
        );
      case 'DELETE':
        return await dio.delete(path, queryParameters: queryParameters);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  String _generateCacheKey(
    String method,
    String path,
    Map<String, dynamic>? params,
  ) {
    final paramString =
        params?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return '$method:$path?$paramString';
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
