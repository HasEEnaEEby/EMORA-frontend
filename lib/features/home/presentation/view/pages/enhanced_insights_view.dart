
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../core/network/dio_client.dart';
import '../../services/enhanced_insights_service.dart';

class EnhancedInsightsView extends StatefulWidget {
  const EnhancedInsightsView({super.key});

  @override
  State<EnhancedInsightsView> createState() => _EnhancedInsightsViewState();
}

class _EnhancedInsightsViewState extends State<EnhancedInsightsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  String _selectedPeriod = 'week';
  String _chartType = 'line'; 
  
  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _patterns = {};
  Map<String, dynamic> _trends = {};
  List<dynamic> _recommendations = [];
  List<dynamic> _achievements = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<Period> _periods = [
    Period('today', 'Today', Icons.today, const Color(0xFF4CAF50)),
    Period('week', 'Week', Icons.view_week, const Color(0xFF2196F3)),
    Period('month', 'Month', Icons.calendar_month, const Color(0xFF8B5CF6)),
    Period('year', 'Year', Icons.event, const Color(0xFFE91E63)),
  ];

  late final EnhancedInsightsService _insightsService;

  @override
  void initState() {
    super.initState();
    _insightsService = EnhancedInsightsService(GetIt.instance<DioClient>());
    _initializeAnimations();
    _fetchRealInsights();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  Future<void> _fetchRealInsights() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
      Logger.info('🎯 Fetching REAL insights for timeframe: $_selectedPeriod');
        
      final response = await _insightsService.getRealInsights(
        timeframe: _selectedPeriod,
      );
        
      Logger.info('✅ Real insights received: ${response.keys}');
        
              setState(() {
        _summary = response['summary'] as Map<String, dynamic>? ?? {};
        _patterns = response['patterns'] as Map<String, dynamic>? ?? {};
        _trends = response['trends'] as Map<String, dynamic>? ?? {};
        _recommendations = response['recommendations'] as List<dynamic>? ?? [];
        _achievements = response['achievements'] as List<dynamic>? ?? [];
                _isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      Logger.error('❌ Failed to fetch real insights', e);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load insights: ${e.toString()}';
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
            _buildHeader(),
            Expanded(
              child: _isLoading 
                  ? _buildLoadingState()
                  : _errorMessage != null 
                      ? _buildErrorState() 
                      : _buildRealInsightsContent(),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildHeader() {
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
                            'Real Data',
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
                      'Your actual emotional patterns',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildRealSummary(),
        ],
      ),
    );
  }

  Widget _buildRealSummary() {
    final totalEntries = _summary['totalEntries'] ?? 0;
    final dominantEmotion = _summary['dominantEmotion'] ?? '';
    final avgIntensity = _summary['averageIntensity'] ?? 0.0;
    final description = _summary['description'] ?? '';
    
    if (totalEntries == 0) {
      return Container(
        padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A2E).withOpacity(0.6),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.analytics, color: Color(0xFF8B5CF6), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No emotions logged for this period',
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
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFF6366F1).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Color(0xFF8B5CF6), size: 20),
              const SizedBox(width: 12),
              Text(
                'Real Insights Summary',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalEntries emotions • Avg: ${avgIntensity.toStringAsFixed(1)}/5 • Dominant: $dominantEmotion',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
                      style: TextStyle(
                color: Colors.grey[300],
                        fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
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
            'Loading real insights...',
            style: TextStyle(color: Colors.white, fontSize: 16),
                ),
            ],
          ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchRealInsights,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildRealInsightsContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildPeriodSelector()),
          
          SliverToBoxAdapter(child: _buildChartTypeSelector()),
          
          SliverToBoxAdapter(child: _buildRealDataChart()),
          
          SliverToBoxAdapter(child: _buildRealQuickStats()),
          
          SliverToBoxAdapter(child: _buildRealPatterns()),
          
          SliverToBoxAdapter(child: _buildRealTrends()),
          
          SliverToBoxAdapter(child: _buildRealRecommendations()),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time Period',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    final chartTypes = [
      ChartType('line', 'Line', Icons.show_chart),
      ChartType('bar', 'Bar', Icons.bar_chart),
      ChartType('pie', 'Pie', Icons.pie_chart),
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

  Widget _buildRealDataChart() {
    if (_summary['totalEntries'] == 0) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A2E).withOpacity(0.6),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, color: Colors.grey, size: 48),
                SizedBox(height: 16),
                Text(
                  'No data available for this period',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Log some emotions to see your analytics',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                const Text(
              'Real Mood Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return _buildRealChart();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealChart() {
    final timeOfDayData = _patterns['timeOfDay'] as List<dynamic>? ?? [];
    final dayOfWeekData = _patterns['dayOfWeek'] as List<dynamic>? ?? [];
    
    switch (_chartType) {
      case 'line':
        return _buildRealLineChart(timeOfDayData);
      case 'bar':
        return _buildRealBarChart(dayOfWeekData);
      case 'pie':
        return _buildRealPieChart();
      default:
        return _buildRealLineChart(timeOfDayData);
    }
  }

  Widget _buildRealLineChart(List<dynamic> timeOfDayData) {
    if (timeOfDayData.isEmpty) {
      return const Center(
        child: Text(
          'No time-based data available',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    final spots = timeOfDayData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final avgIntensity = (data['avgIntensity'] as num?)?.toDouble() ?? 0.0;
      return FlSpot(index.toDouble(), avgIntensity);
    }).toList();

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
                final index = value.toInt();
                if (index >= 0 && index < timeOfDayData.length) {
                  final data = timeOfDayData[index] as Map<String, dynamic>;
                  final timeOfDay = data['timeOfDay']?.toString() ?? '';
                return Text(
                    timeOfDay.length > 3 ? timeOfDay.substring(0, 3) : timeOfDay,
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
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

  Widget _buildRealBarChart(List<dynamic> dayOfWeekData) {
    if (dayOfWeekData.isEmpty) {
      return const Center(
        child: Text(
          'No weekly data available',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    final barGroups = dayOfWeekData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final count = (data['count'] as num?)?.toDouble() ?? 0.0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count,
            color: const Color(0xFF8B5CF6),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: dayOfWeekData.map((d) => (d['count'] as num?)?.toDouble() ?? 0.0).reduce((a, b) => a > b ? a : b) + 1,
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
                final index = value.toInt();
                if (index >= 0 && index < dayOfWeekData.length) {
                  final data = dayOfWeekData[index] as Map<String, dynamic>;
                  final dayOfWeek = data['dayOfWeek']?.toString() ?? '';
                  return Text(
                    dayOfWeek.length > 3 ? dayOfWeek.substring(0, 3) : dayOfWeek,
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
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
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildRealPieChart() {
    final timeOfDayData = _patterns['timeOfDay'] as List<dynamic>? ?? [];
    
    if (timeOfDayData.isEmpty) {
      return const Center(
        child: Text(
          'No emotion distribution data available',
          style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }

    final sections = timeOfDayData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value as Map<String, dynamic>;
      final count = (data['count'] as num?)?.toDouble() ?? 0.0;
      final timeOfDay = data['timeOfDay']?.toString() ?? '';
      
      final colors = [
        const Color(0xFF8B5CF6),
        const Color(0xFF6366F1),
        const Color(0xFF4F46E5),
        const Color(0xFF7C3AED),
      ];
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: count,
        title: timeOfDay,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildRealQuickStats() {
    final totalEntries = _summary['totalEntries'] ?? 0;
    final avgIntensity = _summary['averageIntensity'] ?? 0.0;
    final dominantEmotion = _summary['dominantEmotion'] ?? '';
    final emotionalVariety = _summary['emotionalVariety'] ?? 0;
    
    if (totalEntries == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
                        child: Container(
        padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Entries', totalEntries.toString(), Icons.edit_note),
            _buildStatItem('Avg Mood', avgIntensity.toStringAsFixed(1), Icons.mood),
            _buildStatItem('Variety', emotionalVariety.toString(), Icons.palette),
            _buildStatItem('Dominant', _capitalizeFirst(dominantEmotion), Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
        children: [
        Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
                  color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
                  style: TextStyle(
            color: Colors.grey[400],
                    fontSize: 10,
                ),
              ),
            ],
    );
  }

  Widget _buildRealPatterns() {
    final timeOfDayData = _patterns['timeOfDay'] as List<dynamic>? ?? [];
    final dayOfWeekData = _patterns['dayOfWeek'] as List<dynamic>? ?? [];
    final emotionTransitions = _patterns['emotionTransitions'] as List<dynamic>? ?? [];
    
    if (timeOfDayData.isEmpty && dayOfWeekData.isEmpty && emotionTransitions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          _buildSectionHeader('Real Patterns', Icons.insights, const Color(0xFF4CAF50)),
          const SizedBox(height: 16),
          
          if (timeOfDayData.isNotEmpty) ...[
            Text(
              'Time of Day Patterns',
              style: TextStyle(
                color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            const SizedBox(height: 8),
            ...timeOfDayData.map((pattern) => _buildPatternCard(
              '${pattern['timeOfDay']} (${pattern['count']} entries)',
              'Dominant emotion: ${pattern['dominantEmotion']} • Avg intensity: ${pattern['avgIntensity'].toStringAsFixed(1)}',
              const Color(0xFF4CAF50),
            )),
            const SizedBox(height: 16),
          ],
          
          if (dayOfWeekData.isNotEmpty) ...[
            Text(
              'Day of Week Patterns',
                        style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            const SizedBox(height: 8),
            ...dayOfWeekData.map((pattern) => _buildPatternCard(
              '${pattern['dayOfWeek']}s (${pattern['count']} entries)',
              'Dominant emotion: ${pattern['dominantEmotion']} • Avg intensity: ${pattern['avgIntensity'].toStringAsFixed(1)}',
              const Color(0xFF2196F3),
            )),
            const SizedBox(height: 16),
          ],
          
          if (emotionTransitions.isNotEmpty) ...[
                Text(
              'Emotion Transitions',
                  style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...emotionTransitions.take(3).map((transition) => _buildPatternCard(
              '${transition['from']} → ${transition['to']}',
              'Intensity: ${transition['fromIntensity']} → ${transition['toIntensity']}',
              const Color(0xFFFF9800),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildRealTrends() {
    final trend = _trends['trend'] ?? '';
    final description = _trends['description'] ?? '';
    
    if (trend.isEmpty && description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Mood Trends', Icons.trending_up, const Color(0xFF2196F3)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF2196F3).withOpacity(0.1),
          border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                if (trend.isNotEmpty) ...[
            Row(
              children: [
                      Icon(
                        _getTrendIcon(trend),
                        color: const Color(0xFF2196F3),
                    size: 20,
                  ),
                      const SizedBox(width: 8),
          Text(
                        'Trend: ${_capitalizeFirst(trend)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (description.isNotEmpty)
                Text(
                    description,
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

  Widget _buildRealRecommendations() {
    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildSectionHeader('Recommendations', Icons.lightbulb, const Color(0xFFFFD700)),
          const SizedBox(height: 16),
          ..._recommendations.map((rec) => _buildRecommendationItem(rec)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
              children: [
        Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ],
    );
  }

  Widget _buildPatternCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
            title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const SizedBox(height: 4),
                Text(
            description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(dynamic recommendation) {
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
              color: Color(0xFFFFD700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation is String 
                  ? recommendation 
                  : (recommendation['description'] ?? recommendation.toString()),
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


  void _onPeriodChanged(String period) {
    setState(() => _selectedPeriod = period);
    HapticFeedback.lightImpact();
    _fetchRealInsights();
  }

  void _onChartTypeChanged(String chartType) {
    setState(() => _chartType = chartType);
    HapticFeedback.lightImpact();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await _fetchRealInsights();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Real insights refreshed!'),
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

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      case 'stable':
        return Icons.trending_flat;
      default:
        return Icons.trending_flat;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}


class EnhancedInsightsService {
  final DioClient _dioClient;

  EnhancedInsightsService(this._dioClient);

  Future<Map<String, dynamic>> getRealInsights({
    required String timeframe,
    String? userId,
  }) async {
    try {
      Logger.info('🎯 Fetching REAL insights for timeframe: $timeframe');

      final response = await _dioClient.get(
        '/api/emotions/comprehensive-insights',
        queryParameters: {
          'timeframe': timeframe,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Real insights retrieved successfully');
        
        final responseData = data['data'] as Map<String, dynamic>? ?? {};
        
        return {
          'summary': responseData['summary'] ?? {},
          'patterns': responseData['patterns'] ?? {},
          'trends': responseData['trends'] ?? {},
          'recommendations': responseData['recommendations'] ?? [],
          'achievements': responseData['achievements'] ?? [],
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Failed to fetch insights: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Failed to fetch real insights', e);
rethrow; 
    }
  }
}


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

