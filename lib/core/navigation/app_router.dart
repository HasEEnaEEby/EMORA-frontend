import 'package:emora_mobile_app/features/home/data/model/user_stats_model.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/dashboard_page.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di/injection_container.dart' as di;
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../features/auth/presentation/view/auth_choice_page.dart';
import '../../features/auth/presentation/view/auth_wrapper_view.dart';
import '../../features/auth/presentation/view/login_view.dart';
import '../../features/auth/presentation/view/register_view.dart';
import '../../features/auth/presentation/view_model/bloc/auth_bloc.dart';
import '../../features/auth/presentation/view_model/bloc/auth_state.dart';
import '../../features/home/presentation/view_model/bloc/home_bloc.dart';
import '../../features/home/presentation/view_model/bloc/home_event.dart';
import '../../features/onboarding/presentation/view/onboarding_view.dart';
import '../../features/onboarding/presentation/view_model/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/view_model/bloc/onboarding_event.dart';
import '../../features/splash/presentation/view/splash_view.dart';
import '../../features/splash/presentation/view_model/cubit/splash_cubit.dart';
import 'navigation_service.dart';
import 'route_analytics.dart';

class AppRouter {
  // Route constants
  static const String splash = '/';
  static const String auth = '/auth';
  static const String authChoice = '/auth-choice';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String moodMap = '/mood-map';
  static const String insights = '/insights';
  static const String friends = '/friends';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Main route generator with proper error handling
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    final arguments = settings.arguments;

    Logger.info('🔄 Navigating to: $routeName with args: $arguments');

    try {
      RouteAnalytics.trackNavigation(routeName, arguments);
      switch (routeName) {
        case splash:
          return _createSplashRoute(settings);

        case auth:
          return _createAuthWrapperRoute(settings);

        case authChoice:
          return _createAuthChoiceRoute(settings);

        case login:
          return _createLoginRoute(settings);

        case register:
          return _createRegisterRoute(settings);

        case onboarding:
          return _createOnboardingRoute(settings);

        case home:
          return _createHomeRoute(settings);

        case dashboard:
          return _createDashboardRoute(settings);

        case moodMap:
          return _createMoodMapRoute(settings);

        case insights:
          return _createInsightsRoute(settings);

        case friends:
          return _createFriendsRoute(settings);

        case profile:
          return _createProfileRoute(settings);

        default:
          Logger.warning('❌ Unknown route: $routeName');
          return _createErrorRoute(routeName, 'Route not found');
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Route generation error for $routeName', e, stackTrace);
      RouteAnalytics.trackRouteError(routeName, e.toString());

      // In debug mode, show detailed error
      if (AppConfig.isDebugMode) {
        return _createDebugErrorRoute(routeName, e.toString(), stackTrace);
      }

      // In production, show user-friendly error
      return _createErrorRoute(routeName, 'Navigation failed');
    }
  }

  // Route Factories

  static Route<dynamic> _createSplashRoute(RouteSettings settings) {
    return _createFadeRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider<SplashCubit>(
          create: (_) => di.sl<SplashCubit>(),
          child: const SplashView(),
        );
      },
    );
  }

  static Route<dynamic> _createAuthWrapperRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          child: const AuthWrapperView(),
        );
      },
    );
  }

  static Route<dynamic> _createAuthChoiceRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        Map<String, dynamic>? onboardingData;

        if (settings.arguments != null) {
          try {
            onboardingData = _parseArguments(settings.arguments);
          } catch (e) {
            Logger.warning('⚠️ Invalid arguments for auth choice: $e');
            onboardingData = null;
          }
        }

        return AuthChoiceView(onboardingData: onboardingData);
      },
    );
  }

  static Route<dynamic> _createLoginRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          child: const LoginView(),
        );
      },
    );
  }

  static Route<dynamic> _createRegisterRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        Map<String, dynamic>? onboardingData;

        if (settings.arguments != null) {
          try {
            onboardingData = _parseArguments(settings.arguments);
          } catch (e) {
            Logger.warning('⚠️ Invalid arguments for register: $e');
            onboardingData = null;
          }
        }

        return BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          child: RegisterView(onboardingData: onboardingData),
        );
      },
    );
  }

  static Route<dynamic> _createOnboardingRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider<OnboardingBloc>(
          create: (_) => di.sl<OnboardingBloc>()..add(LoadOnboardingSteps()),
          child: const OnboardingView(),
        );
      },
    );
  }

  // UPDATED HOME ROUTE - SIMPLIFIED WITHOUT FEATURE FLAGS IN ROUTER
  static Route<dynamic> _createHomeRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        Map<String, dynamic>? arguments;

        if (settings.arguments != null) {
          try {
            arguments = _parseArguments(settings.arguments);
          } catch (e) {
            Logger.warning('⚠️ Invalid arguments for home: $e');
            arguments = null;
          }
        }

        // Always use AdaptiveHomeView - it handles feature detection internally
        Logger.info('✅ Using adaptive home view');
        return BlocProvider<HomeBloc>(
          create: (_) => di.sl<HomeBloc>()..add(const LoadHomeDataEvent()),
          child: AdaptiveHomeView(userData: arguments),
        );
      },
    );
  }

  static Route<dynamic> _createDashboardRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        Map<String, dynamic>? arguments;

        if (settings.arguments != null) {
          try {
            arguments = _parseArguments(settings.arguments);
          } catch (e) {
            Logger.warning('⚠️ Invalid arguments for dashboard: $e');
            arguments = null;
          }
        }

        // Helper function to safely convert userStats argument
        Map<String, dynamic>? getUserStatsMap() {
          if (arguments?['userStats'] == null) return null;

          final userStatsArg = arguments!['userStats'];
          if (userStatsArg is Map<String, dynamic>) {
            return userStatsArg;
          } else if (userStatsArg is UserStatsModel) {
            return userStatsArg.toMap();
          } else {
            Logger.warning(
              '⚠️ Invalid userStats type: ${userStatsArg.runtimeType}',
            );
            return null;
          }
        }

        // Create standalone Dashboard
        return BlocProvider<HomeBloc>(
          create: (_) => di.sl<HomeBloc>()..add(const LoadHomeDataEvent()),
          child: EnhancedDarkDashboard(
            homeData: arguments?['homeData'] as Map<String, dynamic>?,
            userStats: getUserStatsMap(),
            username: arguments?['username'] as String?,
          ),
        );
      },
    );
  }

  static Route<dynamic> _createMoodMapRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const MoodMapPlaceholderView(),
    );
  }

  static Route<dynamic> _createInsightsRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const InsightsPlaceholderView(),
    );
  }

  static Route<dynamic> _createFriendsRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const FriendsPlaceholderView(),
    );
  }

  static Route<dynamic> _createProfileRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const ProfilePlaceholderView(),
    );
  }

  static Map<String, dynamic>? _parseArguments(Object? arguments) {
    if (arguments == null) return null;

    if (arguments is Map<String, dynamic>) {
      return arguments;
    }

    if (arguments is Map) {
      return Map<String, dynamic>.from(arguments);
    }

    throw ArgumentError('Invalid argument type: ${arguments.runtimeType}');
  }

  static Route<dynamic> _createFadeRoute({
    required RouteSettings settings,
    required Widget Function(BuildContext) builder,
    Duration? duration,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic> _createSlideRoute({
    required RouteSettings settings,
    required Widget Function(BuildContext) builder,
    Duration? duration,
  }) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  static Route<dynamic> _createErrorRoute(String? routeName, String message) {
    return _createFadeRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (context) =>
          ErrorScreen(routeName: routeName, message: message, isDebug: false),
    );
  }

  static Route<dynamic> _createDebugErrorRoute(
    String? routeName,
    String error,
    StackTrace stackTrace,
  ) {
    return _createFadeRoute(
      settings: const RouteSettings(name: '/debug-error'),
      builder: (context) => DebugErrorScreen(
        routeName: routeName,
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  static bool canNavigateToRoute(String routeName, BuildContext? context) {
    switch (routeName) {
      case home:
      case dashboard:
      case moodMap:
      case insights:
      case friends:
      case profile:
      case settings:
        // These routes require authentication
        if (context != null) {
          try {
            final authBloc = context.read<AuthBloc>();
            return authBloc.state is AuthAuthenticated;
          } catch (e) {
            Logger.warning('Could not check auth state: $e');
            return false;
          }
        }
        return false;
      default:
        return true;
    }
  }

  static Future<void> navigateToAuthenticatedRoute(
    String routeName,
    BuildContext context, {
    Object? arguments,
  }) async {
    if (canNavigateToRoute(routeName, context)) {
      await NavigationService.pushNamed(routeName, arguments: arguments);
    } else {
      await NavigationService.pushNamedAndClearStack(authChoice);
    }
  }
}

// NEW ADAPTIVE HOME VIEW THAT GOES DIRECTLY TO DASHBOARD
class AdaptiveHomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AdaptiveHomeView({super.key, this.userData});

  @override
  State<AdaptiveHomeView> createState() => _AdaptiveHomeViewState();
}

class _AdaptiveHomeViewState extends State<AdaptiveHomeView> {
  @override
  void initState() {
    super.initState();
    // Initialize the bloc event
    context.read<HomeBloc>().add(const LoadHomeDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            NavigationService.showErrorSnackBar(state.message);
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState is HomeLoading || homeState is HomeInitial) {
              return _buildLoadingView();
            } else if (homeState is HomeDashboardState) {
              // Go directly to DashboardPage which has the beautiful UI
              return EnhancedDarkDashboard(
                homeData: _buildHomeData(homeState),
                userStats: homeState.userStatsMap,
                username: _getUserName(homeState),
              );
            } else if (homeState is HomeError) {
              return _buildErrorView(homeState.message);
            }
            return _buildLoadingView();
          },
        ),
      ),
    );
  }

  String _getUserName(HomeDashboardState state) {
    return widget.userData?['username'] ??
        widget.userData?['userData']?['username'] ??
        widget.userData?['user']?.username ??
        state.username ??
        'User';
  }

  Map<String, dynamic> _buildHomeData(HomeDashboardState state) {
    // Create a comprehensive homeData map for DashboardPage
    final Map<String, dynamic> baseData = <String, dynamic>{
      'currentMood': state.homeData.currentMood ?? 'joy',
      'moodEmoji': _getMoodEmoji(state.homeData.currentMood ?? 'joy'),
      'todayMoodLogged': true,
      'streak': state.homeData.streak ?? 7,
      'totalSessions': 25,
      'weekMoods': <String>['😊', '😌', '😊', '😰', '😊', '😑', '😊'],
      'recommendations': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Happy Vibes\nPlaylist',
          'type': 'music',
          'image': 'mood_1.jpg',
        },
        <String, dynamic>{
          'title': 'Calm Mind\nMeditation',
          'type': 'meditation',
          'image': 'meditation_1.jpg',
        },
        <String, dynamic>{
          'title': 'Energy Boost\nWorkout',
          'type': 'exercise',
          'image': 'energy_1.jpg',
        },
      ],
      'risingFromCards': <Map<String, dynamic>>[
        <String, dynamic>{
          'title': 'Rising from\nOverwhelm',
          'completed': false,
          'progress': 0.3,
        },
        <String, dynamic>{
          'title': 'Building\nConfidence',
          'completed': false,
          'progress': 0.6,
        },
        <String, dynamic>{
          'title': 'Managing\nAnxiety',
          'completed': false,
          'progress': 0.2,
        },
        <String, dynamic>{
          'title': 'Finding\nBalance',
          'completed': false,
          'progress': 0.8,
        },
      ],
      'globalEmotions': <String, dynamic>{
        'totalUsers': 2300000,
        'todayEntries': 450000,
        'locations': <Map<String, dynamic>>[
          <String, dynamic>{
            'city': 'New York',
            'emotion': 'Happy',
            'percentage': 42,
          },
          <String, dynamic>{
            'city': 'Tokyo',
            'emotion': 'Calm',
            'percentage': 38,
          },
          <String, dynamic>{
            'city': 'London',
            'emotion': 'Anxious',
            'percentage': 28,
          },
          <String, dynamic>{
            'city': 'Sydney',
            'emotion': 'Happy',
            'percentage': 52,
          },
          <String, dynamic>{
            'city': 'Kathmandu',
            'emotion': 'Happy',
            'percentage': 45,
          },
        ],
      },
    };

    // Merge with dashboard data if available
    if (state.dashboardData.isNotEmpty) {
      baseData.addAll(state.dashboardData);
    }

    return baseData;
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'joy':
      case 'happy':
        return '😊';
      case 'sad':
      case 'sadness':
        return '😢';
      case 'angry':
      case 'anger':
        return '😠';
      case 'fear':
      case 'anxious':
        return '😰';
      case 'disgust':
        return '🤢';
      case 'calm':
        return '😌';
      case 'overwhelmed':
        return '🤯';
      default:
        return '😊';
    }
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Enhanced loading animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      const Color(0xFF6B3FA0).withValues(alpha: 0.2),
                      const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                        strokeWidth: 3,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text('🌍', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
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
                'Loading your emotional journey and global insights...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Connection Lost',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeDataEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep your existing placeholder views
class MoodMapPlaceholderView extends StatelessWidget {
  const MoodMapPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('Mood Atlas', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 80, color: Color(0xFF8B5CF6)),
            SizedBox(height: 16),
            Text(
              'Global Emotion Map',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'Explore emotions worldwide!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightsPlaceholderView extends StatelessWidget {
  const InsightsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('Insights', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 80, color: Color(0xFF8B5CF6)),
            SizedBox(height: 16),
            Text(
              'Emotional Insights',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'Deep analytics coming soon!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendsPlaceholderView extends StatelessWidget {
  const FriendsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('Friends', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Color(0xFF8B5CF6)),
            SizedBox(height: 16),
            Text(
              'Friends & Social',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'Connect with your emotional community!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Color(0xFF8B5CF6)),
            SizedBox(height: 16),
            Text(
              'Your Profile',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              'Personalization options coming soon!',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String? routeName;
  final String message;
  final bool isDebug;

  const ErrorScreen({
    super.key,
    this.routeName,
    required this.message,
    this.isDebug = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Navigation Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (routeName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Route: $routeName',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => NavigationService.pushNamedAndClearStack(
                    AppRouter.splash,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DebugErrorScreen extends StatelessWidget {
  final String? routeName;
  final String error;
  final StackTrace stackTrace;

  const DebugErrorScreen({
    super.key,
    this.routeName,
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Debug Error', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Route Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: $routeName',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Stack Trace:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                stackTrace.toString(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => NavigationService.pushNamedAndClearStack(
                      AppRouter.splash,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Restart App'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
