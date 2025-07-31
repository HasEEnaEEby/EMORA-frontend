import 'package:flutter/material.dart';

class EmotionLegendWidget extends StatefulWidget {
  final String timeFilter;
  final String emotionFilter;
  final bool showHeatmap;
  final Function(String) onTimeFilterChanged;
  final Function(String) onEmotionFilterChanged;
  final Function(bool) onHeatmapToggle;
  final VoidCallback onRefresh;

  const EmotionLegendWidget({
    super.key,
    required this.timeFilter,
    required this.emotionFilter,
    required this.showHeatmap,
    required this.onTimeFilterChanged,
    required this.onEmotionFilterChanged,
    required this.onHeatmapToggle,
    required this.onRefresh,
  });

  @override
  State<EmotionLegendWidget> createState() => _EmotionLegendWidgetState();
}

class _EmotionLegendWidgetState extends State<EmotionLegendWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 20,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2a2a3e).withValues(alpha: 0.95),
              const Color(0xFF1a1a2e).withValues(alpha: 0.90),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isExpanded) ...[
              _buildFilters(),
              _buildEmotionScale(),
              _buildQuickActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Emotions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Divider(
            color: Color(0xFF4CAF50),
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 16),
          
          _buildFilterRow(
            'Time Range',
            ['1h', '6h', '24h', '7d', '30d'],
            widget.timeFilter,
            widget.onTimeFilterChanged,
            Icons.access_time_rounded,
          ),
          
          const SizedBox(height: 12),
          
          _buildFilterRow(
            'Emotion Type',
            ['all', 'joy', 'calm', 'sadness', 'anger', 'anxiety'],
            widget.emotionFilter,
            widget.onEmotionFilterChanged,
            Icons.psychology_rounded,
          ),
          
          const SizedBox(height: 12),
          
          _buildToggleRow(
            'Show Heatmap',
            widget.showHeatmap,
            widget.onHeatmapToggle,
            Icons.layers_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(
    String title,
    List<String> options,
    String selected,
    Function(String) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getDisplayLabel(option),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: value
                ? const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.2),
                    ],
                  ),
            border: Border.all(
              color: value
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(!value),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionScale() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.palette_rounded,
                color: Color(0xFF8B5CF6),
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Emotion Colors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _getEmotionColorItems(),
          ),
        ],
      ),
    );
  }

  List<Widget> _getEmotionColorItems() {
    final emotions = ['joy', 'calm', 'sadness', 'anger', 'anxiety'];
    return emotions.map((emotion) {
      final color = _getEmotionColor(emotion);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0.8)],
              ),
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            emotion.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            icon: Icons.refresh_rounded,
            label: 'Refresh',
            onTap: _handleRefresh,
            color: const Color(0xFF2196F3),
          ),
          _buildQuickActionButton(
            icon: Icons.tune_rounded,
            label: 'Filters',
            onTap: _showAdvancedFilters,
            color: const Color(0xFF8B5CF6),
          ),
          _buildQuickActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: _shareMap,
            color: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (widget.emotionFilter != 'all') {
      return 'Filtering: ${widget.emotionFilter} • ${widget.timeFilter}';
    }
    return 'All emotions • ${widget.timeFilter}';
  }

  String _getDisplayLabel(String option) {
    final labels = {
      '1h': '1 Hour',
      '6h': '6 Hours',
      '24h': '24 Hours',
      '7d': '7 Days',
      '30d': '30 Days',
      'all': 'All',
      'joy': 'Joy',
      'calm': 'Calm',
      'sadness': 'Sadness',
      'anger': 'Anger',
      'anxiety': 'Anxiety',
    };
    return labels[option] ?? option.toUpperCase();
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return const Color(0xFFFFD700);
      case 'calm':
        return const Color(0xFF4CAF50);
      case 'sadness':
        return const Color(0xFF2196F3);
      case 'anger':
        return const Color(0xFFE91E63);
      case 'anxiety':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  void _handleRefresh() {
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    widget.onRefresh();
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedFiltersModal(),
    );
  }

  void _shareMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Map sharing coming soon!'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildAdvancedFiltersModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Customize your emotion map view',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const Expanded(
            child: Center(
              child: Text(
                'Advanced filters coming soon!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 