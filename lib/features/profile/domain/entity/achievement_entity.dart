import 'package:equatable/equatable.dart';

class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String color;
  final bool earned;
  final String? earnedDate;
  final int requirement;
  final int progress;
  final String category;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
    this.earnedDate,
    required this.requirement,
    required this.progress,
    required this.category,
  });

  // Factory constructor to create from backend response
  factory AchievementEntity.fromBackendResponse(Map<String, dynamic> data) {
    return AchievementEntity(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      icon: data['icon'] as String,
      color: data['color'] as String,
      earned: data['earned'] as bool,
      earnedDate: data['earnedDate'] as String?,
      requirement: data['requirement'] as int,
      progress: data['progress'] as int,
      category: data['category'] as String,
    );
  }

  AchievementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? color,
    bool? earned,
    String? earnedDate,
    int? requirement,
    int? progress,
    String? category,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      earned: earned ?? this.earned,
      earnedDate: earnedDate ?? this.earnedDate,
      requirement: requirement ?? this.requirement,
      progress: progress ?? this.progress,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    color,
    earned,
    earnedDate,
    requirement,
    progress,
    category,
  ];

  @override
  String toString() {
    return 'AchievementEntity(id: $id, title: $title, earned: $earned, progress: $progress/$requirement)';
  }
}
