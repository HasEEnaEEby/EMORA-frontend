import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/community_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/navigation/app_router.dart';
import '../core/navigation/navigation_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/logger.dart';
import '../features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'di/injection_container.dart' as di;

class EmoraApp extends StatelessWidget {
  const EmoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global AuthBloc provider
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckStatus()),
          lazy: false, // Initialize immediately
        ),

        // Global CommunityBloc provider
        BlocProvider<CommunityBloc>(
          create: (context) {
            final bloc = di.sl<CommunityBloc>();
            // Load initial community data
            bloc.add(const LoadGlobalFeedEvent());
            bloc.add(const LoadGlobalStatsEvent());
            return bloc;
          },
          lazy: false, // Initialize immediately
        ),

        // Add other global providers here as needed
      ],
      child: MaterialApp(
        title: 'Emora',
        debugShowCheckedModeBanner: false,

        // Theme configuration
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // Navigation configuration
        navigatorKey: NavigationService.navigatorKey,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRouter.splash,

        // Global builders and observers
        builder: (context, child) {
          return _AppWrapper(child: child);
        },

        // Navigation observer for analytics
        navigatorObservers: [_AppNavigatorObserver()],
      ),
    );
  }
}

/// Wrapper widget for global app configurations
class _AppWrapper extends StatelessWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // Ensure consistent text scaling
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// Custom navigator observer for debugging and analytics
class _AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    Logger.info(
      '🔄 Route pushed: ${route.settings.name} '
      '(from: ${previousRoute?.settings.name ?? 'none'})',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    Logger.info(
      '⬅️ Route popped: ${route.settings.name} '
      '(to: ${previousRoute?.settings.name ?? 'none'})',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    Logger.info(
      '🗑️ Route removed: ${route.settings.name} '
      '(previous: ${previousRoute?.settings.name ?? 'none'})',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Logger.info(
      '🔄 Route replaced: ${oldRoute?.settings.name} '
      '-> ${newRoute?.settings.name}',
    );
  }
}
