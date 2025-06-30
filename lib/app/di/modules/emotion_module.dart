import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_heatmap.dart';
import 'package:get_it/get_it.dart';

import '../../../features/emotion/data/data_source/local/emotion_local_data_source.dart';
import '../../../features/emotion/data/data_source/remote/emotion_remote_data_source.dart';
import '../../../features/emotion/data/repository/emotion_repository_impl.dart';
import '../../../features/emotion/domain/repository/emotion_repository.dart';
import '../../../features/emotion/domain/use_case/get_emotion_feed.dart';
import '../../../features/emotion/domain/use_case/get_global_emotion_stats.dart';
import '../../../features/emotion/domain/use_case/log_emotion.dart';
import '../../../features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import '../injection_container.dart';

class EmotionModule {
  static Future<void> init(GetIt sl) async {
    final featureFlags = sl<FeatureFlagService>();

    if (!featureFlags.isEmotionEnabled) {
      Logger.info('⏭️ Skipping emotion module initialization (disabled)');
      return;
    }

    Logger.info('🎭 Initializing emotion module...');

    try {
      _initDataSources(sl);
      _initRepository(sl);
      _initUseCases(sl);
      _initBloc(sl);

      Logger.info('✅ Emotion module initialized successfully');
    } catch (e) {
      Logger.error('❌ Emotion module initialization failed', e);
      rethrow;
    }
  }

  static void _initDataSources(GetIt sl) {
    Logger.info('📱 Initializing emotion data sources...');

    // Local Data Source
    sl.registerLazySingleton<EmotionLocalDataSource>(
      () => EmotionLocalDataSourceImpl(),
    );

    // Remote Data Source
    sl.registerLazySingleton<EmotionRemoteDataSource>(
      () => EmotionRemoteDataSourceImpl(
        dioClient: sl<DioClient>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  static void _initRepository(GetIt sl) {
    Logger.info('🗃️ Initializing emotion repository...');

    sl.registerLazySingleton<EmotionRepository>(
      () => EmotionRepositoryImpl(
        remoteDataSource: sl<EmotionRemoteDataSource>(),
        localDataSource: sl<EmotionLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  static void _initUseCases(GetIt sl) {
    Logger.info('⚙️ Initializing emotion use cases...');

    sl.registerLazySingleton<LogEmotion>(
      () => LogEmotion(sl<EmotionRepository>()),
    );

    sl.registerLazySingleton<GetEmotionFeed>(
      () => GetEmotionFeed(sl<EmotionRepository>()),
    );

    sl.registerLazySingleton<GetGlobalEmotionStats>(
      () => GetGlobalEmotionStats(sl<EmotionRepository>()),
    );

    // Register GetGlobalEmotionHeatmap for emotion module
    sl.registerLazySingleton<GetGlobalEmotionHeatmap>(
      () => GetGlobalEmotionHeatmap(sl<EmotionRepository>()),
    );
  }

  static void _initBloc(GetIt sl) {
    Logger.info('🧩 Initializing emotion bloc...');

    sl.registerFactory<EmotionBloc>(
      () => EmotionBloc(
        logEmotion: sl<LogEmotion>(),
        getEmotionFeed: sl<GetEmotionFeed>(),
        getGlobalEmotionStats: sl<GetGlobalEmotionStats>(),
        getGlobalHeatmap: sl<GetGlobalEmotionHeatmap>(),
        emotionRepository: sl<EmotionRepository>(),
      ),
    );
  }

  static Map<String, dynamic> verify(GetIt sl) {
    Logger.info('🔍 Verifying emotion module registrations...');

    final featureFlags = sl<FeatureFlagService>();

    if (!featureFlags.isEmotionEnabled) {
      Logger.info('⏭️ Skipping emotion module verification (disabled)');
      return {
        'module': 'Emotion',
        'registered': 0,
        'total': 0,
        'success': true,
        'skipped': true,
      };
    }

    final serviceChecks = <String, bool Function()>{
      'EmotionLocalDataSource': () => sl.isRegistered<EmotionLocalDataSource>(),
      'EmotionRemoteDataSource': () =>
          sl.isRegistered<EmotionRemoteDataSource>(),
      'EmotionRepository': () => sl.isRegistered<EmotionRepository>(),
      'LogEmotion': () => sl.isRegistered<LogEmotion>(),
      'GetEmotionFeed': () => sl.isRegistered<GetEmotionFeed>(),
      'GetGlobalEmotionStats': () => sl.isRegistered<GetGlobalEmotionStats>(),
      'GetGlobalEmotionHeatmap': () =>
          sl.isRegistered<GetGlobalEmotionHeatmap>(),
      'EmotionBloc': () => sl.isRegistered<EmotionBloc>(),
    };

    int registeredCount = 0;
    int totalCount = serviceChecks.length;

    for (final entry in serviceChecks.entries) {
      final serviceName = entry.key;
      final isRegistered = entry.value();

      if (isRegistered) {
        Logger.info('✅ Emotion: $serviceName is registered');
        registeredCount++;
      } else {
        Logger.warning('⚠️ Emotion: $serviceName is NOT registered');
      }
    }

    Logger.info(
      '📊 Emotion Module: $registeredCount/$totalCount services registered',
    );

    return {
      'module': 'Emotion',
      'registered': registeredCount,
      'total': totalCount,
      'success': registeredCount == totalCount,
    };
  }
}
