import 'package:latlong2/latlong.dart';

// ============================================================================
// CORE EMOTION MODELS
// ============================================================================

class PlutchikCoreEmotion {
  final String name;
  final String emoji;
  final String color;
  final String character;

  const PlutchikCoreEmotion({
    required this.name,
    required this.emoji,
    required this.color,
    required this.character,
  });

  static const Map<String, PlutchikCoreEmotion> coreEmotions = {
    'joy': PlutchikCoreEmotion(
      name: 'joy',
      emoji: '😊',
      color: '#F59E0B',
      character: 'Joy',
    ),
    'trust': PlutchikCoreEmotion(
      name: 'trust',
      emoji: '🤝',
      color: '#10B981',
      character: 'Trust',
    ),
    'fear': PlutchikCoreEmotion(
      name: 'fear',
      emoji: '😨',
      color: '#8B5CF6',
      character: 'Fear',
    ),
    'surprise': PlutchikCoreEmotion(
      name: 'surprise',
      emoji: '😲',
      color: '#F97316',
      character: 'Surprise',
    ),
    'sadness': PlutchikCoreEmotion(
      name: 'sadness',
      emoji: '😢',
      color: '#3B82F6',
      character: 'Sadness',
    ),
    'disgust': PlutchikCoreEmotion(
      name: 'disgust',
      emoji: '🤢',
      color: '#059669',
      character: 'Disgust',
    ),
    'anger': PlutchikCoreEmotion(
      name: 'anger',
      emoji: '😠',
      color: '#EF4444',
      character: 'Anger',
    ),
    'anticipation': PlutchikCoreEmotion(
      name: 'anticipation',
      emoji: '🤔',
      color: '#FCD34D',
      character: 'Anticipation',
    ),
  };

  static PlutchikCoreEmotion? fromString(String emotion) {
    return coreEmotions[emotion.toLowerCase()];
  }

  static String getEmoji(String emotion) {
    return coreEmotions[emotion.toLowerCase()]?.emoji ?? '😐';
  }

  static String getColor(String emotion) {
    return coreEmotions[emotion.toLowerCase()]?.color ?? '#6B7280';
  }

  static String getCharacter(String emotion) {
    return coreEmotions[emotion.toLowerCase()]?.character ?? 'Neutral';
  }
}

// ============================================================================
// MAP DATA MODELS
// ============================================================================

class GlobalEmotionPoint {
  final String id;
  final LatLng coordinates;
  final String coreEmotion;
  final List<String> emotionTypes;
  final int count;
  final double avgIntensity;
  final double maxIntensity;
  final String? city;
  final String? country;
  final DateTime latestTimestamp;
  final String? clusterId;

  GlobalEmotionPoint({
    required this.id,
    required this.coordinates,
    required this.coreEmotion,
    required this.emotionTypes,
    required this.count,
    required this.avgIntensity,
    required this.maxIntensity,
    this.city,
    this.country,
    required this.latestTimestamp,
    this.clusterId,
  });

  factory GlobalEmotionPoint.fromJson(Map<String, dynamic> json) {
    // Handle both old coordinates format and new GeoJSON location format
    List<dynamic> coordinates;
    if (json['location'] != null && json['location']['coordinates'] != null) {
      // New GeoJSON format
      coordinates = json['location']['coordinates'] as List<dynamic>? ?? [];
    } else if (json['coordinates'] != null) {
      // Old format for backward compatibility
      coordinates = json['coordinates'] as List<dynamic>? ?? [];
    } else {
      throw Exception('No coordinates found in emotion data');
    }
    
    final lat = coordinates[1] as double;
    final lng = coordinates[0] as double;

    return GlobalEmotionPoint(
      id: json['id'] ?? json['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      coordinates: LatLng(lat, lng),
      coreEmotion: json['coreEmotion'] ?? 'joy',
      emotionTypes: List<String>.from(json['emotionTypes'] ?? []),
      count: json['count'] ?? 1,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
      maxIntensity: (json['maxIntensity'] ?? 0.0).toDouble(),
      city: json['city'],
      country: json['country'],
      latestTimestamp: DateTime.tryParse(json['latestTimestamp'] ?? '') ?? DateTime.now(),
      clusterId: json['clusterId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coordinates': [coordinates.longitude, coordinates.latitude],
      'coreEmotion': coreEmotion,
      'emotionTypes': emotionTypes,
      'count': count,
      'avgIntensity': avgIntensity,
      'maxIntensity': maxIntensity,
      'city': city,
      'country': country,
      'latestTimestamp': latestTimestamp.toIso8601String(),
      'clusterId': clusterId,
    };
  }

  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    } else if (country != null) {
      return country!;
    }
    return 'Unknown Location';
  }

  String get emotionEmoji => PlutchikCoreEmotion.getEmoji(coreEmotion);
  String get emotionColor => PlutchikCoreEmotion.getColor(coreEmotion);
  String get emotionCharacter => PlutchikCoreEmotion.getCharacter(coreEmotion);
}

class EmotionCluster {
  final String clusterId;
  final LatLng center;
  final String coreEmotion;
  final List<String> emotionTypes;
  final int count;
  final double avgIntensity;
  final String? city;
  final String? country;
  final DateTime latestTimestamp;
  final double size;

  EmotionCluster({
    required this.clusterId,
    required this.center,
    required this.coreEmotion,
    required this.emotionTypes,
    required this.count,
    required this.avgIntensity,
    this.city,
    this.country,
    required this.latestTimestamp,
    required this.size,
  });

  factory EmotionCluster.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as List<dynamic>? ?? [];
    final lat = coordinates.isNotEmpty ? coordinates[1] as double? ?? 0.0 : 0.0;
    final lng = coordinates.isNotEmpty ? coordinates[0] as double? ?? 0.0 : 0.0;

    return EmotionCluster(
      clusterId: json['clusterId'] ?? '',
      center: LatLng(lat, lng),
      coreEmotion: json['coreEmotion'] ?? 'joy',
      emotionTypes: List<String>.from(json['emotionTypes'] ?? []),
      count: json['count'] ?? 1,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
      city: json['city'],
      country: json['country'],
      latestTimestamp: DateTime.tryParse(json['latestTimestamp'] ?? '') ?? DateTime.now(),
      size: (json['count'] ?? 1) * 2.0, // Size based on count
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clusterId': clusterId,
      'coordinates': [center.longitude, center.latitude],
      'coreEmotion': coreEmotion,
      'emotionTypes': emotionTypes,
      'count': count,
      'avgIntensity': avgIntensity,
      'city': city,
      'country': country,
      'latestTimestamp': latestTimestamp.toIso8601String(),
      'size': size,
    };
  }

  String get displayName {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    } else if (country != null) {
      return country!;
    }
    return 'Unknown Location';
  }

  String get emotionEmoji => PlutchikCoreEmotion.getEmoji(coreEmotion);
  String get emotionColor => PlutchikCoreEmotion.getColor(coreEmotion);
  String get emotionCharacter => PlutchikCoreEmotion.getCharacter(coreEmotion);
}

class EmotionTrend {
  final String date;
  final String coreEmotion;
  final String? city;
  final String? country;
  final int count;
  final double avgIntensity;

  EmotionTrend({
    required this.date,
    required this.coreEmotion,
    this.city,
    this.country,
    required this.count,
    required this.avgIntensity,
  });

  factory EmotionTrend.fromJson(Map<String, dynamic> json) {
    return EmotionTrend(
      date: json['date'] ?? '',
      coreEmotion: json['coreEmotion'] ?? 'joy',
      city: json['city'],
      country: json['country'],
      count: json['count'] ?? 0,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'coreEmotion': coreEmotion,
      'city': city,
      'country': country,
      'count': count,
      'avgIntensity': avgIntensity,
    };
  }

  String get emotionEmoji => PlutchikCoreEmotion.getEmoji(coreEmotion);
  String get emotionColor => PlutchikCoreEmotion.getColor(coreEmotion);
}

class CoreEmotionStats {
  final String coreEmotion;
  final int count;
  final double avgIntensity;

  CoreEmotionStats({
    required this.coreEmotion,
    required this.count,
    required this.avgIntensity,
  });

  factory CoreEmotionStats.fromJson(Map<String, dynamic> json) {
    return CoreEmotionStats(
      coreEmotion: json['coreEmotion'] ?? 'joy',
      count: json['count'] ?? 0,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coreEmotion': coreEmotion,
      'count': count,
      'avgIntensity': avgIntensity,
    };
  }

  String get emotionEmoji => PlutchikCoreEmotion.getEmoji(coreEmotion);
  String get emotionColor => PlutchikCoreEmotion.getColor(coreEmotion);
  String get emotionCharacter => PlutchikCoreEmotion.getCharacter(coreEmotion);
}

class GlobalEmotionStats {
  final int totalEmotions;
  final double avgIntensity;
  final Map<String, CoreEmotionStats> coreEmotionStats;
  final DateTime lastUpdated;

  GlobalEmotionStats({
    required this.totalEmotions,
    required this.avgIntensity,
    required this.coreEmotionStats,
    required this.lastUpdated,
  });

  factory GlobalEmotionStats.fromJson(Map<String, dynamic> json) {
    final coreEmotionStatsMap = <String, CoreEmotionStats>{};
    final statsData = json['coreEmotionStats'] as Map<String, dynamic>? ?? {};
    
    statsData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        coreEmotionStatsMap[key] = CoreEmotionStats.fromJson(value);
      }
    });

    return GlobalEmotionStats(
      totalEmotions: json['totalEmotions'] ?? 0,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
      coreEmotionStats: coreEmotionStatsMap,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmotions': totalEmotions,
      'avgIntensity': avgIntensity,
      'coreEmotionStats': coreEmotionStats.map((key, value) => MapEntry(key, value.toJson())),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  List<CoreEmotionStats> get sortedCoreEmotions {
    final stats = coreEmotionStats.values.toList();
    stats.sort((a, b) => b.count.compareTo(a.count));
    return stats;
  }

  String get dominantEmotion {
    if (coreEmotionStats.isEmpty) return 'joy';
    final sorted = sortedCoreEmotions;
    return sorted.first.coreEmotion;
  }
}

// ============================================================================
// API RESPONSE MODELS
// ============================================================================

class MapApiResponse<T> {
  final bool success;
  final List<T> data;
  final int count;
  final Map<String, dynamic>? filters;
  final String? error;

  MapApiResponse({
    required this.success,
    required this.data,
    required this.count,
    this.filters,
    this.error,
  });

  factory MapApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return MapApiResponse<T>(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      filters: json['filters'] as Map<String, dynamic>?,
      error: json['error'],
    );
  }
}

class StatsApiResponse {
  final bool success;
  final GlobalEmotionStats? data;
  final String? error;

  StatsApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory StatsApiResponse.fromJson(Map<String, dynamic> json) {
    return StatsApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? GlobalEmotionStats.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

// ============================================================================
// FILTER MODELS
// ============================================================================

class EmotionMapFilters {
  final String? coreEmotion;
  final String? country;
  final String? region;
  final String? city;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minIntensity;
  final int? limit;
  final String? timeFilter;
  final bool showClusters;
  final bool showHeatmap;

  EmotionMapFilters({
    this.coreEmotion,
    this.country,
    this.region,
    this.city,
    this.startDate,
    this.endDate,
    this.minIntensity,
    this.limit,
    this.timeFilter,
    this.showClusters = true,
    this.showHeatmap = true,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (coreEmotion != null) params['coreEmotion'] = coreEmotion;
    if (country != null) params['country'] = country;
    if (region != null) params['region'] = region;
    if (city != null) params['city'] = city;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (minIntensity != null) params['minIntensity'] = minIntensity;
    if (limit != null) params['limit'] = limit;

    return params;
  }

  EmotionMapFilters copyWith({
    String? coreEmotion,
    String? country,
    String? region,
    String? city,
    DateTime? startDate,
    DateTime? endDate,
    int? minIntensity,
    int? limit,
    String? timeFilter,
    bool? showClusters,
    bool? showHeatmap,
  }) {
    return EmotionMapFilters(
      coreEmotion: coreEmotion ?? this.coreEmotion,
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minIntensity: minIntensity ?? this.minIntensity,
      limit: limit ?? this.limit,
      timeFilter: timeFilter ?? this.timeFilter,
      showClusters: showClusters ?? this.showClusters,
      showHeatmap: showHeatmap ?? this.showHeatmap,
    );
  }
}

// ============================================================================
// AI INSIGHTS MODELS
// ============================================================================

class EmotionInsight {
  final String region;
  final String timeRange;
  final List<EmotionSummary> summary;
  final String insight;
  final int totalEmotions;
  final Map<String, dynamic> contextStats;
  final DateTime lastUpdated;

  EmotionInsight({
    required this.region,
    required this.timeRange,
    required this.summary,
    required this.insight,
    required this.totalEmotions,
    required this.contextStats,
    required this.lastUpdated,
  });

  factory EmotionInsight.fromJson(Map<String, dynamic> json) {
    final summaryList = (json['summary'] as List<dynamic>? ?? [])
        .map((item) => EmotionSummary.fromJson(item))
        .toList();

    return EmotionInsight(
      region: json['region'] ?? 'Unknown',
      timeRange: json['timeRange'] ?? '7d',
      summary: summaryList,
      insight: json['insight'] ?? 'No insight available',
      totalEmotions: json['totalEmotions'] ?? 0,
      contextStats: json['contextStats'] ?? {},
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'timeRange': timeRange,
      'summary': summary.map((item) => item.toJson()).toList(),
      'insight': insight,
      'totalEmotions': totalEmotions,
      'contextStats': contextStats,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class EmotionSummary {
  final String emotion;
  final int count;
  final double avgIntensity;
  final double percentage;

  EmotionSummary({
    required this.emotion,
    required this.count,
    required this.avgIntensity,
    required this.percentage,
  });

  factory EmotionSummary.fromJson(Map<String, dynamic> json) {
    return EmotionSummary(
      emotion: json['emotion'] ?? 'unknown',
      count: json['count'] ?? 0,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'count': count,
      'avgIntensity': avgIntensity,
      'percentage': percentage,
    };
  }
}

class EmotionTrendData {
  final List<EmotionTrendPoint> trends;
  final String region;
  final String emotion;
  final int days;
  final DateTime lastUpdated;

  EmotionTrendData({
    required this.trends,
    required this.region,
    required this.emotion,
    required this.days,
    required this.lastUpdated,
  });

  factory EmotionTrendData.fromJson(Map<String, dynamic> json) {
    final trendsList = (json['trends'] as List<dynamic>? ?? [])
        .map((item) => EmotionTrendPoint.fromJson(item))
        .toList();

    return EmotionTrendData(
      trends: trendsList,
      region: json['region'] ?? 'Global',
      emotion: json['emotion'] ?? 'All',
      days: json['days'] ?? 7,
      lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trends': trends.map((item) => item.toJson()).toList(),
      'region': region,
      'emotion': emotion,
      'days': days,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class EmotionTrendPoint {
  final String date;
  final String emotion;
  final int count;
  final double avgIntensity;

  EmotionTrendPoint({
    required this.date,
    required this.emotion,
    required this.count,
    required this.avgIntensity,
  });

  factory EmotionTrendPoint.fromJson(Map<String, dynamic> json) {
    return EmotionTrendPoint(
      date: json['date'] ?? '',
      emotion: json['emotion'] ?? 'unknown',
      count: json['count'] ?? 0,
      avgIntensity: (json['avgIntensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'emotion': emotion,
      'count': count,
      'avgIntensity': avgIntensity,
    };
  }
} 