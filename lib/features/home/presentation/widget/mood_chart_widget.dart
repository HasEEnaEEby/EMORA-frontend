import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/mood_chart_painter.dart';
import 'package:flutter/material.dart';


class MoodChartWidget extends StatelessWidget {
  final Map<String, List<MoodData>> data;
  final AnimationController animationController;
  final int selectedDayIndex;
  final Function(int) onDaySelected;
  final VoidCallback onDayDeselected;

  const MoodChartWidget({
    super.key,
    required this.data,
    required this.animationController,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.onDayDeselected,
  });

  @override
  Widget build(BuildContext context) {
    final moodData = data.values.first;
    final avgMood =
        moodData.map((d) => d.value).reduce((a, b) => a + b) / moodData.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
              const Color(0xFF16213E).withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Trend',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Average mood: ${_getMoodLabel(avgMood)} (${(avgMood * 10).toStringAsFixed(1)}/10)',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _getTrendColor(avgMood).withValues(alpha: 0.2),
                  ),
                  child: Text(
                    _getTrendText(avgMood),
                    style: TextStyle(
                      color: _getTrendColor(avgMood),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return GestureDetector(
                    onTapDown: (details) =>
                        _handleTap(details.localPosition, context),
                    child: CustomPaint(
                      painter: MoodChartPainter(
                        moodData,
                        animationController.value,
                        selectedDayIndex,
                      ),
                      size: const Size(double.infinity, 200),
                    ),
                  );
                },
              ),
            ),
            if (selectedDayIndex >= 0 &&
                selectedDayIndex < moodData.length) ...[
              const SizedBox(height: 16),
              _buildSelectedDayInfo(moodData[selectedDayIndex]),
            ],
          ],
        ),
      ),
    );
  }

  void _handleTap(Offset position, BuildContext context) {
    final moodData = data.values.first;
    final stepX = MediaQuery.of(context).size.width / (moodData.length - 1);
    final index = (position.dx / stepX).round();

    if (index >= 0 && index < moodData.length) {
      onDaySelected(index);
    }
  }

  Widget _buildSelectedDayInfo(MoodData dayData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
            ),
            child: Text(dayData.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dayData.day} - ${dayData.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Mood Score: ${(dayData.value * 10).toStringAsFixed(1)}/10',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDayDeselected,
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(double value) {
    if (value >= 0.9) return 'Amazing';
    if (value >= 0.8) return 'Great';
    if (value >= 0.7) return 'Good';
    if (value >= 0.6) return 'Okay';
    if (value >= 0.4) return 'Down';
    return 'Low';
  }

  Color _getTrendColor(double value) {
    if (value >= 0.8) return const Color(0xFF10B981);
    if (value >= 0.6) return const Color(0xFF6366F1);
    return const Color(0xFFFF6B35);
  }

  String _getTrendText(double value) {
    if (value >= 0.8) return 'Excellent';
    if (value >= 0.6) return 'Good';
    return 'Needs Attention';
  }
}
