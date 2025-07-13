import 'package:latlong2/latlong.dart';

class EmotionPoint {
  final LatLng location;
  final String emotion;
  final double intensity;

  EmotionPoint(this.location, this.emotion, this.intensity);

  // Factory constructor for JSON serialization (optional)
  factory EmotionPoint.fromJson(Map<String, dynamic> json) {
    return EmotionPoint(
      LatLng(json['latitude'], json['longitude']),
      json['emotion'],
      json['intensity'].toDouble(),
    );
  }

  // Convert to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'latitude': location.latitude,
      'longitude': location.longitude,
      'emotion': emotion,
      'intensity': intensity,
    };
  }
}
