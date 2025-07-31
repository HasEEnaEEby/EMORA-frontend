import 'package:equatable/equatable.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}


class LoadGlobalFeedEvent extends CommunityEvent {
  final int page;
  final int limit;
  final bool forceRefresh;

  const LoadGlobalFeedEvent({
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, forceRefresh];

  @override
  String toString() => 'LoadGlobalFeedEvent { page: $page, limit: $limit, forceRefresh: $forceRefresh }';
}

class LoadFriendsFeedEvent extends CommunityEvent {
  final int page;
  final int limit;
  final bool forceRefresh;

  const LoadFriendsFeedEvent({
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, forceRefresh];

  @override
  String toString() => 'LoadFriendsFeedEvent { page: $page, limit: $limit, forceRefresh: $forceRefresh }';
}

class LoadTrendingPostsEvent extends CommunityEvent {
  final int timeRange;
  final int limit;
  final bool forceRefresh;

  const LoadTrendingPostsEvent({
    this.timeRange = 24,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [timeRange, limit, forceRefresh];

  @override
  String toString() => 'LoadTrendingPostsEvent { timeRange: $timeRange, limit: $limit, forceRefresh: $forceRefresh }';
}

class SwitchFeedTypeEvent extends CommunityEvent {
final String feedType; 

  const SwitchFeedTypeEvent({required this.feedType});

  @override
  List<Object?> get props => [feedType];

  @override
  String toString() => 'SwitchFeedTypeEvent { feedType: $feedType }';
}


class ReactToPostEvent extends CommunityEvent {
  final String postId;
  final String emoji;
  final String type;

  const ReactToPostEvent({
    required this.postId,
    required this.emoji,
    this.type = 'comfort',
  });

  @override
  List<Object?> get props => [postId, emoji, type];

  @override
  String toString() => 'ReactToPostEvent { postId: $postId, emoji: $emoji, type: $type }';
}

class RemoveReactionEvent extends CommunityEvent {
  final String postId;

  const RemoveReactionEvent({required this.postId});

  @override
  List<Object?> get props => [postId];

  @override
  String toString() => 'RemoveReactionEvent { postId: $postId }';
}

class AddCommentEvent extends CommunityEvent {
  final String postId;
  final String message;
  final bool isAnonymous;

  const AddCommentEvent({
    required this.postId,
    required this.message,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [postId, message, isAnonymous];

  @override
  String toString() => 'AddCommentEvent { postId: $postId, message: $message, isAnonymous: $isAnonymous }';
}

class CreateCommunityPostEvent extends CommunityEvent {
  final String emoji;
  final String note;
  final List<String> tags;
  final bool isAnonymous;
  final String? emotionType;
  final int? emotionIntensity;

  const CreateCommunityPostEvent({
    required this.emoji,
    required this.note,
    this.tags = const [],
    this.isAnonymous = false,
    this.emotionType,
    this.emotionIntensity,
  });

  @override
  List<Object?> get props => [emoji, note, tags, isAnonymous, emotionType, emotionIntensity];

  @override
  String toString() => 'CreateCommunityPostEvent { emoji: $emoji, note: $note, isAnonymous: $isAnonymous }';
}

class LoadCommentsEvent extends CommunityEvent {
  final String postId;
  final int page;
  final int limit;

  const LoadCommentsEvent({
    required this.postId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [postId, page, limit];

  @override
  String toString() => 'LoadCommentsEvent { postId: $postId, page: $page, limit: $limit }';
}


class LoadGlobalStatsEvent extends CommunityEvent {
  final String timeRange;
  final bool forceRefresh;

  const LoadGlobalStatsEvent({
    this.timeRange = '24h',
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [timeRange, forceRefresh];

  @override
  String toString() => 'LoadGlobalStatsEvent { timeRange: $timeRange, forceRefresh: $forceRefresh }';
}


class RefreshCommunityDataEvent extends CommunityEvent {
  const RefreshCommunityDataEvent();

  @override
  String toString() => 'RefreshCommunityDataEvent';
}

class RefreshCurrentFeedEvent extends CommunityEvent {
  const RefreshCurrentFeedEvent();

  @override
  String toString() => 'RefreshCurrentFeedEvent';
}


class ClearCommunityErrorEvent extends CommunityEvent {
  const ClearCommunityErrorEvent();

  @override
  String toString() => 'ClearCommunityErrorEvent';
}

class ResetCommunityStateEvent extends CommunityEvent {
  const ResetCommunityStateEvent();

  @override
  String toString() => 'ResetCommunityStateEvent';
} 