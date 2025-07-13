// lib/app/di/modules/profile_module.dart
import 'package:emora_mobile_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/get_current_user.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_service.dart';
import '../../../core/network/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../../features/profile/data/datasource/profile_local_datasource.dart';
import '../../../features/profile/data/datasource/profile_remote_datasource.dart';
import '../../../features/profile/data/repository/profile_repository_impl.dart';
import '../../../features/profile/domain/repository/profile_repository.dart';
import '../../../features/profile/domain/usecase/export_user_data.dart';
import '../../../features/profile/domain/usecase/get_achievements.dart';
import '../../../features/profile/domain/usecase/get_user_preferences.dart';
import '../../../features/profile/domain/usecase/get_user_profile.dart';
import '../../../features/profile/domain/usecase/update_user_preferences.dart';
import '../../../features/profile/domain/usecase/update_user_profile.dart';

class ProfileModule {
  /// Initialize Profile module dependencies
  static Future<void> init(GetIt sl) async {
    Logger.info('🔧 Initializing profile module...');

    try {
      // Data Sources
      _initDataSources(sl);

      // Repository
      _initRepository(sl);

      // Use Cases
      _initUseCases(sl);

      // BLoC
      _initBloc(sl);

      Logger.info('✅ Profile module initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('❌ Profile module initialization failed', e, stackTrace);
      rethrow;
    }
  }

  /// Initialize data sources
  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing profile data sources...');

    // Remote Data Source
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(apiService: sl<ApiService>()),
    );

    // Local Data Source
    sl.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );

    Logger.info('✅ Profile data sources registered successfully');
  }

  /// Initialize repository
  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing profile repository...');

    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
        localDataSource: sl<ProfileLocalDataSource>(),
        authLocalDataSource:
            sl<AuthLocalDataSource>(), // FIXED: Added missing auth data source
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    Logger.info('✅ Profile repository registered successfully');
  }

  /// Initialize use cases
  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing profile use cases...');

    // FIXED: Added proper named parameters for all use cases
    sl.registerLazySingleton(
      () => GetUserProfile(
        repository: sl<ProfileRepository>(),
        getCurrentUser: sl<GetCurrentUser>(),
      ),
    );

    sl.registerLazySingleton(
      () => UpdateUserProfile(repository: sl<ProfileRepository>()),
    );

    sl.registerLazySingleton(
      () => GetUserPreferences(repository: sl<ProfileRepository>()),
    );

    sl.registerLazySingleton(
      () => UpdateUserPreferences(repository: sl<ProfileRepository>()),
    );

    sl.registerLazySingleton(
      () => GetAchievements(repository: sl<ProfileRepository>()),
    );

    sl.registerLazySingleton(
      () => ExportUserData(repository: sl<ProfileRepository>()),
    );

    Logger.info('✅ Profile use cases registered successfully');
  }

  /// Initialize BLoC
  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing profile bloc...');

    sl.registerFactory(
      () => ProfileBloc(
        getUserProfile: sl<GetUserProfile>(),
        updateUserProfile: sl<UpdateUserProfile>(),
        getUserPreferences: sl<GetUserPreferences>(),
        updateUserPreferences: sl<UpdateUserPreferences>(),
        getAchievements: sl<GetAchievements>(),
        exportUserData: sl<ExportUserData>(),
        getCurrentUser: sl<GetCurrentUser>(),
      ),
    );

    Logger.info('✅ Profile bloc registered successfully');
  }

  /// Verify all profile dependencies are registered correctly
  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying profile module registrations...');

    final serviceChecks = [
      _checkService<ProfileRemoteDataSource>(sl, 'ProfileRemoteDataSource'),
      _checkService<ProfileLocalDataSource>(sl, 'ProfileLocalDataSource'),
      _checkService<ProfileRepository>(sl, 'ProfileRepository'),
      _checkService<GetUserProfile>(sl, 'GetUserProfile'),
      _checkService<UpdateUserProfile>(sl, 'UpdateUserProfile'),
      _checkService<GetUserPreferences>(sl, 'GetUserPreferences'),
      _checkService<UpdateUserPreferences>(sl, 'UpdateUserPreferences'),
      _checkService<GetAchievements>(sl, 'GetAchievements'),
      _checkService<ExportUserData>(sl, 'ExportUserData'),
      _checkService<GetCurrentUser>(sl, 'GetCurrentUser'),
      _checkService<ProfileBloc>(sl, 'ProfileBloc'),
    ];

    int registeredCount = 0;
    int totalCount = serviceChecks.length;
    final List<String> missingServices = [];
    final List<String> registeredServices = [];

    for (final check in serviceChecks) {
      if (check['isRegistered']) {
        Logger.info('✅ Profile: ${check['name']} is registered');
        registeredServices.add(check['name']);
        registeredCount++;
      } else {
        Logger.warning('❌ Profile: ${check['name']} is NOT registered');
        missingServices.add(check['name']);
      }
    }

    final isSuccess = registeredCount == totalCount;
    final result = {
      'module': 'Profile',
      'registered': registeredCount,
      'total': totalCount,
      'success': isSuccess,
      'skipped': false,
      'missing_services': missingServices,
      'registered_services': registeredServices,
    };

    Logger.info(
      '📊 Profile Module: $registeredCount/$totalCount services registered',
    );

    return result;
  }

  /// Helper method to check if a service is registered
  static Map<String, dynamic> _checkService<T extends Object>(
    GetIt sl,
    String name,
  ) {
    try {
      final isRegistered = sl.isRegistered<T>();
      return {'name': name, 'isRegistered': isRegistered};
    } catch (e) {
      Logger.error('🔍 Profile: Error checking $name registration', e);
      return {'name': name, 'isRegistered': false};
    }
  }

  /// Get profile module specific information
  static Map<String, dynamic> getModuleInfo() {
    return {
      'name': 'Profile',
      'version': '1.0.0',
      'description':
          'User profile management with achievements and data export',
      'features': [
        'Profile management',
        'Achievement tracking',
        'User preferences',
        'Data export (GDPR compliant)',
        'Offline support',
        'Real user data integration',
      ],
      'dependencies': [
        'ApiService',
        'SharedPreferences',
        'NetworkInfo',
        'GetCurrentUser',
        'AuthLocalDataSource',
      ],
      'endpoints': [
        'GET /user/profile',
        'PUT /user/profile',
        'GET /user/preferences',
        'PUT /user/preferences',
        'GET /user/achievements',
        'POST /user/export-data',
      ],
    };
  }

  /// Test profile module registration
  static Future<bool> testRegistration(GetIt sl) async {
    try {
      Logger.info('🧪 Testing profile module registration...');

      // Test that we can retrieve all services without using them
      sl<ProfileRemoteDataSource>();
      sl<ProfileLocalDataSource>();
      sl<ProfileRepository>();
      sl<GetUserProfile>();
      sl<UpdateUserProfile>();
      sl<GetUserPreferences>();
      sl<UpdateUserPreferences>();
      sl<GetAchievements>();
      sl<ExportUserData>();
      sl<GetCurrentUser>();

      // Test ProfileBloc creation (but don't keep the instance)
      final profileBloc = sl<ProfileBloc>();

      // Clean up the test bloc
      if (!profileBloc.isClosed) {
        await profileBloc.close();
      }

      Logger.info('✅ Profile module registration test passed');
      return true;
    } catch (e) {
      Logger.error('❌ Profile module registration test failed', e);
      return false;
    }
  }

  /// Clean up profile module (for testing)
  static Future<void> cleanup(GetIt sl) async {
    try {
      Logger.info('🧹 Cleaning up profile module...');

      // Close ProfileBloc if it exists and is open
      if (sl.isRegistered<ProfileBloc>()) {
        try {
          final profileBloc = sl<ProfileBloc>();
          if (!profileBloc.isClosed) {
            await profileBloc.close();
            Logger.info('✅ ProfileBloc closed successfully');
          }
        } catch (e) {
          Logger.warning('⚠️ Error closing ProfileBloc: $e');
        }
      }

      // Unregister services in reverse dependency order
      final servicesToUnregister = [
        ProfileBloc,
        ExportUserData,
        GetAchievements,
        UpdateUserPreferences,
        GetUserPreferences,
        UpdateUserProfile,
        GetUserProfile,
        ProfileRepository,
        ProfileLocalDataSource,
        ProfileRemoteDataSource,
      ];

      for (final serviceType in servicesToUnregister) {
        try {
          if (sl.isRegistered(instance: serviceType)) {
            sl.unregister(instance: serviceType);
            Logger.info('🗑️ Unregistered ${serviceType.toString()}');
          }
        } catch (e) {
          Logger.warning(
            '⚠️ Error unregistering ${serviceType.toString()}: $e',
          );
        }
      }

      Logger.info('✅ Profile module cleanup completed');
    } catch (e) {
      Logger.error('❌ Profile module cleanup failed', e);
    }
  }

  /// Get profile module health status
  static Map<String, dynamic> getHealthStatus(GetIt sl) {
    final health = <String, dynamic>{
      'module': 'Profile',
      'status': 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
      'services': <String, dynamic>{},
      'errors': <String>[],
    };

    try {
      final serviceChecks = [
        _checkService<ProfileRemoteDataSource>(sl, 'ProfileRemoteDataSource'),
        _checkService<ProfileLocalDataSource>(sl, 'ProfileLocalDataSource'),
        _checkService<ProfileRepository>(sl, 'ProfileRepository'),
        _checkService<GetUserProfile>(sl, 'GetUserProfile'),
        _checkService<UpdateUserProfile>(sl, 'UpdateUserProfile'),
        _checkService<GetUserPreferences>(sl, 'GetUserPreferences'),
        _checkService<UpdateUserPreferences>(sl, 'UpdateUserPreferences'),
        _checkService<GetAchievements>(sl, 'GetAchievements'),
        _checkService<ExportUserData>(sl, 'ExportUserData'),
        _checkService<GetCurrentUser>(sl, 'GetCurrentUser'),
        _checkService<ProfileBloc>(sl, 'ProfileBloc'),
      ];

      bool allHealthy = true;
      int healthyCount = 0;

      for (final check in serviceChecks) {
        final serviceName = check['name'];
        final isRegistered = check['isRegistered'];

        if (isRegistered) {
          health['services'][serviceName] = 'registered';
          healthyCount++;
        } else {
          health['services'][serviceName] = 'not_registered';
          health['errors'].add('$serviceName is not registered');
          allHealthy = false;
        }
      }

      health['status'] = allHealthy ? 'healthy' : 'degraded';
      health['healthy_services'] = healthyCount;
      health['total_services'] = serviceChecks.length;
    } catch (e) {
      health['status'] = 'unhealthy';
      health['errors'].add('Health check failed: ${e.toString()}');
    }

    return health;
  }
}
