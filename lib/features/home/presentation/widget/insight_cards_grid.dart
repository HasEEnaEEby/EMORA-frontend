// lib/features/home/presentation/widget/insight_cards_grid.dart
import 'dart:math' as math;

import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:flutter/material.dart';

class InsightCardsGrid extends StatelessWidget {
  final List<InsightCard> insights;
  final AnimationController animationController;

  const InsightCardsGrid({
    super.key,
    required this.insights,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Insights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: insights.length,
                itemBuilder: (context, index) {
                  final insight = insights[index];
                  final delay = index * 0.1;
                  final animationValue = math.max(
                    0.0,
                    math.min(1.0, animationController.value - delay),
                  );

                  return Transform.scale(
                    scale: 0.8 + (0.2 * animationValue),
                    child: Opacity(
                      opacity: animationValue,
                      child: _buildInsightCard(insight, context),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(InsightCard insight, BuildContext context) {
    return GestureDetector(
      onTap: () => _showInsightDetail(insight, context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: insight.color.withValues(alpha: 0.1),
          border: Border.all(color: insight.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(insight.emoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                if (insight.trend != 0)
                  Icon(
                    insight.trend > 0 ? Icons.trending_up : Icons.trending_down,
                    color: insight.trend > 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight.title,
              style: TextStyle(
                color: insight.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                insight.description,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInsightDetail(InsightCard insight, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: insight.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: insight.color.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    insight.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: TextStyle(
                          color: insight.color,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        insight.description,
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(
                      'What This Means',
                      _getInsightExplanation(insight),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      'How to Improve',
                      _getInsightTips(insight),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailSection(
                      'Related Patterns',
                      _getRelatedPatterns(insight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  String _getInsightExplanation(InsightCard insight) {
    switch (insight.category) {
      case 'improvement':
        return 'Your mood has shown consistent improvement over the selected period. This indicates positive changes in your emotional patterns and suggests that your current habits and activities are having a beneficial impact on your wellbeing.';
      case 'pattern':
        return 'We\'ve identified specific times when you tend to feel your best. Understanding these patterns can help you plan important activities during your peak emotional hours and be more mindful during challenging times.';
      case 'achievement':
        return 'Consistency in mood tracking shows commitment to your emotional wellness journey. Regular check-ins help build self-awareness and provide valuable data for understanding your emotional patterns.';
      case 'highlight':
        return 'This represents your peak emotional moment during the selected period. Understanding what contributed to this positive experience can help you recreate similar conditions in the future.';
      default:
        return 'This insight provides valuable information about your emotional patterns and can help guide your wellness journey.';
    }
  }

  String _getInsightTips(InsightCard insight) {
    switch (insight.category) {
      case 'improvement':
        return 'Continue your current positive habits. Consider keeping a brief note about what\'s working well so you can maintain these beneficial patterns. Small consistent improvements compound over time.';
      case 'pattern':
        return 'Schedule important meetings, creative work, or challenging conversations during your peak mood hours when possible. Use your low-energy times for routine tasks or self-care activities.';
      case 'achievement':
        return 'Keep up the great work! Consider setting mood tracking reminders to maintain this streak. You might also explore adding quick notes about what influenced your mood each day.';
      case 'highlight':
        return 'Reflect on what made this day special. Was it activities, people, environment, or mindset? Try to incorporate elements of this positive experience into your regular routine.';
      default:
        return 'Use this insight to make small, positive changes to your daily routine that align with your emotional patterns.';
    }
  }

  String _getRelatedPatterns(InsightCard insight) {
    return 'Based on your data, this insight connects to your sleep patterns, social interactions, and physical activity levels. Consider how these factors might be influencing each other to create a more holistic approach to your emotional wellness.';
  }
}
