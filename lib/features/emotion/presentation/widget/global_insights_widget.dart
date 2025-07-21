import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

class GlobalInsightsWidget extends StatelessWidget {
  final GlobalEmotionStats? stats;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const GlobalInsightsWidget({
    super.key,
    this.stats,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Global Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : stats == null
              ? _buildEmptyState()
              : _buildInsightsContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8B5CF6),
          ),
          SizedBox(height: 16),
          Text(
            'Loading global insights...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights,
            size: 64,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'No global data available',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Global insights will appear here once\nemotions are logged worldwide',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildEmotionBreakdownCard(),
          const SizedBox(height: 16),
          _buildIntensityTrendsCard(),
          const SizedBox(height: 16),
          _buildRegionalInsightsCard(),
          const SizedBox(height: 16),
          _buildRealTimeActivityCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.public,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Global Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Emotions',
                  '${stats?.totalEmotions ?? 0}',
                  Icons.sentiment_satisfied,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Avg Intensity',
                  '${(stats?.avgIntensity ?? 0.0).toStringAsFixed(1)}/5',
                  Icons.trending_up,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          if (stats?.lastUpdated != null) ...[
            const SizedBox(height: 16),
            Text(
              'Last updated: ${_formatDateTime(stats!.lastUpdated)}',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionBreakdownCard() {
    final coreEmotionStats = stats?.coreEmotionStats ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Emotion Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (coreEmotionStats.isEmpty)
            Center(
              child: Text(
                'No emotion data available',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: coreEmotionStats.entries.map((entry) {
                final emotion = entry.key;
                final stats = entry.value;
                final total = coreEmotionStats.values.fold<int>(0, (sum, s) => sum + (s.count ?? 0));
                final percentage = total > 0 ? stats.count / total * 100 : 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEmotionColor(emotion),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getEmotionDisplayName(emotion),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${stats.count} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildIntensityTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Intensity Trends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          stats?.coreEmotionStats.isNotEmpty == true
              ? SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade800,
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade800,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      minX: 0,
                      maxX: stats!.coreEmotionStats.length.toDouble(),
                      minY: 0,
                      maxY: 5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _buildIntensitySpots(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                              const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF8B5CF6),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'No intensity data available',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRegionalInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Regional Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          stats?.coreEmotionStats.isNotEmpty == true
              ? Column(
                  children: stats!.coreEmotionStats.entries.map((entry) {
                    final emotion = entry.key;
                    final emotionStats = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: _buildRegionalItem(
                        _getEmotionDisplayName(emotion),
                        emotion,
                        emotionStats.count,
                        emotionStats.avgIntensity,
                      ),
                    );
                  }).toList(),
                )
              : Center(
                  child: Text(
                    'No regional data available',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRegionalItem(String emotionName, String emotionKey, int count, double intensity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getEmotionColor(emotionKey).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getEmotionColor(emotionKey),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotionName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$count emotions logged',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${intensity.toStringAsFixed(1)}/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Avg Intensity',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeActivityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: const Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Real-Time Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          stats != null
              ? Row(
                  children: [
                    Expanded(
                      child: _buildActivityItem(
                        'Total Emotions',
                        '${stats!.totalEmotions}',
                        Icons.sentiment_satisfied,
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActivityItem(
                        'Avg Intensity',
                        '${stats!.avgIntensity.toStringAsFixed(1)}/5',
                        Icons.trending_up,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    'No activity data available',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return const Color(0xFFF59E0B);
      case 'trust': return const Color(0xFF10B981);
      case 'fear': return const Color(0xFF8B5CF6);
      case 'surprise': return const Color(0xFFF97316);
      case 'sadness': return const Color(0xFF3B82F6);
      case 'disgust': return const Color(0xFF059669);
      case 'anger': return const Color(0xFFEF4444);
      case 'anticipation': return const Color(0xFFFCD34D);
      default: return const Color(0xFF6B7280);
    }
  }

  String _getEmotionDisplayName(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return 'Joy';
      case 'trust': return 'Trust';
      case 'fear': return 'Fear';
      case 'surprise': return 'Surprise';
      case 'sadness': return 'Sadness';
      case 'disgust': return 'Disgust';
      case 'anger': return 'Anger';
      case 'anticipation': return 'Anticipation';
      default: return emotion;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  List<FlSpot> _buildIntensitySpots() {
    if (stats?.coreEmotionStats == null) return [];
    
    final spots = <FlSpot>[];
    int index = 0;
    
    for (final entry in stats!.coreEmotionStats.entries) {
      spots.add(FlSpot(index.toDouble(), entry.value.avgIntensity));
      index++;
    }
    
    return spots;
  }
} 