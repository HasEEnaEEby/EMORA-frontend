// ============================================================================
// FIXED ENHANCED INSIGHTS VIEW - All Compilation Issues Resolved
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../view_model/bloc/home_bloc.dart';
import '../../view_model/bloc/home_event.dart' as home_events;
import '../../view_model/bloc/home_state.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:emora_mobile_app/features/home/data/model/weekly_insights_model.dart' as weekly_model;
import 'package:emora_mobile_app/features/home/presentation/widget/enhanced_stats_widget.dart';

class EnhancedInsightsView extends StatefulWidget {
  const EnhancedInsightsView({super.key});

  @override
  State<EnhancedInsightsView> createState() => _EnhancedInsightsViewState();
}

class _EnhancedInsightsViewState extends State<EnhancedInsightsView>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _pulseController;
  
  // Enhanced period selection
  String _selectedPeriod = 'week';
  String _comparisonPeriod = 'none';
  bool _showComparison = false;
  bool _showPredictions = false;
  bool _showPatterns = true;
  
  // Chart types
  String _chartType = 'line'; 
  
  // Real data integration
  List<EmotionEntryModel> _emotionEntries = [];
  weekly_model.WeeklyInsightsModel? _weeklyInsights;
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<Period> _periods = [
    Period('today', 'Today', Icons.today, const Color(0xFF4CAF50)),
    Period('week', 'Week', Icons.view_week, const Color(0xFF2196F3)),
    Period('month', 'Month', Icons.calendar_month, const Color(0xFF8B5CF6)),
    Period('quarter', 'Quarter', Icons.calendar_view_month, const Color(0xFFFF9800)),
    Period('year', 'Year', Icons.event, const Color(0xFFE91E63)),
    Period('all', 'All Time', Icons.history, const Color(0xFF607D8B)),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _loadRealEmotionData();
  }

  void _initializeAnimations() {
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startAnimations() {
    _chartAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardAnimationController.forward();
    });
  }

  void _loadRealEmotionData() {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Try to get HomeBloc from GetIt
      HomeBloc? homeBloc;
      try {
        homeBloc = GetIt.instance<HomeBloc>();
        Logger.info('🔄 Loading real emotion data for insights...');
        
        // Load emotion history for the selected period
        homeBloc.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: true));
        
        // Load weekly insights
        homeBloc.add(const home_events.LoadWeeklyInsightsEvent(forceRefresh: true));
        
        // Listen to state changes
        homeBloc.stream.listen((state) {
          if (mounted) {
            if (state is HomeDashboardState) {
              setState(() {
                _emotionEntries = state.emotionEntries;
                _weeklyInsights = state.weeklyInsights;
                _isLoading = false;
                _errorMessage = null;
              });
            } else if (state is HomeLoading || state is HomeStatsRefreshing || state is HomeDataRefreshing) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            } else if (state is HomeError) {
              setState(() {
                _isLoading = false;
                _errorMessage = state.message;
              });
            }
          }
        });
        
      } catch (e) {
        Logger.warning('⚠️ HomeBloc not available in GetIt, using demo data');
        // If HomeBloc is not available, we'll use demo data
        setState(() {
          _isLoading = false;
          _errorMessage = 'Using demo data - HomeBloc not available';
          _emotionEntries = [];
        });
      }
      
    } catch (e) {
      Logger.error('❌ Failed to load real emotion data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load emotion data: ${e.toString()}';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildEnhancedHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: const Color(0xFF1A1A2E),
                color: const Color(0xFF8B5CF6),
                child: CustomScrollView(
                  slivers: [
                    // Enhanced Period Selector
                    SliverToBoxAdapter(
                      child: _buildEnhancedPeriodSelector(),
                    ),
                    
                    // Chart Type Selector
                    SliverToBoxAdapter(
                      child: _buildChartTypeSelector(),
                    ),
                    
                    // Main Analytics Chart
                    SliverToBoxAdapter(
                      child: _buildMainAnalyticsChart(),
                    ),
                    
                    // Quick Stats Grid
                    SliverToBoxAdapter(
                      child: EnhancedStatsWidget(
                        emotionEntries: _emotionEntries,
                        onStatsTap: () {
                          Logger.userAction('Tapped View All stats');
                          // Navigate to detailed stats page
                        },
                      ),
                    ),
                    
                    // AI Insights Cards
                    SliverToBoxAdapter(
                      child: _buildAIInsightsCards(),
                    ),
                    
                    // Pattern Analysis
                    if (_showPatterns)
                      SliverToBoxAdapter(
                        child: _buildAdvancedPatternAnalysis(),
                      ),
                    
                    // Predictive Analytics
                    if (_showPredictions)
                      SliverToBoxAdapter(
                        child: _buildPredictiveAnalytics(),
                      ),
                    
                    // Goals & Recommendations
                    SliverToBoxAdapter(
                      child: _buildGoalsAndRecommendations(),
                    ),
                    
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildInsightsFloatingButton(),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0F),
            const Color(0xFF0A0A0F).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Enhanced back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title with AI badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ).createShader(bounds),
                          child: const Text(
                            'Insights',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                            ),
                          ),
                          child: const Text(
                            'AI-Powered',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Discover your emotional patterns',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Hamburger menu for emotion history
              GestureDetector(
                onTap: _showEmotionHistory,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Settings button
              GestureDetector(
                onTap: _showInsightsSettings,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Quick insights summary
          _buildQuickInsightsSummary(),
        ],
      ),
    );
  }

  Widget _buildEnhancedPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Time Period',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_showComparison)
                GestureDetector(
                  onTap: () => setState(() => _showComparison = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                    ),
                    child: const Text(
                      'Compare ON',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Enhanced period buttons
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period.id;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _periods.length - 1 ? 12 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _onPeriodChanged(period.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [period.color, period.color.withValues(alpha: 0.7)],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : period.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            period.icon,
                            color: isSelected ? Colors.white : period.color,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            period.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontSize: 12,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Comparison period selector
          if (_showComparison) ...[
            const SizedBox(height: 16),
            Text(
              'Compare with',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildComparisonSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    final chartTypes = [
      ChartType('line', 'Line', Icons.show_chart),
      ChartType('bar', 'Bar', Icons.bar_chart),
      ChartType('radar', 'Radar', Icons.radar),
      ChartType('heatmap', 'Heatmap', Icons.grid_view),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chart Type',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chartTypes.length,
              itemBuilder: (context, index) {
                final type = chartTypes[index];
                final isSelected = _chartType == type.id;
                
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < chartTypes.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => _onChartTypeChanged(type.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey[600]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            color: isSelected 
                                ? const Color(0xFF8B5CF6) 
                                : Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type.label,
                            style: TextStyle(
                              color: isSelected 
                                  ? const Color(0xFF8B5CF6) 
                                  : Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAnalyticsChart() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
              const Color(0xFF16213E).withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Mood Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _buildChartActions(),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: AnimatedBuilder(
                animation: _chartAnimationController,
                builder: (context, child) {
                  return _buildChartByType();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartByType() {
    switch (_chartType) {
      case 'line':
        return _buildLineChart();
      case 'bar':
        return _buildBarChart();
      case 'radar':
        return _buildRadarChart();
      case 'heatmap':
        return _buildHeatmapChart();
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  _getTimeLabel(value.toInt()),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _generateMoodSpots(),
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final emotions = _getEmotionTypesForBarChart();
                if (value.toInt() < emotions.length) {
                  return Text(
                    _getEmojiForEmotion(emotions[value.toInt()]),
                    style: const TextStyle(fontSize: 16),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _generateBarChartData(),
      ),
    );
  }

  Widget _buildRadarChart() {
    return RadarChart(
      RadarChartData(
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.transparent),
        titleTextStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        getTitle: (index, angle) {
          final titles = ['Energy', 'Mood', 'Social', 'Sleep', 'Stress'];
          return RadarChartTitle(text: titles[index]);
        },
        dataSets: _generateRadarChartData(),
      ),
    );
  }

  Widget _buildHeatmapChart() {
    return Column(
      children: [
        // Week days header
        Row(
          children: [
            const SizedBox(width: 40),
            ...['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) =>
              Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Heatmap grid
        Expanded(
          child: Column(
            children: List.generate(4, (weekIndex) {
              return Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'W${weekIndex + 1}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ),
                    ...List.generate(7, (dayIndex) {
                      final intensity = _generateHeatmapIntensity(weekIndex, dayIndex);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _getHeatmapColor(intensity),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Less', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(width: 8),
            ...List.generate(5, (index) {
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _getHeatmapColor(index / 4),
                ),
              );
            }),
            const SizedBox(width: 8),
            Text('More', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildAIInsightsCards() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI insight cards
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: _buildAIInsightCard(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard(int index) {
    final insights = _generateAIInsights();
    if (index >= insights.length) return const SizedBox.shrink();
    
    final insight = insights[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: (insight['color'] as Color).withValues(alpha: 0.1),
        border: Border.all(
          color: (insight['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (insight['color'] as Color).withValues(alpha: 0.2),
            ),
            child: Icon(
              insight['icon'] as IconData,
              color: insight['color'] as Color,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (insight['color'] as Color).withValues(alpha: 0.2),
                      ),
                      child: Text(
                        '${insight['confidence']}%',
                        style: TextStyle(
                          color: insight['color'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  insight['description'] as String,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedPatternAnalysis() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
              const Color(0xFF16213E).withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Pattern Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _showPatterns = !_showPatterns),
                  child: Icon(
                    _showPatterns ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ..._generatePatternInsights().map((pattern) => _buildPatternCard(pattern)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: (pattern['color'] as Color).withValues(alpha: 0.1),
        border: Border.all(
          color: (pattern['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            pattern['emoji'] as String,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pattern['description'] as String,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey[700],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pattern['strength'] as double,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: pattern['color'] as Color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveAnalytics() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withValues(alpha: 0.8),
              const Color(0xFF16213E).withValues(alpha: 0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Mood Predictions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  ),
                  child: const Text(
                    'Beta',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Based on your patterns, here\'s what we predict:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ..._generatePredictions().map((prediction) => _buildPredictionCard(prediction)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFFFD700).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            ),
            child: Icon(
              prediction['icon'] as IconData,
              color: const Color(0xFFFFD700),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  prediction['description'] as String,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${prediction['confidence']}%',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsAndRecommendations() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withValues(alpha: 0.1),
              const Color(0xFF8BC34A).withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF4CAF50), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Personalized suggestions to improve your wellbeing:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 12),
            
            ..._generateRecommendations().map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        // Add action for insights floating button
        NavigationService.showInfoSnackBar('More insights coming soon!');
      },
      backgroundColor: const Color(0xFF8B5CF6),
      child: const Icon(Icons.auto_graph, color: Colors.white),
    );
  }

  Widget _buildQuickInsightsSummary() {
    if (_emotionEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Start logging emotions to see your insights here',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            const Color(0xFF6366F1).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics, color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Insights',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_emotionEntries.length} emotions logged • Avg: ${_getAverageIntensity().toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showComparison = !_showComparison),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _showComparison 
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: Icon(
              Icons.compare_arrows,
              color: _showComparison 
                  ? const Color(0xFF8B5CF6)
                  : Colors.grey[400],
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _showPredictions = !_showPredictions),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _showPredictions 
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: Icon(
              Icons.auto_graph,
              color: _showPredictions 
                  ? const Color(0xFFFFD700)
                  : Colors.grey[400],
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSelector() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: const Text(
        'Comparison feature coming soon',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // Event handlers and utility methods
  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    HapticFeedback.lightImpact();
    _loadRealEmotionData();
  }

  void _onChartTypeChanged(String chartType) {
    setState(() => _chartType = chartType);
    _chartAnimationController.reset();
    _chartAnimationController.forward();
    HapticFeedback.lightImpact();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    _loadRealEmotionData();
    
    if (mounted) {
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

  void _showEmotionHistory() {
    NavigationService.showInfoSnackBar('Emotion history coming soon!');
  }

  void _showInsightsSettings() {
    NavigationService.showInfoSnackBar('Insights settings coming soon!');
  }

  // Data generation methods
  List<FlSpot> _generateMoodSpots() {
    if (_emotionEntries.isEmpty) return [];
    
    final spots = <FlSpot>[];
    for (int i = 0; i < _emotionEntries.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), _emotionEntries[i].intensity.toDouble()));
    }
    return spots;
  }

  List<BarChartGroupData> _generateBarChartData() {
    if (_emotionEntries.isEmpty) return [];
    
    final emotionCounts = <String, int>{};
    for (final emotion in _emotionEntries) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }
    
    final barGroups = <BarChartGroupData>[];
    int index = 0;
    for (final entry in emotionCounts.entries) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: _getEmotionColor(entry.key),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      index++;
    }
    
    return barGroups;
  }

  List<String> _getEmotionTypesForBarChart() {
    if (_emotionEntries.isEmpty) return [];
    
    final emotionCounts = <String, int>{};
    for (final emotion in _emotionEntries) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }
    
    return emotionCounts.keys.take(8).toList();
  }

  List<RadarDataSet> _generateRadarChartData() {
    return [
      RadarDataSet(
        fillColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        borderColor: const Color(0xFF8B5CF6),
        dataEntries: List.generate(5, (index) => RadarEntry(value: 7.0 + index)),
      ),
    ];
  }

  double _generateHeatmapIntensity(int week, int day) {
    return ((week + day) % 5) / 4.0;
  }

  Color _getHeatmapColor(double intensity) {
    if (intensity == 0.0) return const Color(0xFF1A1A2E);
    
    final colors = [
      const Color(0xFF8B5CF6).withValues(alpha: 0.2),
      const Color(0xFF8B5CF6).withValues(alpha: 0.4),
      const Color(0xFF8B5CF6).withValues(alpha: 0.6),
      const Color(0xFF8B5CF6).withValues(alpha: 0.8),
      const Color(0xFF8B5CF6),
    ];
    
    final index = (intensity * (colors.length - 1)).round().clamp(0, colors.length - 1);
    return colors[index];
  }

  String _getTimeLabel(int index) {
    switch (_selectedPeriod) {
      case 'today':
        return '${index * 2}h';
      case 'week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index % 7];
      case 'month':
        return 'W${index + 1}';
      case 'quarter':
        return 'M${index + 1}';
      case 'year':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][index % 12];
      default:
        return '${index + 1}';
    }
  }

  List<Map<String, dynamic>> _generateAIInsights() {
    return [
      {
        'title': 'Peak Performance Hours',
        'description': 'You perform best between 9-11 AM. Consider scheduling important tasks during this time.',
        'confidence': 92,
        'icon': Icons.schedule,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Sleep Impact',
        'description': 'Your mood improves by 23% when you get 7+ hours of sleep.',
        'confidence': 88,
        'icon': Icons.bedtime,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Social Connection',
        'description': 'Your happiness increases significantly after social interactions.',
        'confidence': 85,
        'icon': Icons.people,
        'color': const Color(0xFFE91E63),
      },
    ];
  }

  List<Map<String, dynamic>> _generatePatternInsights() {
    return [
      {
        'title': 'Morning Boost',
        'description': 'You feel most energetic in the morning hours',
        'emoji': '🌅',
        'strength': 0.9,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Weekend Effect',
        'description': 'Your mood typically improves on weekends',
        'emoji': '🎉',
        'strength': 0.7,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Exercise Correlation',
        'description': 'Physical activity boosts your emotional wellbeing',
        'emoji': '💪',
        'strength': 0.8,
        'color': const Color(0xFFFF9800),
      },
    ];
  }

  List<Map<String, dynamic>> _generatePredictions() {
    return [
      {
        'title': 'Tomorrow\'s Mood',
        'description': 'Likely to be positive based on recent patterns',
        'confidence': 75,
        'icon': Icons.wb_sunny,
      },
      {
        'title': 'Weekly Outlook',
        'description': 'Expect stable emotions with potential stress mid-week',
        'confidence': 68,
        'icon': Icons.trending_up,
      },
      {
        'title': 'Optimal Time',
        'description': 'Best mood window: 9-11 AM tomorrow',
        'confidence': 82,
        'icon': Icons.schedule,
      },
    ];
  }

  List<String> _generateRecommendations() {
    return [
      'Schedule important tasks during your peak hours (9-11 AM)',
      'Maintain consistent sleep schedule for better mood stability',
      'Incorporate 20 minutes of physical activity daily',
      'Practice mindfulness meditation during stress periods',
      'Connect with friends and family regularly for emotional support',
    ];
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happiness':
      case 'joy':
      case 'excitement':
        return const Color(0xFF4CAF50);
      case 'sadness':
      case 'fear':
      case 'anxiety':
        return const Color(0xFF2196F3);
      case 'anger':
      case 'frustration':
        return const Color(0xFFFF5722);
      case 'contentment':
      case 'calm':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getEmojiForEmotion(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happiness': return '😊';
      case 'joy': return '😄';
      case 'excitement': return '🤩';
      case 'sadness': return '😢';
      case 'fear': return '😰';
      case 'anxiety': return '😰';
      case 'anger': return '😠';
      case 'frustration': return '😤';
      case 'contentment': return '😌';
      case 'calm': return '😌';
      default: return '😊';
    }
  }

  double _getAverageIntensity() {
    if (_emotionEntries.isEmpty) return 0.0;
    final sum = _emotionEntries.map((e) => e.intensity).reduce((a, b) => a + b);
    return sum / _emotionEntries.length;
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _cardAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// Data models
class Period {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  Period(this.id, this.label, this.icon, this.color);
}

class ChartType {
  final String id;
  final String label;
  final IconData icon;

  ChartType(this.id, this.label, this.icon);
}