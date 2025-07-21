import 'dart:async';

import 'package:emora_mobile_app/features/auth/presentation/view/auth_choice_page.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/friends_view.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/insights_view.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../app/di/injection_container.dart' as di;
import '../../core/config/app_config.dart';
import '../../core/utils/logger.dart';
import '../../features/auth/presentation/view/login_view.dart';
import '../../features/auth/presentation/view/register_view.dart';
import '../../features/auth/presentation/view_model/bloc/auth_bloc.dart';
import '../../features/auth/presentation/view_model/bloc/auth_state.dart';
import '../../features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import '../../features/home/presentation/view/pages/dashboard_page.dart';
import '../../features/home/presentation/view_model/bloc/home_bloc.dart';
import '../../features/home/presentation/view_model/bloc/home_event.dart';
import '../../features/home/presentation/view_model/bloc/home_state.dart';
import '../../features/onboarding/presentation/view/onboarding_view.dart';
import '../../features/onboarding/presentation/view_model/bloc/onboarding_bloc.dart';
import '../../features/onboarding/presentation/view_model/bloc/onboarding_event.dart';
import '../../features/profile/presentation/view_model/profile_bloc.dart';
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
  static const String profileFull = '/profile-full';
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
          Logger.info('🔄 Redirecting /dashboard to /home for consistency');
          return _createHomeRoute(RouteSettings(
            name: home,
            arguments: settings.arguments,
          ));

        case moodMap:
          return _createMoodMapRoute(settings);

        case insights:
          return _createInsightsRoute(settings);

        case friends:
          return _createFriendsRoute(settings);

        case profile:
          return MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => GetIt.instance<ProfileBloc>(),
              child: const ProfileView(),
            ),
            settings: settings,
          );

        case profileFull:
          return _createFullProfileRoute(settings);

        default:
          Logger.warning('❌ Unknown route: $routeName');
          return _createErrorRoute(routeName, 'Route not found');
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Route generation error for $routeName', e, stackTrace);

      if (AppConfig.isDebugMode) {
        return _createDebugErrorRoute(routeName, e.toString(), stackTrace);
      }

      return _createErrorRoute(routeName, 'Navigation failed');
    }
  }

  // ============================================================================
  // ROUTE FACTORIES - FIXED WITH PROPER BLOC MANAGEMENT
  // ============================================================================

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
          child: const AuthChoiceView(),
        );
      },
    );
  }

  // CRITICAL FIX: Provide AuthBloc at the auth choice level to share across auth flows
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

        // CRITICAL FIX: Create AuthBloc here to share across auth flows
        return BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          child: AuthChoiceView(onboardingData: onboardingData),
        );
      },
    );
  }

  // CRITICAL FIX: Reuse existing AuthBloc when available
  static Route<dynamic> _createLoginRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        return Builder(
          builder: (context) {
            // Try to get existing AuthBloc from context
            try {
              final existingBloc = context.read<AuthBloc>();
              // Check if BLoC is not closed
              if (!existingBloc.isClosed) {
                Logger.info('✅ Reusing existing AuthBloc for login');
                return const LoginView();
              }
            } catch (e) {
              Logger.info('ℹ️ No existing AuthBloc found, creating new one');
            }

            // If no existing BLoC or it's closed, create a new one
            return BlocProvider<AuthBloc>(
              create: (_) => di.sl<AuthBloc>(),
              child: const LoginView(),
            );
          },
        );
      },
    );
  }

  // CRITICAL FIX: Reuse existing AuthBloc when available
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

        return Builder(
          builder: (context) {
            // Try to get existing AuthBloc from context
            try {
              final existingBloc = context.read<AuthBloc>();
              // Check if BLoC is not closed
              if (!existingBloc.isClosed) {
                Logger.info('✅ Reusing existing AuthBloc for register');
                return RegisterView(onboardingData: onboardingData);
              }
            } catch (e) {
              Logger.info('ℹ️ No existing AuthBloc found, creating new one');
            }

            // If no existing BLoC or it's closed, create a new one
            return BlocProvider<AuthBloc>(
              create: (_) => di.sl<AuthBloc>(),
              child: RegisterView(onboardingData: onboardingData),
            );
          },
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

        Logger.info('🏠 Creating home route with enhanced dashboard');

        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(
              create: (_) => di.sl<HomeBloc>(), // ✅ CRITICAL FIX: Don't add events immediately
              lazy: false,
            ),
            BlocProvider<EmotionBloc>(
              create: (_) => di.sl<EmotionBloc>(),
              lazy: false,
            ),
            BlocProvider<ProfileBloc>(
              create: (_) => di.sl<ProfileBloc>(),
              lazy: true,
            ),
          ],
          child: Builder(
            builder: (context) {
              // ✅ CRITICAL FIX: Add the event after the BLoC is properly initialized
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<HomeBloc>().add(const LoadHomeData());
                }
              });
              return EnhancedHomeWrapper(userData: arguments);
            },
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

  static Route<dynamic> _createFriendsRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const FriendsView(),
    );
  }

  static Route<dynamic> _createInsightsRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const InsightsView(),
    );
  }

  static Route<dynamic> _createProfileTabRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) => const ProfileView(),
    );
  }

  static Route<dynamic> _createFullProfileRoute(RouteSettings settings) {
    return _createSlideRoute(
      settings: settings,
      builder: (context) {
        final featureFlags = di.getFeatureFlags();

        if (!featureFlags.isProfileEnabled) {
          Logger.warning('⚠️ Profile feature is disabled');
          return const ProfileDisabledView();
        }

        return BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>(),
          child: const FullProfileView(),
        );
      },
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

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

  // ============================================================================
  // ROUTE TRANSITION BUILDERS
  // ============================================================================

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

  // ============================================================================
  // ERROR ROUTE BUILDERS
  // ============================================================================

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

  // ============================================================================
  // NAVIGATION UTILITY METHODS
  // ============================================================================

  static bool canNavigateToRoute(String routeName, BuildContext? context) {
    switch (routeName) {
      case home:
      case dashboard:
      case moodMap:
      case insights:
      case friends:
      case profile:
      case profileFull:
      case settings:
        if (context != null) {
          try {
            final authBloc = context.read<AuthBloc>();
            return authBloc.state is AuthAuthenticated;
          } catch (e) {
            Logger.warning('⚠️ Could not check auth state: $e');
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
      await NavigationService.safeNavigate(routeName, arguments: arguments);
    } else {
      await NavigationService.safeNavigate(authChoice, clearStack: true);
    }
  }

  static Future<void> navigateToProfile(BuildContext context) async {
    final featureFlags = di.getFeatureFlags();

    if (!featureFlags.isProfileEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile feature is currently disabled'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await navigateToAuthenticatedRoute(profileFull, context);
  }
}

// ============================================================================
// ENHANCED HOME WRAPPER
// ============================================================================
class EnhancedHomeWrapper extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EnhancedHomeWrapper({super.key, this.userData});

  @override
  State<EnhancedHomeWrapper> createState() => _EnhancedHomeWrapperState();
}

class _EnhancedHomeWrapperState extends State<EnhancedHomeWrapper> {
  Timer? _loadingTimeoutTimer;
  bool _shouldShowDashboard = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.read<HomeBloc>().add(const LoadHomeData());
        } catch (e) {
          Logger.error('❌ Failed to trigger home data load: $e');
        }
      }
    });

    _loadingTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_shouldShowDashboard) {
        Logger.warning('⏰ Loading timeout reached - forcing dashboard display');
        setState(() {
          _shouldShowDashboard = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeError) {
            Logger.error('❌ Home error: ${state.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Connection issue: ${state.message}'),
                  backgroundColor: Colors.orange,
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeData());
                    },
                  ),
                ),
              );
            }
          } else if (state is HomeDashboardState) {
            _loadingTimeoutTimer?.cancel();
            if (!_shouldShowDashboard) {
              setState(() {
                _shouldShowDashboard = true;
              });
            }
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            Logger.info('🏠 Home state: ${state.runtimeType}');

            if (_shouldShowDashboard || state is HomeDashboardState) {
              return const Dashboard();
            } else if (state is HomeLoading || state is HomeInitial) {
              return _buildLoadingView();
            } else if (state is HomeError) {
              return const Dashboard();
            } else {
              return const Dashboard();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
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
                    Text('🏠', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
                ).createShader(bounds),
                child: const Text(
                  'Setting up your dashboard',
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
                'Almost ready! Just a moment while we prepare your personal space...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Logger.info('👆 User manually continued to dashboard');
                  setState(() {
                    _shouldShowDashboard = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Enter Dashboard →',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PROFILE VIEWS
// ============================================================================

class FullProfileView extends StatelessWidget {
  const FullProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => di.sl<ProfileBloc>(),
      child: const ProfileView(),
    );
  }
}

class ProfileDisabledView extends StatelessWidget {
  const ProfileDisabledView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090110),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFF8B5CF6)),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person_off, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profile Unavailable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Profile features are currently disabled.\nPlease check back later.',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PLACEHOLDER VIEWS
// ============================================================================

class MoodMapPlaceholderView extends StatelessWidget {
  const MoodMapPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090110),
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
            Text('Global Emotion Map', style: TextStyle(color: Colors.white, fontSize: 24)),
            Text('Explore emotions worldwide!', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR SCREENS
// ============================================================================

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
      backgroundColor: const Color(0xFF090110),
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
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(Icons.error_outline, size: 50, color: Colors.red),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Navigation Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                if (routeName != null) ...[
                  const SizedBox(height: 8),
                  Text('Route: $routeName', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => NavigationService.safeNavigate(AppRouter.splash, clearStack: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: const Color(0xFF090110),
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
                    onPressed: () => NavigationService.safeNavigate(
                      AppRouter.splash,
                      clearStack: true,
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