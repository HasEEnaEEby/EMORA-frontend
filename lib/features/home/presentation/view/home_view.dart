// lib/features/home/presentation/view/home_view.dart

import 'package:emora_mobile_app/app/constants/app_colors.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/navigation_service.dart';
import '../view_model/bloc/home_bloc.dart';
import '../view_model/bloc/home_event.dart';
import '../view_model/bloc/home_state.dart';
import 'pages/welcome_completion_page.dart';

class IntegratedHomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const IntegratedHomeView({super.key, this.userData});

  @override
  State<IntegratedHomeView> createState() => _IntegratedHomeViewState();
}

class _IntegratedHomeViewState extends State<IntegratedHomeView> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
    // Note: MoodBloc removed until mood feature is implemented
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            NavigationService.showErrorSnackBar(state.message);
          } else if (state is HomeWelcomeState) {
            _showWelcomeMessage();
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (_shouldShowLoading(homeState)) {
              return _buildLoadingView();
            } else if (homeState is HomeWelcomeState) {
              final isActualFirstTime = widget.userData?['isFirstTime'] == true;
              if (isActualFirstTime) {
                return WelcomeCompletionPage(
                  homeData: _convertToMap(homeState.homeData),
                  isFirstTimeLogin: true,
                );
              } else {
                return _buildDashboard(homeState);
              }
            } else if (_hasData(homeState)) {
              return _buildDashboard(homeState);
            } else if (homeState is HomeError) {
              return _buildErrorView(homeState.message);
            }

            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  bool _shouldShowLoading(HomeState homeState) {
    return (homeState is HomeLoading || homeState is HomeInitial);
  }

  bool _hasData(HomeState homeState) {
    return (homeState is HomeDashboardState || homeState is HomeWelcomeState);
  }

  Widget _buildDashboard(HomeState homeState) {
    Map<String, dynamic> homeData = {};
    Map<String, dynamic> userStats = {};

    if (homeState is HomeDashboardState) {
      homeData = _convertToMap(homeState.homeData);
      userStats = _convertToMap(homeState.userStats);
    } else if (homeState is HomeWelcomeState) {
      homeData = _convertToMap(homeState.homeData);
      userStats = _getMockUserStats();
    }

    // Enhanced data (without mood information for now)
    Map<String, dynamic> enhancedData = Map.from(homeData);

    return EnhancedDarkDashboard(
      homeData: enhancedData,
      userStats: userStats,
      username: _getUserName(),
    );
  }

  String _getUserName() {
    return widget.userData?['userData']?['username'] ??
        widget.userData?['user']?.username ??
        widget.userData?['username'] ??
        'User';
  }

  void _showWelcomeMessage() {
    if (widget.userData?['isFirstTime'] == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final username = _getUserName();
          NavigationService.showSuccessSnackBar(
            'Welcome to Emora, $username! 🎉',
          );
        }
      });
    }
  }

  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) {
      return _getMockHomeData();
    }

    if (data is Map<String, dynamic>) {
      return data.isNotEmpty ? data : _getMockHomeData();
    }

    // Try to convert model to map
    try {
      if (data.runtimeType.toString().contains('Model')) {
        return data.toMap() ?? _getMockHomeData();
      }
    } catch (e) {
      return _getMockHomeData();
    }

    return _getMockHomeData();
  }

  Map<String, dynamic> _getMockHomeData() {
    return {
      'username': _getUserName(),
      'currentMood': 'Happy',
      'moodEmoji': '😊',
      'todayMoodLogged': true,
      'streak': 7,
      'totalSessions': 25,
      'selectedAvatar': 'panda',
      'weekMoods': ['😊', '😌', '😊', '😰', '😊', '😑', '😊'],
      'globalEmotions': {
        'totalUsers': 2300000,
        'todayEntries': 450000,
        'locations': [
          {'city': 'New York', 'emotion': 'Happy', 'percentage': 42},
          {'city': 'Tokyo', 'emotion': 'Calm', 'percentage': 38},
          {'city': 'London', 'emotion': 'Anxious', 'percentage': 28},
          {'city': 'Sydney', 'emotion': 'Happy', 'percentage': 52},
          {'city': 'Kathmandu', 'emotion': 'Happy', 'percentage': 45},
        ],
      },
    };
  }

  Map<String, dynamic> _getMockUserStats() {
    return {
      'moodCheckins': 25,
      'streakDays': 7,
      'totalSessions': 25,
      'averageMood': 'Happy',
      'weeklyTrend': 'Improving',
      'lastActivityDate': DateTime.now().toIso8601String(),
      'joinDate': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
    };
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.4),
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🌍', style: TextStyle(fontSize: 32)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(bounds),
                child: const Text(
                  'Connecting to EMORA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your emotional journey...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.red.withValues(alpha: 0.3),
                        Colors.red.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Connection Lost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _initializeData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
