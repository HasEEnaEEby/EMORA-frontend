part of 'emotion_bloc.dart';

abstract class EmotionEvent extends Equatable {
  const EmotionEvent();

  @override
  List<Object?> get props => [];
}

class LogEmotionEvent extends EmotionEvent {
  final String userId;
  final String emotion;
  final double intensity;
  final String? context;
  final String? memory;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? additionalData;

  const LogEmotionEvent({
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

class LoadEmotionFeedEvent extends EmotionEvent {
  final int limit;
  final int offset;
  final bool forceRefresh;

  const LoadEmotionFeedEvent({
    this.limit = 20,
    this.offset = 0,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [limit, offset, forceRefresh];
}

class LoadGlobalEmotionStatsEvent extends EmotionEvent {
  final String timeframe;
  final bool forceRefresh;

  const LoadGlobalEmotionStatsEvent({
    this.timeframe = '24h',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [timeframe, forceRefresh];
}

class LoadGlobalHeatmapEvent extends EmotionEvent {
  final bool forceRefresh;

  const LoadGlobalHeatmapEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class LoadUserEmotionHistoryEvent extends EmotionEvent {
  final String userId;
  final int limit;
  final int offset;
  final bool forceRefresh;

  const LoadUserEmotionHistoryEvent({
    required this.userId,
    this.limit = 50,
    this.offset = 0,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, limit, offset, forceRefresh];
}

class LoadUserInsightsEvent extends EmotionEvent {
  final String userId;
  final String timeframe;
  final bool forceRefresh;

  const LoadUserInsightsEvent({
    required this.userId,
    this.timeframe = '30d',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, timeframe, forceRefresh];
}

class LoadUserAnalyticsEvent extends EmotionEvent {
  final String userId;
  final String timeframe;
  final bool forceRefresh;

  const LoadUserAnalyticsEvent({
    required this.userId,
    this.timeframe = '7d',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [userId, timeframe, forceRefresh];
}

class ClearEmotionCacheEvent extends EmotionEvent {
  const ClearEmotionCacheEvent();
}

class RefreshAllEmotionDataEvent extends EmotionEvent {
  const RefreshAllEmotionDataEvent();
}

class InitializeEmotionDataEvent extends EmotionEvent {
  const InitializeEmotionDataEvent();
}
