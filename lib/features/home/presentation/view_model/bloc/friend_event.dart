
import 'package:equatable/equatable.dart';

import '../../../domain/entity/friend_entity.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}


class SearchUsersEvent extends FriendEvent {
  final String query;
  final int page;
  final int limit;
  final bool forceRefresh;

  const SearchUsersEvent({
    required this.query,
    this.page = 1,
    this.limit = 10,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [query, page, limit, forceRefresh];

  @override
  String toString() => 'SearchUsersEvent { query: $query, page: $page, limit: $limit }';
}

class SearchAllUsersEvent extends FriendEvent {
  final String query;
  final int page;
  final int limit;
  final bool forceRefresh;

  const SearchAllUsersEvent({
    required this.query,
    this.page = 1,
    this.limit = 10,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [query, page, limit, forceRefresh];

  @override
  String toString() => 'SearchAllUsersEvent { query: $query, page: $page, limit: $limit }';
}

class ClearSearchEvent extends FriendEvent {
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'ClearSearchEvent';
}


class SendFriendRequestEvent extends FriendEvent {
  final String userId;
final String? message; 

  const SendFriendRequestEvent({
    required this.userId,
    this.message,
  });

  @override
  List<Object?> get props => [userId, message];

  @override
  String toString() => 'SendFriendRequestEvent { userId: $userId, message: $message }';
}

class CancelFriendRequestEvent extends FriendEvent {
  final String userId;
final String? reason; 

  const CancelFriendRequestEvent({
    required this.userId,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];

  @override
  String toString() => 'CancelFriendRequestEvent { userId: $userId, reason: $reason }';
}

class RespondToFriendRequestEvent extends FriendEvent {
  final String requestUserId;
final String action; 
final String? message; 

  const RespondToFriendRequestEvent({
    required this.requestUserId,
    required this.action,
    this.message,
  });

  @override
  List<Object?> get props => [requestUserId, action, message];

  @override
  String toString() => 'RespondToFriendRequestEvent { requestUserId: $requestUserId, action: $action, message: $message }';
}

class LoadPendingRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadPendingRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadPendingRequestsEvent { forceRefresh: $forceRefresh }';
}

class LoadSentRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadSentRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadSentRequestsEvent { forceRefresh: $forceRefresh }';
}

class LoadReceivedRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadReceivedRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadReceivedRequestsEvent { forceRefresh: $forceRefresh }';
}


class LoadFriendsEvent extends FriendEvent {
  final int page;
  final int limit;
  final bool forceRefresh;

  const LoadFriendsEvent({
    this.page = 1,
    this.limit = 20,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, forceRefresh];

  @override
  String toString() => 'LoadFriendsEvent { page: $page, limit: $limit, forceRefresh: $forceRefresh }';
}

class RemoveFriendEvent extends FriendEvent {
  final String friendUserId;
final String? reason; 

  const RemoveFriendEvent({
    required this.friendUserId,
    this.reason,
  });

  @override
  List<Object?> get props => [friendUserId, reason];

  @override
  String toString() => 'RemoveFriendEvent { friendUserId: $friendUserId, reason: $reason }';
}

class LoadFriendSuggestionsEvent extends FriendEvent {
  final int limit;
  final bool forceRefresh;
final String? filterType; 

  const LoadFriendSuggestionsEvent({
    this.limit = 10,
    this.forceRefresh = false,
    this.filterType,
  });

  @override
  List<Object?> get props => [limit, forceRefresh, filterType];

  @override
  String toString() => 'LoadFriendSuggestionsEvent { limit: $limit, forceRefresh: $forceRefresh, filterType: $filterType }';
}


class AcceptAllRequestsEvent extends FriendEvent {
  const AcceptAllRequestsEvent();

  @override
  String toString() => 'AcceptAllRequestsEvent';
}

class CancelAllSentRequestsEvent extends FriendEvent {
  const CancelAllSentRequestsEvent();

  @override
  String toString() => 'CancelAllSentRequestsEvent';
}

class RejectAllRequestsEvent extends FriendEvent {
  const RejectAllRequestsEvent();

  @override
  String toString() => 'RejectAllRequestsEvent';
}


class BlockUserEvent extends FriendEvent {
  final String userId;
  final String? reason;

  const BlockUserEvent({
    required this.userId,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];

  @override
  String toString() => 'BlockUserEvent { userId: $userId, reason: $reason }';
}

class UnblockUserEvent extends FriendEvent {
  final String userId;

  const UnblockUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'UnblockUserEvent { userId: $userId }';
}

class ReportUserEvent extends FriendEvent {
  final String userId;
  final String reason;
  final String? description;

  const ReportUserEvent({
    required this.userId,
    required this.reason,
    this.description,
  });

  @override
  List<Object?> get props => [userId, reason, description];

  @override
  String toString() => 'ReportUserEvent { userId: $userId, reason: $reason, description: $description }';
}

class UpdateFriendSettingsEvent extends FriendEvent {
  final String friendId;
  final Map<String, dynamic> settings;

  const UpdateFriendSettingsEvent({
    required this.friendId,
    required this.settings,
  });

  @override
  List<Object?> get props => [friendId, settings];

  @override
  String toString() => 'UpdateFriendSettingsEvent { friendId: $friendId, settings: $settings }';
}


class RealTimeFriendRequestReceivedEvent extends FriendEvent {
  final FriendRequestEntity request;

  const RealTimeFriendRequestReceivedEvent({required this.request});

  @override
  List<Object?> get props => [request];

  @override
  String toString() => 'RealTimeFriendRequestReceivedEvent { request: ${request.id} }';
}

class RealTimeFriendRequestAcceptedEvent extends FriendEvent {
  final String requestId;
  final String friendId;
  final String friendName;

  const RealTimeFriendRequestAcceptedEvent({
    required this.requestId,
    required this.friendId,
    required this.friendName,
  });

  @override
  List<Object?> get props => [requestId, friendId, friendName];

  @override
  String toString() => 'RealTimeFriendRequestAcceptedEvent { requestId: $requestId, friendId: $friendId }';
}

class RealTimeFriendRequestCanceledEvent extends FriendEvent {
  final String requestId;
  final String userId;

  const RealTimeFriendRequestCanceledEvent({
    required this.requestId,
    required this.userId,
  });

  @override
  List<Object?> get props => [requestId, userId];

  @override
  String toString() => 'RealTimeFriendRequestCanceledEvent { requestId: $requestId, userId: $userId }';
}

class RealTimeFriendOnlineStatusEvent extends FriendEvent {
  final String friendId;
  final bool isOnline;
  final DateTime? lastSeen;

  const RealTimeFriendOnlineStatusEvent({
    required this.friendId,
    required this.isOnline,
    this.lastSeen,
  });

  @override
  List<Object?> get props => [friendId, isOnline, lastSeen];

  @override
  String toString() => 'RealTimeFriendOnlineStatusEvent { friendId: $friendId, isOnline: $isOnline, lastSeen: $lastSeen }';
}

class RealTimeFriendMoodUpdateEvent extends FriendEvent {
  final String friendId;
  final String mood;
  final String emoji;
  final DateTime timestamp;

  const RealTimeFriendMoodUpdateEvent({
    required this.friendId,
    required this.mood,
    required this.emoji,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [friendId, mood, emoji, timestamp];

  @override
  String toString() => 'RealTimeFriendMoodUpdateEvent { friendId: $friendId, mood: $mood, emoji: $emoji }';
}


class RefreshFriendsDataEvent extends FriendEvent {
  const RefreshFriendsDataEvent();

  @override
  String toString() => 'RefreshFriendsDataEvent';
}

class RefreshSpecificDataEvent extends FriendEvent {
final String dataType; 

  const RefreshSpecificDataEvent({required this.dataType});

  @override
  List<Object?> get props => [dataType];

  @override
  String toString() => 'RefreshSpecificDataEvent { dataType: $dataType }';
}


class MarkNotificationReadEvent extends FriendEvent {
  final String notificationId;

  const MarkNotificationReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];

  @override
  String toString() => 'MarkNotificationReadEvent { notificationId: $notificationId }';
}

class MarkAllNotificationsReadEvent extends FriendEvent {
  const MarkAllNotificationsReadEvent();

  @override
  String toString() => 'MarkAllNotificationsReadEvent';
}

class UpdateNotificationPreferencesEvent extends FriendEvent {
  final Map<String, bool> preferences;

  const UpdateNotificationPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdateNotificationPreferencesEvent { preferences: $preferences }';
}


class LoadFriendshipAnalyticsEvent extends FriendEvent {
final String period; 

  const LoadFriendshipAnalyticsEvent({this.period = 'month'});

  @override
  List<Object?> get props => [period];

  @override
  String toString() => 'LoadFriendshipAnalyticsEvent { period: $period }';
}

class TrackFriendInteractionEvent extends FriendEvent {
  final String friendId;
final String interactionType; 
  final Map<String, dynamic>? metadata;

  const TrackFriendInteractionEvent({
    required this.friendId,
    required this.interactionType,
    this.metadata,
  });

  @override
  List<Object?> get props => [friendId, interactionType, metadata];

  @override
  String toString() => 'TrackFriendInteractionEvent { friendId: $friendId, interactionType: $interactionType }';
}


class ClearFriendErrorEvent extends FriendEvent {
  const ClearFriendErrorEvent();

  @override
  String toString() => 'ClearFriendErrorEvent';
}

class ResetFriendStateEvent extends FriendEvent {
  const ResetFriendStateEvent();

  @override
  String toString() => 'ResetFriendStateEvent';
}

class RetryFailedOperationEvent extends FriendEvent {
  final String operationType;
  final Map<String, dynamic>? parameters;

  const RetryFailedOperationEvent({
    required this.operationType,
    this.parameters,
  });

  @override
  List<Object?> get props => [operationType, parameters];

  @override
  String toString() => 'RetryFailedOperationEvent { operationType: $operationType, parameters: $parameters }';
}


class UpdateFriendPrivacySettingsEvent extends FriendEvent {
  final Map<String, dynamic> privacySettings;

  const UpdateFriendPrivacySettingsEvent({required this.privacySettings});

  @override
  List<Object?> get props => [privacySettings];

  @override
  String toString() => 'UpdateFriendPrivacySettingsEvent { privacySettings: $privacySettings }';
}

class LoadFriendPrivacySettingsEvent extends FriendEvent {
  const LoadFriendPrivacySettingsEvent();

  @override
  String toString() => 'LoadFriendPrivacySettingsEvent';
}

class UpdateDiscoveryPreferencesEvent extends FriendEvent {
  final Map<String, dynamic> preferences;

  const UpdateDiscoveryPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdateDiscoveryPreferencesEvent { preferences: $preferences }';
}


class ImportFriendsFromContactsEvent extends FriendEvent {
  final List<Map<String, String>> contacts;

  const ImportFriendsFromContactsEvent({required this.contacts});

  @override
  List<Object?> get props => [contacts];

  @override
  String toString() => 'ImportFriendsFromContactsEvent { contactsCount: ${contacts.length} }';
}

class ExportFriendsListEvent extends FriendEvent {
final String format; 

  const ExportFriendsListEvent({this.format = 'json'});

  @override
  List<Object?> get props => [format];

  @override
  String toString() => 'ExportFriendsListEvent { format: $format }';
}


class SyncFriendsDataEvent extends FriendEvent {
  final bool forceSync;

  const SyncFriendsDataEvent({this.forceSync = false});

  @override
  List<Object?> get props => [forceSync];

  @override
  String toString() => 'SyncFriendsDataEvent { forceSync: $forceSync }';
}

class HandleSyncConflictEvent extends FriendEvent {
  final String conflictId;
final String resolution; 

  const HandleSyncConflictEvent({
    required this.conflictId,
    required this.resolution,
  });

  @override
  List<Object?> get props => [conflictId, resolution];

  @override
  String toString() => 'HandleSyncConflictEvent { conflictId: $conflictId, resolution: $resolution }';
}