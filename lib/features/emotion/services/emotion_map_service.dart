import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

class EmotionMapService {
  static const String baseUrl = 'http://localhost:8000/api/map';
  
  // Singleton pattern
  static final EmotionMapService _instance = EmotionMapService._internal();
  factory EmotionMapService() => _instance;
  EmotionMapService._internal();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Fetch emotion data points from the API
  Future<MapApiResponse<GlobalEmotionPoint>> getEmotionData({
    String? coreEmotion,
    String? country,
    String? region,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    int? minIntensity,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (city != null) queryParams['city'] = city;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();
      if (minIntensity != null) queryParams['minIntensity'] = minIntensity;
      if (limit != null) queryParams['limit'] = limit;

      final uri = Uri.parse('$baseUrl/emotion-data').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MapApiResponse.fromJson(
          jsonData,
          (json) => GlobalEmotionPoint.fromJson(json),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch emotion data: $e');
    }
  }

  /// Fetch emotion clusters from the API
  Future<MapApiResponse<EmotionCluster>> getEmotionClusters({
    String? coreEmotion,
    String? country,
    String? region,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    int? minIntensity,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (city != null) queryParams['city'] = city;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();
      if (minIntensity != null) queryParams['minIntensity'] = minIntensity;
      if (limit != null) queryParams['limit'] = limit;

      final uri = Uri.parse('$baseUrl/emotion-clusters').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MapApiResponse.fromJson(
          jsonData,
          (json) => EmotionCluster.fromJson(json),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch emotion clusters: $e');
    }
  }

  /// Fetch global emotion statistics
  Future<StatsApiResponse> getGlobalStats({
    String? coreEmotion,
    String? country,
    String? region,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (city != null) queryParams['city'] = city;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();

      final uri = Uri.parse('$baseUrl/stats').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return StatsApiResponse.fromJson(jsonData);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch global stats: $e');
    }
  }

  /// Fetch emotion trends over time
  Future<MapApiResponse<EmotionTrend>> getEmotionTrends({
    String? coreEmotion,
    String? country,
    String? region,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    String? timeGroup = 'day', // day, week, month
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (country != null) queryParams['country'] = country;
      if (region != null) queryParams['region'] = region;
      if (city != null) queryParams['city'] = city;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();
      if (timeGroup != null) queryParams['timeGroup'] = timeGroup;

      final uri = Uri.parse('$baseUrl/emotion-trends').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MapApiResponse.fromJson(
          jsonData,
          (json) => EmotionTrend.fromJson(json),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch emotion trends: $e');
    }
  }

  /// Submit user emotion to the global map
  Future<bool> submitEmotion({
    required double latitude,
    required double longitude,
    required String coreEmotion,
    required List<String> emotionTypes,
    required double intensity,
    String? city,
    String? country,
    String? context,
  }) async {
    try {
      final payload = {
        'coordinates': [longitude, latitude],
        'coreEmotion': coreEmotion,
        'emotionTypes': emotionTypes,
        'intensity': intensity,
        'city': city,
        'country': country,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/submit-emotion'),
        headers: _headers,
        body: json.encode(payload),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] ?? false;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit emotion: $e');
    }
  }

  /// Get real-time emotion updates via WebSocket (if available)
  Stream<GlobalEmotionPoint>? getRealtimeEmotions() {
    // TODO: Implement WebSocket connection for real-time updates
    // This would require a WebSocket implementation
    return null;
  }

  /// Get heatmap data for visualization
  Future<List<Map<String, dynamic>>> getHeatmapData({
    String? coreEmotion,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();

      final uri = Uri.parse('$baseUrl/heatmap').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch heatmap data: $e');
    }
  }

  /// Get AI-generated insights for a region
  Future<String> getRegionalInsights({
    required String region,
    String? coreEmotion,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'region': region,
      };
      
      if (coreEmotion != null) queryParams['coreEmotion'] = coreEmotion;
      if (startDate != null) queryParams['startDate'] = startDate!.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate!.toIso8601String();

      final uri = Uri.parse('$baseUrl/insights').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['insight'] ?? 'No insights available for this region.';
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch regional insights: $e');
    }
  }

  /// Get emotion predictions for a region
  Future<Map<String, dynamic>> getEmotionPredictions({
    required String region,
    int? hoursAhead = 24,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'region': region,
        'hoursAhead': hoursAhead,
      };

      final uri = Uri.parse('$baseUrl/predictions').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch emotion predictions: $e');
    }
  }
} 