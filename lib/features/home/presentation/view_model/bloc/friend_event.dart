// Complete Enhanced Friend Events with Cancel Functionality
// lib/features/community/presentation/view_model/bloc/friend_event.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entity/friend_entity.dart';

abstract class FriendEvent extends Equatable {
  const FriendEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// SEARCH EVENTS
// ============================================================================

/// Search users for friend suggestions
class SearchUsersEvent extends FriendEvent {
  final String query;
  final int page;
  final int limit;

  const SearchUsersEvent({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, page, limit];

  @override
  String toString() => 'SearchUsersEvent { query: $query, page: $page, limit: $limit }';
}

/// Clear search results
class ClearSearchEvent extends FriendEvent {
  const ClearSearchEvent();

  @override
  String toString() => 'ClearSearchEvent';
}

// ============================================================================
// FRIEND REQUEST EVENTS
// ============================================================================

/// Send friend request to a user
class SendFriendRequestEvent extends FriendEvent {
  final String userId;
  final String? message; // Optional message with request

  const SendFriendRequestEvent({
    required this.userId,
    this.message,
  });

  @override
  List<Object?> get props => [userId, message];

  @override
  String toString() => 'SendFriendRequestEvent { userId: $userId, message: $message }';
}

/// Cancel a sent friend request
class CancelFriendRequestEvent extends FriendEvent {
  final String userId;
  final String? reason; // Optional reason for cancellation

  const CancelFriendRequestEvent({
    required this.userId,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, reason];

  @override
  String toString() => 'CancelFriendRequestEvent { userId: $userId, reason: $reason }';
}

/// Respond to a friend request (accept/reject)
class RespondToFriendRequestEvent extends FriendEvent {
  final String requestUserId;
  final String action; // 'accept' or 'reject'
  final String? message; // Optional response message

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

/// Load pending friend requests
class LoadPendingRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadPendingRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadPendingRequestsEvent { forceRefresh: $forceRefresh }';
}

/// Load sent friend requests specifically
class LoadSentRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadSentRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadSentRequestsEvent { forceRefresh: $forceRefresh }';
}

/// Load received friend requests specifically
class LoadReceivedRequestsEvent extends FriendEvent {
  final bool forceRefresh;

  const LoadReceivedRequestsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];

  @override
  String toString() => 'LoadReceivedRequestsEvent { forceRefresh: $forceRefresh }';
}

// ============================================================================
// FRIENDS MANAGEMENT EVENTS
// ============================================================================

/// Load friends list
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

/// Remove a friend
class RemoveFriendEvent extends FriendEvent {
  final String friendUserId;
  final String? reason; // Optional reason for removal

  const RemoveFriendEvent({
    required this.friendUserId,
    this.reason,
  });

  @override
  List<Object?> get props => [friendUserId, reason];

  @override
  String toString() => 'RemoveFriendEvent { friendUserId: $friendUserId, reason: $reason }';
}

/// Load friend suggestions
class LoadFriendSuggestionsEvent extends FriendEvent {
  final int limit;
  final bool forceRefresh;
  final String? filterType; // 'mood_based', 'interest_based', 'location_based'

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

// ============================================================================
// BATCH OPERATION EVENTS
// ============================================================================

/// Accept all pending friend requests
class AcceptAllRequestsEvent extends FriendEvent {
  const AcceptAllRequestsEvent();

  @override
  String toString() => 'AcceptAllRequestsEvent';
}

/// Cancel all sent friend requests
class CancelAllSentRequestsEvent extends FriendEvent {
  const CancelAllSentRequestsEvent();

  @override
  String toString() => 'CancelAllSentRequestsEvent';
}

/// Reject all received friend requests
class RejectAllRequestsEvent extends FriendEvent {
  const RejectAllRequestsEvent();

  @override
  String toString() => 'RejectAllRequestsEvent';
}

// ============================================================================
// FRIEND INTERACTION EVENTS
// ============================================================================

/// Block a user
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

/// Unblock a user
class UnblockUserEvent extends FriendEvent {
  final String userId;

  const UnblockUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];

  @override
  String toString() => 'UnblockUserEvent { userId: $userId }';
}

/// Report a user
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

/// Update friend settings (notifications, privacy, etc.)
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

// ============================================================================
// REAL-TIME EVENTS
// ============================================================================

/// Handle real-time friend request received
class RealTimeFriendRequestReceivedEvent extends FriendEvent {
  final FriendRequestEntity request;

  const RealTimeFriendRequestReceivedEvent({required this.request});

  @override
  List<Object?> get props => [request];

  @override
  String toString() => 'RealTimeFriendRequestReceivedEvent { request: ${request.id} }';
}

/// Handle real-time friend request accepted
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

/// Handle real-time friend request canceled
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

/// Handle real-time friend online status update
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

/// Handle real-time friend mood update
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

// ============================================================================
// REFRESH EVENTS
// ============================================================================

/// Refresh all friends data
class RefreshFriendsDataEvent extends FriendEvent {
  const RefreshFriendsDataEvent();

  @override
  String toString() => 'RefreshFriendsDataEvent';
}

/// Refresh specific data type
class RefreshSpecificDataEvent extends FriendEvent {
  final String dataType; // 'friends', 'requests', 'suggestions'

  const RefreshSpecificDataEvent({required this.dataType});

  @override
  List<Object?> get props => [dataType];

  @override
  String toString() => 'RefreshSpecificDataEvent { dataType: $dataType }';
}

// ============================================================================
// NOTIFICATION EVENTS
// ============================================================================

/// Mark friend notification as read
class MarkNotificationReadEvent extends FriendEvent {
  final String notificationId;

  const MarkNotificationReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];

  @override
  String toString() => 'MarkNotificationReadEvent { notificationId: $notificationId }';
}

/// Mark all friend notifications as read
class MarkAllNotificationsReadEvent extends FriendEvent {
  const MarkAllNotificationsReadEvent();

  @override
  String toString() => 'MarkAllNotificationsReadEvent';
}

/// Update notification preferences
class UpdateNotificationPreferencesEvent extends FriendEvent {
  final Map<String, bool> preferences;

  const UpdateNotificationPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdateNotificationPreferencesEvent { preferences: $preferences }';
}

// ============================================================================
// ANALYTICS EVENTS
// ============================================================================

/// Load friendship analytics
class LoadFriendshipAnalyticsEvent extends FriendEvent {
  final String period; // 'week', 'month', 'year'

  const LoadFriendshipAnalyticsEvent({this.period = 'month'});

  @override
  List<Object?> get props => [period];

  @override
  String toString() => 'LoadFriendshipAnalyticsEvent { period: $period }';
}

/// Track friend interaction
class TrackFriendInteractionEvent extends FriendEvent {
  final String friendId;
  final String interactionType; // 'message', 'mood_reaction', 'profile_view'
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

// ============================================================================
// ERROR HANDLING EVENTS
// ============================================================================

/// Clear friend error state
class ClearFriendErrorEvent extends FriendEvent {
  const ClearFriendErrorEvent();

  @override
  String toString() => 'ClearFriendErrorEvent';
}

/// Reset friend state to initial
class ResetFriendStateEvent extends FriendEvent {
  const ResetFriendStateEvent();

  @override
  String toString() => 'ResetFriendStateEvent';
}

/// Retry failed operation
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

// ============================================================================
// PRIVACY AND SETTINGS EVENTS
// ============================================================================

/// Update friend privacy settings
class UpdateFriendPrivacySettingsEvent extends FriendEvent {
  final Map<String, dynamic> privacySettings;

  const UpdateFriendPrivacySettingsEvent({required this.privacySettings});

  @override
  List<Object?> get props => [privacySettings];

  @override
  String toString() => 'UpdateFriendPrivacySettingsEvent { privacySettings: $privacySettings }';
}

/// Load friend privacy settings
class LoadFriendPrivacySettingsEvent extends FriendEvent {
  const LoadFriendPrivacySettingsEvent();

  @override
  String toString() => 'LoadFriendPrivacySettingsEvent';
}

/// Update discovery preferences
class UpdateDiscoveryPreferencesEvent extends FriendEvent {
  final Map<String, dynamic> preferences;

  const UpdateDiscoveryPreferencesEvent({required this.preferences});

  @override
  List<Object?> get props => [preferences];

  @override
  String toString() => 'UpdateDiscoveryPreferencesEvent { preferences: $preferences }';
}

// ============================================================================
// IMPORT/EXPORT EVENTS
// ============================================================================

/// Import friends from contacts
class ImportFriendsFromContactsEvent extends FriendEvent {
  final List<Map<String, String>> contacts;

  const ImportFriendsFromContactsEvent({required this.contacts});

  @override
  List<Object?> get props => [contacts];

  @override
  String toString() => 'ImportFriendsFromContactsEvent { contactsCount: ${contacts.length} }';
}

/// Export friends list
class ExportFriendsListEvent extends FriendEvent {
  final String format; // 'json', 'csv', 'vcard'

  const ExportFriendsListEvent({this.format = 'json'});

  @override
  List<Object?> get props => [format];

  @override
  String toString() => 'ExportFriendsListEvent { format: $format }';
}

// ============================================================================
// SYNC EVENTS
// ============================================================================

/// Sync friends data with server
class SyncFriendsDataEvent extends FriendEvent {
  final bool forceSync;

  const SyncFriendsDataEvent({this.forceSync = false});

  @override
  List<Object?> get props => [forceSync];

  @override
  String toString() => 'SyncFriendsDataEvent { forceSync: $forceSync }';
}

/// Handle sync conflict
class HandleSyncConflictEvent extends FriendEvent {
  final String conflictId;
  final String resolution; // 'local', 'remote', 'merge'

  const HandleSyncConflictEvent({
    required this.conflictId,
    required this.resolution,
  });

  @override
  List<Object?> get props => [conflictId, resolution];

  @override
  String toString() => 'HandleSyncConflictEvent { conflictId: $conflictId, resolution: $resolution }';
}