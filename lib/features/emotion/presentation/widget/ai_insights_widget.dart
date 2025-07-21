import 'package:flutter/material.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';

class AIInsightsWidget extends StatelessWidget {
  final EmotionInsight? insight;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? errorMessage;

  const AIInsightsWidget({
    super.key,
    this.insight,
    this.isLoading = false,
    this.onRefresh,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingState()
          else if (errorMessage != null)
            _buildErrorState()
          else if (insight != null)
            _buildInsightContent()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.psychology,
          color: const Color(0xFF8B5CF6),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Emotional Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (insight != null)
                Text(
                  '${insight!.region} • ${_formatTimeRange(insight!.timeRange)}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
        if (onRefresh != null)
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh insights',
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFF8B5CF6),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing emotional patterns...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load insights',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Please try again later',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.insights,
            color: Colors.grey.shade600,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No insights available',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI insights will appear here once\nsufficient emotion data is available',
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

  Widget _buildInsightContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsightText(),
        const SizedBox(height: 20),
        _buildEmotionBreakdown(),
        if (insight!.contextStats.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildContextStats(),
        ],
        const SizedBox(height: 16),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildInsightText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: const Color(0xFF8B5CF6),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight!.insight,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emotion Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...insight!.summary.take(5).map((summary) => _buildEmotionItem(summary)),
      ],
    );
  }

  Widget _buildEmotionItem(EmotionSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getEmotionColor(summary.emotion),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getEmotionDisplayName(summary.emotion),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${summary.count} (${summary.percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${summary.avgIntensity.toStringAsFixed(1)}/5',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Context Patterns',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (insight!.contextStats['weather'] != null)
          _buildContextSection('Weather', insight!.contextStats['weather']),
        if (insight!.contextStats['timeOfDay'] != null)
          _buildContextSection('Time of Day', insight!.contextStats['timeOfDay']),
        if (insight!.contextStats['socialContext'] != null)
          _buildContextSection('Social Context', insight!.contextStats['socialContext']),
      ],
    );
  }

  Widget _buildContextSection(String title, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: data.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.grey.shade600,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '${insight!.totalEmotions} emotions analyzed • ${_formatDateTime(insight!.lastUpdated)}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
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

  String _formatTimeRange(String timeRange) {
    switch (timeRange) {
      case '24h': return 'Past 24 hours';
      case '7d': return 'Past 7 days';
      case '30d': return 'Past 30 days';
      default: return 'Recent period';
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
} 