import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../view_model/bloc/home_bloc.dart';
import '../../view_model/bloc/home_event.dart' as home_events;
import '../../view_model/bloc/home_state.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart' hide WeeklyInsightsModel;
import 'package:emora_mobile_app/features/home/data/model/weekly_insights_model.dart';
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
  String _chartType = 'line'; // line, bar, radar, heatmap
  
  // Real data integration
  List<EmotionEntryModel> _emotionEntries = [];
  WeeklyInsightsModel? _weeklyInsights;
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<Period> _periods = [
    Period('today', 'Today', Icons.today, Color(0xFF4CAF50)),
    Period('week', 'Week', Icons.view_week, Color(0xFF2196F3)),
    Period('month', 'Month', Icons.calendar_month, Color(0xFF8B5CF6)),
    Period('quarter', 'Quarter', Icons.calendar_view_month, Color(0xFFFF9800)),
    Period('year', 'Year', Icons.event, Color(0xFFE91E63)),
    Period('all', 'All Time', Icons.history, Color(0xFF607D8B)),
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
        Logger.info('📊 Loading real emotion data for insights...');
        
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
          _emotionEntries = _getDemoEmotionData();
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

  List<EmotionEntryModel> _getDemoEmotionData() {
    // Return some demo emotion data for testing
    return [
      EmotionEntryModel(
        id: 'demo_1',
        userId: 'demo_user',
        emotion: 'happiness',
        intensity: 4.0,
        context: 'Had a great day with friends',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isAnonymous: false,
      ),
      EmotionEntryModel(
        id: 'demo_2',
        userId: 'demo_user',
        emotion: 'calm',
        intensity: 3.0,
        context: 'Peaceful morning meditation',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isAnonymous: false,
      ),
      EmotionEntryModel(
        id: 'demo_3',
        userId: 'demo_user',
        emotion: 'excitement',
        intensity: 5.0,
        context: 'Got exciting news about a project',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isAnonymous: false,
      ),
    ];
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
            const Color(0xFF0A0A0F).withOpacity(0.8),
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
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
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
                    color: const Color(0xFF1A1A2E).withOpacity(0.6),
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
                    color: const Color(0xFF1A1A2E).withOpacity(0.6),
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
          
          const SizedBox(height: 16),
          
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
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
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
                                colors: [period.color, period.color.withOpacity(0.7)],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : const Color(0xFF1A1A2E).withOpacity(0.5),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : period.color.withOpacity(0.3),
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
                    onTap: () => setState(() => _chartType = type.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? const Color(0xFF8B5CF6).withOpacity(0.2)
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
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF16213E).withOpacity(0.6),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
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
              color: Colors.white.withOpacity(0.1),
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
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(
                  days[value.toInt() % 7],
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
                  const Color(0xFF8B5CF6).withOpacity(0.3),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
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
                final emotions = ['😢', '😕', '😐', '😊', '😍'];
                return Text(
                  emotions[value.toInt() % emotions.length],
                  style: const TextStyle(fontSize: 16),
                );
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
              Expanded(
                child: Text(
                  'AI Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
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
    final insights = [
      {
        'title': 'Peak Performance Hours',
        'description': 'You perform best between 9-11 AM. Consider scheduling important tasks during this time.',
        'confidence': 92,
        'type': 'pattern',
        'icon': Icons.schedule,
        'color': Color(0xFF4CAF50),
      },
      {
        'title': 'Sleep Impact',
        'description': 'Your mood improves by 23% when you get 7+ hours of sleep.',
        'confidence': 88,
        'type': 'correlation',
        'icon': Icons.bedtime,
        'color': Color(0xFF2196F3),
      },
      {
        'title': 'Social Connection',
        'description': 'Your happiness increases significantly after social interactions.',
        'confidence': 85,
        'type': 'recommendation',
        'icon': Icons.people,
        'color': Color(0xFFE91E63),
      },
    ];

    final insight = insights[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: (insight['color'] as Color).withOpacity(0.1),
        border: Border.all(
          color: (insight['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (insight['color'] as Color).withOpacity(0.2),
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (insight['color'] as Color).withOpacity(0.2),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods and other widgets...
  
  Widget _buildQuickInsightsSummary() {
    if (_emotionEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withOpacity(0.6),
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

    // Calculate real insights
    final totalEmotions = _emotionEntries.length;
    final averageIntensity = _emotionEntries.map((e) => e.intensity).reduce((a, b) => a + b) / totalEmotions;
    final mostFrequentEmotion = _getMostFrequentEmotion();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: const Color(0xFF8B5CF6), size: 20),
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
                  '$totalEmotions emotions logged • Avg intensity: ${averageIntensity.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                if (mostFrequentEmotion != null)
                  Text(
                    'Most frequent: $mostFrequentEmotion',
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

  Widget _buildStatCard(
    String title,
    String value,
    String suffix,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(Icons.trending_up, color: color, size: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                suffix,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods and data generators...
  
  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    _chartAnimationController.reset();
    _chartAnimationController.forward();
  }

  Future<void> _handleRefresh() async {
    try {
      HomeBloc? homeBloc;
      try {
        homeBloc = GetIt.instance<HomeBloc>();
        homeBloc.add(const home_events.LoadEmotionHistoryEvent(forceRefresh: true));
        homeBloc.add(const home_events.LoadWeeklyInsightsEvent(forceRefresh: true));
      } catch (e) {
        Logger.warning('⚠️ HomeBloc not available in GetIt during refresh');
        // If HomeBloc is not available, just reload demo data
        setState(() {
          _emotionEntries = _getDemoEmotionData();
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('❌ Failed to refresh insights data', e);
    }
  }

  void _showInsightsSettings() {
    // TODO: Implement insights settings
    NavigationService.showInfoSnackBar('Settings coming soon!');
  }

  void _showEmotionHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEmotionHistoryModal(),
    );
  }

  Widget _buildEmotionHistoryModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF8B5CF6), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Emotion History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Emotion list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  )
                : _emotionEntries.isEmpty
                    ? _buildEmptyEmotionHistory()
                    : _buildEmotionHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEmotionHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No emotions logged yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start logging your emotions to see your history here',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _emotionEntries.length,
      itemBuilder: (context, index) {
        final emotion = _emotionEntries[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getEmotionColor(emotion.emotion).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getEmotionColor(emotion.emotion).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                _getEmotionEmoji(emotion.emotion),
                style: const TextStyle(fontSize: 32),
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
                      DateFormat('MMM dd, yyyy HH:mm').format(emotion.timestamp),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    if (emotion.context != null && emotion.context!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        emotion.context!,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Intensity: ${emotion.intensity}',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEmotionColor(emotion.emotion).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      emotion.isAnonymous ? 'Anonymous' : 'Public',
                      style: TextStyle(
                        color: _getEmotionColor(emotion.emotion),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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

  String _getEmotionEmoji(String emotion) {
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

  List<FlSpot> _generateMoodSpots() {
    if (_emotionEntries.isEmpty) {
      return [];
    }
    
    // Group emotions by day and calculate average intensity
    final Map<String, List<double>> dailyEmotions = {};
    
    for (final emotion in _emotionEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(emotion.timestamp);
      dailyEmotions.putIfAbsent(dateKey, () => []).add(emotion.intensity);
    }
    
    // Convert to chart spots
    final spots = <FlSpot>[];
    final sortedDates = dailyEmotions.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      final dateKey = sortedDates[i];
      final intensities = dailyEmotions[dateKey]!;
      final averageIntensity = intensities.reduce((a, b) => a + b) / intensities.length;
      
      spots.add(FlSpot(i.toDouble(), averageIntensity));
    }
    
    return spots;
  }

  List<BarChartGroupData> _generateBarChartData() {
    if (_emotionEntries.isEmpty) {
      return [];
    }
    
    // Count emotions by type
    final Map<String, int> emotionCounts = {};
    
    for (final emotion in _emotionEntries) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }
    
    // Convert to bar chart data
    final barGroups = <BarChartGroupData>[];
    final emotions = emotionCounts.keys.toList();
    
    for (int i = 0; i < emotions.length; i++) {
      final emotion = emotions[i];
      final count = emotionCounts[emotion]!;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getEmotionColor(emotion),
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }

  List<RadarDataSet> _generateRadarChartData() {
    if (_emotionEntries.isEmpty) {
      // Return default data with 5 points for the radar chart
      return [
        RadarDataSet(
          fillColor: const Color(0xFF8B5CF6).withOpacity(0.2),
          borderColor: const Color(0xFF8B5CF6),
          dataEntries: List.generate(5, (index) => RadarEntry(value: 0.0)),
        ),
      ];
    }
    
    // Map emotions to the 5 radar chart categories
    final Map<String, List<double>> categoryData = {
      'Energy': [],
      'Mood': [],
      'Social': [],
      'Sleep': [],
      'Stress': [],
    };
    
    // Categorize emotions into the radar chart categories
    for (final emotion in _emotionEntries) {
      final emotionType = emotion.emotion.toLowerCase();
      final intensity = emotion.intensity;
      
      // Map emotions to categories
      if (emotionType.contains('happiness') || emotionType.contains('joy') || emotionType.contains('excitement')) {
        categoryData['Mood']!.add(intensity);
        categoryData['Energy']!.add(intensity);
      } else if (emotionType.contains('sadness') || emotionType.contains('fear') || emotionType.contains('anxiety')) {
        categoryData['Mood']!.add(intensity);
        categoryData['Stress']!.add(intensity);
      } else if (emotionType.contains('anger') || emotionType.contains('frustration')) {
        categoryData['Stress']!.add(intensity);
        categoryData['Energy']!.add(intensity);
      } else if (emotionType.contains('calm') || emotionType.contains('contentment')) {
        categoryData['Mood']!.add(intensity);
        categoryData['Sleep']!.add(intensity);
      } else {
        // Default mapping
        categoryData['Mood']!.add(intensity);
      }
    }
    
    // Calculate average values for each category
    final values = categoryData.values.map((intensities) {
      if (intensities.isEmpty) return 0.0;
      return intensities.reduce((a, b) => a + b) / intensities.length;
    }).toList();
    
    // Ensure we have exactly 5 values
    while (values.length < 5) {
      values.add(0.0);
    }
    
    return [
      RadarDataSet(
        fillColor: const Color(0xFF8B5CF6).withOpacity(0.2),
        borderColor: const Color(0xFF8B5CF6),
        dataEntries: values.map((value) => RadarEntry(value: value)).toList(),
      ),
    ];
  }

  double _generateHeatmapIntensity(int week, int day) {
    // Generate realistic intensity values
    return ((week + day) % 5) / 4.0;
  }

  Color _getHeatmapColor(double intensity) {
    final colors = [
      const Color(0xFF1A1A2E),
      const Color(0xFF8B5CF6).withOpacity(0.3),
      const Color(0xFF8B5CF6).withOpacity(0.5),
      const Color(0xFF8B5CF6).withOpacity(0.7),
      const Color(0xFF8B5CF6),
    ];
    
    final index = (intensity * (colors.length - 1)).round();
    return colors[index];
  }

  String? _getMostFrequentEmotion() {
    if (_emotionEntries.isEmpty) return null;
    
    final Map<String, int> emotionCounts = {};
    for (final emotion in _emotionEntries) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }
    
    String? mostFrequent;
    int maxCount = 0;
    
    emotionCounts.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = emotion;
      }
    });
    
    return mostFrequent;
  }

  String _getRecentTrend() {
    if (_emotionEntries.length < 2) return 'Insufficient data';
    
    // Get last 7 days of emotions
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final recentEmotions = _emotionEntries
        .where((e) => e.timestamp.isAfter(weekAgo))
        .toList();
    
    if (recentEmotions.length < 2) return 'Need more recent data';
    
    // Calculate trend
    final firstHalf = recentEmotions.take(recentEmotions.length ~/ 2);
    final secondHalf = recentEmotions.skip(recentEmotions.length ~/ 2);
    
    final firstAvg = firstHalf.map((e) => e.intensity).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((e) => e.intensity).reduce((a, b) => a + b) / secondHalf.length;
    
    if (secondAvg > firstAvg + 0.5) return 'Improving';
    if (secondAvg < firstAvg - 0.5) return 'Declining';
    return 'Stable';
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _cardAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  // Additional widgets and methods would go here...
  Widget _buildComparisonSelector() => Container(); // Placeholder
  Widget _buildChartActions() => Container(); // Placeholder
  Widget _buildAdvancedPatternAnalysis() => Container(); // Placeholder
  Widget _buildPredictiveAnalytics() => Container(); // Placeholder
  Widget _buildGoalsAndRecommendations() => Container(); // Placeholder
  Widget _buildInsightsFloatingButton() => Container(); // Placeholder
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

class InsightsSettingsModal extends StatelessWidget {
  final bool showComparison;
  final bool showPredictions;
  final bool showPatterns;
  final Function(Map<String, bool>) onSettingsChanged;

  const InsightsSettingsModal({
    super.key,
    required this.showComparison,
    required this.showPredictions,
    required this.showPatterns,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Insights Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Add settings toggles here
          ],
        ),
      ),
    );
  }
} 