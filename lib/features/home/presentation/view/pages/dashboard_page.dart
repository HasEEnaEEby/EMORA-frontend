import 'package:emora_mobile_app/features/emotion/presentation/view/pages/mood_atlas_view.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_state.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/community_feed_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/custom_mood_face.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dashboard_modals.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/emotion_analytics_card.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/mood_capsule_timeline.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/quick_actions_grid.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/enhanced_stats_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/todays_journey_widget.dart';
import 'package:emora_mobile_app/features/home/data/model/emotion_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import '../../services/emotion_backend_service.dart';

// 🔧 CRITICAL FIX: Use builder pattern to ensure context has access to HomeBloc
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommunityBloc>(
      create: (context) => GetIt.instance<CommunityBloc>()
        ..add(const LoadGlobalFeedEvent())
        ..add(const LoadGlobalStatsEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Now this context definitely has access to HomeBloc and CommunityBloc
          return _DashboardContent(homeState: state);
        },
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final HomeState homeState;

  const _DashboardContent({required this.homeState});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _breathingController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  late Animation<double> _breathingAnimation;

  // Navigation & State - Using MoodType from custom_mood_face.dart
  int selectedNavIndex = 0;
  MoodType currentMood = MoodType.good;
  String currentMoodLabel = 'good';

  // Backend Integration - Safe access
  EmotionBackendService? _emotionService;
  EmotionBloc? _emotionBloc;
  HomeBloc? _homeBloc;
  bool _isBackendConnected = false;
  final String _userId = 'demo_user_123';

  // Track if user is new
  bool _isNewUser = true;

  // Helper methods to extract data from homeState
  bool get _isUserNew {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.totalMoodEntries == 0;
    }
    return true;
  }

  // Enhanced emotion data extraction
  List<EmotionEntryModel> get _emotionEntries {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.emotionEntries;
    }
    return [];
  }

  List<EmotionEntryModel> get _todaysEmotions {
    final today = DateTime.now();
    return _emotionEntries.where((emotion) {
      final emotionDate = DateTime(
        emotion.timestamp.year,
        emotion.timestamp.month,
        emotion.timestamp.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);
      return emotionDate.isAtSameMomentAs(todayDate);
    }).toList();
  }

  WeeklyInsightsModel? get _weeklyInsights {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.weeklyInsights;
    }
    return null;
  }

  // Stats calculation
  int get _totalLogs {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.totalMoodEntries ?? 0;
    }
    return 0;
  }

  int get _currentStreak {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.streakDays ?? 0;
    }
    return 0;
  }

  double get _averageMood {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      return dashboardState.userStats?.averageMoodScore ?? 0.0;
    }
    return 0.0;
  }

  List<MoodCapsule>? get _moodCapsulesData {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      // For now, return null since we don't have emotion data in the model yet
      // In a real implementation, this would extract emotion entries from dashboardState.homeData
      return null;
    }
    return null;
  }

  List<Map<String, dynamic>>? get _communityPostsData {
    // This method is deprecated - we now get community data directly from CommunityBloc
    // Return null to let CommunityFeedWidget handle real data from CommunityBloc
    return null;
  }

  List<Map<String, dynamic>>? get _weeklyMoodData {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      // For now, return null since we don't have weekly analytics in the model yet
      // In a real implementation, this would extract weekly mood data from userStats
      return null;
    }
    return null;
  }

  Map<String, dynamic>? get _analyticsData {
    if (widget.homeState is HomeDashboardState) {
      final dashboardState = widget.homeState as HomeDashboardState;
      // For now, return null since we don't have analytics data in the model yet
      // In a real implementation, this would extract analytics from userStats
      return null;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Delay initialization to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBackendServices();
      _loadInitialData();
    });
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  // 🔧 FIXED: Safe initialization with proper context access
  void _initializeBackendServices() {
    try {
      if (!mounted) return;

      // Initialize DIO client and emotion service
      try {
        final dioClient = GetIt.instance<DioClient>();
        _emotionService = EmotionBackendService(dioClient);
        Logger.info('✅ EmotionService initialized');
      } catch (e) {
        Logger.warning('⚠️ Could not initialize EmotionService: $e');
      }

      // Get EmotionBloc from GetIt
      try {
        _emotionBloc = GetIt.instance<EmotionBloc>();
        Logger.info('✅ EmotionBloc retrieved from GetIt');
      } catch (e) {
        Logger.warning('⚠️ Could not get EmotionBloc: $e');
      }

      // 🔧 CRITICAL FIX: Now context definitely has HomeBloc access
      try {
        _homeBloc = context.read<HomeBloc>();
        Logger.info('✅ HomeBloc retrieved from context successfully');
      } catch (e) {
        Logger.warning('⚠️ HomeBloc access failed, trying GetIt: $e');
        try {
          _homeBloc = GetIt.instance<HomeBloc>();
          Logger.info('✅ HomeBloc retrieved from GetIt as fallback');
        } catch (e2) {
          Logger.error('❌ Could not get HomeBloc from anywhere: $e2');
        }
      }

      Logger.info('✅ Backend services initialization completed');
      _testBackendConnection();
    } catch (e) {
      Logger.error('❌ Failed to initialize backend services', e);
      _isBackendConnected = false;
    }
  }

  Future<void> _testBackendConnection() async {
    try {
      if (_emotionService == null) return;

      final isHealthy = await _emotionService!.checkBackendHealth();
      if (mounted) {
        setState(() {
          _isBackendConnected = isHealthy;
        });
      }
      Logger.info(isHealthy ? '✅ Backend is healthy' : '⚠️ Backend offline');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBackendConnected = false;
        });
      }
      Logger.warning('⚠️ Backend connection test failed: $e');
    }
  }

  void _loadInitialData() {
    try {
      Logger.info(
        '🎭 Dashboard initialized - loading enhanced emotion data',
      );
      
      // Load emotion history and weekly insights
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(const LoadEmotionHistoryEvent());
        _homeBloc!.add(const LoadWeeklyInsightsEvent());
      }
    } catch (e) {
      Logger.error('❌ Failed to load initial data', e);
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      selectedNavIndex = index;
    });

    switch (index) {
      case 0: // Atlas
        _navigateToMoodAtlas();
        break;
      case 1: // Friends
        NavigationService.pushNamed(AppRouter.friends);
        break;
      case 2: // Insights
        NavigationService.pushNamed(AppRouter.insights);
        break;
      case 3: // Profile
        NavigationService.pushNamed(AppRouter.profile);
        break;
    }
  }

  void _onMoodTapped() {
    _showCustomMoodSelector();
  }

  void _navigateToMoodAtlas() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MoodAtlasView(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _updateMood(MoodType newMood) {
    setState(() {
      currentMood = newMood;
      currentMoodLabel = MoodUtils.moodTypeToString(newMood);
    });

    // Safe EmotionBloc access
    try {
      if (_emotionBloc != null) {
        _emotionBloc!.add(
          LogEmotionEvent(
            emotion: currentMoodLabel,
            intensity: MoodUtils.getMoodIntensity(newMood),
            context: 'daily_check_in',
            userId: _userId,
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ Failed to log mood update', e);
    }

    // Show success feedback for new users
    if (_isNewUser) {
      _showFirstEmotionSuccess();
    }
  }

  void _showCustomMoodSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomMoodSelectorModal(
        currentMood: currentMood,
        onMoodSelected: _updateMood,
      ),
    );
  }

  void _showFirstEmotionSuccess() {
    NavigationService.showSuccessSnackBar(
      '🎉 Congratulations! You logged your first emotion!',
    );
  }

  Future<void> _handleRefresh() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _testBackendConnection();

      // ✅ Safe HomeBloc refresh with proper lifecycle check
      if (_homeBloc != null && !_homeBloc!.isClosed) {
        _homeBloc!.add(const RefreshHomeDataEvent());
      }

      Logger.info('🔄 Dashboard refresh completed');
    } catch (e) {
      Logger.error('❌ Error refreshing data', e);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: SafeArea(
          // 🔧 CRITICAL FIX: Now we can safely use BlocListener since context has HomeBloc
          child: BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state is HomeDashboardState) {
                final isNewUser = state.userStats?.totalMoodEntries == 0;
                if (_isNewUser != isNewUser) {
                  setState(() {
                    _isNewUser = isNewUser;
                  });
                }
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    backgroundColor: const Color(0xFF1A1A2E),
                    color: const Color(0xFF8B5CF6),
                    child: _buildContent(widget.homeState),
                  ),
                ),
                EnhancedBottomNavigationCustom(
                  selectedIndex: selectedNavIndex,
                  onItemTapped: _onNavItemTapped,
                  onMoodTapped: _onMoodTapped,
                  currentMood: currentMood,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state is HomeLoading) {
      return _buildLoadingState();
    } else if (state is HomeError) {
      return _buildErrorState(state.message);
    } else if (state is HomeDashboardState) {
      return _buildDashboardContent(state);
    }
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return _buildEnhancedErrorState(widget.homeState);
  }

  Widget _buildEnhancedErrorState(HomeState state) {
    // Extract error details from HomeError state
    String message = 'Something went wrong';
    bool canRetry = true;
    String retryAction = 'load_home_data';
    
    if (state is HomeError) {
      message = state.message;
      canRetry = state.canRetry;
      retryAction = state.retryAction ?? 'load_home_data';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon with animation
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.orange.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.wifi_off,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Error Title
            const Text(
              'Unable to Load Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Error Message
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            if (canRetry) ...[
              // Primary Retry Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _retryOperation(retryAction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Secondary Action - Use Offline Mode
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _tryOfflineMode();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[300],
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.offline_bolt, size: 20),
                  label: const Text(
                    'Use Offline Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // If can't retry, show contact support option
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showContactSupport();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.support_agent, size: 20),
                  label: const Text('Contact Support'),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Connection Status
            _buildConnectionStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[700]!,
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
              color: _isBackendConnected ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isBackendConnected ? 'Backend Connected' : 'Backend Offline',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _retryOperation(String operation) {
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      switch (operation) {
        case 'load_home_data':
          _homeBloc!.add(const LoadHomeDataEvent(forceRefresh: true));
          break;
        case 'load_user_stats':
          _homeBloc!.add(const LoadUserStatsEvent(forceRefresh: true));
          break;
        default:
          _homeBloc!.add(const LoadHomeDataEvent(forceRefresh: true));
      }
      
      // Show retry feedback
      NavigationService.showInfoSnackBar('Retrying...');
    }
  }

  void _tryOfflineMode() {
    // Try to load cached data
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      // This could trigger loading cached data or showing a simplified offline UI
      NavigationService.showInfoSnackBar('Loading offline data...');
      _loadInitialData(); // Attempt to use any cached data
    }
  }

  void _showContactSupport() {
    // Show support contact options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'re here to help! Reach out if this issue persists.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.showInfoSnackBar('Opening email...');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                    ),
                    icon: const Icon(Icons.email),
                    label: const Text('Email'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.showInfoSnackBar('Opening help center...');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.help),
                    label: const Text('Help'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(HomeDashboardState state) {
    final isNewUser = state.userStats?.totalMoodEntries == 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          if (isNewUser)
            _buildNewUserHeader(state)
          else
            _buildRegularHeader(state),
          const SizedBox(height: 24),
          if (isNewUser) _buildNewUserContent() else _buildRegularContent(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNewUserHeader(HomeDashboardState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              const Color(0xFF6366F1).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to EMORA!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Hi ${state.homeData.username}, ready to start your emotional journey?',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Track your emotions, discover patterns, and connect with a global community of emotional wellness.',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _onMoodTapped,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Log Your First Emotion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularHeader(HomeDashboardState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    const Color(0xFF6366F1).withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CustomMoodFace(
                      mood: currentMood,
                      size: 70,
                      backgroundColor: _isBackendConnected
                          ? MoodUtils.getMoodColor(currentMood)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Current Mood',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isBackendConnected
                                    ? const Color(0xFF10B981)
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoodUtils.getMoodLabel(currentMood),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isBackendConnected
                              ? 'Tap to update your mood'
                              : 'Backend offline - mood saved locally',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _onMoodTapped,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewUserContent() {
    return Column(
      children: [
        _buildFeaturePreview(),
        const SizedBox(height: 24),
        EmotionAnalyticsCard(
          weeklyMoodData: _weeklyMoodData,
          analyticsData: _analyticsData,
          isNewUser: _isUserNew,
        ),
        const SizedBox(height: 24),
        CommunityFeedWidget(
          onViewAllTapped: () => NavigationService.pushNamed(AppRouter.friends),
          isNewUser: _isUserNew,
        ),
      ],
    );
  }

  Widget _buildRegularContent() {
    return Column(
      children: [
        // Enhanced Stats Row
        EnhancedStatsWidget(
          totalLogs: _totalLogs,
          currentStreak: _currentStreak,
          averageMood: _averageMood,
          emotionEntries: _emotionEntries,
          onStatsTap: () => NavigationService.pushNamed(AppRouter.insights),
        ),
        const SizedBox(height: 24),
        
        // Interactive Calendar
        EmotionCalendarWidget(
          emotionEntries: _emotionEntries,
          onDateSelected: _onCalendarDateSelected,
          selectedDate: null, // TODO: Add selected date state
        ),
        const SizedBox(height: 24),
        
        // Today's Journey
        TodaysJourneyWidget(
          todaysEmotions: _todaysEmotions,
          onAddEmotion: _onMoodTapped,
          onEmotionTap: _onEmotionTap,
        ),
        const SizedBox(height: 24),
        
        // Weekly Insights Preview
        WeeklyInsightsPreviewWidget(
          weeklyInsights: _weeklyInsights,
          onViewAll: () => NavigationService.pushNamed(AppRouter.insights),
        ),
        const SizedBox(height: 24),
        
        // Quick Actions
        QuickActionsGrid(
          onVentTapped: _showVentingModal,
          onJournalTapped: _showJournalModal,
          onInsightsTapped: () =>
              NavigationService.pushNamed(AppRouter.insights),
          onAtlasTapped: _navigateToMoodAtlas,
          onDashboardTapped: () => NavigationService.pushNamed(AppRouter.dashboard),
        ),
        const SizedBox(height: 24),
        
        // Community Feed
        CommunityFeedWidget(
          onViewAllTapped: () => NavigationService.pushNamed(AppRouter.friends),
          isNewUser: false,
        ),
      ],
    );
  }

  Widget _buildFeaturePreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What you\'ll discover:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.timeline,
            title: 'Emotion Timeline',
            description: 'Track your emotional patterns over time',
          ),
          _buildFeatureItem(
            icon: Icons.insights,
            title: 'Personal Insights',
            description: 'Discover what influences your mood',
          ),
          _buildFeatureItem(
            icon: Icons.public,
            title: 'Global Community',
            description: 'See how others around the world are feeling',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modal Methods
  void _showMoodCapsuleDetail(dynamic capsule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood Capsule'),
        content: Text('Capsule details: $capsule'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVentingModal() {
    NavigationService.showBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Venting Modal', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Express your feelings freely here...'),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showJournalModal() {
    NavigationService.showBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Journal Modal', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Write about your day and emotions...'),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Enhanced dashboard interaction methods
  void _onCalendarDateSelected(DateTime date) {
    // TODO: Implement calendar date selection
    // This could show a modal with emotions for the selected date
    print('Selected date: $date');
    
    final emotionsForDate = _emotionEntries.where((emotion) {
      final emotionDate = DateTime(
        emotion.timestamp.year,
        emotion.timestamp.month,
        emotion.timestamp.day,
      );
      final selectedDate = DateTime(date.year, date.month, date.day);
      return emotionDate.isAtSameMomentAs(selectedDate);
    }).toList();

    if (emotionsForDate.isNotEmpty) {
      _showDateEmotionsModal(date, emotionsForDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No emotions logged on ${DateFormat('MMM dd, yyyy').format(date)}'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
      );
    }
  }

  void _onEmotionTap(EmotionEntryModel emotion) {
    // TODO: Implement emotion detail view
    // This could show a detailed view of the emotion with edit options
    print('Tapped emotion: ${emotion.emotion}');
    
    _showEmotionDetailModal(emotion);
  }

  void _showDateEmotionsModal(DateTime date, List<EmotionEntryModel> emotions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, MMM dd, yyyy').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: emotions.length,
                itemBuilder: (context, index) {
                  final emotion = emotions[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: emotion.moodColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: emotion.moodColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          emotion.emotionEmoji,
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
                                DateFormat('HH:mm').format(emotion.timestamp),
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
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmotionDetailModal(EmotionEntryModel emotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    emotion.emotionEmoji,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy HH:mm').format(emotion.timestamp),
                          style: TextStyle(
                            color: Colors.grey[400],
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Intensity', emotion.intensityLabel),
                    if (emotion.context != null && emotion.context!.isNotEmpty)
                      _buildDetailRow('Context', emotion.context!),
                    if (emotion.memory != null && emotion.memory!.isNotEmpty)
                      _buildDetailRow('Memory', emotion.memory!),
                    if (emotion.hasLocation)
                      _buildDetailRow('Location', '${emotion.latitude!.toStringAsFixed(4)}, ${emotion.longitude!.toStringAsFixed(4)}'),
                    if (emotion.hasTags)
                      _buildDetailRow('Tags', emotion.tags!.join(', ')),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Implement edit functionality
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                              side: const BorderSide(color: Color(0xFF8B5CF6)),
                            ),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Implement delete functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Bottom Navigation with Custom Mood Face
class EnhancedBottomNavigationCustom extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onMoodTapped;
  final MoodType currentMood;

  const EnhancedBottomNavigationCustom({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onMoodTapped,
    this.currentMood = MoodType.good,
  });

  @override
  State<EnhancedBottomNavigationCustom> createState() =>
      _EnhancedBottomNavigationCustomState();
}


class _EnhancedBottomNavigationCustomState
    extends State<EnhancedBottomNavigationCustom>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Atlas (Map)
                  Expanded(
                    child: _buildNavItem(
                      index: 0,
                      icon: Icons.public_rounded,
                      activeIcon: Icons.public_rounded,
                      label: 'Atlas',
                      isActive: widget.selectedIndex == 0,
                    ),
                  ),

                  // Friends
                  Expanded(
                    child: _buildNavItem(
                      index: 1,
                      icon: Icons.people_outline_rounded,
                      activeIcon: Icons.people_rounded,
                      label: 'Friends',
                      isActive: widget.selectedIndex == 1,
                    ),
                  ),

                  // Space for floating mood button
                  const SizedBox(width: 70),

                  // Insights
                  Expanded(
                    child: _buildNavItem(
                      index: 2,
                      icon: Icons.insights_outlined,
                      activeIcon: Icons.insights_rounded,
                      label: 'Insights',
                      isActive: widget.selectedIndex == 2,
                    ),
                  ),

                  // Profile
                  Expanded(
                    child: _buildNavItem(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      isActive: widget.selectedIndex == 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Mood Button with Custom Face
          Positioned(
            top: 5,
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: _buildFloatingMoodButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[400],
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF8B5CF6) : Colors.grey[500],
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingMoodButton() {
    return GestureDetector(
      onTap: widget.onMoodTapped,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6366F1),
                    Color(0xFF4F46E5),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withValues(alpha: _glowAnimation.value),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomMoodFace(
                    mood: widget.currentMood,
                    size: 45,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    faceColor: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


// Custom Mood Selector Modal with Purple Theme
class CustomMoodSelectorModal extends StatefulWidget {
  final MoodType currentMood;
  final Function(MoodType) onMoodSelected;

  const CustomMoodSelectorModal({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
  });

  @override
  State<CustomMoodSelectorModal> createState() =>
      _CustomMoodSelectorModalState();
}

class _CustomMoodSelectorModalState extends State<CustomMoodSelectorModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ).createShader(bounds),
                  child: const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Mood Options
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: MoodUtils.getAllMoods().map((mood) {
                    final isSelected = mood == widget.currentMood;
                    return _buildMoodOption(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () => _selectMood(mood),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption({
    required MoodType mood,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: CustomMoodFace(mood: mood, size: 60),
          ),
          const SizedBox(height: 8),
          Text(
            MoodUtils.getMoodLabel(mood),
            style: TextStyle(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  void _selectMood(MoodType mood) {
    widget.onMoodSelected(mood);
    Navigator.of(context).pop();
  }
}
