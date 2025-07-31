import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/services/username_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../injection_container.dart';

class CoreModule {
  static void _initializeApiServiceWithSavedToken(GetIt sl) {
    try {
      Logger.info('🔑 Initializing ApiService with saved auth token...');
      
      final sharedPreferences = sl<SharedPreferences>();
      final apiService = sl<ApiService>();
      
      final savedToken = sharedPreferences.getString(AppConfig.authTokenKey);
      
      if (savedToken != null && savedToken.isNotEmpty) {
        apiService.setAuthToken(savedToken);
        Logger.info('. Auth token loaded and set in ApiService on app startup');
      } else {
        Logger.info('ℹ️ No saved auth token found - user needs to log in');
      }
    } catch (e) {
      Logger.error('. Failed to initialize ApiService with saved token', e);
    }
  }
  static Future<void> init(GetIt sl) async {
    Logger.info('. Initializing core module...');

    try {
      await _initExternalDependencies(sl);
      _initCoreDependencies(sl);
      _initServices(sl);
      _initFeatureFlags(sl);

      Logger.info('. Core module initialized successfully');
    } catch (e) {
      Logger.error('. Core module initialization failed', e);
      rethrow;
    }
  }

  static Future<void> _initExternalDependencies(GetIt sl) async {
    Logger.info('📦 Initializing external dependencies...');

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
      Logger.info('. SharedPreferences registered successfully');

      sl.registerLazySingleton<InternetConnectionChecker>(
        () => InternetConnectionChecker.createInstance(
          checkTimeout: const Duration(seconds: 10),
          checkInterval: const Duration(seconds: 15),
        ),
      );
      Logger.info('. InternetConnectionChecker registered successfully');
    } catch (e) {
      Logger.error('. Failed to initialize external dependencies', e);
      rethrow;
    }
  }

  static void _initCoreDependencies(GetIt sl) {
    Logger.info('. Initializing core dependencies...');

    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
    );

    sl.registerLazySingleton<DioClient>(() => DioClient.create());

    sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

    sl.registerLazySingleton<ApiService>(() => ApiService(dio: sl<Dio>()));

    _initializeApiServiceWithSavedToken(sl);

    Logger.info('. Core dependencies registered successfully');
  }

  static void _initServices(GetIt sl) {
    Logger.info('🛠️ Initializing core services...');

    sl.registerLazySingleton<UsernameService>(() => UsernameService());

    Logger.info('. Core services registered successfully');
  }

  static void _initFeatureFlags(GetIt sl) {
    Logger.info('🚩 Initializing feature flags...');

    const isMoodFeatureAvailable =
false; 
const isEmotionFeatureAvailable = true; 
const isAutomatedUsernamesEnabled = true; 

    sl.registerLazySingleton<FeatureFlagService>(
      () => const FeatureFlagService(
        isMoodEnabled: isMoodFeatureAvailable,
        isAnalyticsEnabled: false,
        isSocialEnabled: false,
        isEmotionEnabled: isEmotionFeatureAvailable,
        isAutomatedUsernamesEnabled: isAutomatedUsernamesEnabled,
      ),
    );

    Logger.info(
      '. Feature flags initialized - Mood: $isMoodFeatureAvailable, Emotion: $isEmotionFeatureAvailable, Automated Usernames: $isAutomatedUsernamesEnabled',
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('. Verifying core module registrations...');

    final serviceChecks = <String, bool Function()>{
      'SharedPreferences': () => sl.isRegistered<SharedPreferences>(),
      'InternetConnectionChecker': () =>
          sl.isRegistered<InternetConnectionChecker>(),
      'NetworkInfo': () => sl.isRegistered<NetworkInfo>(),
      'DioClient': () => sl.isRegistered<DioClient>(),
      'Dio': () => sl.isRegistered<Dio>(),
      'ApiService': () => sl.isRegistered<ApiService>(),
      'UsernameService': () => sl.isRegistered<UsernameService>(),
      'FeatureFlagService': () => sl.isRegistered<FeatureFlagService>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('. Core: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('. Core: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '. Core Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Core',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }

  static Future<bool> testServices(GetIt sl) async {
    Logger.info('🧪 Testing core services...');

    try {
      final prefs = sl<SharedPreferences>();
      await prefs.setString('test_key', 'test_value');
      final testValue = prefs.getString('test_key');
      await prefs.remove('test_key');

      if (testValue != 'test_value') {
        throw Exception('SharedPreferences test failed');
      }

      final networkInfo = sl<NetworkInfo>();
      final isConnected = await networkInfo.isConnected;
      Logger.info(
        '🌐 Network status: ${isConnected ? 'Connected' : 'Disconnected'}',
      );

      final dioClient = sl<DioClient>();
      final clientInfo = dioClient.getClientInfo();
      Logger.info('📡 DioClient info: ${clientInfo['baseUrl']}');

      final apiService = sl<ApiService>();
      final cacheStats = apiService.getCacheStats();
      Logger.info(
        '📦 ApiService cache: ${cacheStats['cachedResponses']} items',
      );

      final usernameService = sl<UsernameService>();
      Logger.info('🔄 Testing automated username generation...');

      final testSuggestions = await usernameService.generateCreativeUsernames(
        count: 5,
      );
      Logger.info(
        '💡 Automated username test: ${testSuggestions.length} generated',
      );
      Logger.info(
        '🎯 Sample suggestions: ${testSuggestions.take(3).join(', ')}',
      );

      final wordStats = UsernameService.getWordStats();
      Logger.info('. Word automation: ${wordStats['automation_status']}');

      final featureFlags = sl<FeatureFlagService>();
      Logger.info('🚩 Feature flags: ${featureFlags.enabledFeatures}');

      Logger.info('. All core services tested successfully');
      return true;
    } catch (e) {
      Logger.error('. Core services test failed', e);
      return false;
    }
  }

  static Map<String, dynamic> getHealthStatus(GetIt sl) {
    final health = <String, dynamic>{
      'module': 'Core',
      'timestamp': DateTime.now().toIso8601String(),
      'services': <String, dynamic>{},
      'overall_status': 'unknown',
    };

    try {
      final services = [
        'SharedPreferences',
        'InternetConnectionChecker',
        'NetworkInfo',
        'DioClient',
        'Dio',
        'ApiService',
        'UsernameService',
        'FeatureFlagService',
      ];

      int healthyServices = 0;

      for (final service in services) {
        try {
          bool isHealthy = false;
          String status = 'unknown';
          Map<String, dynamic>? additionalInfo;

          switch (service) {
            case 'SharedPreferences':
              sl<SharedPreferences>();
              isHealthy = true;
              status = 'registered';
              break;
            case 'InternetConnectionChecker':
              sl<InternetConnectionChecker>();
              isHealthy = true;
              status = 'registered';
              break;
            case 'NetworkInfo':
              sl<NetworkInfo>();
              isHealthy = true;
              status = 'registered';
              break;
            case 'DioClient':
              final client = sl<DioClient>();
              isHealthy = client.dio.options.baseUrl.isNotEmpty;
              status = isHealthy ? 'healthy' : 'misconfigured';
              break;
            case 'Dio':
              sl<Dio>();
              isHealthy = true;
              status = 'registered';
              break;
            case 'ApiService':
              final apiService = sl<ApiService>();
              final stats = apiService.getCacheStats();
              isHealthy = stats.isNotEmpty;
              status = isHealthy ? 'healthy' : 'error';
              additionalInfo = stats;
              break;
            case 'UsernameService':
              sl<UsernameService>();
              final cacheStats = UsernameService.getCacheStats();
              final wordStats = UsernameService.getWordStats();
              isHealthy = true;
              status = cacheStats['automation_status'] == 'active'
                  ? 'automated'
                  : 'fallback';
              additionalInfo = {
                'cache_stats': cacheStats,
                'word_counts': {
                  'adjectives': wordStats['adjectives_count'],
                  'nouns': wordStats['nouns_count'],
                  'emotions': wordStats['emotions_count'],
                },
              };
              break;
            case 'FeatureFlagService':
              final flags = sl<FeatureFlagService>();
              isHealthy = flags.hasAnyFeatureEnabled;
              status = isHealthy ? 'healthy' : 'no_features_enabled';
              break;
          }

          health['services'][service] = {
            'healthy': isHealthy,
            'status': status,
            if (additionalInfo != null) 'details': additionalInfo,
          };

          if (isHealthy) healthyServices++;
        } catch (e) {
          health['services'][service] = {
            'healthy': false,
            'status': 'error',
            'error': e.toString(),
          };
        }
      }

      final healthPercentage = (healthyServices / services.length * 100)
          .round();
      if (healthPercentage == 100) {
        health['overall_status'] = 'healthy';
      } else if (healthPercentage >= 80) {
        health['overall_status'] = 'degraded';
      } else {
        health['overall_status'] = 'unhealthy';
      }

      health['healthy_services'] = healthyServices;
      health['total_services'] = services.length;
      health['health_percentage'] = healthPercentage;
    } catch (e) {
      health['overall_status'] = 'error';
      health['error'] = e.toString();
    }

    return health;
  }

  static Future<void> reset(GetIt sl) async {
    Logger.info('🔄 Resetting core module...');

    try {
      if (sl.isRegistered<ApiService>()) {
        sl<ApiService>().clearCache();
      }

      if (sl.isRegistered<DioClient>()) {
        sl<DioClient>().clearCache();
      }

      UsernameService.clearCache();
      await UsernameService.forceRefreshWords();

      Logger.info('. Core module reset completed');
    } catch (e) {
      Logger.warning('. Error during core module reset: $e');
    }
  }

  static Future<Map<String, dynamic>> getAutomationStatus(GetIt sl) async {
    try {
      final wordStats = UsernameService.getWordStats();
      final cacheStats = UsernameService.getCacheStats();

      return {
        'automation_active': cacheStats['automation_status'] == 'active',
        'word_sources': {
          'adjectives': wordStats['adjectives_count'],
          'nouns': wordStats['nouns_count'],
          'emotions': wordStats['emotions_count'],
        },
        'last_refresh': wordStats['last_refresh'],
        'cache_expires': wordStats['cache_expires'],
        'sample_words': {
          'adjectives': wordStats['sample_adjectives'],
          'nouns': wordStats['sample_nouns'],
          'emotions': wordStats['sample_emotions'],
        },
        'recommendations': _getAutomationRecommendations(cacheStats, wordStats),
      };
    } catch (e) {
      return {
        'automation_active': false,
        'error': e.toString(),
        'recommendations': ['Check network connection', 'Restart the service'],
      };
    }
  }

  static List<String> _getAutomationRecommendations(
    Map<String, dynamic> cacheStats,
    Map<String, dynamic> wordStats,
  ) {
    final recommendations = <String>[];

    if (cacheStats['automation_status'] != 'active') {
      recommendations.add('Enable network access for word automation');
    }

    if ((wordStats['adjectives_count'] as int) < 20) {
      recommendations.add('Refresh word database for better variety');
    }

    if (wordStats['last_refresh'] == null) {
      recommendations.add('Initialize word automation system');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Automation is working optimally');
    }

    return recommendations;
  }
}
