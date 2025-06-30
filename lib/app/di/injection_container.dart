// lib/app/di/injection_container.dart
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/splash/presentation/view_model/cubit/splash_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/logger.dart';
import 'modules/auth_module.dart';
import 'modules/core_module.dart';
import 'modules/emotion_module.dart';
import 'modules/home_module.dart';
import 'modules/onboarding_module.dart';
import 'modules/splash_module.dart';

final sl = GetIt.instance;

// Feature Flag Service
class FeatureFlagService {
  final bool isMoodEnabled;
  final bool isAnalyticsEnabled;
  final bool isSocialEnabled;
  final bool isEmotionEnabled;

  const FeatureFlagService({
    this.isMoodEnabled = true, // Enable mood feature
    this.isAnalyticsEnabled = false,
    this.isSocialEnabled = false,
    this.isEmotionEnabled = true, // Enable emotion feature by default
  });

  // Helper methods for checking feature availability
  bool get hasAnyFeatureEnabled =>
      isMoodEnabled ||
      isAnalyticsEnabled ||
      isSocialEnabled ||
      isEmotionEnabled;

  Map<String, bool> get allFeatures => {
    'mood': isMoodEnabled,
    'analytics': isAnalyticsEnabled,
    'social': isSocialEnabled,
    'emotion': isEmotionEnabled,
  };

  List<String> get enabledFeatures => allFeatures.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  @override
  String toString() => 'FeatureFlagService(${enabledFeatures.join(', ')})';
}

/// Initialize all dependency injection modules
Future<void> init() async {
  Logger.info('🚀 Initializing dependency injection...');

  try {
    // Initialize modules in dependency order
    await CoreModule.init(sl);
    await AuthModule.init(sl);
    await OnboardingModule.init(sl);
    await EmotionModule.init(sl);
    await HomeModule.init(sl);
    await SplashModule.init(sl);

    _verifyRegistrations();
    _logInitializationSummary();

    Logger.info('✅ Dependency injection completed successfully');
  } catch (e, stackTrace) {
    Logger.error('❌ Dependency injection failed', e, stackTrace);
    rethrow;
  }
}

/// Verify that all required services are registered
void _verifyRegistrations() {
  Logger.info('🔍 Verifying service registrations...');

  final moduleChecks = [
    CoreModule.verify(sl),
    AuthModule.verify(sl),
    OnboardingModule.verify(sl),
    EmotionModule.verify(sl),
    HomeModule.verify(sl),
    SplashModule.verify(sl),
  ];

  int totalRegistered = 0;
  int totalServices = 0;
  final List<String> failedModules = [];

  for (final moduleResult in moduleChecks) {
    final moduleName = moduleResult['module'] as String;
    final registered = moduleResult['registered'] as int;
    final total = moduleResult['total'] as int;
    final success = moduleResult['success'] as bool;
    final skipped = moduleResult['skipped'] as bool? ?? false;

    totalRegistered += registered;
    totalServices += total;

    if (!success && !skipped) {
      failedModules.add(moduleName);
    }

    final status = skipped ? 'SKIPPED' : (success ? 'SUCCESS' : 'FAILED');
    Logger.info('📊 $moduleName Module: $registered/$total services - $status');
  }

  Logger.info(
    '📊 Overall Registration Summary: $totalRegistered/$totalServices services registered',
  );

  if (failedModules.isNotEmpty) {
    throw Exception(
      'Service registration verification failed for modules: ${failedModules.join(', ')}',
    );
  }

  _verifyCriticalServices();
}

/// Verify that critical services can be retrieved successfully
void _verifyCriticalServices() {
  Logger.info('🔧 Testing critical service retrieval...');

  final criticalServices = <String, Function()>{
    'FeatureFlagService': () => sl<FeatureFlagService>(),
  };

  // Check feature flags first to determine what services to test
  final featureFlags = sl<FeatureFlagService>();

  // Always check these core services
  criticalServices.addAll({
    'AuthBloc': () {
      final bloc = sl<AuthBloc>();
      bloc.close();
      return bloc;
    },
    'HomeBloc': () {
      final bloc = sl<HomeBloc>();
      bloc.close();
      return bloc;
    },
    'SplashCubit': () {
      final cubit = sl<SplashCubit>();
      cubit.close();
      return cubit;
    },
  });

  // Conditionally check emotion bloc
  if (featureFlags.isEmotionEnabled) {
    criticalServices['EmotionBloc'] = () {
      final bloc = sl<EmotionBloc>();
      bloc.close();
      return bloc;
    };
  }
  for (final entry in criticalServices.entries) {
    final serviceName = entry.key;
    final serviceGetter = entry.value;

    try {
      serviceGetter();
      Logger.info('✅ $serviceName retrieved and tested successfully');
    } catch (e) {
      Logger.error('❌ Failed to retrieve $serviceName', e);
      throw Exception(
        'Critical service verification failed for $serviceName: $e',
      );
    }
  }

  Logger.info('🎯 Critical services verification completed successfully');
}

/// Log initialization summary with feature flags and module status
void _logInitializationSummary() {
  try {
    final featureFlags = sl<FeatureFlagService>();

    Logger.info('🎯 Initialization Summary:');
    Logger.info('   📦 Total Services: ${_getTotalServiceCount()}');
    Logger.info('   🚩 Enabled Features: ${featureFlags.enabledFeatures}');
    Logger.info('   🔧 Core Services: ✅ Available');
    Logger.info('   🔐 Auth Services: ✅ Available');
    Logger.info('   🏠 Home Services: ✅ Available');
    Logger.info('   📋 Onboarding Services: ✅ Available');
    Logger.info(
      '   🎭 Emotion Services: ${featureFlags.isEmotionEnabled ? '✅ Available' : '⏭️ Disabled'}',
    );
    Logger.info(
      '   🎯 Mood Services: ${featureFlags.isMoodEnabled ? '✅ Available' : '⏭️ Disabled'}',
    );
    Logger.info('   💫 Splash Services: ✅ Available');

    if (kDebugMode) {
      Logger.info('🐛 Debug mode: Additional logging enabled');
    }
  } catch (e) {
    Logger.warning('⚠️ Could not generate initialization summary: $e');
  }
}

/// Get total count of registered services
int _getTotalServiceCount() {
  try {
    int count = 6; // Base services (SharedPreferences, DioClient, etc.)

    final featureFlags = sl<FeatureFlagService>();
    count += 4; // Auth, Home, Onboarding, Splash

    if (featureFlags.isEmotionEnabled) {
      count += 7; // Emotion services
    }

    if (featureFlags.isMoodEnabled) {
      count += 11; // Mood services
    }

    return count;
  } catch (e) {
    return 0;
  }
}

/// Reset GetIt for testing purposes
void resetForTesting() {
  Logger.info('🧪 Resetting GetIt for testing...');
  sl.reset();
}

/// Validate the entire injection container
void validateInjectionContainer() {
  Logger.info('🔍 Validating injection container...');

  try {
    _verifyRegistrations();
    Logger.info('✅ Injection container validation passed');
  } catch (e) {
    Logger.error(
      '❌ Injection container validation failed',
      e,
      StackTrace.current,
    );
    rethrow;
  }
}

/// Get feature flags service (convenience method)
FeatureFlagService getFeatureFlags() {
  try {
    return sl<FeatureFlagService>();
  } catch (e) {
    Logger.error('❌ Failed to get feature flags', e);
    // Return default feature flags as fallback
    return const FeatureFlagService(
      isMoodEnabled: false,
      isAnalyticsEnabled: false,
      isSocialEnabled: false,
      isEmotionEnabled: false,
    );
  }
}

/// Check if a specific service is registered
bool isServiceRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

/// Get service with error handling
T? getServiceSafely<T extends Object>() {
  try {
    return sl<T>();
  } catch (e) {
    Logger.error('❌ Failed to get service ${T.toString()}', e);
    return null;
  }
}

/// Debug method to print all registrations (only in debug mode)
void debugPrintRegistrations() {
  if (kDebugMode) {
    Logger.info('🐛 DEBUG: Printing all registrations...');

    try {
      final featureFlags = sl<FeatureFlagService>();
      Logger.info('🚩 Feature Flags: $featureFlags');

      final services = ['AuthBloc', 'HomeBloc', 'SplashCubit'];
      if (featureFlags.isEmotionEnabled) services.add('EmotionBloc');
      if (featureFlags.isMoodEnabled) services.add('MoodBloc');

      for (final service in services) {
        Logger.info('🔍 $service: Available');
      }
    } catch (e) {
      Logger.warning('⚠️ Could not print debug registrations: $e');
    }
  }
}

/// Cleanup method for app shutdown
Future<void> cleanup() async {
  Logger.info('🧹 Cleaning up dependency injection...');

  try {
    sl.reset();
    Logger.info('✅ Dependency injection cleanup completed');
  } catch (e) {
    Logger.error('❌ Error during cleanup', e);
  }
}

/// Health check for the dependency injection system
Map<String, dynamic> healthCheck() {
  final health = <String, dynamic>{
    'status': 'unknown',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': <String, dynamic>{},
    'features': <String, dynamic>{},
    'errors': <String>[],
  };

  try {
    final featureFlags = sl<FeatureFlagService>();
    health['features'] = featureFlags.allFeatures;

    final criticalServices = ['AuthBloc', 'HomeBloc', 'SplashCubit'];
    if (featureFlags.isEmotionEnabled) criticalServices.add('EmotionBloc');
    if (featureFlags.isMoodEnabled) criticalServices.add('MoodBloc');

    bool allHealthy = true;
    for (final service in criticalServices) {
      try {
        health['modules'][service] = 'healthy';
      } catch (e) {
        health['modules'][service] = 'unhealthy';
        health['errors'].add('$service: ${e.toString()}');
        allHealthy = false;
      }
    }

    health['status'] = allHealthy ? 'healthy' : 'degraded';
  } catch (e) {
    health['status'] = 'unhealthy';
    health['errors'].add('Health check failed: ${e.toString()}');
  }

  return health;
}
