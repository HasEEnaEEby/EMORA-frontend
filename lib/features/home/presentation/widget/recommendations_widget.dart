import 'package:emora_mobile_app/features/home/data/mock_insights_data.dart';
import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:flutter/material.dart';

class RecommendationsWidget extends StatelessWidget {
  final Map<String, dynamic>? analyticsData;
  
  const RecommendationsWidget({
    super.key,
    this.analyticsData,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.1),
              const Color(0xFF059669).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Color(0xFF10B981), size: 24),
                SizedBox(width: 8),
                Text(
                  'Personalized Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map(
              (recommendation) => _buildRecommendationItem(
                recommendation.emoji,
                recommendation.title,
                recommendation.description,
                recommendation.impact,
                recommendation.impactColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<RecommendationItem> _getRecommendations() {
    if (analyticsData == null || analyticsData!.isEmpty) {
      return MockInsightsData.getRecommendations();
    }

    final recommendations = <RecommendationItem>[];
    
    final totalEntries = analyticsData!['totalEntries'] as int? ?? 0;
    final dominantEmotion = analyticsData!['dominantEmotion'] as String?;
    final moodTrend = analyticsData!['moodTrend'] as String?;
    final musicRecommendation = analyticsData!['musicRecommendation'] as String?;
    
    if (totalEntries == 0) {
      recommendations.add(RecommendationItem(
        emoji: '🎯',
        title: 'Start Tracking',
        description: 'Begin logging your emotions to get personalized insights',
        impact: 'Essential',
        impactColor: const Color(0xFF8B5CF6),
      ));
    } else if (totalEntries < 5) {
      recommendations.add(RecommendationItem(
        emoji: '📈',
        title: 'Keep Going',
        description: 'Log more emotions to unlock detailed patterns',
        impact: 'High',
        impactColor: const Color(0xFF10B981),
      ));
    }
    
    if (dominantEmotion != null) {
      switch (dominantEmotion) {
        case 'sadness':
        case 'anxiety':
        case 'fear':
          recommendations.add(RecommendationItem(
            emoji: '🧘',
            title: 'Mindfulness Practice',
            description: 'Try meditation or deep breathing exercises',
            impact: 'High',
            impactColor: const Color(0xFF10B981),
          ));
          break;
        case 'anger':
        case 'frustration':
          recommendations.add(RecommendationItem(
            emoji: '🏃',
            title: 'Physical Activity',
            description: 'Exercise can help release tension and improve mood',
            impact: 'Medium',
            impactColor: const Color(0xFFFFD700),
          ));
          break;
        case 'joy':
        case 'gratitude':
          recommendations.add(RecommendationItem(
            emoji: '🌟',
            title: 'Share Positivity',
            description: 'Connect with others and spread your positive energy',
            impact: 'High',
            impactColor: const Color(0xFF4CAF50),
          ));
          break;
      }
    }
    
    if (moodTrend == 'needs_attention') {
      recommendations.add(RecommendationItem(
        emoji: '💬',
        title: 'Talk to Someone',
        description: 'Consider reaching out to friends, family, or a professional',
        impact: 'High',
        impactColor: const Color(0xFF10B981),
      ));
    }
    
    if (musicRecommendation != null && musicRecommendation != 'Start logging emotions to get personalized recommendations') {
      recommendations.add(RecommendationItem(
        emoji: '🎵',
        title: 'Music Therapy',
        description: musicRecommendation,
        impact: 'Medium',
        impactColor: const Color(0xFF8B5CF6),
      ));
    }
    
    return recommendations.isNotEmpty ? recommendations : MockInsightsData.getRecommendations();
  }

  Widget _buildRecommendationItem(
    String emoji,
    String title,
    String description,
    String impact,
    Color impactColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: impactColor.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        impact,
                        style: TextStyle(
                          color: impactColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
