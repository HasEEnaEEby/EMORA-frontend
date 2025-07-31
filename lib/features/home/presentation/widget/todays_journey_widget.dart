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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotion.emotionEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(emotion.createdAt),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
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
                  if (emotion.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      emotion.note.isNotEmpty ? emotion.note : 'No note',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
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
