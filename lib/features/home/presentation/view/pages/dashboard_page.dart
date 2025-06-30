import 'package:emora_mobile_app/app/constants/app_dimensions.dart';
import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/emotion_greeting_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../view_model/bloc/home_bloc.dart';
import '../../view_model/bloc/home_event.dart';

class EnhancedDarkDashboard extends StatefulWidget {
  final Map<String, dynamic>? homeData;
  final Map<String, dynamic>? userStats;
  final String? username;
  final bool? hasLoggedMoodToday;

  const EnhancedDarkDashboard({
    super.key,
    this.homeData,
    this.userStats,
    this.username,
    this.hasLoggedMoodToday,
  });

  @override
  State<EnhancedDarkDashboard> createState() => _EnhancedDarkDashboardState();
}

class _EnhancedDarkDashboardState extends State<EnhancedDarkDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  String selectedMood = 'happy';
  int selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _bounceController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeData() {
    if (widget.homeData != null) {
      selectedMood = widget.homeData!['currentMood']?.toLowerCase() ?? 'happy';
      if (!EmotionConstants.emotions.containsKey(selectedMood)) {
        selectedMood = 'happy';
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F), // Pure dark background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: const Color(0xFF1A1A2E),
                  color: const Color(0xFF8B5CF6),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Enhanced Dark Header
                        _buildDarkHeader(),
                        const SizedBox(height: AppDimensions.paddingLarge),

                        // Personalized greeting card with dark theme
                        ScaleTransition(
                          scale: _bounceAnimation,
                          child: EmotionGreetingCard(
                            username: widget.username,
                            hasLoggedMoodToday: widget.hasLoggedMoodToday,
                            selectedMood: selectedMood,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingXLarge),

                        // Enhanced stats grid
                        _buildEnhancedStats(),

                        const SizedBox(height: AppDimensions.paddingXLarge),

                        // Dark themed emotion selector
                        _buildDarkEmotionSelector(),

                        const SizedBox(height: AppDimensions.paddingXLarge),

                        // Insights card
                        _buildInsightsCard(),

                        const SizedBox(height: AppDimensions.paddingXLarge),

                        // Global emotion preview with dark theme
                        _buildDarkGlobalEmotions(),

                        const SizedBox(height: AppDimensions.paddingXLarge),

                        // Safe space message
                        _buildDarkSafeSpace(),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              // Enhanced dark navigation
              _buildDarkBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkHeader() {
    final emotion = EmotionConstants.getEmotion(selectedMood);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          // Animated logo with emotion color
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        emotion['color'].withOpacity(0.8),
                        emotion['color'].withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: emotion['color'].withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 15),

          // App title and greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      emotion['color'],
                      emotion['color'].withOpacity(0.7),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'EMORA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTimeBasedGreeting(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Notification icon with emotion accent
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.circle,
              border: Border.all(
                color: emotion['color'].withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: emotion['color'].withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: emotion['color'],
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: emotion['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStats() {
    final streak = widget.userStats?['streakDays'] ?? 7;
    final totalSessions = widget.userStats?['totalSessions'] ?? 25;
    final moodCheckins = widget.userStats?['moodCheckins'] ?? 25;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDarkStatCard(
              '🔥',
              '$streak',
              'Day Streak',
              const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildDarkStatCard(
              '📊',
              '$totalSessions',
              'Sessions',
              const Color(0xFF00BCD4),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildDarkStatCard(
              '💭',
              '$moodCheckins',
              'Check-ins',
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStatCard(
    String emoji,
    String value,
    String label,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkEmotionSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mood, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Express Yourself',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDarkEmotionCard('😊', 'Happy', const Color(0xFFFFC107)),
              _buildDarkEmotionCard('😌', 'Calm', const Color(0xFF4CAF50)),
              _buildDarkEmotionCard('😰', 'Anxious', const Color(0xFF9C27B0)),
              _buildDarkEmotionCard('😢', 'Sad', const Color(0xFF2196F3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkEmotionCard(String emoji, String emotion, Color color) {
    return GestureDetector(
      onTap: () => _onEmotionSelected(emotion),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 40)),
            ),
            const SizedBox(height: 16),
            Text(
              emotion,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final emotion = EmotionConstants.getEmotion(selectedMood);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.insights, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getRandomPercentage()}% of people feel ${emotion['name']} today',
                  style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                ),
              ],
            ),
          ),
          Text(emotion['emoji'], style: const TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildDarkGlobalEmotions() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.public, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Emotions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'See how the world feels today',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your emotions connect you to the world 🌊',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkSafeSpace() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF4CAF50),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is your safe space',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Express your emotions freely and authentically',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingMedium,
        horizontal: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.home_filled,
              'Home',
              const Color(0xFF8B5CF6),
            ),
            _buildNavItem(1, Icons.public, 'Atlas', const Color(0xFF4CAF50)),
            _buildNavItem(
              2,
              Icons.insights,
              'Insights',
              const Color(0xFF00BCD4),
            ),
            _buildNavItem(3, Icons.people, 'Friends', const Color(0xFFFF6B35)),
            _buildVentingNavItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color) {
    final isSelected = selectedNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavigationItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentingNavItem() {
    return GestureDetector(
      onTap: _showVentingInterface,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.air, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text(
              'Vent',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  int _getRandomPercentage() {
    return 25 + (DateTime.now().millisecond % 30); // 25-55%
  }

  Future<void> _handleRefresh() async {
    context.read<HomeBloc>().add(const RefreshHomeDataEvent());
    await Future.delayed(const Duration(seconds: 1));
  }

  void _onEmotionSelected(String emotion) {
    Logger.info('🎭 Emotion selected: $emotion');
    setState(() {
      selectedMood = emotion.toLowerCase();
    });
    _showEmotionIntensityDialog(emotion);
  }

  void _showEmotionIntensityDialog(String emotion) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EmotionIntensitySelector(
        emotion: emotion,
        onSelected: (intensity) {
          Navigator.pop(context);
          _logEmotion(emotion, intensity);
        },
      ),
    );
  }

  void _logEmotion(String emotion, double intensity) {
    Logger.info('📝 Logging emotion: $emotion with intensity: $intensity');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(EmotionConstants.getEmotionEmoji(emotion)),
            const SizedBox(width: 8),
            Text('Emotion logged: $emotion'),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onNavigationItemSelected(int index) {
    setState(() {
      selectedNavIndex = index;
    });
    _handleNavigation(index);
  }

  void _showVentingInterface() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const VentingModal(),
    );
  }

  void _handleNavigation(int index) {
    final homeBloc = context.read<HomeBloc>();

    switch (index) {
      case 0:
        homeBloc.add(const LoadHomeDataEvent());
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood Atlas coming soon! 🗺️'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insights coming soon! 📊'),
            backgroundColor: Color(0xFF00BCD4),
          ),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friends coming soon! 👥'),
            backgroundColor: Color(0xFFFF6B35),
          ),
        );
        break;
    }
  }
}

// Emotion Intensity Selector for Dark Theme
class EmotionIntensitySelector extends StatefulWidget {
  final String emotion;
  final Function(double) onSelected;

  const EmotionIntensitySelector({
    super.key,
    required this.emotion,
    required this.onSelected,
  });

  @override
  State<EmotionIntensitySelector> createState() =>
      _EmotionIntensitySelectorState();
}

class _EmotionIntensitySelectorState extends State<EmotionIntensitySelector> {
  double _intensity = 0.5;

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(widget.emotion);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'How intense is this ${widget.emotion.toLowerCase()} feeling?',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: emotion['color'],
              inactiveTrackColor: emotion['color'].withOpacity(0.3),
              thumbColor: emotion['color'],
              overlayColor: emotion['color'].withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: _intensity,
              onChanged: (value) {
                setState(() {
                  _intensity = value;
                });
              },
              min: 0.1,
              max: 1.0,
              divisions: 9,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mild',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Intense',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => widget.onSelected(_intensity),
              style: ElevatedButton.styleFrom(
                backgroundColor: emotion['color'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: emotion['color'].withOpacity(0.3),
              ),
              child: const Text(
                'Log Emotion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Enhanced Venting Modal for Dark Theme
class VentingModal extends StatefulWidget {
  const VentingModal({super.key});

  @override
  State<VentingModal> createState() => _VentingModalState();
}

class _VentingModalState extends State<VentingModal> {
  String ventingText = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2D1B69), Color(0xFF1A1A2E), Color(0xFF0A0A0F)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          children: [
            _buildHandleBar(),
            const SizedBox(height: 24),
            _buildVentingHeader(),
            const SizedBox(height: 24),
            _buildSafeSpaceMessage(),
            const SizedBox(height: 24),
            _buildVentingTextArea(),
            const SizedBox(height: 24),
            _buildReleaseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildVentingHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E63).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.air, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Let It Out',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Release what\'s weighing on your mind',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafeSpaceMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.security, color: Colors.white70, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'This is your safe space. Nothing you write here will be saved or shared.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentingTextArea() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: TextField(
          onChanged: (value) => setState(() => ventingText = value),
          maxLines: null,
          expands: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText:
                'Just let it all out... \n\nType whatever you\'re feeling. Get frustrated, be angry, feel sad - it\'s all okay here. \n\nNo one will judge you. This is your moment.',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
              height: 1.5,
            ),
            border: InputBorder.none,
          ),
          textAlignVertical: TextAlignVertical.top,
        ),
      ),
    );
  }

  Widget _buildReleaseButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: ventingText.isNotEmpty ? _releaseEmotions : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.whatshot, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'Release & Let Go 🔥',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _releaseEmotions() {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('🌸', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'ve let it go. Take a deep breath. You\'re okay. 💙',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
