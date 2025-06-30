import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../../../core/utils/logger.dart';
import '../entity/emotion_entity.dart';
import '../repository/emotion_repository.dart';

class GetEmotionFeed extends UseCase<List<EmotionEntity>, GetEmotionFeedParams> {
  final EmotionRepository repository;

  GetEmotionFeed(this.repository);

  @override
  Future<Either<Failure, List<EmotionEntity>>> call(GetEmotionFeedParams params) async {
    Logger.info('📰 GetEmotionFeed use case (limit: ${params.limit}, offset: ${params.offset})');
    return await repository.getEmotionFeed(
      limit: params.limit,
      offset: params.offset,
      forceRefresh: params.forceRefresh,
    );
  }
}

class GetEmotionFeedParams extends Equatable {
  final int limit;
  final int offset;
  final bool forceRefresh;

  const GetEmotionFeedParams({
    this.limit = 20,
    this.offset = 0,
    this.forceRefresh = false,
  });

  @override
  List<Object> get props => [limit, offset, forceRefresh];
}