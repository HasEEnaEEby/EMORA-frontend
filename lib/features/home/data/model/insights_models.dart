import 'dart:ui';

class MoodData {
  final String day;
  final double value;
  final String label;
  final String emoji;
  final DateTime timestamp;

  MoodData(this.day, this.value, this.label, this.emoji, this.timestamp);
}

class InsightCard {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final double trend;
  final String category;

  InsightCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.trend,
    required this.category,
  });
}

class PatternInsight {
  final String emoji;
  final String title;
  final String description;
  final double strength;
  final String category;
  final String details;

  PatternInsight({
    required this.emoji,
    required this.title,
    required this.description,
    required this.strength,
    required this.category,
    required this.details,
  });
}

class RecommendationItem {
  final String emoji;
  final String title;
  final String description;
  final String impact;
  final Color impactColor;

  RecommendationItem({
    required this.emoji,
    required this.title,
    required this.description,
    required this.impact,
    required this.impactColor,
  });
}

class MoodDistributionItem {
  final String emoji;
  final String label;
  final double percentage;
  final Color color;

  MoodDistributionItem({
    required this.emoji,
    required this.label,
    required this.percentage,
    required this.color,
  });
}
