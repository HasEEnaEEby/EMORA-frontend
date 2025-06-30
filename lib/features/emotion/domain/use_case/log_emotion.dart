import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entity/emotion_entity.dart';
import '../repository/emotion_repository.dart';

class LogEmotion implements UseCase<EmotionEntity, LogEmotionParams> {
  final EmotionRepository repository;

  LogEmotion(this.repository);

  @override
  Future<Either<Failure, EmotionEntity>> call(LogEmotionParams params) async {
    return await repository.logEmotion(
      userId: params.userId,
      emotion: params.emotion,
      intensity: params.intensity,
      context: params.context,
      memory: params.memory,
      latitude: params.latitude,
      longitude: params.longitude,
      additionalData: params.additionalData,
    );
  }
}

class LogEmotionParams extends Equatable {
  final String userId;
  final String emotion;
  final double intensity;
  final String? context;
  final String? memory;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? additionalData;

  const LogEmotionParams({
    required this.userId,
    required this.emotion,
    required this.intensity,
    this.context,
    this.memory,
    this.latitude,
    this.longitude,
    this.additionalData,
  });

  @override
  List<Object?> get props => [
    userId,
    emotion,
    intensity,
    context,
    memory,
    latitude,
    longitude,
    additionalData,
  ];
}
