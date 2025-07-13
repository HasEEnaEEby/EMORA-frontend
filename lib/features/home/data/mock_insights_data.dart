import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:flutter/material.dart';

class MockInsightsData {
  static Map<String, List<MoodData>> getMoodData(String period) {
    final data = {
      'week': [
        MoodData(
          'Mon',
          0.7,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 6)),
        ),
        MoodData(
          'Tue',
          0.8,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 5)),
        ),
        MoodData(
          'Wed',
          0.6,
          'Okay',
          '😐',
          DateTime.now().subtract(const Duration(days: 4)),
        ),
        MoodData(
          'Thu',
          0.9,
          'Amazing',
          '🤩',
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        MoodData(
          'Fri',
          0.8,
          'Great',
          '😊',
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        MoodData(
          'Sat',
          0.95,
          'Excellent',
          '🌟',
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        MoodData('Sun', 0.75, 'Good', '😌', DateTime.now()),
      ],
      'month': [
        MoodData(
          'Week 1',
          0.75,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 21)),
        ),
        MoodData(
          'Week 2',
          0.65,
          'Okay',
          '😐',
          DateTime.now().subtract(const Duration(days: 14)),
        ),
        MoodData(
          'Week 3',
          0.85,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 7)),
        ),
        MoodData('Week 4', 0.80, 'Good', '😊', DateTime.now()),
      ],
      'year': [
        MoodData(
          'Jan',
          0.65,
          'Okay',
          '😐',
          DateTime.now().subtract(const Duration(days: 330)),
        ),
        MoodData(
          'Feb',
          0.70,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 300)),
        ),
        MoodData(
          'Mar',
          0.75,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 270)),
        ),
        MoodData(
          'Apr',
          0.80,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 240)),
        ),
        MoodData(
          'May',
          0.85,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 210)),
        ),
        MoodData(
          'Jun',
          0.78,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 180)),
        ),
        MoodData(
          'Jul',
          0.82,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 150)),
        ),
        MoodData(
          'Aug',
          0.88,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 120)),
        ),
        MoodData(
          'Sep',
          0.75,
          'Good',
          '😊',
          DateTime.now().subtract(const Duration(days: 90)),
        ),
        MoodData(
          'Oct',
          0.90,
          'Amazing',
          '🤩',
          DateTime.now().subtract(const Duration(days: 60)),
        ),
        MoodData(
          'Nov',
          0.85,
          'Great',
          '😄',
          DateTime.now().subtract(const Duration(days: 30)),
        ),
        MoodData('Dec', 0.80, 'Good', '😊', DateTime.now()),
      ],
    };

    return {period: data[period] ?? data['week']!};
  }

  static List<InsightCard> getInsights() {
    return [
      InsightCard(
        emoji: '📈',
        title: 'Trending Up',
        description: 'Your mood improved 15% this week',
        color: const Color(0xFF10B981),
        trend: 0.15,
        category: 'improvement',
      ),
      InsightCard(
        emoji: '⏰',
        title: 'Best Time',
        description: 'You feel best around 10 AM',
        color: const Color(0xFF6366F1),
        trend: 0.0,
        category: 'pattern',
      ),
      InsightCard(
        emoji: '🎯',
        title: 'Streak',
        description: '7 days of mood tracking',
        color: const Color(0xFFFF6B35),
        trend: 0.0,
        category: 'achievement',
      ),
      InsightCard(
        emoji: '🌟',
        title: 'Highlight',
        description: 'Saturday was your best day',
        color: const Color(0xFFFFD700),
        trend: 0.0,
        category: 'highlight',
      ),
    ];
  }

  static List<PatternInsight> getPatterns() {
    return [
      PatternInsight(
        emoji: '🌅',
        title: 'Morning Boost',
        description: 'You tend to feel better in the mornings',
        strength: 0.85,
        category: 'time',
        details: 'Peak mood hours: 8-11 AM',
      ),
      PatternInsight(
        emoji: '☕',
        title: 'Coffee Connection',
        description: 'Mood improves after your first coffee',
        strength: 0.72,
        category: 'habit',
        details: 'Average improvement: +12% within 30 minutes',
      ),
      PatternInsight(
        emoji: '🏃',
        title: 'Exercise Effect',
        description: 'Working out consistently improves your mood',
        strength: 0.90,
        category: 'activity',
        details: 'Post-workout mood boost lasts 4-6 hours',
      ),
      PatternInsight(
        emoji: '😴',
        title: 'Sleep Impact',
        description: 'Better sleep = better mood the next day',
        strength: 0.78,
        category: 'health',
        details: '7+ hours of sleep correlates with higher mood',
      ),
      PatternInsight(
        emoji: '🌧️',
        title: 'Weather Influence',
        description: 'Sunny days boost your mood by 8%',
        strength: 0.65,
        category: 'environment',
        details: 'Mood drops on cloudy/rainy days',
      ),
      PatternInsight(
        emoji: '👥',
        title: 'Social Connection',
        description: 'Spending time with friends lifts your spirits',
        strength: 0.88,
        category: 'social',
        details: 'Social interactions add +15% to daily mood',
      ),
    ];
  }

  static List<RecommendationItem> getRecommendations() {
    return [
      RecommendationItem(
        emoji: '🌅',
        title: 'Morning Routine',
        description:
            'Start your day with 5 minutes of meditation to boost morning mood',
        impact: 'High Impact',
        impactColor: const Color(0xFF10B981),
      ),
      RecommendationItem(
        emoji: '🚶',
        title: 'Midday Walk',
        description:
            'Take a 10-minute walk around 2 PM when your energy typically dips',
        impact: 'Medium Impact',
        impactColor: const Color(0xFF6366F1),
      ),
      RecommendationItem(
        emoji: '📱',
        title: 'Digital Detox',
        description:
            'Consider reducing screen time 1 hour before bed for better sleep',
        impact: 'High Impact',
        impactColor: const Color(0xFF10B981),
      ),
    ];
  }

  static List<MoodDistributionItem> getMoodDistribution() {
    return [
      MoodDistributionItem(
        emoji: '🤩',
        label: 'Amazing',
        percentage: 25.0,
        color: const Color(0xFFFFD700),
      ),
      MoodDistributionItem(
        emoji: '😊',
        label: 'Good',
        percentage: 35.0,
        color: const Color(0xFF10B981),
      ),
      MoodDistributionItem(
        emoji: '😐',
        label: 'Okay',
        percentage: 25.0,
        color: const Color(0xFF6B7280),
      ),
      MoodDistributionItem(
        emoji: '😔',
        label: 'Down',
        percentage: 15.0,
        color: const Color(0xFF6366F1),
      ),
    ];
  }
}
