// ============================================================================
// ENHANCED ATLAS WITH LEAFLET & AI FEATURES - FIXED VERSION
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// ============================================================================
// ENHANCED ATLAS VIEW WITH AI FEATURES
// ============================================================================

class EnhancedAtlasView extends StatefulWidget {
  const EnhancedAtlasView({super.key});

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
  
  // AI-powered data
  List<GlobalEmotionPoint> _emotionPoints = [];
  List<EmotionCluster> _emotionClusters = [];
  GlobalEmotionStats? _globalStats;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadGlobalEmotionData();
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

  Future<void> _loadGlobalEmotionData() async {
    // Simulate AI-powered global emotion data loading
    setState(() {
      _emotionPoints = _generateGlobalEmotionPoints();
      _emotionClusters = _generateEmotionClusters();
      _globalStats = _generateGlobalStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Enhanced Leaflet Map
          _buildEnhancedMap(),
          
          // Gradient Overlay
          _buildGradientOverlay(),
          
          // Enhanced Header
          _buildEnhancedHeader(),
          
          // AI Control Panel - FIXED WITH INTRINSIC WIDTH
          _buildAIControlPanel(),
          
          // Live Stats Panel - FIXED WITH INTRINSIC WIDTH
          _buildLiveStatsPanel(),
          
          // Floating Action Buttons
          _buildFloatingActions(),
        ],
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
      ),
      children: [
        // Dark theme map tiles
        TileLayer(
          urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.emora.atlas',
        ),
        
        // Emotion Clusters
        if (_showClusters) MarkerLayer(
          markers: _emotionClusters.map((cluster) => Marker(
            point: cluster.center,
            width: cluster.size * 2,
            height: cluster.size * 2,
            child: EmotionClusterMarker(
              cluster: cluster,
              animation: _pulseAnimation,
              onTap: () => _showClusterDetails(cluster),
            ),
          )).toList(),
        ),
        
        // Individual Emotion Points
        MarkerLayer(
          markers: _emotionPoints.map((point) => Marker(
            point: point.location,
            width: 40,
            height: 40,
            child: GlobalEmotionMarker(
              point: point,
              animation: _pulseAnimation,
              onTap: () => _showEmotionDetails(point),
            ),
          )).toList(),
        ),
        
        // User's emotion contribution
        MarkerLayer(
          markers: [
            Marker(
              point: LatLng(27.7172, 85.3240), // User location
              width: 60,
              height: 60,
              child: UserContributionMarker(animation: _pulseAnimation),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.transparent,
              const Color(0xFF0A0A0F).withOpacity(0.3),
            ],
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
              const Color(0xFF0A0A0F).withOpacity(0.9),
              const Color(0xFF0A0A0F).withOpacity(0.7),
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
                                'Global Atlas',
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
                        'AI-powered global emotion intelligence',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Share emotion button
                _buildGlassButton(
                  icon: Icons.favorite,
                  onTap: _shareEmotionToGlobal,
                  color: const Color(0xFFE91E63),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIControlPanel() {
    return Positioned(
      top: 140,
      left: 20,
      child: IntrinsicWidth( // FIX: Wrap with IntrinsicWidth
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 40, // Respect screen bounds
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1A2E).withOpacity(0.9),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
            children: [
              Row(
                mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
                children: [
                  Icon(Icons.psychology, color: Color(0xFF8B5CF6), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'AI Controls',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Time filter - FIXED
              _buildFilterRow(
                'Time Range',
                ['1h', '24h', '7d', '30d'],
                _timeFilter,
                (value) => setState(() => _timeFilter = value),
              ),
              
              const SizedBox(height: 8),
              
              // Emotion filter - FIXED
              _buildFilterRow(
                'Emotion Type',
                ['all', 'positive', 'negative', 'neutral'],
                _emotionFilter,
                (value) => setState(() => _emotionFilter = value),
              ),
              
              const SizedBox(height: 12),
              
              // Toggle switches - FIXED
              _buildToggleRow('Clusters', _showClusters, (value) {
                setState(() => _showClusters = value);
              }),
              
              _buildToggleRow('Predictions', _showPredictions, (value) {
                setState(() => _showPredictions = value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatsPanel() {
    if (_globalStats == null) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: IntrinsicHeight( // FIX: Wrap with IntrinsicHeight
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF1A1A2E).withOpacity(0.9),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
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
                    'Live • ${_globalStats!.lastUpdated}',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Global stats grid - FIXED
              IntrinsicHeight( // FIX: Wrap Row with IntrinsicHeight
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Users',
                        '${(_globalStats!.activeUsers / 1000).toStringAsFixed(1)}K',
                        Icons.people,
                        Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Avg Mood',
                        '${_globalStats!.averageMood.toStringAsFixed(1)}/10',
                        Icons.mood,
                        _getMoodColor(_globalStats!.averageMood),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Dominant',
                        _globalStats!.dominantEmotion,
                        Icons.favorite,
                        Color(0xFFE91E63),
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
            heroTag: 'my_location',
            backgroundColor: Color(0xFF2196F3),
            onPressed: _goToMyLocation,
            child: Icon(Icons.my_location, color: Colors.white),
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
            backgroundColor: Color(0xFF8B5CF6),
            onPressed: _showGlobalInsights,
            child: Icon(Icons.analytics, color: Colors.white),
          ),
        ],
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
          color: (color ?? Colors.white).withOpacity(0.1),
          border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.2),
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
        // Clamp the animation value to prevent overflow
        final clampedValue = _pulseAnimation.value.clamp(0.0, 1.0);
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFF4CAF50).withOpacity(0.2),
            border: Border.all(
              color: Color(0xFF4CAF50).withOpacity(clampedValue),
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
                      ? Color(0xFF8B5CF6).withOpacity(0.3)
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
        maxWidth: MediaQuery.of(context).size.width - 80, // FIX: Add max width constraint
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // FIX: Add mainAxisSize.min
        children: [
          Flexible( // FIX: Use Flexible instead of Expanded in constrained space
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          SizedBox(width: 8), // FIX: Add some spacing
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
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
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
  void _shareEmotionToGlobal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareEmotionModal(),
    );
  }

  void _goToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        8.0,
      );
    } catch (e) {
      // Handle error
    }
  }

  void _refreshGlobalData() {
    _loadGlobalEmotionData();
  }

  void _showGlobalInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlobalInsightsView(stats: _globalStats),
      ),
    );
  }

  void _showClusterDetails(EmotionCluster cluster) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClusterDetailsModal(cluster: cluster),
    );
  }

  void _showEmotionDetails(GlobalEmotionPoint point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => EmotionDetailsModal(point: point),
    );
  }

  // Data generation methods (replace with real AI/API calls)
  List<GlobalEmotionPoint> _generateGlobalEmotionPoints() {
    return [
      GlobalEmotionPoint(
        location: LatLng(40.7128, -74.0060),
        emotion: 'excited',
        intensity: 0.8,
        timestamp: DateTime.now(),
        aiContext: 'Major event happening in NYC',
      ),
      GlobalEmotionPoint(
        location: LatLng(51.5074, -0.1278),
        emotion: 'content',
        intensity: 0.7,
        timestamp: DateTime.now(),
        aiContext: 'UK showing high contentment due to recent policy changes',
      ),
      GlobalEmotionPoint(
        location: LatLng(35.6762, 139.6503),
        emotion: 'focused',
        intensity: 0.9,
        timestamp: DateTime.now(),
        aiContext: 'Tokyo showing high focus during work hours',
      ),
      // Add more points...
    ];
  }

  List<EmotionCluster> _generateEmotionClusters() {
    return [
      EmotionCluster(
        center: LatLng(51.5074, -0.1278),
        dominantEmotion: 'content',
        emotionCount: 1250,
        averageIntensity: 0.65,
        size: 60,
        aiInsight: 'UK showing high contentment due to recent policy changes',
      ),
      EmotionCluster(
        center: LatLng(40.7128, -74.0060),
        dominantEmotion: 'excited',
        emotionCount: 2100,
        averageIntensity: 0.8,
        size: 80,
        aiInsight: 'NYC showing high excitement around major events',
      ),
      // Add more clusters...
    ];
  }

  GlobalEmotionStats _generateGlobalStats() {
    return GlobalEmotionStats(
      activeUsers: 125000,
      averageMood: 7.2,
      dominantEmotion: 'Content',
      lastUpdated: '2 min ago',
      trendDirection: 'up',
    );
  }

  Color _getMoodColor(double mood) {
    if (mood >= 8.0) return Color(0xFF4CAF50);
    if (mood >= 6.0) return Color(0xFF2196F3);
    if (mood >= 4.0) return Color(0xFFFF9800);
    return Color(0xFFF44336);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class GlobalEmotionPoint {
  final LatLng location;
  final String emotion;
  final double intensity;
  final DateTime timestamp;
  final String aiContext;

  GlobalEmotionPoint({
    required this.location,
    required this.emotion,
    required this.intensity,
    required this.timestamp,
    required this.aiContext,
  });
}

class EmotionCluster {
  final LatLng center;
  final String dominantEmotion;
  final int emotionCount;
  final double averageIntensity;
  final double size;
  final String aiInsight;

  EmotionCluster({
    required this.center,
    required this.dominantEmotion,
    required this.emotionCount,
    required this.averageIntensity,
    required this.size,
    required this.aiInsight,
  });
}

class GlobalEmotionStats {
  final int activeUsers;
  final double averageMood;
  final String dominantEmotion;
  final String lastUpdated;
  final String trendDirection;

  GlobalEmotionStats({
    required this.activeUsers,
    required this.averageMood,
    required this.dominantEmotion,
    required this.lastUpdated,
    required this.trendDirection,
  });
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
              // Pulsing ring
              Container(
                width: cluster.size * animation.value,
                height: cluster.size * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(cluster.dominantEmotion)
                      .withOpacity(0.1 * (2 - animation.value).clamp(0.0, 1.0)),
                  border: Border.all(
                    color: _getEmotionColor(cluster.dominantEmotion)
                        .withOpacity(0.3 * (2 - animation.value).clamp(0.0, 1.0)),
                    width: 2,
                  ),
                ),
              ),
              
              // Main cluster marker
              Container(
                width: cluster.size * 0.6,
                height: cluster.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getEmotionColor(cluster.dominantEmotion),
                      _getEmotionColor(cluster.dominantEmotion).withOpacity(0.7),
                    ],
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(
                    '${(cluster.emotionCount / 1000).toStringAsFixed(1)}K',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
      case 'happy': case 'excited': case 'joyful':
        return Color(0xFFFFD700);
      case 'content': case 'peaceful': case 'calm':
        return Color(0xFF4CAF50);
      case 'sad': case 'down': case 'melancholy':
        return Color(0xFF2196F3);
      case 'angry': case 'frustrated': case 'annoyed':
        return Color(0xFFE91E63);
      case 'anxious': case 'worried': case 'stressed':
        return Color(0xFFFF9800);
      default:
        return Color(0xFF8B5CF6);
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
              // Pulsing effect
              Container(
                width: 30 * animation.value,
                height: 30 * animation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(point.emotion)
                      .withOpacity(0.2 * (2 - animation.value).clamp(0.0, 1.0)),
                ),
              ),
              
              // Main marker
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getEmotionColor(point.emotion),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    // Same as EmotionClusterMarker._getEmotionColor
    switch (emotion.toLowerCase()) {
      case 'happy': case 'excited': case 'joyful':
        return Color(0xFFFFD700);
      case 'content': case 'peaceful': case 'calm':
        return Color(0xFF4CAF50);
      case 'sad': case 'down': case 'melancholy':
        return Color(0xFF2196F3);
      case 'angry': case 'frustrated': case 'annoyed':
        return Color(0xFFE91E63);
      case 'anxious': case 'worried': case 'stressed':
        return Color(0xFFFF9800);
      default:
        return Color(0xFF8B5CF6);
    }
  }
}

class UserContributionMarker extends StatelessWidget {
  final Animation<double> animation;

  const UserContributionMarker({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing rings
            Container(
              width: 50 * animation.value,
              height: 50 * animation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8B5CF6).withOpacity(0.1 * (2 - animation.value).clamp(0.0, 1.0)),
                border: Border.all(
                  color: Color(0xFF8B5CF6).withOpacity(0.3 * (2 - animation.value).clamp(0.0, 1.0)),
                  width: 2,
                ),
              ),
            ),
            
            // Main marker
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// MODAL COMPONENTS
// ============================================================================

class ShareEmotionModal extends StatelessWidget {
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
              'Share Your Emotion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your emotion will be anonymously added to the global emotion map',
              style: TextStyle(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            // Add emotion selection UI here
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
              '${cluster.emotionCount} people feeling ${cluster.dominantEmotion}',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              cluster.aiInsight,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
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
              'Feeling: ${point.emotion}',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Intensity: ${(point.intensity * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 16),
            Text(
              point.aiContext,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalInsightsView extends StatelessWidget {
  final GlobalEmotionStats? stats;

  const GlobalInsightsView({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Global Insights'),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Global insights coming soon...',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}