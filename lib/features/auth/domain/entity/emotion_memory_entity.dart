class EmotionMemoryEntity {
  final String? description;
  final List<String>? tags;
  final bool isPrivate;

  const EmotionMemoryEntity({
    this.description,
    this.tags,
    this.isPrivate = false,
  });

  factory EmotionMemoryEntity.fromJson(Map<String, dynamic> json) {
    return EmotionMemoryEntity(
      description: json['description'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isPrivate: json['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'tags': tags, 'isPrivate': isPrivate};
  }
}
