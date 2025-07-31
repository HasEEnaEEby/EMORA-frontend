import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/auth/data/data_source/local/auth_local_data_source.dart';
import '../../../features/splash/presentation/view_model/cubit/splash_cubit.dart';

class SplashModule {
  static Future<void> init(GetIt sl) async {
    Logger.info('💫 Initializing splash module...');

    try {
      _initCubit(sl);

      Logger.info('. Splash module initialized successfully');
    } catch (e) {
      Logger.error('. Splash module initialization failed', e);
      rethrow;
    }
  }

  static void _initCubit(GetIt sl) {
    Logger.info('🧩 Initializing splash cubit...');

    sl.registerFactory<SplashCubit>(
      () => SplashCubit(
        sharedPreferences: sl<SharedPreferences>(),
        authLocalDataSource: sl<AuthLocalDataSource>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('. Verifying splash module registrations...');

    final serviceChecks = <String, bool Function()>{
      'SplashCubit': () => sl.isRegistered<SplashCubit>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('. Splash: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('. Splash: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '. Splash Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Splash',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
