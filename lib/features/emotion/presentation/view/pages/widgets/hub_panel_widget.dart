import 'package:flutter/material.dart';

class HubPanelWidget extends StatelessWidget {
  final Animation<double> hubAnimation;
  final String activeFeature;
  final List<dynamic> emotionalCommunities;
  final List<dynamic> personalInsights;
  final List<dynamic> emotionalTrends;
  final Map<String, dynamic> globalPatterns;
  final Function(String) onFeatureChanged;
  final VoidCallback onClose;

  const HubPanelWidget({
    super.key,
    required this.hubAnimation,
    required this.activeFeature,
    required this.emotionalCommunities,
    required this.personalInsights,
    required this.emotionalTrends,
    required this.globalPatterns,
    required this.onFeatureChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: hubAnimation,
      child: Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1a1a2e).withValues(alpha: 0.95),
                const Color(0xFF16213e).withValues(alpha: 0.90),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildFeatureTabs(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withValues(alpha: 0.2),
            const Color(0xFFFF5722).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              ),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emotional Intelligence Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Discover global emotional patterns',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs() {
    final features = [
      {'id': 'patterns', 'label': 'Patterns', 'icon': Icons.analytics_rounded},
      {'id': 'communities', 'label': 'Communities', 'icon': Icons.people_rounded},
      {'id': 'insights', 'label': 'Insights', 'icon': Icons.lightbulb_rounded},
      {'id': 'trends', 'label': 'Trends', 'icon': Icons.trending_up_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: features.map((feature) {
          final isActive = feature['id'] == activeFeature;
          return Expanded(
            child: GestureDetector(
              onTap: () => onFeatureChanged(feature['id'] as String),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        )
                      : null,
                  color: isActive ? null : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFFF9800)
                        : Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['label'] as String,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (activeFeature) {
      case 'patterns':
        return _buildPatternsContent();
      case 'communities':
        return _buildCommunitiesContent();
      case 'insights':
        return _buildInsightsContent();
      case 'trends':
        return _buildTrendsContent();
      default:
        return _buildPatternsContent();
    }
  }

  Widget _buildPatternsContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPatternCard(
            time: '6-9 AM',
            emotion: 'Calm',
            intensity: 'High',
            description: 'Most people start their day with calmness and focus',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildPatternCard(
            time: '12-2 PM',
            emotion: 'Energetic',
            intensity: 'Medium',
            description: 'Peak energy levels during lunch hours',
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 12),
          _buildPatternCard(
            time: '6-9 PM',
            emotion: 'Relaxed',
            intensity: 'High',
            description: 'Evening relaxation and family time',
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitiesContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCommunityCard(
            name: 'Joyful Souls',
            emotion: 'Joy',
            memberCount: 1247,
            description: 'Community of people experiencing joy and happiness',
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 12),
          _buildCommunityCard(
            name: 'Peace Seekers',
            emotion: 'Calm',
            memberCount: 892,
            description: 'People finding inner peace and tranquility',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildCommunityCard(
            name: 'Creative Minds',
            emotion: 'Focus',
            memberCount: 567,
            description: 'Artists and creators sharing their passion',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInsightCard(
            type: 'emotional_pattern',
            title: 'Your Joy Peaks',
            description: 'You\'re most joyful on weekends, especially in the morning',
            confidence: 0.85,
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            type: 'social_connection',
            title: 'Community Impact',
            description: 'Your positive emotions influence 3 people in your network',
            confidence: 0.72,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildInsightCard(
            type: 'emotional_growth',
            title: 'Emotional Growth',
            description: 'Your emotional awareness has increased by 23% this month',
            confidence: 0.91,
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTrendCard(
            emotion: 'Joy',
            trend: 'increasing',
            percentage: 15.3,
            timeframe: '7 days',
            description: 'Global joy levels are rising, possibly due to recent positive events',
            color: const Color(0xFFFFD700),
          ),
          const SizedBox(height: 12),
          _buildTrendCard(
            emotion: 'Anxiety',
            trend: 'decreasing',
            percentage: 8.7,
            timeframe: '7 days',
            description: 'Anxiety levels are decreasing globally',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildTrendCard(
            emotion: 'Focus',
            trend: 'stable',
            percentage: 2.1,
            timeframe: '7 days',
            description: 'Focus levels remain stable across regions',
            color: const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard({
    required String time,
    required String emotion,
    required String intensity,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      intensity,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  emotion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard({
    required String name,
    required String emotion,
    required int memberCount,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.people_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$memberCount members',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  emotion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String type,
    required String title,
    required String description,
    required double confidence,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(confidence * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard({
    required String emotion,
    required String trend,
    required double percentage,
    required String timeframe,
    required String description,
    required Color color,
  }) {
    final trendIcon = trend == 'increasing' 
        ? Icons.trending_up_rounded 
        : trend == 'decreasing' 
            ? Icons.trending_down_rounded 
            : Icons.trending_flat_rounded;
    
    final trendColor = trend == 'increasing' 
        ? const Color(0xFF4CAF50) 
        : trend == 'decreasing' 
            ? const Color(0xFFE91E63) 
            : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.2),
            ),
            child: Icon(
              trendIcon,
              color: trendColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      emotion,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${trend.toUpperCase()} • $timeframe',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
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