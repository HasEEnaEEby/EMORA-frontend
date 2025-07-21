import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view/pages/models/emotion_map_models.dart';
import 'package:emora_mobile_app/features/emotion/services/emotion_map_service.dart';
import 'package:emora_mobile_app/features/emotion/services/insights_service.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/global_insights_widget.dart';
import 'package:emora_mobile_app/features/emotion/presentation/widget/ai_insights_widget.dart';
import 'package:emora_mobile_app/app/di/injection_container.dart' as di;
import 'package:emora_mobile_app/core/network/api_service.dart';

class EnhancedAtlasView extends StatefulWidget {
  final EmotionBloc? emotionBloc; // Optional parameter

  const EnhancedAtlasView({super.key, this.emotionBloc});

  @override
  State<EnhancedAtlasView> createState() => _EnhancedAtlasViewState();
}

class _EnhancedAtlasViewState extends State<EnhancedAtlasView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  
  final MapController _mapController = MapController();
  
  // Map state
  bool _showHeatmap = true;
  bool _showClusters = true;
  bool _showPredictions = false;
  String _timeFilter = '24h';
  String _emotionFilter = 'all';
  
  // Real data from API
  List<GlobalEmotionPoint> _emotionPoints = [];
  List<EmotionCluster> _emotionClusters = [];
  GlobalEmotionStats? _globalStats;
  bool _isLoadingEmotions = true;
  String? _errorMessage;

  // AI Insights
  EmotionInsight? _globalInsight;
  EmotionInsight? _selectedRegionInsight;
  bool _isLoadingInsights = false;
  String? _insightsErrorMessage;
  String _selectedTimeRange = '7d';

  late EmotionBloc _emotionBloc;
  final EmotionMapService _mapService = EmotionMapService();
  InsightsService? _insightsService;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Use the passed bloc or try to find it in context
    if (widget.emotionBloc != null) {
      _emotionBloc = widget.emotionBloc!;
    } else {
      _emotionBloc = context.read<EmotionBloc>();
    }
    
    // Initialize insights service
    try {
      _insightsService = InsightsService(di.sl<ApiService>());
      print('✅ InsightsService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize InsightsService: $e');
      _insightsService = null;
    }
    
    _loadGlobalEmotionData();
    
    // Load AI insights
    _loadGlobalInsights();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  // API Methods
  Future<void> _loadGlobalEmotionData() async {
          setState(() {
      _isLoadingEmotions = true;
      _errorMessage = null;
    });

    try {
      // Load emotion data points
      await _loadEmotionData();
      
      // Load emotion clusters
      await _loadEmotionClusters();
      
      // Load global stats
      await _loadGlobalStats();
      
      setState(() {
        _isLoadingEmotions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEmotions = false;
        _errorMessage = 'Failed to load emotion data: $e';
      });
    }
  }

  Future<void> _loadEmotionData() async {
    try {
      print('🔄 Loading emotion data points...');
      final apiResponse = await _mapService.getEmotionData();

      if (apiResponse.success) {
        print('✅ Loaded ${apiResponse.data.length} emotion points');
        setState(() {
          _emotionPoints = apiResponse.data;
        });
      } else {
        throw Exception(apiResponse.error ?? 'Failed to load emotion data');
      }
    } catch (e) {
      setState(() {
        _emotionPoints = [];
      });
      print('❌ Error loading emotion data: $e');
    }
  }

  Future<void> _loadEmotionClusters() async {
    try {
      print('🔄 Loading emotion clusters...');
      final apiResponse = await _mapService.getEmotionClusters();

      if (apiResponse.success) {
        print('✅ Loaded ${apiResponse.data.length} emotion clusters');
        print('📊 Cluster data: ${apiResponse.data.map((c) => '${c.country ?? c.displayName}: ${c.count} emotions (${c.coreEmotion})').join(', ')}');
        
        // Debug: Print each cluster details
        for (int i = 0; i < apiResponse.data.length; i++) {
          final cluster = apiResponse.data[i];
          print('📍 Cluster $i: ${cluster.country} - ${cluster.coreEmotion} (${cluster.count} emotions, intensity: ${cluster.avgIntensity})');
        }
        
        setState(() {
          _emotionClusters = apiResponse.data;
        });
      } else {
        print('❌ Failed to load clusters: ${apiResponse.error}');
        setState(() {
            _emotionClusters = [];
        });
      }
    } catch (e) {
      setState(() {
            _emotionClusters = [];
      });
      print('❌ Error loading emotion clusters: $e');
    }
  }

  Future<void> _loadGlobalStats() async {
    try {
      final apiResponse = await _mapService.getGlobalStats();

      if (apiResponse.success && apiResponse.data != null) {
        setState(() {
          _globalStats = apiResponse.data;
        });
      }
    } catch (e) {
      setState(() {
            _globalStats = null;
      });
      print('Error loading global stats: $e');
    }
  }

  // AI Insights Methods
  Future<void> _loadGlobalInsights() async {
    if (_insightsService == null) {
      print('⚠️ InsightsService not initialized');
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Insights service not available';
      });
      return;
    }

    setState(() {
      _isLoadingInsights = true;
      _insightsErrorMessage = null;
    });

    try {
      final insight = await _insightsService!.getGlobalInsights(
        timeRange: _selectedTimeRange,
      );
      
      setState(() {
        _globalInsight = insight;
        _isLoadingInsights = false;
          });
    } catch (e) {
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Failed to load AI insights: $e';
      });
      print('Error loading global insights: $e');
    }
  }

  Future<void> _loadRegionInsights(String region) async {
    if (_insightsService == null) {
      print('⚠️ InsightsService not initialized');
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Insights service not available';
      });
      return;
    }

    setState(() {
      _isLoadingInsights = true;
      _insightsErrorMessage = null;
    });

    try {
      final insight = await _insightsService!.getRegionInsights(
        region: region,
        timeRange: _selectedTimeRange,
      );
      
      setState(() {
        _selectedRegionInsight = insight;
        _isLoadingInsights = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingInsights = false;
        _insightsErrorMessage = 'Failed to load region insights: $e';
      });
      print('Error loading region insights: $e');
    }
  }

  void _showAIInsightsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
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
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'AI Emotional Intelligence',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Time range selector
                        _buildTimeRangeSelector(),
                        const SizedBox(height: 20),
                        
                        // Global Insights
                        if (_globalInsight != null) ...[
                          Text(
                            'Global Insights',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AIInsightsWidget(
                            insight: _globalInsight,
                            onRefresh: _loadGlobalInsights,
                          ),
                          const SizedBox(height: 20),
                        ] else if (_insightsService == null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.orange.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'AI Insights service not available. Please check your connection.',
                                    style: TextStyle(
                                      color: Colors.orange.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Region Insights (if available)
                        if (_selectedRegionInsight != null) ...[
                          Text(
                            '${_selectedRegionInsight!.region} Insights',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AIInsightsWidget(
                            insight: _selectedRegionInsight,
                            onRefresh: () => _loadRegionInsights(_selectedRegionInsight!.region),
                          ),
                        ],
                        
                        // Loading state
                        if (_isLoadingInsights)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        
                        // Error state
                        if (_insightsErrorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _insightsErrorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildTimeRangeSelector() {
    final timeRanges = [
      {'value': '24h', 'label': '24 Hours'},
      {'value': '7d', 'label': '7 Days'},
      {'value': '30d', 'label': '30 Days'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time Range',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: timeRanges.map((range) {
            final isSelected = _selectedTimeRange == range['value'];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeRange = range['value']!;
                  });
                  _loadGlobalInsights();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey.shade600,
                    ),
                  ),
                  child: Text(
                    range['label']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClusterStats(EmotionCluster cluster) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cluster Statistics',
            style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Count',
                  '${cluster.count}',
                  Icons.people,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Avg Intensity',
                  '${cluster.avgIntensity.toStringAsFixed(1)}/5',
                  Icons.speed,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Dominant Emotion',
                  cluster.coreEmotion,
                  Icons.sentiment_satisfied,
                  _getEmotionColor(cluster.coreEmotion),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Location',
                  cluster.displayName,
                  Icons.location_on,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
        }



  @override
  Widget build(BuildContext context) {
    return BlocListener<EmotionBloc, EmotionState>(
      listener: (context, state) {
        // Handle emotion bloc state changes if needed
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Stack(
          children: [
            // Enhanced Leaflet Map
            _buildEnhancedMap(),
            
            // Gradient Overlay
            _buildGradientOverlay(),
            
            // Enhanced Header
            _buildEnhancedHeader(),
            
            // Live Stats Panel
            if (_globalStats != null) _buildLiveStatsPanel(),
            
            // Floating Action Buttons
            _buildFloatingActions(),
            
            // Loading Overlay
            if (_isLoadingEmotions) _buildLoadingOverlay(),
            
            // Error Overlay
            if (_errorMessage != null) _buildErrorOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(20.0, 0.0), // Center on world
        initialZoom: 2.0,
        minZoom: 1.0,
        maxZoom: 18.0,
        backgroundColor: const Color(0xFF0A0A0F),

        onMapReady: () {
          print('Map is ready for interaction');
        },
      ),
      children: [
        // Dark theme map tiles
        TileLayer(
          urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.emora.atlas',
        ),
        
        // Emotion Clusters
        if (_showClusters && _emotionClusters.isNotEmpty) MarkerLayer(
          markers: _emotionClusters.map((cluster) => Marker(
            point: cluster.center,
            width: (cluster.size * 0.8).clamp(15.0, 40.0), // Smaller size
            height: (cluster.size * 0.8).clamp(15.0, 40.0), // Smaller size
            child: EmotionClusterMarker(
              cluster: cluster,
              animation: _pulseAnimation,
              onTap: () => _showClusterDetails(cluster),
            ),
          )).toList(),
        ),
        
        // Individual Emotion Points
        if (_emotionPoints.isNotEmpty) MarkerLayer(
          markers: _emotionPoints.map((point) => Marker(
            point: point.coordinates,
            width: 20, // Smaller size
            height: 20, // Smaller size
            child: GlobalEmotionMarker(
              point: point,
              animation: _pulseAnimation,
              onTap: () => _showEmotionDetails(point),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.transparent,
                const Color(0xFF0A0A0F).withValues(alpha: 0.2),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0F).withValues(alpha: 0.9),
              const Color(0xFF0A0A0F).withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Back button
                _buildGlassButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                
                const SizedBox(width: 16),
                
                // Title with live indicator
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                              ).createShader(bounds),
                              child: const Text(
                                'Global Emotion Map',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildLiveIndicator(),
                        ],
                      ),
                      Text(
                        'Real-time global emotional intelligence',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Filter button
                _buildGlassButton(
                  icon: Icons.filter_list,
                  onTap: _showFilterModal,
                ),
                _buildGlassButton(
                  icon: Icons.refresh,
                  onTap: _refreshGlobalData,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatsPanel() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.public, color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Global Pulse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Live • ${_formatTimeAgo(_globalStats!.lastUpdated)}',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Global stats grid
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Emotions',
                        '${_globalStats!.totalEmotions}',
                        Icons.psychology,
                        Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Avg Intensity',
                        '${_globalStats!.avgIntensity.toStringAsFixed(1)}/5',
                        Icons.trending_up,
                        _getIntensityColor(_globalStats!.avgIntensity),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Dominant',
                        _globalStats!.dominantEmotion.toUpperCase(),
                        Icons.favorite,
                        _getEmotionColor(_globalStats!.dominantEmotion),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 200,
      right: 20,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'ai_insights',
            backgroundColor: Color(0xFF8B5CF6),
            onPressed: _showAIInsightsModal,
            child: Icon(Icons.psychology, color: Colors.white),
          ),
          
          SizedBox(height: 12),
          
          FloatingActionButton(
            heroTag: 'refresh',
            backgroundColor: Color(0xFF4CAF50),
            onPressed: _refreshGlobalData,
            child: Icon(Icons.refresh, color: Colors.white),
          ),
          
          SizedBox(height: 12),
          
          FloatingActionButton(
            heroTag: 'insights',
            backgroundColor: Color(0xFF6366F1),
            onPressed: _showGlobalInsights,
            child: Icon(Icons.analytics, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Loading global emotions...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() => _errorMessage = null),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: (color ?? Colors.white).withValues(alpha: 0.1),
          border: Border.all(
            color: (color ?? Colors.white).withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon, color: color ?? Colors.white, size: 20),
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final clampedValue = _pulseAnimation.value.clamp(0.0, 1.0);
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFF4CAF50).withValues(alpha: 0.2),
            border: Border.all(
              color: Color(0xFF4CAF50).withValues(alpha: clampedValue),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(
    String title,
    List<String> options,
    String selected,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        // FIX: Replace problematic Row with Wrap for better overflow handling
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected 
                      ? Color(0xFF8B5CF6).withValues(alpha: 0.3)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? Color(0xFF8B5CF6)
                        : Colors.grey[600]!,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Color(0xFF8B5CF6) : Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String title, bool value, Function(bool) onChanged) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 80, 
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible( 
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF8B5CF6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
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

  // Action methods
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onFiltersChanged: (filters) {
          // Apply filters and reload data
          _loadGlobalEmotionData();
        },
      ),
      );
  }

  void _refreshGlobalData() {
    _loadGlobalEmotionData();
    _loadGlobalInsights();
  }

  void _showGlobalInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlobalInsightsWidget(stats: _globalStats),
      ),
    );
  }



  void _showClusterDetails(EmotionCluster cluster) {
    // Load region insights for this cluster
    // Use country name for better matching, fallback to city, then display name
    final regionName = cluster.country ?? cluster.city ?? cluster.displayName;
    print('🔍 Loading insights for region: $regionName (cluster: ${cluster.displayName})');
    _loadRegionInsights(regionName);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
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
                            Text(
                              cluster.emotionEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${cluster.count} people feeling ${cluster.coreEmotion}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    cluster.displayName,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Cluster statistics
                        _buildClusterStats(cluster),
                        
                        const SizedBox(height: 20),
                        
                        // AI Insights for this region
                        if (_selectedRegionInsight != null) ...[
                          Text(
                            'AI Insights for ${cluster.displayName}',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AIInsightsWidget(
                            insight: _selectedRegionInsight,
                            onRefresh: () => _loadRegionInsights(cluster.displayName),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Loading state for insights
                        if (_isLoadingInsights)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B5CF6),
                              ),
                            ),
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

  void _showEmotionDetails(GlobalEmotionPoint point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => EmotionDetailsModal(point: point),
    );
  }

  // Utility methods
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Color _getIntensityColor(double intensity) {
    if (intensity >= 4.0) return Color(0xFF4CAF50);
    if (intensity >= 3.0) return Color(0xFF2196F3);
    if (intensity >= 2.0) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return Color(0xFFF59E0B);
      case 'trust': return Color(0xFF10B981);
      case 'fear': return Color(0xFF8B5CF6);
      case 'surprise': return Color(0xFFF97316);
      case 'sadness': return Color(0xFF3B82F6);
      case 'disgust': return Color(0xFF059669);
      case 'anger': return Color(0xFFEF4444);
      case 'anticipation': return Color(0xFFFCD34D);
      default: return Color(0xFF6B7280);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// ============================================================================
// CUSTOM MARKERS
// ============================================================================

class EmotionClusterMarker extends StatelessWidget {
  final EmotionCluster cluster;
  final Animation<double> animation;
  final VoidCallback onTap;

  const EmotionClusterMarker({
    super.key,
    required this.cluster,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Blurred pulsing ring
              Container(
                width: (cluster.size * 0.6 * animation.value).clamp(8.0, 25.0),
                height: (cluster.size * 0.6 * animation.value).clamp(8.0, 25.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(cluster.coreEmotion)
                      .withValues(alpha: 0.05 * (2 - animation.value).clamp(0.0, 1.0)),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(cluster.coreEmotion).withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                  ),
                  ],
                ),
              ),
              
              // Main cluster marker - smaller with blur
              Container(
                width: (cluster.size * 0.4).clamp(6.0, 18.0),
                height: (cluster.size * 0.4).clamp(6.0, 18.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(cluster.coreEmotion).withValues(alpha: 0.8),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(cluster.coreEmotion).withValues(alpha: 0.4),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return Color(0xFFF59E0B);
      case 'trust': return Color(0xFF10B981);
      case 'fear': return Color(0xFF8B5CF6);
      case 'surprise': return Color(0xFFF97316);
      case 'sadness': return Color(0xFF3B82F6);
      case 'disgust': return Color(0xFF059669);
      case 'anger': return Color(0xFFEF4444);
      case 'anticipation': return Color(0xFFFCD34D);
      default: return Color(0xFF6B7280);
    }
  }
}

class GlobalEmotionMarker extends StatelessWidget {
  final GlobalEmotionPoint point;
  final Animation<double> animation;
  final VoidCallback onTap;

  const GlobalEmotionMarker({
    super.key,
    required this.point,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Blurred pulsing effect
              Container(
                width: (15 * animation.value).clamp(8.0, 20.0),
                height: (15 * animation.value).clamp(8.0, 20.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(point.coreEmotion)
                      .withValues(alpha: 0.1 * (2 - animation.value).clamp(0.0, 1.0)),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(point.coreEmotion).withValues(alpha: 0.2),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
              
              // Main marker - smaller with blur
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(point.coreEmotion).withValues(alpha: 0.9),
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: _getEmotionColor(point.coreEmotion).withValues(alpha: 0.3),
                      blurRadius: 2.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy': return Color(0xFFF59E0B);
      case 'trust': return Color(0xFF10B981);
      case 'fear': return Color(0xFF8B5CF6);
      case 'surprise': return Color(0xFFF97316);
      case 'sadness': return Color(0xFF3B82F6);
      case 'disgust': return Color(0xFF059669);
      case 'anger': return Color(0xFFEF4444);
      case 'anticipation': return Color(0xFFFCD34D);
      default: return Color(0xFF6B7280);
    }
  }
}

// ============================================================================
// MODAL COMPONENTS
// ============================================================================

class FilterModal extends StatelessWidget {
  final Function(EmotionMapFilters) onFiltersChanged;

  const FilterModal({super.key, required this.onFiltersChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Filter Emotions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Customize your global emotion view',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            // Add filter controls here
          ],
        ),
      ),
    );
  }
}

class ClusterDetailsModal extends StatelessWidget {
  final EmotionCluster cluster;

  const ClusterDetailsModal({super.key, required this.cluster});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Emotion Cluster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${cluster.count} people feeling ${cluster.coreEmotion}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${cluster.displayName}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Average Intensity: ${cluster.avgIntensity.toStringAsFixed(1)}/5',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionDetailsModal extends StatelessWidget {
  final GlobalEmotionPoint point;

  const EmotionDetailsModal({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Emotion Point',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Location: ${point.displayName}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Core Emotion: ${point.coreEmotion}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 8),
            Text(
              'Count: ${point.count} emotions',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 8),
            Text(
              'Avg Intensity: ${point.avgIntensity.toStringAsFixed(1)}/5',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
