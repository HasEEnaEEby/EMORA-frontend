class GlobalEmotionMapEntity {
  final String id;
  final double latitude;
  final double longitude;
  final String emotion;
  final String? coreEmotion;
  final double intensity;
  final DateTime timestamp;
  final String? location;
  final int count;

  const GlobalEmotionMapEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.emotion,
    this.coreEmotion,
    required this.intensity,
    required this.timestamp,
    this.location,
    this.count = 1,
  });

  factory GlobalEmotionMapEntity.fromJson(Map<String, dynamic> json) {
    return GlobalEmotionMapEntity(
      id: json['_id'] ?? json['id'] ?? '',
      latitude:
          (json['location']?['coordinates']?[1] ?? json['latitude'] ?? 0.0)
              .toDouble(),
      longitude:
          (json['location']?['coordinates']?[0] ?? json['longitude'] ?? 0.0)
              .toDouble(),
      emotion: json['emotion'] ?? json['coreEmotion'] ?? '',
      coreEmotion: json['coreEmotion'],
      intensity: (json['intensity'] ?? 0.5).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      location: json['locationName'] ?? json['location']?['name'],
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'emotion': emotion,
      'coreEmotion': coreEmotion,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'count': count,
    };
  }
}
