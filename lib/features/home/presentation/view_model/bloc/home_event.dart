import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}


class LoadHomeDataEvent extends HomeEvent {
  final bool forceRefresh;
  
  const LoadHomeDataEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadHomeDataEvent { forceRefresh: $forceRefresh }';
}

class RefreshHomeDataEvent extends HomeEvent {
  final bool forceRefresh;
  
  const RefreshHomeDataEvent({this.forceRefresh = true});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'RefreshHomeDataEvent { forceRefresh: $forceRefresh }';
}

class LoadUserStatsEvent extends HomeEvent {
  final bool forceRefresh;
  final String? userId;
  
  const LoadUserStatsEvent({this.forceRefresh = false, this.userId});

  @override
  List<Object?> get props => [forceRefresh, userId];

  @override
  String toString() => 'LoadUserStatsEvent { forceRefresh: $forceRefresh, userId: $userId }';
}

class RefreshUserStatsEvent extends HomeEvent {
  final bool forceRefresh;
  
  const RefreshUserStatsEvent({this.forceRefresh = true});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'RefreshUserStatsEvent { forceRefresh: $forceRefresh }';
}


class NavigateToMainFlowEvent extends HomeEvent {
  final Map<String, dynamic>? userData;
  
  const NavigateToMainFlowEvent({this.userData});

  @override
  List<Object?> get props => [userData];

  @override
  String toString() => 'NavigateToMainFlowEvent { userData: $userData }';
}

class MarkFirstTimeLoginCompleteEvent extends HomeEvent {
  final Map<String, dynamic>? additionalData;
  
  const MarkFirstTimeLoginCompleteEvent({this.additionalData});

  @override
  List<Object?> get props => [additionalData];

  @override
  String toString() => 'MarkFirstTimeLoginCompleteEvent { additionalData: $additionalData }';
}


class UpdateLastActivityEvent extends HomeEvent {
  final DateTime? timestamp;
  
  const UpdateLastActivityEvent({this.timestamp});

  @override
  List<Object?> get props => [timestamp];

  @override
  String toString() => 'UpdateLastActivityEvent { timestamp: $timestamp }';
}

class EmotionLoggedEvent extends HomeEvent {
  final String emotion;
  final double intensity;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;
  
  const EmotionLoggedEvent({
    required this.emotion,
    required this.intensity,
    this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [emotion, intensity, timestamp, metadata];

  @override
  String toString() => 'EmotionLoggedEvent { emotion: $emotion, intensity: $intensity, timestamp: $timestamp }';
}

class LoadEmotionHistoryEvent extends HomeEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool forceRefresh;
  
  const LoadEmotionHistoryEvent({
    this.startDate,
    this.endDate,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [startDate, endDate, forceRefresh];

  @override
  String toString() => 'LoadEmotionHistoryEvent { startDate: $startDate, endDate: $endDate, forceRefresh: $forceRefresh }';
}

class LoadWeeklyInsightsEvent extends HomeEvent {
  final bool forceRefresh;
  
  const LoadWeeklyInsightsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadWeeklyInsightsEvent { forceRefresh: $forceRefresh }';
}

class LoadTodaysJourneyEvent extends HomeEvent {
  final bool forceRefresh;
  
  const LoadTodaysJourneyEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadTodaysJourneyEvent { forceRefresh: $forceRefresh }';
}

class LoadEmotionCalendarEvent extends HomeEvent {
  final DateTime month;
  final bool forceRefresh;
  
  const LoadEmotionCalendarEvent({
    required this.month,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [month, forceRefresh];

  @override
  String toString() => 'LoadEmotionCalendarEvent { month: $month, forceRefresh: $forceRefresh }';
}

class SelectCalendarDateEvent extends HomeEvent {
  final DateTime selectedDate;
  
  const SelectCalendarDateEvent({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];

  @override
  String toString() => 'SelectCalendarDateEvent { selectedDate: $selectedDate }';
}

class LogEmotionEvent extends HomeEvent {
  final String emotion;
  final int intensity;
  final String? note;
  final List<String>? tags;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? context;
  
  const LogEmotionEvent({
    required this.emotion,
    required this.intensity,
    this.note,
    this.tags,
    this.location,
    this.context,
  });

  @override
  List<Object?> get props => [emotion, intensity, note, tags, location, context];

  @override
  String toString() => 'LogEmotionEvent { emotion: $emotion, intensity: $intensity }';
}


class ClearHomeDataEvent extends HomeEvent {
  const ClearHomeDataEvent();

  @override
  String toString() => 'ClearHomeDataEvent';
}

class UpdateHomeDataEvent extends HomeEvent {
  final Map<String, dynamic> updates;
  
  const UpdateHomeDataEvent(this.updates);

  @override
  List<Object?> get props => [updates];

  @override
  String toString() => 'UpdateHomeDataEvent { updates: $updates }';
}


class LogoutEvent extends HomeEvent {
  final bool clearCache;
  
  const LogoutEvent({this.clearCache = true});

  @override
  List<Object?> get props => [clearCache];

  @override
  String toString() => 'LogoutEvent { clearCache: $clearCache }';
}


class HomeErrorOccurredEvent extends HomeEvent {
  final String error;
  final String? operation;
  final dynamic exception;
  
  const HomeErrorOccurredEvent({
    required this.error,
    this.operation,
    this.exception,
  });

  @override
  List<Object?> get props => [error, operation, exception];

  @override
  String toString() => 'HomeErrorOccurredEvent { error: $error, operation: $operation }';
}

class RetryHomeOperationEvent extends HomeEvent {
  final String operation;
  
  const RetryHomeOperationEvent({required this.operation});

  @override
  List<Object?> get props => [operation];

  @override
  String toString() => 'RetryHomeOperationEvent { operation: $operation }';
}

class ClearHomeErrorEvent extends HomeEvent {
  const ClearHomeErrorEvent();

  @override
  String toString() => 'ClearHomeErrorEvent';
}


class LoadHomeData extends HomeEvent {
  final bool forceRefresh;
  
  const LoadHomeData({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadHomeData { forceRefresh: $forceRefresh }';
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();

  @override
  String toString() => 'RefreshHomeData';
}

class LoadUserStats extends HomeEvent {
  final String? userId;
  
  const LoadUserStats({this.userId});

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'LoadUserStats { userId: $userId }';
}

class NavigateToMainFlow extends HomeEvent {
  final Map<String, dynamic>? userData;
  
  const NavigateToMainFlow({this.userData});

  @override
  List<Object?> get props => [userData];

  @override
  String toString() => 'NavigateToMainFlow { userData: $userData }';
}


class ForceAppRefreshEvent extends HomeEvent {
  const ForceAppRefreshEvent();

  @override
  String toString() => 'ForceAppRefreshEvent';
}

class SyncDataEvent extends HomeEvent {
  final bool forceSync;
  
  const SyncDataEvent({this.forceSync = false});

  @override
  List<Object?> get props => [forceSync];

  @override
  String toString() => 'SyncDataEvent { forceSync: $forceSync }';
}

class InitializeHomeEvent extends HomeEvent {
  final Map<String, dynamic>? initialData;
  
  const InitializeHomeEvent({this.initialData});

  @override
  List<Object?> get props => [initialData];

  @override
  String toString() => 'InitializeHomeEvent { initialData: $initialData }';
}