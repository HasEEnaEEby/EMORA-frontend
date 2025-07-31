import 'package:emora_mobile_app/features/emotion/presentation/widget/emotion_list_view_widget.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EnhancedEmotionsView extends StatefulWidget {
  const EnhancedEmotionsView({super.key});

  @override
  State<EnhancedEmotionsView> createState() => _EnhancedEmotionsViewState();
}

class _EnhancedEmotionsViewState extends State<EnhancedEmotionsView>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  List<String> _selectedEmotionIds = [];
  bool _isSelectionMode = false;
  String _searchQuery = '';
  String _filterEmotion = '';
  int _filterIntensity = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEmotions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadEmotions() {
    context.read<HomeBloc>().add(const LoadEmotionHistoryEvent(forceRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllEmotionsTab(),
                _buildTodayEmotionsTab(),
                _buildWeekEmotionsTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : _buildFloatingActionButton(),
      bottomSheet: _isSelectionMode ? _buildSelectionBottomSheet() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      title: _isSelectionMode
          ? Text('${_selectedEmotionIds.length} selected')
          : const Text(
              'Your Emotions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _exitSelectionMode,
              icon: const Icon(Icons.close, color: Colors.white),
            )
          : IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
      actions: [
        if (!_isSelectionMode) ...[
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A2E),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.checklist, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Select Multiple', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Export Data', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          IconButton(
            onPressed: _selectAll,
            icon: const Icon(Icons.select_all, color: Colors.white),
          ),
          IconButton(
            onPressed: _deleteSelected,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterSection() {
    if (_searchQuery.isEmpty && _filterEmotion.isEmpty && _filterIntensity == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Filters:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (_searchQuery.isNotEmpty)
                _buildFilterChip('Search: $_searchQuery', () {
                  setState(() => _searchQuery = '');
                }),
              if (_filterEmotion.isNotEmpty)
                _buildFilterChip('Emotion: $_filterEmotion', () {
                  setState(() => _filterEmotion = '');
                }),
              if (_filterIntensity > 0)
                _buildFilterChip('Intensity: $_filterIntensity', () {
                  setState(() => _filterIntensity = 0);
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF8B5CF6),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade400,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'Week'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAllEmotionsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeDashboardState) {
          final allEmotions = _getFilteredEmotions(state.emotionEntries);
          return _buildEmotionListView(allEmotions);
        }
        return _buildLoadingView();
      },
    );
  }

  Widget _buildTodayEmotionsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeDashboardState) {
          final todayEmotions = _getTodayEmotions(state.emotionEntries);
          final filteredEmotions = _getFilteredEmotions(todayEmotions);
          return _buildEmotionListView(
            filteredEmotions,
            emptyMessage: 'No emotions logged today',
          );
        }
        return _buildLoadingView();
      },
    );
  }

  Widget _buildWeekEmotionsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeDashboardState) {
          final weekEmotions = _getWeekEmotions(state.emotionEntries);
          final filteredEmotions = _getFilteredEmotions(weekEmotions);
          return _buildEmotionListView(
            filteredEmotions,
            emptyMessage: 'No emotions logged this week',
          );
        }
        return _buildLoadingView();
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeDashboardState) {
          return _buildAnalyticsView(state.emotionEntries);
        }
        return _buildLoadingView();
      },
    );
  }

  Widget _buildEmotionListView(
    List<EmotionEntryModel> emotions, {
    String emptyMessage = 'No emotions found',
  }) {
    return EmotionListViewWidget(
      emotions: emotions,
      onEmotionTap: _handleEmotionTap,
      onEmotionEdit: _handleEmotionEdit,
      onEmotionDelete: _handleEmotionDelete,
      allowSelection: _isSelectionMode,
      selectedEmotionIds: _selectedEmotionIds,
      onSelectionChanged: _handleSelectionChanged,
      emptyStateMessage: emptyMessage,
      showDateHeaders: true,
    );
  }

  Widget _buildAnalyticsView(List<EmotionEntryModel> emotions) {
    final enhancedEmotions = emotions.map((e) {
      return EmotionEntryModel.fromJson(e.toJson());
    }).toList();

    final stats = _calculateEmotionStats(enhancedEmotions);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard('Total Emotions', stats['total'].toString()),
          const SizedBox(height: 16),
          _buildStatsCard('Average Intensity', stats['avgIntensity'].toStringAsFixed(1)),
          const SizedBox(height: 16),
          _buildStatsCard('Most Common', stats['mostCommon'] ?? 'None'),
          const SizedBox(height: 16),
          _buildEmotionDistributionChart(enhancedEmotions),
          const SizedBox(height: 16),
          _buildIntensityTrendChart(enhancedEmotions),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDistributionChart(List<EmotionEntryModel> emotions) {
    final distribution = <String, int>{};
    for (final emotion in emotions) {
      distribution[emotion.emotion] = (distribution[emotion.emotion] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotion Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...distribution.entries.map((entry) {
            final percentage = (entry.value / emotions.length * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key.capitalize(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade700,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getEmotionColor(entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIntensityTrendChart(List<EmotionEntryModel> emotions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Intensity Trends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Last 7 days average intensity',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(7, (index) {
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            final dayEmotions = emotions.where((e) {
              final emotionDate = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
              final checkDate = DateTime(date.year, date.month, date.day);
              return emotionDate.isAtSameMomentAs(checkDate);
            }).toList();
            
            final avgIntensity = dayEmotions.isNotEmpty
                ? dayEmotions.map((e) => e.intensity).reduce((a, b) => a + b) / dayEmotions.length
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: avgIntensity / 5,
                      backgroundColor: Colors.grey.shade700,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getIntensityColor(avgIntensity),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    avgIntensity.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          Text(
            'Loading emotions...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddEmotionModal,
      backgroundColor: const Color(0xFF8B5CF6),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildSelectionBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${_selectedEmotionIds.length} selected',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _exportSelected,
              icon: const Icon(Icons.download, color: Colors.blue),
              tooltip: 'Export Selected',
            ),
            IconButton(
              onPressed: _shareSelected,
              icon: const Icon(Icons.share, color: Colors.green),
              tooltip: 'Share Selected',
            ),
            IconButton(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Delete Selected',
            ),
          ],
        ),
      ),
    );
  }

  List<EmotionEntryModel> _getFilteredEmotions(List<dynamic> emotions) {
    var filtered = emotions.map((e) {
      if (e is EmotionEntryModel) return e;
      return EmotionEntryModel.fromJson(e.toJson());
    }).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) =>
        e.emotion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        e.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    if (_filterEmotion.isNotEmpty) {
      filtered = filtered.where((e) => e.emotion == _filterEmotion).toList();
    }

    if (_filterIntensity > 0) {
      filtered = filtered.where((e) => e.intensity == _filterIntensity).toList();
    }

    return filtered;
  }

  List<EmotionEntryModel> _getTodayEmotions(List<dynamic> emotions) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return emotions.map((e) {
      if (e is EmotionEntryModel) return e;
      return EmotionEntryModel.fromJson(e.toJson());
    }).where((e) =>
      e.createdAt.isAfter(todayStart) && e.createdAt.isBefore(todayEnd)
    ).toList();
  }

  List<EmotionEntryModel> _getWeekEmotions(List<dynamic> emotions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return emotions.map((e) {
      if (e is EmotionEntryModel) return e;
      return EmotionEntryModel.fromJson(e.toJson());
    }).where((e) =>
      e.createdAt.isAfter(weekStart) && e.createdAt.isBefore(weekEnd)
    ).toList();
  }

  Map<String, dynamic> _calculateEmotionStats(List<EmotionEntryModel> emotions) {
    if (emotions.isEmpty) {
      return {
        'total': 0,
        'avgIntensity': 0.0,
        'mostCommon': null,
      };
    }

    final total = emotions.length;
    final avgIntensity = emotions.map((e) => e.intensity).reduce((a, b) => a + b) / total;
    
    final emotionCounts = <String, int>{};
    for (final emotion in emotions) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }
    
    final mostCommon = emotionCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'total': total,
      'avgIntensity': avgIntensity,
      'mostCommon': mostCommon,
    };
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happiness':
      case 'excitement':
        return Colors.green;
      case 'sadness':
      case 'disappointment':
        return Colors.blue;
      case 'anger':
      case 'frustration':
        return Colors.red;
      case 'fear':
      case 'anxiety':
        return Colors.orange;
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  Color _getIntensityColor(double intensity) {
    if (intensity >= 4) return Colors.green;
    if (intensity >= 3) return Colors.blue;
    if (intensity >= 2) return Colors.orange;
    return Colors.red;
  }

  void _handleEmotionTap(EmotionEntryModel emotion) {
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
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleEmotionEdit(emotion);
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _handleEmotionDelete(emotion);
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

  void _handleEmotionEdit(EmotionEntryModel emotion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${emotion.emotion}'),
        backgroundColor: emotion.moodColor,
      ),
    );
  }

  void _handleEmotionDelete(EmotionEntryModel emotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Emotion', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete this ${emotion.emotion} emotion?',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emotion deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleSelectionChanged(String emotionId) {
    setState(() {
      if (_selectedEmotionIds.contains(emotionId)) {
        _selectedEmotionIds.remove(emotionId);
      } else {
        _selectedEmotionIds.add(emotionId);
      }
      
      if (_selectedEmotionIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'select':
        setState(() => _isSelectionMode = true);
        break;
      case 'export':
        _exportAllEmotions();
        break;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Search Emotions', style: TextStyle(color: Colors.white)),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search by emotion, note, or tag...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B5CF6)),
            ),
          ),
          onChanged: (value) => _searchQuery = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Filter Emotions', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _filterEmotion.isEmpty ? null : _filterEmotion,
              decoration: const InputDecoration(labelText: 'Emotion Type'),
              items: ['joy', 'sadness', 'anger', 'fear', 'surprise', 'disgust']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.capitalize())))
                  .toList(),
              onChanged: (value) => _filterEmotion = value ?? '',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _filterIntensity == 0 ? null : _filterIntensity,
              decoration: const InputDecoration(labelText: 'Intensity'),
              items: [1, 2, 3, 4, 5]
                  .map((i) => DropdownMenuItem(value: i, child: Text(i.toString())))
                  .toList(),
              onChanged: (value) => _filterIntensity = value ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _filterEmotion = '';
              _filterIntensity = 0;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAddEmotionModal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add emotion modal would open here'),
        backgroundColor: Color(0xFF8B5CF6),
      ),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedEmotionIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
_selectedEmotionIds = ['all']; 
    });
  }

  void _deleteSelected() {
    if (_selectedEmotionIds.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Delete Selected', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_selectedEmotionIds.length} emotions?',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitSelectionMode();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_selectedEmotionIds.length} emotions deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${_selectedEmotionIds.length} emotions...')),
    );
  }

  void _shareSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${_selectedEmotionIds.length} emotions...')),
    );
  }

  void _exportAllEmotions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting all emotions...')),
    );
  }
}