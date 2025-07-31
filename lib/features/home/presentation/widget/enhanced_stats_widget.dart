import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/logger.dart';
import '../../data/data_source/remote/emotion_api_service.dart';
import '../../data/model/emotion_entry_model.dart';

class EnhancedStatsWidget extends StatefulWidget {
  final List<EmotionEntryModel> emotionEntries;
  final VoidCallback? onStatsTap;

  const EnhancedStatsWidget({
    super.key,
    this.emotionEntries = const [],
    this.onStatsTap,
  });

  @override
  State<EnhancedStatsWidget> createState() => _EnhancedStatsWidgetState();
}

class _EnhancedStatsWidgetState extends State<EnhancedStatsWidget> {
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
      Logger.info('. No emotion entries provided for enhanced stats');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info('. Loading enhanced stats data');
      
      final emotionApiService = GetIt.instance<EmotionApiService>();
      final stats = await emotionApiService.getEmotionStats(period: '7d');
      
      setState(() {
        _statsData = stats;
        _isLoading = false;
      });
      
      Logger.info('. Enhanced stats loaded successfully');
    } catch (e) {
      Logger.error('. Failed to load enhanced stats: $e');
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Quick Stats',
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
              if (widget.onStatsTap != null && !_isLoading)
                GestureDetector(
                  onTap: widget.onStatsTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalLogs = _statsData?['totalEntries'] ?? widget.emotionEntries.length;
    final currentStreak = _statsData?['currentStreak'] ?? _calculateCurrentStreak();
    final averageMood = _statsData?['averageIntensity']?.toStringAsFixed(1) ?? _calculateAverageMood().toStringAsFixed(1);

    Logger.info('. Stats Data: $_statsData');
    Logger.info('. Total Logs: $totalLogs, Current Streak: $currentStreak, Average Mood: $averageMood');

    if (totalLogs == 0 && widget.emotionEntries.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
childAspectRatio: 1.2, 
      children: [
        _buildStatCard(
          icon: Icons.timeline,
          title: 'Total Logs',
          value: totalLogs.toString(),
          subtitle: 'emotions tracked',
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildStatCard(
          icon: Icons.local_fire_department,
          title: 'Current Streak',
          value: currentStreak.toString(),
          subtitle: 'days in a row',
          color: const Color(0xFFFF6B6B),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _buildStatCard(
          icon: Icons.analytics,
          title: 'Average Mood',
          value: averageMood,
          subtitle: 'out of 5.0',
          color: const Color(0xFF4CAF50),
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
          begin: gradient.begin,
          end: gradient.end,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 1),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 7,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCurrentStreak() {
    if (widget.emotionEntries.isEmpty) return 0;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sortedEntries = List<EmotionEntryModel>.from(widget.emotionEntries)
..sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
    
    int streak = 0;
    DateTime currentDate = today;

    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      final daysDiff = currentDate.difference(entryDate).inDays;
      
      if (daysDiff == 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (daysDiff == 1) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  double _calculateAverageMood() {
    if (widget.emotionEntries.isEmpty) return 0.0;
    
    final totalIntensity = widget.emotionEntries.map((e) => e.intensity).reduce((a, b) => a + b);
    return totalIntensity / widget.emotionEntries.length;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: const Color(0xFF8B5CF6),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No emotion data yet',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start logging emotions to see your statistics',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 