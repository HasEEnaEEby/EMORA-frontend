class EmotionContextEntity {
  final String? trigger;
  final String? socialContext;
  final String? activity;
  final String? weather;
  final double? temperature;
  final String? location;

  const EmotionContextEntity({
    this.trigger,
    this.socialContext,
    this.activity,
    this.weather,
    this.temperature,
    this.location,
  });

  factory EmotionContextEntity.fromJson(Map<String, dynamic> json) {
    return EmotionContextEntity(
      trigger: json['trigger'],
      socialContext: json['socialContext'],
      activity: json['activity'],
      weather: json['weather'],
      temperature: json['temperature']?.toDouble(),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'socialContext': socialContext,
      'activity': activity,
      'weather': weather,
      'temperature': temperature,
      'location': location,
    };
  }
}
