import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/emotion_entry_model.dart';

class TodaysJourneyWidget extends StatelessWidget {
  final List<EmotionEntryModel> todaysEmotions;
  final VoidCallback? onAddEmotion;
  final Function(EmotionEntryModel)? onEmotionTap;

  const TodaysJourneyWidget({
    super.key,
    required this.todaysEmotions,
    this.onAddEmotion,
    this.onEmotionTap,
  });

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
                'Today\'s Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onAddEmotion != null)
                GestureDetector(
                  onTap: onAddEmotion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Color(0xFF8B5CF6),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Log Mood',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildJourneyContent(),
        ],
      ),
    );
  }

  Widget _buildJourneyContent() {
    if (todaysEmotions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ...todaysEmotions.map((emotion) => _buildEmotionEntry(emotion)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmotionEntry(EmotionEntryModel emotion) {
    return GestureDetector(
      onTap: () => onEmotionTap?.call(emotion),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: emotion.moodColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: emotion.moodColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Emotion emoji and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotion.emotionEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(emotion.timestamp),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Emotion details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emotion.emotion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Intensity: ${emotion.intensityLabel}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  if (emotion.context != null && emotion.context!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      emotion.context!,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Intensity indicator
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: emotion.moodColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            color: const Color(0xFF8B5CF6),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No emotions logged today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the mood face above to start tracking your emotional journey',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          if (onAddEmotion != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddEmotion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Log Your First Mood'),
            ),
          ],
        ],
      ),
    );
  }
}

// Weekly insights preview widget
class WeeklyInsightsPreviewWidget extends StatelessWidget {
  final WeeklyInsightsModel? weeklyInsights;
  final VoidCallback? onViewAll;

  const WeeklyInsightsPreviewWidget({
    super.key,
    this.weeklyInsights,
    this.onViewAll,
  });

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
                'Weekly Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
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
          const SizedBox(height: 16),
          _buildInsightsContent(),
        ],
      ),
    );
  }

  Widget _buildInsightsContent() {
    if (weeklyInsights == null) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInsightRow(
            icon: Icons.emoji_emotions,
            title: 'Most Common Mood',
            value: weeklyInsights!.mostCommonMood,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            icon: Icons.analytics,
            title: 'Average Score',
            value: '${weeklyInsights!.averageMoodScore.toStringAsFixed(1)}/5.0',
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          _buildInsightRow(
            icon: Icons.local_fire_department,
            title: 'Current Streak',
            value: '${weeklyInsights!.currentStreak} days',
            color: const Color(0xFFFF6B6B),
          ),
          if (weeklyInsights!.insights.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
            ...weeklyInsights!.insights.take(2).map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFFFFD700),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            color: const Color(0xFF8B5CF6),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'No insights yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log more emotions to see personalized insights',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 