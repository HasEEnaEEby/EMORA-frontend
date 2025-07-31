
class AchievementDataHandler {
  static AchievementModel safeParse(dynamic achievement) {
    if (achievement is Map<String, dynamic>) {
      return AchievementModel.fromMap(achievement);
    } else if (achievement is AchievementModel) {
      return achievement;
    } else {
      return AchievementModel.createDefault();
    }
  }

  static List<AchievementModel> safeParseList(List<dynamic> achievements) {
    return achievements
        .map((achievement) => safeParse(achievement))
        .where((achievement) => achievement.isValid)
        .toList();
  }

  static List<AchievementModel> createMockAchievements() {
    return [
      AchievementModel(
        id: 'first_emotion',
        name: 'First Steps',
        description: 'Log your first emotion',
        category: 'milestone',
        iconName: 'star',
        points: 10,
        isEarned: true,
        progress: 1,
        target: 1,
        earnedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AchievementModel(
        id: 'week_streak',
        name: 'Weekly Warrior',
        description: 'Log emotions for 7 consecutive days',
        category: 'streak',
        iconName: 'flame',
        points: 50,
        isEarned: false,
        progress: 3,
        target: 7,
        earnedDate: null,
      ),
      AchievementModel(
        id: 'social_butterfly',
        name: 'Social Butterfly',
        description: 'Connect with 5 friends',
        category: 'social',
        iconName: 'heart',
        points: 25,
        isEarned: false,
        progress: 0,
        target: 5,
        earnedDate: null,
      ),
      AchievementModel(
        id: 'mood_master',
        name: 'Mood Master',
        description: 'Log 100 different emotions',
        category: 'discovery',
        iconName: 'target',
        points: 100,
        isEarned: false,
        progress: 15,
        target: 100,
        earnedDate: null,
      ),
      AchievementModel(
        id: 'mindful_month',
        name: 'Mindful Month',
        description: 'Complete 30 days of emotion tracking',
        category: 'wellness',
        iconName: 'calendar',
        points: 200,
        isEarned: false,
        progress: 8,
        target: 30,
        earnedDate: null,
      ),
    ];
  }
}

class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconName;
  final int points;
  final bool isEarned;
  final int progress;
  final int target;
  final DateTime? earnedDate;

  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.points,
    required this.isEarned,
    required this.progress,
    required this.target,
    this.earnedDate,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map) {
    try {
      return AchievementModel(
        id:
            map['id']?.toString() ??
            'unknown_${DateTime.now().millisecondsSinceEpoch}',
        name: map['name']?.toString() ?? 'Unknown Achievement',
        description:
            map['description']?.toString() ?? 'No description available',
        category: map['category']?.toString() ?? 'general',
        iconName:
            map['iconName']?.toString() ?? map['icon']?.toString() ?? 'star',
        points: _safeParseInt(map['points']) ?? 0,
        isEarned:
            _safeParseBool(map['isEarned']) ??
            _safeParseBool(map['earned']) ??
            false,
        progress: _safeParseInt(map['progress']) ?? 0,
        target: _safeParseInt(map['target']) ?? 1,
        earnedDate: _safeParseDate(map['earnedDate'] ?? map['dateEarned']),
      );
    } catch (e) {
      return AchievementModel.createDefault();
    }
  }

  factory AchievementModel.createDefault() {
    return AchievementModel(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Mystery Achievement',
      description: 'Achievement data unavailable',
      category: 'general',
      iconName: 'star',
      points: 0,
      isEarned: false,
      progress: 0,
      target: 1,
      earnedDate: null,
    );
  }

  bool get isValid => name.isNotEmpty && id.isNotEmpty;

  double get completionPercentage {
    if (target <= 0) return 0.0;
    return (progress / target).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'iconName': iconName,
      'points': points,
      'isEarned': isEarned,
      'progress': progress,
      'target': target,
      'earnedDate': earnedDate?.toIso8601String(),
    };
  }

  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _safeParseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    if (value is int) return value != 0;
    return null;
  }

  static DateTime? _safeParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
