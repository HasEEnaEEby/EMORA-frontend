import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

import '../../../features/home/data/data_source/local/home_local_data_source.dart';
import '../../../features/home/data/data_source/remote/home_remote_data_source.dart';
import '../../../features/home/data/repository/home_repository_impl.dart';
import '../../../features/home/domain/repository/home_repository.dart';
import '../../../features/home/domain/use_case/get_user_stats.dart';
import '../../../features/home/domain/use_case/load_home_data.dart';
import '../../../features/home/domain/use_case/navigate_to_main_flow.dart';
import '../../../features/home/presentation/view_model/bloc/home_bloc.dart';

class HomeModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('🏠 Initializing home module...');

    try {
      _initDataSources(sl);
      _initRepository(sl);
      _initUseCases(sl);
      _initBloc(sl);

      Logger.info('✅ Home module initialized successfully');
    } catch (e) {
      Logger.error('❌ Home module initialization failed', e);
      rethrow;
    }
  }

  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing home data sources...');

    // Local Data Source
    sl.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(),
    );

    // Remote Data Source
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(dioClient: sl<DioClient>()),
    );
  }

  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing home repository...');

    // Repository - Register both interface and implementation
    sl.registerLazySingleton<HomeRepositoryImpl>(
      () => HomeRepositoryImpl(
        remoteDataSource: sl<HomeRemoteDataSource>(),
        localDataSource: sl<HomeLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    // Register the interface pointing to the implementation
    sl.registerLazySingleton<HomeRepository>(() => sl<HomeRepositoryImpl>());
  }

  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing home use cases...');

    sl.registerLazySingleton<LoadHomeData>(
      () => LoadHomeData(sl<HomeRepository>()),
    );

    sl.registerLazySingleton<GetUserStats>(
      () => GetUserStats(sl<HomeRepository>()),
    );

    sl.registerLazySingleton<NavigateToMainFlow>(() => NavigateToMainFlow());
  }

  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing home bloc...');

    sl.registerFactory<HomeBloc>(
      () => HomeBloc(
        loadHomeData: sl<LoadHomeData>(),
        getUserStats: sl<GetUserStats>(),
        navigateToMainFlow: sl<NavigateToMainFlow>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying home module registrations...');

    final serviceChecks = <String, bool Function()>{
      'HomeLocalDataSource': () => sl.isRegistered<HomeLocalDataSource>(),
      'HomeRemoteDataSource': () => sl.isRegistered<HomeRemoteDataSource>(),
      'HomeRepositoryImpl': () => sl.isRegistered<HomeRepositoryImpl>(),
      'HomeRepository': () => sl.isRegistered<HomeRepository>(),
      'LoadHomeData': () => sl.isRegistered<LoadHomeData>(),
      'GetUserStats': () => sl.isRegistered<GetUserStats>(),
      'NavigateToMainFlow': () => sl.isRegistered<NavigateToMainFlow>(),
      'HomeBloc': () => sl.isRegistered<HomeBloc>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Home: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Home: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Home Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Home',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
