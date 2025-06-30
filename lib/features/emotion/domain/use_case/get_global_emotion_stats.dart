import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../repository/emotion_repository.dart';

class GetGlobalEmotionStats
    implements UseCase<Map<String, dynamic>, GetGlobalEmotionStatsParams> {
  final EmotionRepository repository;

  GetGlobalEmotionStats(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetGlobalEmotionStatsParams params,
  ) async {
    return await repository.getGlobalEmotionStats(
      timeframe: params.timeframe,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetGlobalEmotionStatsParams extends Equatable {
  final String timeframe;
  final bool forceRefresh;

  const GetGlobalEmotionStatsParams({
    this.timeframe = '24h',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [timeframe, forceRefresh];
}
