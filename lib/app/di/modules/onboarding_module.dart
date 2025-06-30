import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/onboarding/data/data_source/local/onboarding_local_data_source.dart';
import '../../../features/onboarding/data/data_source/remote/onboarding_remote_data_source.dart';
import '../../../features/onboarding/data/repository/onboarding_repository_impl.dart';
import '../../../features/onboarding/domain/repository/onboarding_repository.dart';
import '../../../features/onboarding/domain/use_case/complete_onboarding.dart';
import '../../../features/onboarding/domain/use_case/get_onboarding_steps.dart';
import '../../../features/onboarding/domain/use_case/save_user_data.dart';
import '../../../features/onboarding/presentation/view_model/bloc/onboarding_bloc.dart';

class OnboardingModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('📋 Initializing onboarding module...');

    try {
      _initDataSources(sl);
      _initRepository(sl);
      _initUseCases(sl);
      _initBloc(sl);

      Logger.info('✅ Onboarding module initialized successfully');
    } catch (e) {
      Logger.error('❌ Onboarding module initialization failed', e);
      rethrow;
    }
  }

  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing onboarding data sources...');

    // Local Data Source
    sl.registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );

    // Remote Data Source
    sl.registerLazySingleton<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing onboarding repository...');

    sl.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        remoteDataSource: sl<OnboardingRemoteDataSource>(),
        localDataSource: sl<OnboardingLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing onboarding use cases...');

    sl.registerLazySingleton<GetOnboardingSteps>(
      () => GetOnboardingSteps(sl<OnboardingRepository>()),
    );

    sl.registerLazySingleton<SaveUserData>(
      () => SaveUserData(sl<OnboardingRepository>()),
    );

    sl.registerLazySingleton<CompleteOnboarding>(
      () => CompleteOnboarding(sl<OnboardingRepository>()),
    );
  }

  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing onboarding bloc...');

    sl.registerFactory<OnboardingBloc>(
      () => OnboardingBloc(
        getOnboardingSteps: sl<GetOnboardingSteps>(),
        saveUserData: sl<SaveUserData>(),
        completeOnboarding: sl<CompleteOnboarding>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying onboarding module registrations...');

    final serviceChecks = <String, bool Function()>{
      'OnboardingLocalDataSource': () =>
          sl.isRegistered<OnboardingLocalDataSource>(),
      'OnboardingRemoteDataSource': () =>
          sl.isRegistered<OnboardingRemoteDataSource>(),
      'OnboardingRepository': () => sl.isRegistered<OnboardingRepository>(),
      'GetOnboardingSteps': () => sl.isRegistered<GetOnboardingSteps>(),
      'SaveUserData': () => sl.isRegistered<SaveUserData>(),
      'CompleteOnboarding': () => sl.isRegistered<CompleteOnboarding>(),
      'OnboardingBloc': () => sl.isRegistered<OnboardingBloc>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Onboarding: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Onboarding: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Onboarding Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Onboarding',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
