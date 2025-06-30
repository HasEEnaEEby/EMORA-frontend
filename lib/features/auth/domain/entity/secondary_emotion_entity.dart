class SecondaryEmotionEntity {
  final String emotion;
  final double intensity;

  const SecondaryEmotionEntity({
    required this.emotion,
    required this.intensity,
  });

  factory SecondaryEmotionEntity.fromJson(Map<String, dynamic> json) {
    return SecondaryEmotionEntity(
      emotion: json['emotion'] ?? '',
      intensity: (json['intensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'emotion': emotion, 'intensity': intensity};
  }
}
