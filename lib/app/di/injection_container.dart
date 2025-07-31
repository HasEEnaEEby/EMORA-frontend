import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/splash/presentation/view_model/cubit/splash_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../core/utils/logger.dart';
import 'modules/auth_module.dart';
import 'modules/core_module.dart';
import 'modules/emotion_module.dart';
import 'modules/home_module.dart';
import 'modules/onboarding_module.dart';
import 'modules/profile_module.dart';
import 'modules/splash_module.dart';

final sl = GetIt.instance;

class FeatureFlagService {
  final bool isMoodEnabled;
  final bool isAnalyticsEnabled;
  final bool isSocialEnabled;
  final bool isEmotionEnabled;
final bool isProfileEnabled; 
final bool isAutomatedUsernamesEnabled; 

  const FeatureFlagService({
this.isMoodEnabled = true, 
    this.isAnalyticsEnabled = false,
    this.isSocialEnabled = false,
this.isEmotionEnabled = true, 
this.isProfileEnabled = true, 
    this.isAutomatedUsernamesEnabled =
true, 
  });

  bool get hasAnyFeatureEnabled =>
      isMoodEnabled ||
      isAnalyticsEnabled ||
      isSocialEnabled ||
      isEmotionEnabled ||
      isProfileEnabled ||
      isAutomatedUsernamesEnabled;

  Map<String, bool> get allFeatures => {
    'mood': isMoodEnabled,
    'analytics': isAnalyticsEnabled,
    'social': isSocialEnabled,
    'emotion': isEmotionEnabled,
    'profile': isProfileEnabled,
    'automated_usernames': isAutomatedUsernamesEnabled,
  };

  List<String> get enabledFeatures => allFeatures.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  @override
  String toString() => 'FeatureFlagService(${enabledFeatures.join(', ')})';
}

Future<void> init() async {
  Logger.info('🚀 Initializing dependency injection...');

  try {
    await CoreModule.init(sl);
    await AuthModule.init(sl);
    await OnboardingModule.init(sl);
    await EmotionModule.init(sl);
await ProfileModule.init(sl); 
    await HomeModule.init(sl);
    await SplashModule.init(sl);

    _verifyRegistrations();
    _logInitializationSummary();

    Logger.info('. Dependency injection completed successfully');
  } catch (e, stackTrace) {
    Logger.error('. Dependency injection failed', e, stackTrace);
    rethrow;
  }
}

void _verifyRegistrations() {
  Logger.info('. Verifying service registrations...');

  final moduleChecks = [
    CoreModule.verify(sl),
    AuthModule.verify(sl),
    OnboardingModule.verify(sl),
    EmotionModule.verify(sl),
ProfileModule.verify(sl), 
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
    Logger.info('. $moduleName Module: $registered/$total services - $status');
  }

  Logger.info(
    '. Overall Registration Summary: $totalRegistered/$totalServices services registered',
  );

  if (failedModules.isNotEmpty) {
    throw Exception(
      'Service registration verification failed for modules: ${failedModules.join(', ')}',
    );
  }

  _verifyCriticalServices();
}

void _verifyCriticalServices() {
  Logger.info('. Testing critical service registrations...');

  final featureFlags = sl<FeatureFlagService>();
  Logger.info('. FeatureFlagService retrieved and tested successfully');

  final List<String> criticalServices = ['AuthBloc', 'HomeBloc', 'SplashCubit'];

  if (featureFlags.isEmotionEnabled) {
    criticalServices.add('EmotionBloc');
  }

  if (featureFlags.isProfileEnabled) {
criticalServices.add('ProfileBloc'); 
  }

  for (final serviceName in criticalServices) {
    try {
      bool isRegistered = false;

      switch (serviceName) {
        case 'AuthBloc':
          isRegistered = sl.isRegistered<AuthBloc>();
          break;
        case 'HomeBloc':
          isRegistered = sl.isRegistered<HomeBloc>();
          break;
        case 'SplashCubit':
          isRegistered = sl.isRegistered<SplashCubit>();
          break;
        case 'EmotionBloc':
          isRegistered = sl.isRegistered<EmotionBloc>();
          break;
case 'ProfileBloc': 
          isRegistered = sl.isRegistered<ProfileBloc>();
          break;
      }

      if (isRegistered) {
        Logger.info('. $serviceName is registered and available');
      } else {
        throw Exception('$serviceName is not registered');
      }
    } catch (e) {
      Logger.error('. Failed to verify $serviceName registration', e);
      throw Exception(
        'Critical service verification failed for $serviceName: $e',
      );
    }
  }

  Logger.info('🎯 Critical services verification completed successfully');
}

void _logInitializationSummary() {
  try {
    final featureFlags = sl<FeatureFlagService>();

    Logger.info('🎯 Initialization Summary:');
    Logger.info('   📦 Total Services: ${_getTotalServiceCount()}');
    Logger.info('   🚩 Enabled Features: ${featureFlags.enabledFeatures}');
    Logger.info('   . Core Services: . Available');
    Logger.info('   🔐 Auth Services: . Available');
    Logger.info('   🏠 Home Services: . Available');
    Logger.info('   . Onboarding Services: . Available');
    Logger.info(
      '   🎭 Emotion Services: ${featureFlags.isEmotionEnabled ? '. Available' : '⏭️ Disabled'}',
    );
    Logger.info(
'   . Profile Services: ${featureFlags.isProfileEnabled ? '. Available' : '⏭️ Disabled'}', 
    );
    Logger.info(
      '   🎯 Mood Services: ${featureFlags.isMoodEnabled ? '. Available' : '⏭️ Disabled'}',
    );
    Logger.info(
      '   🤖 Automated Usernames: ${featureFlags.isAutomatedUsernamesEnabled ? '. Available' : '⏭️ Disabled'}',
    );
    Logger.info('   💫 Splash Services: . Available');

    if (kDebugMode) {
      Logger.info('🐛 Debug mode: Additional logging enabled');
    }
  } catch (e) {
    Logger.warning('. Could not generate initialization summary: $e');
  }
}

int _getTotalServiceCount() {
  try {
int count = 6; 

    final featureFlags = sl<FeatureFlagService>();
count += 4; 

    if (featureFlags.isEmotionEnabled) {
count += 7; 
    }

    if (featureFlags.isProfileEnabled) {
count += 9; 
    }

    if (featureFlags.isMoodEnabled) {
count += 11; 
    }

    if (featureFlags.isAutomatedUsernamesEnabled) {
count += 1; 
    }

    return count;
  } catch (e) {
    return 0;
  }
}

void resetForTesting() {
  Logger.info('🧪 Resetting GetIt for testing...');

  try {
    _closeExistingBlocs();
    sl.reset();
    Logger.info('. GetIt reset completed for testing');
  } catch (e) {
    Logger.error('. Error during testing reset', e);
    sl.reset();
  }
}

void validateInjectionContainer() {
  Logger.info('. Validating injection container...');

  try {
    _verifyRegistrations();
    Logger.info('. Injection container validation passed');
  } catch (e) {
    Logger.error(
      '. Injection container validation failed',
      e,
      StackTrace.current,
    );
    rethrow;
  }
}

FeatureFlagService getFeatureFlags() {
  try {
    return sl<FeatureFlagService>();
  } catch (e) {
    Logger.error('. Failed to get feature flags', e);
    return const FeatureFlagService(
      isMoodEnabled: false,
      isAnalyticsEnabled: false,
      isSocialEnabled: false,
      isEmotionEnabled: false,
isProfileEnabled: false, 
      isAutomatedUsernamesEnabled: false,
    );
  }
}

bool isServiceRegistered<T extends Object>() {
  return sl.isRegistered<T>();
}

T? getServiceSafely<T extends Object>() {
  try {
    return sl<T>();
  } catch (e) {
    Logger.error('. Failed to get service ${T.toString()}', e);
    return null;
  }
}

T getBlocSafely<T extends Object>() {
  try {
    final bloc = sl<T>();

    if (bloc is AuthBloc && bloc.isClosed) {
      throw Exception('AuthBloc is already closed');
    }
    if (bloc is EmotionBloc && bloc.isClosed) {
      throw Exception('EmotionBloc is already closed');
    }
    if (bloc is ProfileBloc && bloc.isClosed) {
      throw Exception('ProfileBloc is already closed');
    }
    if (bloc is SplashCubit && bloc.isClosed) {
      throw Exception('SplashCubit is already closed');
    }

    return bloc;
  } catch (e) {
    Logger.error('. Failed to get bloc ${T.toString()} safely', e);
    rethrow;
  }
}

void _closeExistingBlocs() {
  Logger.info('🧹 Closing existing bloc instances...');

  final blocsToClose = <String, Function()>{
    'AuthBloc': () {
      if (sl.isRegistered<AuthBloc>()) {
        try {
          final bloc = sl<AuthBloc>();
          if (!bloc.isClosed) {
            bloc.close();
            Logger.info('. AuthBloc closed successfully');
          } else {
            Logger.info('ℹ️ AuthBloc was already closed');
          }
        } catch (e) {
          Logger.warning('. Error closing AuthBloc: $e');
        }
      }
    },
    'EmotionBloc': () {
      if (sl.isRegistered<EmotionBloc>()) {
        try {
          final bloc = sl<EmotionBloc>();
          if (!bloc.isClosed) {
            bloc.close();
            Logger.info('. EmotionBloc closed successfully');
          } else {
            Logger.info('ℹ️ EmotionBloc was already closed');
          }
        } catch (e) {
          Logger.warning('. Error closing EmotionBloc: $e');
        }
      }
    },
    'ProfileBloc': () {
      if (sl.isRegistered<ProfileBloc>()) {
        try {
          final bloc = sl<ProfileBloc>();
          if (!bloc.isClosed) {
            bloc.close();
            Logger.info('. ProfileBloc closed successfully');
          } else {
            Logger.info('ℹ️ ProfileBloc was already closed');
          }
        } catch (e) {
          Logger.warning('. Error closing ProfileBloc: $e');
        }
      }
    },
    'SplashCubit': () {
      if (sl.isRegistered<SplashCubit>()) {
        try {
          final cubit = sl<SplashCubit>();
          if (!cubit.isClosed) {
            cubit.close();
            Logger.info('. SplashCubit closed successfully');
          } else {
            Logger.info('ℹ️ SplashCubit was already closed');
          }
        } catch (e) {
          Logger.warning('. Error closing SplashCubit: $e');
        }
      }
    },
  };

  for (final entry in blocsToClose.entries) {
    try {
      entry.value();
    } catch (e) {
      Logger.warning('. Error in ${entry.key} cleanup: $e');
    }
  }
}

void debugPrintRegistrations() {
  if (kDebugMode) {
    Logger.info('🐛 DEBUG: Printing all registrations...');

    try {
      final featureFlags = sl<FeatureFlagService>();
      Logger.info('🚩 Feature Flags: $featureFlags');

      final services = <String, Type>{
        'AuthBloc': AuthBloc,
'HomeBloc': HomeBloc, 
        'SplashCubit': SplashCubit,
      };

      if (featureFlags.isEmotionEnabled) {
        services['EmotionBloc'] = EmotionBloc;
      }

      if (featureFlags.isProfileEnabled) {
        services['ProfileBloc'] = ProfileBloc;
      }

      if (featureFlags.isMoodEnabled) {
        services['MoodBloc'] =
Object; 
      }

      for (final entry in services.entries) {
        final serviceName = entry.key;
        final serviceType = entry.value;

        try {
          final isRegistered = sl.isRegistered(instance: serviceType);
          Logger.info(
            '. $serviceName: ${isRegistered ? 'Registered' : 'Not Registered'}',
          );
        } catch (e) {
          Logger.info('. $serviceName: Error checking registration - $e');
        }
      }
    } catch (e) {
      Logger.warning('. Could not print debug registrations: $e');
    }
  }
}

Future<void> cleanup() async {
  Logger.info('🧹 Cleaning up dependency injection...');

  try {
    _closeExistingBlocs();

    await Future.delayed(const Duration(milliseconds: 100));

    sl.reset();

    Logger.info('. Dependency injection cleanup completed');
  } catch (e) {
    Logger.error('. Error during cleanup', e);
    try {
      sl.reset();
      Logger.info('. Forced cleanup completed');
    } catch (resetError) {
      Logger.error('. Failed to force reset GetIt', resetError);
    }
  }
}

Map<String, dynamic> healthCheck() {
  final health = <String, dynamic>{
    'status': 'unknown',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': <String, dynamic>{},
    'features': <String, dynamic>{},
    'errors': <String>[],
    'summary': <String, dynamic>{},
  };

  try {
    final featureFlags = sl<FeatureFlagService>();
    health['features'] = featureFlags.allFeatures;

    final Map<String, Type> servicesToCheck = {
      'AuthBloc': AuthBloc,
'HomeBloc': HomeBloc, 
      'SplashCubit': SplashCubit,
    };

    if (featureFlags.isEmotionEnabled) {
      servicesToCheck['EmotionBloc'] = EmotionBloc;
    }

    if (featureFlags.isProfileEnabled) {
      servicesToCheck['ProfileBloc'] = ProfileBloc;
    }

    if (featureFlags.isMoodEnabled) {
    }

    bool allHealthy = true;
    int healthyCount = 0;
    int totalCount = servicesToCheck.length;

    for (final entry in servicesToCheck.entries) {
      final serviceName = entry.key;
      final serviceType = entry.value;

      try {
        if (sl.isRegistered(instance: serviceType)) {
          health['modules'][serviceName] = 'registered';
          healthyCount++;
        } else {
          health['modules'][serviceName] = 'not_registered';
          health['errors'].add('$serviceName is not registered');
          allHealthy = false;
        }
      } catch (e) {
        health['modules'][serviceName] = 'error';
        health['errors'].add('$serviceName: ${e.toString()}');
        allHealthy = false;
      }
    }

    if (allHealthy) {
      health['status'] = 'healthy';
    } else if (healthyCount > 0) {
      health['status'] = 'degraded';
    } else {
      health['status'] = 'unhealthy';
    }

    health['summary'] = {
      'healthy_services': healthyCount,
      'total_services': totalCount,
      'health_percentage': totalCount > 0
          ? (healthyCount / totalCount * 100).round()
          : 0,
      'enabled_features': featureFlags.enabledFeatures.length,
      'total_features': featureFlags.allFeatures.length,
      'automated_usernames_enabled': featureFlags.isAutomatedUsernamesEnabled,
      'profile_enabled':
featureFlags.isProfileEnabled, 
    };
  } catch (e) {
    health['status'] = 'unhealthy';
    health['errors'].add('Health check failed: ${e.toString()}');
    Logger.error('. Health check failed', e);
  }

  return health;
}

Map<String, dynamic> getServiceDetails() {
  final details = <String, dynamic>{
    'timestamp': DateTime.now().toIso8601String(),
    'registered_services': <String, dynamic>{},
    'feature_flags': <String, dynamic>{},
    'statistics': <String, dynamic>{},
    'automation_status': <String, dynamic>{},
  };

  try {
    final featureFlags = sl<FeatureFlagService>();
    details['feature_flags'] = {
      'enabled_features': featureFlags.enabledFeatures,
      'all_features': featureFlags.allFeatures,
      'has_any_enabled': featureFlags.hasAnyFeatureEnabled,
      'automated_usernames_enabled': featureFlags.isAutomatedUsernamesEnabled,
      'profile_enabled':
featureFlags.isProfileEnabled, 
    };

    if (featureFlags.isAutomatedUsernamesEnabled) {
      try {
        details['automation_status'] = CoreModule.getAutomationStatus(sl);
      } catch (e) {
        details['automation_status'] = {
          'error': 'Failed to get automation status: ${e.toString()}',
        };
      }
    }

    final serviceTypes = <String, Type>{
      'AuthBloc': AuthBloc,
      'HomeBloc': HomeBloc,
      'SplashCubit': SplashCubit,
      'EmotionBloc': EmotionBloc,
'ProfileBloc': ProfileBloc, 
      'FeatureFlagService': FeatureFlagService,
    };

    int registeredCount = 0;
    for (final entry in serviceTypes.entries) {
      final serviceName = entry.key;
      final serviceType = entry.value;

      try {
        final isRegistered = sl.isRegistered(instance: serviceType);
        details['registered_services'][serviceName] = {
          'registered': isRegistered,
          'type': serviceType.toString(),
        };

        if (isRegistered) registeredCount++;
      } catch (e) {
        details['registered_services'][serviceName] = {
          'registered': false,
          'error': e.toString(),
        };
      }
    }

    details['statistics'] = {
      'total_checked': serviceTypes.length,
      'registered_count': registeredCount,
      'registration_rate': serviceTypes.isNotEmpty
          ? (registeredCount / serviceTypes.length * 100).round()
          : 0,
      'expected_services': _getTotalServiceCount(),
    };
  } catch (e) {
    details['error'] = e.toString();
    Logger.error('. Failed to get service details', e);
  }

  return details;
}

Future<bool> reinitializeService<T extends Object>() async {
  try {
    Logger.info('🔄 Attempting to reinitialize ${T.toString()}...');

    if (sl.isRegistered<T>()) {
      sl.unregister<T>();
    }

    Logger.info('. Service reinitialization requires module-specific logic');
    return false;
  } catch (e) {
    Logger.error('. Failed to reinitialize ${T.toString()}', e);
    return false;
  }
}

Future<Map<String, dynamic>> getUsernameAutomationInsights() async {
  try {
    final featureFlags = getFeatureFlags();

    if (!featureFlags.isAutomatedUsernamesEnabled) {
      return {
        'enabled': false,
        'message': 'Automated usernames feature is disabled',
      };
    }

    final automationStatus = await CoreModule.getAutomationStatus(sl);
    return {
      'enabled': true,
      'automation_details': automationStatus,
      'recommendations': automationStatus['recommendations'] ?? [],
    };
  } catch (e) {
    return {
      'enabled': false,
      'error': e.toString(),
      'message': 'Failed to get automation insights',
    };
  }
}

Future<Map<String, dynamic>> getProfileInsights() async {
  try {
    final featureFlags = getFeatureFlags();

    if (!featureFlags.isProfileEnabled) {
      return {'enabled': false, 'message': 'Profile feature is disabled'};
    }

    final healthStatus = ProfileModule.getHealthStatus(sl);
    return {
      'enabled': true,
      'health_status': healthStatus,
      'module_info': ProfileModule.getModuleInfo(),
    };
  } catch (e) {
    return {
      'enabled': false,
      'error': e.toString(),
      'message': 'Failed to get profile insights',
    };
  }
}
