// lib/features/home/presentation/widget/emotion_list_view_widget.dart
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmotionListViewWidget extends StatefulWidget {
  final List<EmotionEntryModel> emotions;
  final Function(EmotionEntryModel)? onEmotionTap;
  final Function(EmotionEntryModel)? onEmotionEdit;
  final Function(EmotionEntryModel)? onEmotionDelete;
  final bool showDateHeaders;
  final bool isLoading;
  final String emptyStateMessage;
  final Widget? emptyStateWidget;
  final bool allowSelection;
  final List<String> selectedEmotionIds;
  final Function(String)? onSelectionChanged;

  const EmotionListViewWidget({
    super.key,
    required this.emotions,
    this.onEmotionTap,
    this.onEmotionEdit,
    this.onEmotionDelete,
    this.showDateHeaders = true,
    this.isLoading = false,
    this.emptyStateMessage = 'No emotions logged yet',
    this.emptyStateWidget,
    this.allowSelection = false,
    this.selectedEmotionIds = const [],
    this.onSelectionChanged,
  });

  @override
  State<EmotionListViewWidget> createState() => _EmotionListViewWidgetState();
}

class _EmotionListViewWidgetState extends State<EmotionListViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late Animation<double> _listAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutCubic,
    ));

    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.emotions.isEmpty) {
      return widget.emptyStateWidget ?? _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_listAnimation),
            child: _buildEmotionList(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading emotions...',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 64,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyStateMessage,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your emotions to see your emotional journey here.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionList() {
    if (!widget.showDateHeaders) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.emotions.length,
        itemBuilder: (context, index) {
          return _buildEmotionItem(widget.emotions[index], index);
        },
      );
    }

    // Group emotions by date
    final groupedEmotions = _groupEmotionsByDate(widget.emotions);
    final dates = groupedEmotions.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final date = dates[index];
        final emotionsForDate = groupedEmotions[date]!;
        return _buildDateSection(date, emotionsForDate);
      },
    );
  }

  Map<DateTime, List<EmotionEntryModel>> _groupEmotionsByDate(
      List<EmotionEntryModel> emotions) {
    final Map<DateTime, List<EmotionEntryModel>> grouped = {};
    
    for (final emotion in emotions) {
      final date = DateTime(
        emotion.createdAt.year,
        emotion.createdAt.month,
        emotion.createdAt.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(emotion);
    }
    
    // Sort emotions within each date by time (newest first)
    for (final emotions in grouped.values) {
      emotions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    return grouped;
  }

  Widget _buildDateSection(DateTime date, List<EmotionEntryModel> emotions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader(date, emotions.length),
        ...emotions.asMap().entries.map((entry) {
          final index = entry.key;
          final emotion = entry.value;
          return _buildEmotionItem(emotion, index, showDate: false);
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date, int emotionCount) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    String dateText;
    if (date.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (date.isAtSameMomentAs(yesterday)) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMM dd').format(date);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        const Color(0xFF6366F1).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 16,
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$emotionCount ${emotionCount == 1 ? 'entry' : 'entries'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionItem(
    EmotionEntryModel emotion, 
    int index, {
    bool showDate = true,
  }) {
    final isSelected = widget.selectedEmotionIds.contains(emotion.id);
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleEmotionTap(emotion),
          onLongPress: widget.allowSelection 
              ? () => _handleEmotionLongPress(emotion)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                          ? emotion.moodColor.withValues(alpha: 0.1)
        : const Color(0xFF1A1A2E).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                            ? emotion.moodColor.withValues(alpha: 0.5)
        : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: emotion.moodColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                // Emotion icon and info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: emotion.intensityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emotion.emotionEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            emotion.emotion.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: emotion.intensityColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              emotion.intensity.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Time and location
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            showDate 
                                ? emotion.formattedDateTime 
                                : emotion.formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (emotion.hasLocation) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                          ],
                        ],
                      ),
                      
                      // Note preview
                      if (emotion.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          emotion.note,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade300,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Tags preview
                      if (emotion.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: emotion.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                                      decoration: BoxDecoration(
          color: emotion.moodColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: emotion.moodColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Actions and selection
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.allowSelection)
                      Checkbox(
                        value: isSelected,
                        onChanged: (_) => _handleEmotionLongPress(emotion),
                        activeColor: emotion.moodColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    
                    // Intensity indicator
                    _buildCompactIntensityIndicator(emotion),
                    
                    const SizedBox(height: 8),
                    
                    // Quick actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      color: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onSelected: (value) => _handlePopupMenuAction(value, emotion),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text('View Details', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        if (widget.onEmotionEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              Icon(Icons.share, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Share', style: TextStyle(color: Colors.green)),
                            ],
                          ),
                        ),
                        if (widget.onEmotionDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIntensityIndicator(EmotionEntryModel emotion) {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1),
          height: 3,
          width: 12,
          decoration: BoxDecoration(
            color: index < emotion.intensity
                ? emotion.intensityColor
                : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }).reversed.toList(),
    );
  }

  void _handleEmotionTap(EmotionEntryModel emotion) {
    if (widget.allowSelection && widget.selectedEmotionIds.isNotEmpty) {
      _handleEmotionLongPress(emotion);
    } else if (widget.onEmotionTap != null) {
      widget.onEmotionTap!(emotion);
    } else {
      _showEmotionDetail(emotion);
    }
  }

  void _handleEmotionLongPress(EmotionEntryModel emotion) {
    if (widget.allowSelection && widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(emotion.id);
    }
  }

  void _handlePopupMenuAction(String action, EmotionEntryModel emotion) {
    switch (action) {
      case 'view':
        _showEmotionDetail(emotion);
        break;
      case 'edit':
        widget.onEmotionEdit?.call(emotion);
        break;
      case 'share':
        _shareEmotion(emotion);
        break;
      case 'delete':
        _confirmDelete(emotion);
        break;
    }
  }

  void _showEmotionDetail(EmotionEntryModel emotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: emotion.moodColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.sentiment_satisfied,
                                color: emotion.moodColor,
                                size: 24,
                              ),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    emotion.formattedDateTime,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Intensity
                        Text(
                          'Intensity: ${emotion.intensityLabel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 4),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: index < emotion.intensity
                                    ? emotion.moodColor
                                    : Colors.grey.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        
                        // Note
                        if (emotion.note.isNotEmpty) ...[
                          Text(
                            'Note',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              emotion.note,
                              style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Actions
                        Row(
                          children: [
                            if (widget.onEmotionEdit != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onEmotionEdit!(emotion);
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            if (widget.onEmotionEdit != null && widget.onEmotionDelete != null)
                              const SizedBox(width: 12),
                            if (widget.onEmotionDelete != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onEmotionDelete!(emotion);
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _shareEmotion(EmotionEntryModel emotion) {
    // Implementation would depend on share_plus package
    // final shareText = '''
    // 🎭 ${emotion.emotion} (${emotion.intensityLabel})
    // 📅 ${emotion.formattedDateTime}
    // ${emotion.note.isNotEmpty ? '📝 ${emotion.note}' : ''}
    // #EmotionTracking
    // ''';
    
    // Share.share(shareText);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${emotion.emotion}'),
        backgroundColor: emotion.moodColor,
      ),
    );
  }

  void _confirmDelete(EmotionEntryModel emotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Emotion',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this ${emotion.emotion} emotion?',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onEmotionDelete?.call(emotion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}