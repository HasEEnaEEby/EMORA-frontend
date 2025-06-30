// Create this file: lib/features/emotion/domain/use_case/get_global_emotion_heatmap.dart

import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/features/emotion/domain/entity/global_heatmap_entity.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../../../core/utils/logger.dart';
import '../repository/emotion_repository.dart';

class GetGlobalEmotionHeatmap
    extends UseCase<GlobalHeatmapEntity, GetGlobalEmotionHeatmapParams> {
  final EmotionRepository repository;

  GetGlobalEmotionHeatmap(this.repository);

  @override
  Future<Either<Failure, GlobalHeatmapEntity>> call(
    GetGlobalEmotionHeatmapParams params,
  ) async {
    Logger.info('🗺️ GetGlobalEmotionHeatmap use case for emotions');

    final result = await repository.getGlobalHeatmap(
      forceRefresh: params.forceRefresh,
    );

    return result.fold((failure) => Left(failure), (heatmapData) {
      // Convert Map to Entity
      final entity = GlobalHeatmapEntity.fromJson(heatmapData);
      return Right(entity);
    });
  }
}

class GetGlobalEmotionHeatmapParams extends Equatable {
  final bool forceRefresh;

  const GetGlobalEmotionHeatmapParams({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}
