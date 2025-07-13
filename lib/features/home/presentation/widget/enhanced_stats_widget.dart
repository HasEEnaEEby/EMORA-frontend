import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/emotion_entry_model.dart';

class EnhancedStatsWidget extends StatelessWidget {
  final int totalLogs;
  final int currentStreak;
  final double averageMood;
  final List<EmotionEntryModel> emotionEntries;
  final VoidCallback? onStatsTap;

  const EnhancedStatsWidget({
    super.key,
    required this.totalLogs,
    required this.currentStreak,
    required this.averageMood,
    this.emotionEntries = const [],
    this.onStatsTap,
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
                'Quick Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onStatsTap != null)
                GestureDetector(
                  onTap: onStatsTap,
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
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
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
          value: averageMood.toStringAsFixed(1),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
          begin: gradient.begin,
          end: gradient.end,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Enhanced calendar widget for emotion tracking
class EmotionCalendarWidget extends StatefulWidget {
  final List<EmotionEntryModel> emotionEntries;
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;

  const EmotionCalendarWidget({
    super.key,
    required this.emotionEntries,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  State<EmotionCalendarWidget> createState() => _EmotionCalendarWidgetState();
}

class _EmotionCalendarWidgetState extends State<EmotionCalendarWidget> {
  late DateTime _focusedDay;
  late DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Emotional Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: _buildCalendar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    // For now, we'll create a simple calendar-like widget
    // In a real implementation, you'd use table_calendar package
    return Column(
      children: [
        _buildCalendarHeader(),
        const SizedBox(height: 16),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left, color: Colors.white),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    return Column(
      children: [
        // Day headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        ...List.generate((daysInMonth + firstWeekday - 1) ~/ 7 + 1, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              final emotionsForDay = _getEmotionsForDate(date);
              final isSelected = _selectedDay?.year == date.year &&
                  _selectedDay?.month == date.month &&
                  _selectedDay?.day == date.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = date;
                    });
                    widget.onDateSelected(date);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : emotionsForDay.isNotEmpty
                              ? _getDominantMoodColor(emotionsForDay)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : emotionsForDay.isNotEmpty
                                ? _getDominantMoodColor(emotionsForDay)
                                : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : emotionsForDay.isNotEmpty
                                  ? Colors.white
                                  : Colors.grey[400],
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  List<EmotionEntryModel> _getEmotionsForDate(DateTime date) {
    return widget.emotionEntries.where((emotion) {
      final emotionDate = DateTime(
        emotion.timestamp.year,
        emotion.timestamp.month,
        emotion.timestamp.day,
      );
      return emotionDate.isAtSameMomentAs(date);
    }).toList();
  }

  Color _getDominantMoodColor(List<EmotionEntryModel> emotions) {
    if (emotions.isEmpty) return Colors.transparent;
    
    // Calculate average intensity and determine color
    final avgIntensity = emotions.map((e) => e.intensity).reduce((a, b) => a + b) / emotions.length;
    
    if (avgIntensity >= 0.7) {
      return const Color(0xFF4CAF50).withOpacity(0.8); // Green for positive
    } else if (avgIntensity <= 0.3) {
      return const Color(0xFFFF6B6B).withOpacity(0.8); // Red for negative
    } else {
      return const Color(0xFFFFD700).withOpacity(0.8); // Yellow for neutral
    }
  }
} 