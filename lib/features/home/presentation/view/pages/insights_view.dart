// lib/features/home/presentation/view/pages/insights_view.dart
import 'package:emora_mobile_app/features/home/data/mock_insights_data.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/detailed_stats_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/insight_cards_grid.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/insights_floating_button.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/insights_header.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/mood_chart_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/pattern_analysis_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/period_selector.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/recommendations_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late AnimationController _insightCardController;
  late AnimationController _floatingController;

  String _selectedPeriod = 'week';
  bool _showDetailed = false;
  int _selectedDayIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _insightCardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _chartAnimationController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _insightCardController.forward();
      }
    });
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _insightCardController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            InsightsHeader(
              showDetailed: _showDetailed,
              onToggleDetailed: () =>
                  setState(() => _showDetailed = !_showDetailed),
              onExport: _showExportDialog,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: const Color(0xFF1A1A2E),
                color: const Color(0xFF8B5CF6),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      PeriodSelector(
                        selectedPeriod: _selectedPeriod,
                        onPeriodChanged: _onPeriodChanged,
                      ),
                      const SizedBox(height: 24),
                      MoodChartWidget(
                        data: MockInsightsData.getMoodData(_selectedPeriod),
                        animationController: _chartAnimationController,
                        selectedDayIndex: _selectedDayIndex,
                        onDaySelected: (index) =>
                            setState(() => _selectedDayIndex = index),
                        onDayDeselected: () =>
                            setState(() => _selectedDayIndex = -1),
                      ),
                      const SizedBox(height: 24),
                      InsightCardsGrid(
                        insights: MockInsightsData.getInsights(),
                        animationController: _insightCardController,
                      ),
                      const SizedBox(height: 24),
                      if (_showDetailed) ...[
                        DetailedStatsWidget(
                          period: _selectedPeriod,
                          emotionEntries: [], // TODO: Pass real emotion entries
                        ),
                        const SizedBox(height: 24),
                      ],
                      PatternAnalysisWidget(
                        patterns: MockInsightsData.getPatterns(),
                      ),
                      const SizedBox(height: 24),
                      const RecommendationsWidget(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: InsightsFloatingButton(
        animationController: _floatingController,
      ),
    );
  }

  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    HapticFeedback.lightImpact();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();

    _chartAnimationController.reset();
    _insightCardController.reset();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _startAnimations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insights refreshed!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Export Insights',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose how you\'d like to export your insights data:',
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              'PDF Report',
              Icons.picture_as_pdf,
              'Complete insights report',
            ),
            _buildExportOption(
              'CSV Data',
              Icons.table_chart,
              'Raw data for analysis',
            ),
            _buildExportOption(
              'Share Summary',
              Icons.share,
              'Share key insights',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, IconData icon, String description) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: Colors.grey[400], fontSize: 12),
      ),
      onTap: () {
        Navigator.pop(context);
        _showComingSoonDialog(title);
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Coming Soon!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '$feature is coming soon to EMORA. We\'re working hard to bring you advanced analytics and goal-setting features!',
          style: TextStyle(color: Colors.grey[300], fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Got it!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
