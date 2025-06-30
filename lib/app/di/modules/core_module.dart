import 'package:dio/dio.dart';
import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../injection_container.dart';

class CoreModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('🔧 Initializing core module...');

    try {
      await _initExternalDependencies(sl);
      _initCoreDependencies(sl);
      _initFeatureFlags(sl);

      Logger.info('✅ Core module initialized successfully');
    } catch (e) {
      Logger.error('❌ Core module initialization failed', e);
      rethrow;
    }
  }

  static Future<void> _initExternalDependencies(GetIt sl) async {
    Logger.info('📦 Initializing external dependencies...');

    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
      Logger.info('✅ SharedPreferences registered successfully');
    } catch (e) {
      Logger.error('❌ Failed to initialize SharedPreferences', e);
      rethrow;
    }

    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker.createInstance(
        checkTimeout: const Duration(seconds: 10),
        checkInterval: const Duration(seconds: 15),
      ),
    );

    // Register DioClient instead of Dio directly
    sl.registerLazySingleton<DioClient>(() => DioClient.create());

    // Keep Dio registration for backward compatibility if needed
    sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  }

  static void _initCoreDependencies(GetIt sl) {
    Logger.info('🔧 Initializing core dependencies...');

    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
    );
  }

  static void _initFeatureFlags(GetIt sl) {
    Logger.info('🚩 Initializing feature flags...');

    const isMoodFeatureAvailable =
        false; // Set to true when mood feature is ready
    const isEmotionFeatureAvailable = true; // Emotion feature is available

    sl.registerLazySingleton<FeatureFlagService>(
      () => const FeatureFlagService(
        isMoodEnabled: isMoodFeatureAvailable,
        isAnalyticsEnabled: false,
        isSocialEnabled: false,
        isEmotionEnabled: isEmotionFeatureAvailable,
      ),
    );

    Logger.info(
      '✅ Feature flags initialized - Mood: $isMoodFeatureAvailable, Emotion: $isEmotionFeatureAvailable',
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying core module registrations...');

    final serviceChecks = <String, bool Function()>{
      'SharedPreferences': () => sl.isRegistered<SharedPreferences>(),
      'DioClient': () => sl.isRegistered<DioClient>(),
      'Dio': () => sl.isRegistered<Dio>(),
      'InternetConnectionChecker': () =>
          sl.isRegistered<InternetConnectionChecker>(),
      'NetworkInfo': () => sl.isRegistered<NetworkInfo>(),
      'FeatureFlagService': () => sl.isRegistered<FeatureFlagService>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Core: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Core: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Core Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Core',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
