// ============================================================================
// FIXED INSIGHTS VIEW - All Type Errors and Warnings Resolved
// ============================================================================

import 'package:emora_mobile_app/features/home/data/mock_insights_data.dart';
import 'package:emora_mobile_app/features/home/data/model/insights_models.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
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
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

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
  
  // Real data state
  List<EmotionEntryModel> _emotionEntries = [];
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadEmotionData();
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

  Future<void> _loadEmotionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Logger.info('🔄 Loading emotion data for insights...');
      
      final apiService = GetIt.instance<ApiService>();
      
      // Calculate date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;
      
      switch (_selectedPeriod) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'year':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      final response = await apiService.get(
        '/api/emotions',
        queryParameters: {
          'limit': 200,
          'offset': 0,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final emotions = response.data['data']['emotions'] as List;
        
        setState(() {
          _emotionEntries = emotions
              .map((e) => EmotionEntryModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _analyticsData = _calculateAnalyticsData(_emotionEntries);
          _isLoading = false;
        });
        
        Logger.info('✅ Loaded ${_emotionEntries.length} emotion entries for insights');
      } else {
        throw Exception('Failed to load emotion data: ${response.statusCode}');
      }
    } catch (error) {
      Logger.error('❌ Error loading emotion data: $error');
      setState(() {
        _errorMessage = 'Failed to load emotion data';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateAnalyticsData(List<EmotionEntryModel> emotions) {
    if (emotions.isEmpty) {
      return {
        'totalEntries': 0,
        'averageIntensity': 0.0,
        'moodTrend': 'stable',
        'musicRecommendation': 'Start logging emotions to get personalized recommendations',
        'dominantEmotion': null,
        'emotionBreakdown': {},
      };
    }

    // Calculate analytics
    final totalEntries = emotions.length;
    final avgIntensity = emotions.map((e) => e.intensity).reduce((a, b) => a + b) / totalEntries;
    
    // Emotion breakdown
    final emotionBreakdown = <String, int>{};
    for (final emotion in emotions) {
      final type = emotion.emotion;
      emotionBreakdown[type] = (emotionBreakdown[type] ?? 0) + 1;
    }
    
    // Find dominant emotion
    String? dominantEmotion;
    int maxCount = 0;
    for (final entry in emotionBreakdown.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        dominantEmotion = entry.key;
      }
    }
    
    // Determine mood trend
    final recentEmotions = emotions.take(5).toList();
    final recentAvg = recentEmotions.isNotEmpty
        ? recentEmotions.map((e) => e.intensity).reduce((a, b) => a + b) / recentEmotions.length
        : avgIntensity;
    
    String moodTrend;
    if (recentAvg > avgIntensity + 0.5) {
      moodTrend = 'improving';
    } else if (recentAvg < avgIntensity - 0.5) {
      moodTrend = 'needs_attention';
    } else {
      moodTrend = 'stable';
    }
    
    // Music recommendation based on dominant emotion
    String musicRecommendation;
    switch (dominantEmotion) {
      case 'joy':
      case 'excitement':
      case 'gratitude':
        musicRecommendation = 'Upbeat pop with positive vibes';
        break;
      case 'calm':
      case 'contentment':
        musicRecommendation = 'Reflective indie with hopeful undertones';
        break;
      case 'sadness':
      case 'anxiety':
      case 'fear':
        musicRecommendation = 'Calming ambient with gentle melodies';
        break;
      case 'anger':
      case 'frustration':
        musicRecommendation = 'Soothing instrumental for emotional support';
        break;
      default:
        musicRecommendation = 'Reflective indie with hopeful undertones';
    }
    
    return {
      'totalEntries': totalEntries,
      'averageIntensity': avgIntensity,
      'moodTrend': moodTrend,
      'musicRecommendation': musicRecommendation,
      'dominantEmotion': dominantEmotion,
      'emotionBreakdown': emotionBreakdown,
    };
  }

  Map<String, List<MoodData>> _getWeeklyMoodData() {
    if (_emotionEntries.isEmpty) {
      // Use mock data if no real data is available
      return MockInsightsData.getMoodData(_selectedPeriod);
    }

    final List<MoodData> moodDataList = _emotionEntries.map((e) {
      return MoodData(
        _getDayLabel(e.createdAt),
        e.intensity / 10.0, 
        _getLabelForIntensity(e.intensity.toDouble()),
        _getEmojiForEmotion(e.emotion),
        e.createdAt,
      );
    }).toList();

    // Sort by date
    moodDataList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return {_selectedPeriod: moodDataList};
  }

  String _getDayLabel(DateTime date) {
    switch (_selectedPeriod) {
      case 'week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      case 'month':
        return 'Week ${((date.day - 1) / 7).floor() + 1}';
      case 'year':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
      default:
        return date.day.toString();
    }
  }

  String _getLabelForIntensity(double intensity) {
    final intensityInt = intensity.round();
    if (intensityInt >= 9) return 'Amazing';
    if (intensityInt >= 8) return 'Great';
    if (intensityInt >= 7) return 'Good';
    if (intensityInt >= 6) return 'Okay';
    if (intensityInt >= 4) return 'Down';
    return 'Low';
  }

  String _getEmojiForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return '😊';
      case 'sadness': return '😢';
      case 'anger': return '😠';
      case 'fear': return '😨';
      case 'surprise': return '😲';
      case 'disgust': return '🤢';
      case 'love': return '🥰';
      case 'excitement': return '🤩';
      case 'anxiety': return '😰';
      case 'calm': return '😌';
      case 'frustration': return '😤';
      case 'gratitude': return '🙏';
      case 'happiness': return '😄';
      case 'contentment': return '😊';
      case 'pride': return '😌';
      case 'relief': return '😌';
      case 'hope': return '🤗';
      case 'enthusiasm': return '🤩';
      case 'serenity': return '😇';
      case 'bliss': return '🌟';
      default: return '😊';
    }
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
                child: _isLoading 
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                PeriodSelector(
                                  selectedPeriod: _selectedPeriod,
                                  onPeriodChanged: _onPeriodChanged,
                                ),
                                const SizedBox(height: 24),
                                MoodChartWidget(
                                  data: _getWeeklyMoodData(),
                                  animationController: _chartAnimationController,
                                  selectedDayIndex: _selectedDayIndex,
                                  onDaySelected: (index) =>
                                      setState(() => _selectedDayIndex = index),
                                  onDayDeselected: () =>
                                      setState(() => _selectedDayIndex = -1),
                                ),
                                const SizedBox(height: 24),
                                InsightCardsGrid(
                                  insights: _getInsightsFromData(),
                                  animationController: _insightCardController,
                                ),
                                const SizedBox(height: 24),
                                if (_showDetailed) ...[
                                  DetailedStatsWidget(
                                    period: _selectedPeriod,
                                    emotionEntries: _emotionEntries,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                PatternAnalysisWidget(
                                  patterns: _getPatternsFromData(),
                                ),
                                const SizedBox(height: 24),
                                RecommendationsWidget(
                                  analyticsData: _analyticsData,
                                ),
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          Text(
            'Loading your insights...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load insights',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadEmotionData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  List<InsightCard> _getInsightsFromData() {
    if (_emotionEntries.isEmpty) {
      return MockInsightsData.getInsights();
    }

    final List<InsightCard> insights = [];
    
    // Total entries insight
    insights.add(InsightCard(
      emoji: '📊',
      title: 'Tracking Progress',
      description: 'You\'ve logged ${_analyticsData['totalEntries']} emotions this $_selectedPeriod',
      color: const Color(0xFF8B5CF6),
      trend: 0.0,
      category: 'tracking',
    ));

    // Average mood insight
    final avgIntensity = _analyticsData['averageIntensity'] as double;
    insights.add(InsightCard(
      emoji: '📈',
      title: 'Average Mood',
      description: 'Your average mood score is ${avgIntensity.toStringAsFixed(1)}/10',
      color: avgIntensity >= 7 ? const Color(0xFF10B981) : 
             avgIntensity >= 5 ? const Color(0xFFFFD700) : const Color(0xFFFF6B35),
      trend: 0.0,
      category: 'mood',
    ));

    // Dominant emotion insight
    final dominantEmotion = _analyticsData['dominantEmotion'] as String?;
    if (dominantEmotion != null) {
      insights.add(InsightCard(
        emoji: _getEmojiForEmotion(dominantEmotion),
        title: 'Dominant Emotion',
        description: 'You felt $dominantEmotion most often',
        color: const Color(0xFF6366F1),
        trend: 0.0,
        category: 'emotion',
      ));
    }

    // Mood trend insight
    final moodTrend = _analyticsData['moodTrend'] as String;
    Color trendColor;
    String trendDescription;
    switch (moodTrend) {
      case 'improving':
        trendColor = const Color(0xFF10B981);
        trendDescription = 'Your mood is trending upward';
        break;
      case 'needs_attention':
        trendColor = const Color(0xFFFF6B35);
        trendDescription = 'Your mood needs some attention';
        break;
      default:
        trendColor = const Color(0xFF6B7280);
        trendDescription = 'Your mood is stable';
    }

    insights.add(InsightCard(
      emoji: moodTrend == 'improving' ? '📈' : 
             moodTrend == 'needs_attention' ? '📉' : '➡️',
      title: 'Mood Trend',
      description: trendDescription,
      color: trendColor,
      trend: 0.0,
      category: 'trend',
    ));

    return insights;
  }

  List<PatternInsight> _getPatternsFromData() {
    if (_emotionEntries.isEmpty) {
      // Use mock data if no real data is available
      return MockInsightsData.getPatterns();
    }

    final List<PatternInsight> patterns = [];
    
    // Analyze time patterns
    final Map<int, List<EmotionEntryModel>> hourlyEntries = {};
    for (final entry in _emotionEntries) {
      final hour = entry.createdAt.hour;
      hourlyEntries[hour] = (hourlyEntries[hour] ?? [])..add(entry);
    }

    // Find the hour with the best average mood
    double bestHourAverage = 0.0;
    int bestHour = 9;
    for (final hourEntry in hourlyEntries.entries) {
      final avgIntensity = hourEntry.value.map((e) => e.intensity).reduce((a, b) => a + b) / hourEntry.value.length;
      if (avgIntensity > bestHourAverage) {
        bestHourAverage = avgIntensity;
        bestHour = hourEntry.key;
      }
    }

    patterns.add(PatternInsight(
      title: 'Peak Hour',
      description: 'You feel best around $bestHour:00',
      emoji: bestHour < 12 ? '🌅' : bestHour < 17 ? '☀️' : '🌙',
      strength: (bestHourAverage / 10.0).clamp(0.0, 1.0),
      category: 'time',
      details: 'Your mood tends to peak around $bestHour:00 with an average intensity of ${bestHourAverage.toStringAsFixed(1)}/10.',
    ));

    // Analyze emotion frequency patterns
    final emotionBreakdown = _analyticsData['emotionBreakdown'] as Map<String, dynamic>;
    final sortedEmotions = emotionBreakdown.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));

    if (sortedEmotions.isNotEmpty) {
      final topEmotion = sortedEmotions.first;
      patterns.add(PatternInsight(
        title: 'Emotional Pattern',
        description: 'You experience ${topEmotion.key} frequently',
        emoji: _getEmojiForEmotion(topEmotion.key),
        strength: (topEmotion.value as int) / _emotionEntries.length,
        category: 'emotion',
        details: 'You\'ve experienced ${topEmotion.key} ${topEmotion.value} times out of ${_emotionEntries.length} total entries.',
      ));
    }

    // Add more pattern analysis as needed
    return patterns.isNotEmpty ? patterns : MockInsightsData.getPatterns();
  }

  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    HapticFeedback.lightImpact();
    _loadEmotionData(); // Reload data for new period
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();

    _chartAnimationController.reset();
    _insightCardController.reset();

    await _loadEmotionData();

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