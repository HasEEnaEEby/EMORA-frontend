import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class EarthEmotionalMapView extends StatefulWidget {
  const EarthEmotionalMapView({super.key});

  @override
  State<EarthEmotionalMapView> createState() => _EarthEmotionalMapViewState();
}

class _EarthEmotionalMapViewState extends State<EarthEmotionalMapView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // User location
  LatLng _userLocation = LatLng(27.7172, 85.3240); // Default to Kathmandu
  bool _isLoadingLocation = true;
  bool _showSearchResults = false;

  // Search results
  final List<SearchResult> _searchResults = [];

  // Enhanced emotion data with more visual variety
  final List<EmotionRadarPoint> _emotionPoints = [
    EmotionRadarPoint(
      location: LatLng(40.7128, -74.0060),
      city: "New York",
      country: "USA",
      emotion: "Energetic",
      intensity: 85,
      population: 12000,
      color: Color(0xFFFFD700),
      icon: Icons.flash_on,
    ),
    EmotionRadarPoint(
      location: LatLng(51.5074, -0.1278),
      city: "London",
      country: "UK",
      emotion: "Calm",
      intensity: 72,
      population: 8500,
      color: Color(0xFF4FC3F7),
      icon: Icons.waves,
    ),
    EmotionRadarPoint(
      location: LatLng(35.6762, 139.6503),
      city: "Tokyo",
      country: "Japan",
      emotion: "Focused",
      intensity: 90,
      population: 15000,
      color: Color(0xFF9C27B0),
      icon: Icons.center_focus_strong,
    ),
    EmotionRadarPoint(
      location: LatLng(48.8566, 2.3522),
      city: "Paris",
      country: "France",
      emotion: "Romantic",
      intensity: 78,
      population: 9200,
      color: Color(0xFFE91E63),
      icon: Icons.favorite,
    ),
    EmotionRadarPoint(
      location: LatLng(27.7172, 85.3240),
      city: "Kathmandu",
      country: "Nepal",
      emotion: "Peaceful",
      intensity: 65,
      population: 3400,
      color: Color(0xFF4CAF50),
      icon: Icons.self_improvement,
    ),
    EmotionRadarPoint(
      location: LatLng(-33.8688, 151.2093),
      city: "Sydney",
      country: "Australia",
      emotion: "Excited",
      intensity: 88,
      population: 7800,
      color: Color(0xFFFF9800),
      icon: Icons.celebration,
    ),
    EmotionRadarPoint(
      location: LatLng(55.7558, 37.6176),
      city: "Moscow",
      country: "Russia",
      emotion: "Contemplative",
      intensity: 60,
      population: 11500,
      color: Color(0xFF9E9E9E),
      icon: Icons.psychology,
    ),
    EmotionRadarPoint(
      location: LatLng(39.9042, 116.4074),
      city: "Beijing",
      country: "China",
      emotion: "Ambitious",
      intensity: 92,
      population: 18000,
      color: Color(0xFFF44336),
      icon: Icons.trending_up,
    ),
  ];

  // Famous locations for search
  final List<SearchResult> _worldLocations = [
    SearchResult("New York, USA", LatLng(40.7128, -74.0060)),
    SearchResult("London, UK", LatLng(51.5074, -0.1278)),
    SearchResult("Tokyo, Japan", LatLng(35.6762, 139.6503)),
    SearchResult("Paris, France", LatLng(48.8566, 2.3522)),
    SearchResult("Sydney, Australia", LatLng(-33.8688, 151.2093)),
    SearchResult("Moscow, Russia", LatLng(55.7558, 37.6176)),
    SearchResult("Beijing, China", LatLng(39.9042, 116.4074)),
    SearchResult("Mumbai, India", LatLng(19.0760, 72.8777)),
    SearchResult("São Paulo, Brazil", LatLng(-23.5505, -46.6333)),
    SearchResult("Cairo, Egypt", LatLng(30.0444, 31.2357)),
    SearchResult("Lagos, Nigeria", LatLng(6.5244, 3.3792)),
    SearchResult("Mexico City, Mexico", LatLng(19.4326, -99.1332)),
    SearchResult("Bangkok, Thailand", LatLng(13.7563, 100.5018)),
    SearchResult("Istanbul, Turkey", LatLng(41.0082, 28.9784)),
    SearchResult("Dubai, UAE", LatLng(25.2048, 55.2708)),
    SearchResult("Singapore", LatLng(1.3521, 103.8198)),
    SearchResult("Los Angeles, USA", LatLng(34.0522, -118.2437)),
    SearchResult("Berlin, Germany", LatLng(52.5200, 13.4050)),
    SearchResult("Toronto, Canada", LatLng(43.6532, -79.3832)),
    SearchResult("Buenos Aires, Argentina", LatLng(-34.6037, -58.3816)),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getUserLocation();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _mapController.move(_userLocation, 8.0);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _showSearchResults = false;
      });
      return;
    }

    final results = _worldLocations
        .where(
          (location) =>
              location.name.toLowerCase().contains(query.toLowerCase()),
        )
        .take(5)
        .toList();

    setState(() {
      _searchResults.clear();
      _searchResults.addAll(results);
      _showSearchResults = true;
    });
  }

  void _goToLocation(LatLng location) {
    _mapController.move(location, 12.0);
    setState(() {
      _showSearchResults = false;
    });
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // Enhanced background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 2.0,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
          ),

          // Main Map with enhanced styling
          _buildMap(),

          // Animated Header
          _buildAnimatedHeader(),

          // Enhanced Search Results
          if (_showSearchResults) _buildEnhancedSearchResults(),

          // Modern Legend
          _buildModernLegend(),

          // Stylish Map Controls
          _buildStylishMapControls(),

          // Loading overlay
          if (_isLoadingLocation) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation,
        initialZoom: _isLoadingLocation ? 2.0 : 8.0,
        minZoom: 2.0,
        maxZoom: 18.0,
      ),
      children: [
        // Enhanced dark map style
        TileLayer(
          urlTemplate:
              'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_nolabels/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.emora.emotional_radar',
          retinaMode: RetinaMode.isHighDensity(context),
        ),

        // Enhanced emotion radar points
        MarkerLayer(
          markers: _emotionPoints.map((point) {
            return Marker(
              point: point.location,
              width: 100,
              height: 100,
              child: EnhancedEmotionMarker(
                point: point,
                pulseAnimation: _pulseAnimation,
                onTap: () => _showEmotionDetails(point),
              ),
            );
          }).toList(),
        ),

        // Enhanced user location
        if (!_isLoadingLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation,
                width: 50,
                height: 50,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2196F3).withValues(alpha: 0.6),
                            blurRadius: 15 * _pulseAnimation.value,
                            spreadRadius: 5 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAnimatedHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e).withValues(alpha: 0.95),
              Color(0xFF1a1a2e).withValues(alpha: 0.8),
              Colors.transparent,
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced Header Row
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Global Emotion Map',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'Real-time emotional insights',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildStatusIndicator(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Enhanced Search Bar
                _buildEnhancedSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xFF4CAF50).withValues(alpha: 0.2),
            border: Border.all(
              color: Color(
                0xFF4CAF50,
              ).withValues(alpha: 0.5 + 0.3 * _pulseAnimation.value),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4CAF50),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4CAF50).withValues(alpha: 0.5),
                      blurRadius: 4 * _pulseAnimation.value,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Live',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchLocation,
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search cities worldwide...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _showSearchResults = false);
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchResults() {
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final double headerHeight = safeAreaTop + 120;

    return Positioned(
      top: headerHeight,
      left: 20,
      right: 20,
      child: Container(
        constraints: BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF2a2a3e).withValues(alpha: 0.95),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return Container(
                decoration: BoxDecoration(
                  border: index < _searchResults.length - 1
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 0.5,
                          ),
                        )
                      : null,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFF2196F3).withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    result.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  onTap: () => _goToLocation(result.location),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernLegend() {
    return Positioned(
      bottom: 30,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF2a2a3e).withValues(alpha: 0.9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.radar, color: Color(0xFF4CAF50), size: 18),
                SizedBox(width: 8),
                Text(
                  'Live Emotions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Tap any city for details',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Active Now',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylishMapControls() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.my_location,
            onTap: () => _mapController.move(_userLocation, 12.0),
            color: Color(0xFF2196F3),
          ),
          SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.add,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          SizedBox(height: 12),
          _buildControlButton(
            icon: Icons.remove,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: (color ?? Color(0xFF2a2a3e)).withValues(alpha: 0.9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Color(0xFF0F0F23).withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color(0xFF2a2a3e),
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      Icons.location_searching,
                      color: Color(0xFF2196F3),
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Finding your location...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmotionDetails(EmotionRadarPoint point) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EnhancedEmotionDetailsSheet(point: point),
    );
  }
}

// Enhanced Data Models
class EmotionRadarPoint {
  final LatLng location;
  final String city;
  final String country;
  final String emotion;
  final int intensity;
  final int population;
  final Color color;
  final IconData icon;

  EmotionRadarPoint({
    required this.location,
    required this.city,
    required this.country,
    required this.emotion,
    required this.intensity,
    required this.population,
    required this.color,
    required this.icon,
  });
}

class SearchResult {
  final String name;
  final LatLng location;

  SearchResult(this.name, this.location);
}

// Enhanced Emotion Marker
class EnhancedEmotionMarker extends StatelessWidget {
  final EmotionRadarPoint point;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const EnhancedEmotionMarker({
    super.key,
    required this.point,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 60 * pulseAnimation.value,
                height: 60 * pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: point.color.withValues(
                    alpha: 0.1 * (2 - pulseAnimation.value),
                  ),
                  border: Border.all(
                    color: point.color.withValues(
                      alpha: 0.3 * (2 - pulseAnimation.value),
                    ),
                    width: 2,
                  ),
                ),
              ),

              // Inner pulse ring
              Container(
                width: 35 * pulseAnimation.value,
                height: 35 * pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: point.color.withValues(
                    alpha: 0.2 * (2 - pulseAnimation.value),
                  ),
                ),
              ),

              // Main marker
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [point.color.withValues(alpha: 0.9), point.color],
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: point.color.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(point.icon, color: Colors.white, size: 14),
              ),

              // Intensity label
              Positioned(
                top: -8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withValues(alpha: 0.8),
                    border: Border.all(
                      color: point.color.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${point.intensity}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
}

// Enhanced Emotion Details Sheet
class EnhancedEmotionDetailsSheet extends StatefulWidget {
  final EmotionRadarPoint point;

  const EnhancedEmotionDetailsSheet({super.key, required this.point});

  @override
  State<EnhancedEmotionDetailsSheet> createState() =>
      _EnhancedEmotionDetailsSheetState();
}

class _EnhancedEmotionDetailsSheetState
    extends State<EnhancedEmotionDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
          ),
          child: Stack(
            children: [
              // Backdrop tap to close
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),

              // Bottom sheet content
              Positioned(
                bottom: -400 * _slideAnimation.value,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF2a2a3e), Color(0xFF1a1a2e)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Header with city info
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: RadialGradient(
                                  colors: [
                                    widget.point.color.withValues(alpha: 0.3),
                                    widget.point.color.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: widget.point.color.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                widget.point.icon,
                                color: widget.point.color,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.point.city,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.point.country,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Emotion stats
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Current emotion
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Current Emotion',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        widget.point.emotion,
                                        style: TextStyle(
                                          color: widget.point.color,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: widget.point.color.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    child: Text(
                                      '${widget.point.intensity}%',
                                      style: TextStyle(
                                        color: widget.point.color,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Progress bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Intensity Level',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _getIntensityLabel(
                                          widget.point.intensity,
                                        ),
                                        style: TextStyle(
                                          color: widget.point.color,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: widget.point.intensity / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              widget.point.color.withValues(
                                                alpha: 0.7,
                                              ),
                                              widget.point.color,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24),

                              // Active users
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Active Users',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${(widget.point.population / 1000).toStringAsFixed(1)}k people',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.people,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Action buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Close',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add your view trends functionality here
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.point.color,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.trending_up, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'View Trends',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getIntensityLabel(int intensity) {
    if (intensity >= 80) return 'Very High';
    if (intensity >= 60) return 'High';
    if (intensity >= 40) return 'Moderate';
    if (intensity >= 20) return 'Low';
    return 'Very Low';
  }
}
