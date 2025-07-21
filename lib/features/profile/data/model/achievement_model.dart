import '../../domain/entity/achievement_entity.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;
  final bool earned;
  final String? earnedDate;
  final int progress;
  final int requirement;
  final String color;
  final String rarity;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.earned,
    this.earnedDate,
    required this.progress,
    required this.requirement,
    required this.color,
    this.rarity = 'common',
  });

  // FIXED: Remove null-aware operators where not needed
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    try {
      return AchievementModel(
        id: _safeString(json['id']),
        title: _safeString(json['title']) ?? _safeString(json['name']),
        description: _safeString(json['description']),
        icon:
            _safeString(json['icon']) ??
            _safeString(json['iconName']) ??
            'star',
        category: _safeString(json['category']),
        earned: _safeBool(json['earned']) ?? _safeBool(json['isEarned']),
        earnedDate: _safeString(json['earnedDate']).isEmpty
            ? null
            : _safeString(json['earnedDate']),
        progress: _safeInt(json['progress']),
        requirement:
            _safeInt(json['requirement']) ?? _safeInt(json['target']) ?? 1,
        color: _safeString(json['color']),
        rarity: _safeString(json['rarity']),
      );
    } catch (e) {
      return const AchievementModel(
        id: 'unknown',
        title: 'Achievement',
        description: 'Failed to load achievement details',
        icon: 'star',
        category: 'general',
        earned: false,
        earnedDate: null,
        progress: 0,
        requirement: 1,
        color: '#6B7280',
        rarity: 'common',
      );
    }
  }

  // FIXED: Remove null-aware operators and make safe
  static String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) {
      return value == 1;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category,
      'earned': earned,
      'earnedDate': earnedDate,
      'progress': progress,
      'requirement': requirement,
      'color': color,
      'rarity': rarity,
    };
  }

  // FIXED: Correct mapping for entity conversion
  AchievementEntity toEntity() {
    return AchievementEntity(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      earned: earned,
      earnedDate: earnedDate,
      requirement: requirement,
      progress: progress,
      category: category,
      rarity: rarity,
    );
  }

  factory AchievementModel.fromEntity(AchievementEntity entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      icon: entity.icon,
      category: entity.category,
      earned: entity.earned,
      earnedDate: entity.earnedDate,
      progress: entity.progress,
      requirement: entity.requirement,
      color: entity.color,
      rarity: 'common',
    );
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? category,
    bool? earned,
    String? earnedDate,
    int? progress,
    int? requirement,
    String? color,
    String? rarity,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      earned: earned ?? this.earned,
      earnedDate: earnedDate ?? this.earnedDate,
      progress: progress ?? this.progress,
      requirement: requirement ?? this.requirement,
      color: color ?? this.color,
      rarity: rarity ?? this.rarity,
    );
  }

  @override
  String toString() {
    return 'AchievementModel(id: $id, title: $title, earned: $earned, progress: $progress/$requirement)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
