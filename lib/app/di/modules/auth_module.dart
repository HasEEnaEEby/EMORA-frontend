import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/data/data_source/local/auth_local_data_source.dart';
import '../../../features/auth/data/data_source/remote/auth_remote_data_source.dart';
import '../../../features/auth/data/repository/auth_repository_impl.dart';
import '../../../features/auth/domain/repository/auth_repository.dart';
import '../../../features/auth/domain/use_case/check_username_availability.dart';
import '../../../features/auth/domain/use_case/get_current_user.dart';
import '../../../features/auth/domain/use_case/login_user.dart';
import '../../../features/auth/domain/use_case/logout_user.dart';
import '../../../features/auth/domain/use_case/register_user.dart';
import '../../../features/auth/presentation/view_model/bloc/auth_bloc.dart';

class AuthModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('🔐 Initializing auth module...');

    try {
      _initDataSources(sl);
      _initRepository(sl);
      _initUseCases(sl);
      _initBloc(sl);

      Logger.info('✅ Auth module initialized successfully');
    } catch (e) {
      Logger.error('❌ Auth module initialization failed', e);
      rethrow;
    }
  }

  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing auth data sources...');

    // Local Data Source
    sl.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
    );

    // Remote Data Source
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing auth repository...');

    // Repository - Register both interface and implementation
    sl.registerLazySingleton<AuthRepositoryImpl>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<AuthRemoteDataSource>(),
        localDataSource: sl<AuthLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    // Register the interface pointing to the implementation
    sl.registerLazySingleton<AuthRepository>(() => sl<AuthRepositoryImpl>());
  }

  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing auth use cases...');

    sl.registerLazySingleton<CheckUsernameAvailability>(
      () => CheckUsernameAvailability(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<RegisterUser>(
      () => RegisterUser(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<LoginUser>(() => LoginUser(sl<AuthRepository>()));

    sl.registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(sl<AuthRepository>()),
    );

    sl.registerLazySingleton<LogoutUser>(
      () => LogoutUser(sl<AuthRepository>()),
    );
  }

  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing auth bloc...');

    sl.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        checkUsernameAvailability: sl<CheckUsernameAvailability>(),
        registerUser: sl<RegisterUser>(),
        loginUser: sl<LoginUser>(),
        getCurrentUser: sl<GetCurrentUser>(),
        logoutUser: sl<LogoutUser>(),
        authRepository: sl<AuthRepositoryImpl>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying auth module registrations...');

    final serviceChecks = <String, bool Function()>{
      'AuthLocalDataSource': () => sl.isRegistered<AuthLocalDataSource>(),
      'AuthRemoteDataSource': () => sl.isRegistered<AuthRemoteDataSource>(),
      'AuthRepositoryImpl': () => sl.isRegistered<AuthRepositoryImpl>(),
      'AuthRepository': () => sl.isRegistered<AuthRepository>(),
      'CheckUsernameAvailability': () =>
          sl.isRegistered<CheckUsernameAvailability>(),
      'RegisterUser': () => sl.isRegistered<RegisterUser>(),
      'LoginUser': () => sl.isRegistered<LoginUser>(),
      'GetCurrentUser': () => sl.isRegistered<GetCurrentUser>(),
      'LogoutUser': () => sl.isRegistered<LogoutUser>(),
      'AuthBloc': () => sl.isRegistered<AuthBloc>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Auth: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Auth: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Auth Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Auth',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
