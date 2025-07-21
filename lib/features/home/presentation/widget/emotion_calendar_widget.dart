import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../data/model/emotion_entry_model.dart';

class EmotionCalendarWidget extends StatefulWidget {
  final List<EmotionEntryModel> emotionEntries;
  final Function(DateTime) onDateSelected;
  final DateTime? selectedDate;
  final bool isLoading;

  const EmotionCalendarWidget({
    super.key,
    required this.emotionEntries,
    required this.onDateSelected,
    this.selectedDate,
    this.isLoading = false,
  });

  @override
  State<EmotionCalendarWidget> createState() => _EmotionCalendarWidgetState();
}

class _EmotionCalendarWidgetState extends State<EmotionCalendarWidget> {
  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDate;
    _calendarFormat = CalendarFormat.month;
  }

  @override
  void didUpdateWidget(EmotionCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDay = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Emotion Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<EmotionEntryModel>(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDateSelected(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      eventLoader: (day) {
        return _getEmotionsForDay(day);
      },
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Colors.white),
        holidayTextStyle: TextStyle(color: Colors.white),
        defaultTextStyle: TextStyle(color: Colors.white),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayTextStyle: TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: Color(0xFF8B5CF6),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 6,
        markerMargin: EdgeInsets.symmetric(horizontal: 1),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Color(0xFF8B5CF6),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        formatButtonTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Color(0xFF8B5CF6),
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Color(0xFF8B5CF6),
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Legend',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildLegendItem('Positive', const Color(0xFF10B981)),
            const SizedBox(width: 16),
            _buildLegendItem('Neutral', const Color(0xFF6B7280)),
            const SizedBox(width: 16),
            _buildLegendItem('Negative', const Color(0xFFEF4444)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  List<EmotionEntryModel> _getEmotionsForDay(DateTime day) {
    return widget.emotionEntries.where((emotion) {
      final emotionDate = DateTime(
        emotion.createdAt.year,
        emotion.createdAt.month,
        emotion.createdAt.day,
      );
      final dayDate = DateTime(day.year, day.month, day.day);
      return emotionDate.isAtSameMomentAs(dayDate);
    }).toList();
  }
}

// Helper function to check if two dates are the same day
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
} 