
part of 'emotion_bloc.dart';

enum EmotionErrorType { server, cache, network, validation, general }

abstract class EmotionState extends Equatable {
  const EmotionState();

  @override
  List<Object?> get props => [];
}

class EmotionInitial extends EmotionState {
  const EmotionInitial();
}

class EmotionLoading extends EmotionState {
  final String message;

  const EmotionLoading({this.message = 'Loading...'});

  @override
  List<Object?> get props => [message];
}

class EmotionLogSuccess extends EmotionState {
  final Map<String, dynamic> loggedEmotion;
  final bool syncedToRemote;

  const EmotionLogSuccess({
    required this.loggedEmotion,
    required this.syncedToRemote,
  });

  @override
  List<Object?> get props => [loggedEmotion, syncedToRemote];
}

class EmotionLoaded extends EmotionState {
  final List<Map<String, dynamic>> emotionFeed;
  final Map<String, dynamic> globalStats;
  final Map<String, dynamic> heatmapData;
  final List<Map<String, dynamic>> userEmotionHistory;
  final Map<String, dynamic> userInsights;
  final Map<String, dynamic> userAnalytics;
  final DateTime lastUpdated;

  const EmotionLoaded({
    required this.emotionFeed,
    required this.globalStats,
    required this.heatmapData,
    required this.userEmotionHistory,
    required this.userInsights,
    required this.userAnalytics,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    emotionFeed,
    globalStats,
    heatmapData,
    userEmotionHistory,
    userInsights,
    userAnalytics,
    lastUpdated,
  ];
}

class EmotionPartiallyLoaded extends EmotionState {
  final List<Map<String, dynamic>>? emotionFeed;
  final Map<String, dynamic>? globalStats;
  final Map<String, dynamic>? heatmapData;
  final List<Map<String, dynamic>>? userEmotionHistory;
  final Map<String, dynamic>? userInsights;
  final Map<String, dynamic>? userAnalytics;
  final List<String> failedOperations;
  final DateTime lastUpdated;

  const EmotionPartiallyLoaded({
    this.emotionFeed,
    this.globalStats,
    this.heatmapData,
    this.userEmotionHistory,
    this.userInsights,
    this.userAnalytics,
    required this.failedOperations,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    emotionFeed,
    globalStats,
    heatmapData,
    userEmotionHistory,
    userInsights,
    userAnalytics,
    failedOperations,
    lastUpdated,
  ];
}

class EmotionError extends EmotionState {
  final String message;
  final String? details;
  final EmotionErrorType errorType;

  const EmotionError({
    required this.message,
    this.details,
    this.errorType = EmotionErrorType.general,
  });

  @override
  List<Object?> get props => [message, details, errorType];
}

class EmotionCacheCleared extends EmotionState {
  const EmotionCacheCleared();
}
