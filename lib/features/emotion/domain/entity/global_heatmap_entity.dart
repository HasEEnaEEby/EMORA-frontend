// Create this file: lib/features/emotion/domain/entity/global_heatmap_entity.dart

import 'package:equatable/equatable.dart';

class GlobalHeatmapEntity extends Equatable {
  final List<Map<String, dynamic>> locations;
  final Map<String, dynamic> summary;
  final DateTime? lastUpdated;

  const GlobalHeatmapEntity({
    required this.locations,
    required this.summary,
    this.lastUpdated,
  });

  factory GlobalHeatmapEntity.fromJson(Map<String, dynamic> json) {
    return GlobalHeatmapEntity(
      locations: List<Map<String, dynamic>>.from(json['locations'] ?? []),
      summary: Map<String, dynamic>.from(json['summary'] ?? {}),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locations': locations,
      'summary': summary,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [locations, summary, lastUpdated];

  @override
  String toString() {
    return 'GlobalHeatmapEntity('
        'locations: ${locations.length} items, '
        'summary: $summary, '
        'lastUpdated: $lastUpdated'
        ')';
  }

  // Helper methods for easier data access
  int get locationCount => locations.length;

  bool get hasLocations => locations.isNotEmpty;

  String? get mostActiveLocation {
    if (summary.containsKey('mostActiveLocation')) {
      return summary['mostActiveLocation'] as String?;
    }
    return null;
  }

  int get totalEmotions {
    if (summary.containsKey('totalEmotions')) {
      return summary['totalEmotions'] as int? ?? 0;
    }
    return 0;
  }

  // Copy with method for state management
  GlobalHeatmapEntity copyWith({
    List<Map<String, dynamic>>? locations,
    Map<String, dynamic>? summary,
    DateTime? lastUpdated,
  }) {
    return GlobalHeatmapEntity(
      locations: locations ?? this.locations,
      summary: summary ?? this.summary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
