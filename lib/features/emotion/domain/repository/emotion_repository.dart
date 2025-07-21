import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entity/emotion_entity.dart';

abstract class EmotionRepository {
  Future<Either<Failure, EmotionEntity>> logEmotion({
    required String userId,
    required String emotion,
    required double intensity,
    String? context,
    String? memory,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? additionalData,
  });

  Future<Either<Failure, List<EmotionEntity>>> getEmotionFeed({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getGlobalEmotionStats({
    String timeframe = '24h',
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getGlobalHeatmap({
    bool forceRefresh = false,
  });

  Future<Either<Failure, List<EmotionEntity>>> getUserEmotionHistory({
    required String userId,
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getUserEmotionStats({
    required String userId,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getUserInsights({
    required String userId,
    String timeframe = '30d',
    bool forceRefresh = false,
  });

  Future<Either<Failure, Map<String, dynamic>>> getUserAnalytics({
    required String userId,
    String timeframe = '7d',
    bool forceRefresh = false,
  });

  Future<Either<Failure, void>> clearEmotionCache();

  Future<Either<Failure, bool>> isCacheStale({
    Duration maxAge = const Duration(hours: 1),
  });

  Future<Either<Failure, int>> syncLocalEmotions();

  Future<Either<Failure, Map<String, dynamic>>> getEmotionAnalytics({
    required String userId,
    String period = 'week',
    bool forceRefresh = false,
  });
}
