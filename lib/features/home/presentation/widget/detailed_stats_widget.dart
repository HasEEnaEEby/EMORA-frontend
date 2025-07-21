// lib/features/home/presentation/widget/detailed_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/logger.dart';
import '../../data/data_source/remote/emotion_api_service.dart';
import '../../data/model/emotion_entry_model.dart';

class DetailedStatsWidget extends StatefulWidget {
  final String period;
  final List<EmotionEntryModel> emotionEntries;

  const DetailedStatsWidget({
    super.key, 
    required this.period,
    this.emotionEntries = const [],
  });

  @override
  State<DetailedStatsWidget> createState() => _DetailedStatsWidgetState();
}

class _DetailedStatsWidgetState extends State<DetailedStatsWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _statsData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatsData();
  }

  Future<void> _loadStatsData() async {
    if (widget.emotionEntries.isEmpty) {
      Logger.info('. No emotion entries provided, using demo data');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info('. Loading detailed stats for period: ${widget.period}');
      
      final emotionApiService = GetIt.instance<EmotionApiService>();
      final stats = await emotionApiService.getEmotionStats(period: widget.period);
      
      setState(() {
        _statsData = stats;
        _isLoading = false;
      });
      
      Logger.info('. Detailed stats loaded successfully');
    } catch (e) {
      Logger.error('. Failed to load detailed stats: $e');
      setState(() {
        _errorMessage = 'Failed to load statistics';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Detailed Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_errorMessage != null) const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 16),
            _buildMoodDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalEntries = _statsData?['totalEmotions'] ?? widget.emotionEntries.length;
    final bestStreak = _statsData?['longestStreak'] ?? _calculateBestStreak();
    final moodVariance = _statsData?['moodVariance'] ?? _calculateMoodVariance();
    final consistency = _statsData?['consistency'] ?? _calculateConsistency();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Entries',
                totalEntries.toString(),
                Icons.event_note,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Best Streak',
                '$bestStreak days',
                Icons.local_fire_department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Mood Variance',
                moodVariance,
                Icons.show_chart,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Consistency',
                '$consistency%',
                Icons.track_changes,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution() {
    final moodDistribution = _calculateMoodDistribution();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mood Distribution',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...moodDistribution.map(
          (mood) => _buildDistributionItem(
            mood['emoji'] as String,
            mood['label'] as String,
            mood['percentage'] as double,
            mood['color'] as Color,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionItem(
    String emoji,
    String label,
    double percentage,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[300], fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.grey[800],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: color,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to calculate statistics from emotion entries
  int _calculateBestStreak() {
    if (widget.emotionEntries.isEmpty) return 0;
    
    final sortedEntries = List<EmotionEntryModel>.from(widget.emotionEntries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    int currentStreak = 1;
    int bestStreak = 1;
    
    for (int i = 1; i < sortedEntries.length; i++) {
      final daysDiff = sortedEntries[i].createdAt.difference(sortedEntries[i - 1].createdAt).inDays;
      if (daysDiff == 1) {
        currentStreak++;
        bestStreak = bestStreak < currentStreak ? currentStreak : bestStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return bestStreak;
  }

  String _calculateMoodVariance() {
    if (widget.emotionEntries.isEmpty) return 'Low';
    
    final intensities = widget.emotionEntries.map((e) => e.intensity).toList();
    final mean = intensities.reduce((a, b) => a + b) / intensities.length;
    final variance = intensities.map((i) => (i - mean) * (i - mean)).reduce((a, b) => a + b) / intensities.length;
    
    if (variance < 0.5) return 'Low';
    if (variance < 1.0) return 'Medium';
    return 'High';
  }

  double _calculateConsistency() {
    if (widget.emotionEntries.isEmpty) return 0.0;
    
    final totalDays = widget.emotionEntries.length;
    final uniqueDays = widget.emotionEntries.map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)).toSet().length;
    
    return (uniqueDays / totalDays * 100).clamp(0.0, 100.0);
  }

  List<Map<String, dynamic>> _calculateMoodDistribution() {
    if (widget.emotionEntries.isEmpty) {
      return [
        {'emoji': '😊', 'label': 'Happy', 'percentage': 0.0, 'color': const Color(0xFF4CAF50)},
        {'emoji': '😐', 'label': 'Neutral', 'percentage': 0.0, 'color': const Color(0xFFFFD700)},
        {'emoji': '😔', 'label': 'Sad', 'percentage': 0.0, 'color': const Color(0xFFFF6B6B)},
      ];
    }

    final emotionCounts = <String, int>{};
    for (final entry in widget.emotionEntries) {
      final emotion = entry.emotion.toLowerCase();
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
    }

    final total = widget.emotionEntries.length;
    final distribution = <Map<String, dynamic>>[];

    // Categorize emotions
    final positiveEmotions = ['joy', 'happiness', 'excitement', 'love', 'gratitude', 'contentment', 'pride', 'relief', 'hope', 'enthusiasm', 'serenity', 'bliss'];
    final negativeEmotions = ['sadness', 'anger', 'fear', 'anxiety', 'frustration', 'disappointment', 'loneliness', 'stress', 'guilt', 'shame', 'jealousy', 'regret'];
    final neutralEmotions = ['calm', 'peaceful', 'neutral', 'focused', 'curious', 'thoughtful', 'contemplative', 'reflective', 'alert', 'balanced'];

    double positivePercentage = 0.0;
    double negativePercentage = 0.0;
    double neutralPercentage = 0.0;

    for (final entry in emotionCounts.entries) {
      final emotion = entry.key;
      final count = entry.value;
      final percentage = (count / total) * 100;

      if (positiveEmotions.contains(emotion)) {
        positivePercentage += percentage;
      } else if (negativeEmotions.contains(emotion)) {
        negativePercentage += percentage;
      } else {
        neutralPercentage += percentage;
      }
    }

    distribution.addAll([
      {'emoji': '😊', 'label': 'Positive', 'percentage': positivePercentage, 'color': const Color(0xFF4CAF50)},
      {'emoji': '😐', 'label': 'Neutral', 'percentage': neutralPercentage, 'color': const Color(0xFFFFD700)},
      {'emoji': '😔', 'label': 'Negative', 'percentage': negativePercentage, 'color': const Color(0xFFFF6B6B)},
    ]);

    return distribution;
  }
}
