import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/use_case/use_case.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/use_case/friend_use_cases.dart';
import '../../../domain/entity/friend_entity.dart';
import '../../widget/enhanced_friend_request_button.dart';
import 'friend_event.dart';
import 'friend_state.dart';

class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final SearchUsers searchUsers;
  final SearchAllUsers searchAllUsers;
  final SendFriendRequest sendFriendRequest;
  final CancelFriendRequest cancelFriendRequest;
  final RespondToFriendRequest respondToFriendRequest;
  final GetFriends getFriends;
  final GetPendingRequests getPendingRequests;
  final RemoveFriend removeFriend;
  final GetFriendSuggestions getFriendSuggestions;

  bool _isSearching = false;
  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false;
  bool _isSendingFriendRequest = false; 
  bool _isRespondingToFriendRequest = false; 

  FriendBloc({
    required this.searchUsers,
    required this.searchAllUsers,
    required this.sendFriendRequest,
    required this.cancelFriendRequest,
    required this.respondToFriendRequest,
    required this.getFriends,
    required this.getPendingRequests,
    required this.removeFriend,
    required this.getFriendSuggestions,
  }) : super(const FriendInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<SearchAllUsersEvent>(_onSearchAllUsers);
    on<ClearSearchEvent>(_onClearSearch);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<CancelFriendRequestEvent>(_onCancelFriendRequest);
    on<RespondToFriendRequestEvent>(_onRespondToFriendRequest);
    on<LoadPendingRequestsEvent>(_onLoadPendingRequests);
    on<LoadFriendsEvent>(_onLoadFriends);
    on<RemoveFriendEvent>(_onRemoveFriend);
    on<LoadFriendSuggestionsEvent>(_onLoadFriendSuggestions);
    on<RefreshFriendsDataEvent>(_onRefreshFriendsData);
    on<ClearFriendErrorEvent>(_onClearFriendError);
    on<ResetFriendStateEvent>(_onResetFriendState);
  }


  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isSearching) {
      Logger.info('. Search already in progress, ignoring duplicate request');
      return;
    }

    _isSearching = true;

    try {
      Logger.info('. Searching users: ${event.query}');
      emit(const FriendSearchLoading());

      final result = await searchUsers(SearchUsersParams(
        query: event.query,
        page: event.page,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('. Search users failed: ${failure.message}');
          emit(FriendSearchError(
            message: failure.message,
            query: event.query,
          ));
        },
        (searchResults) {
          Logger.info('. Found ${searchResults.length} users');
          
          if (searchResults.isEmpty) {
            emit(FriendSearchEmpty(query: event.query));
          } else {
            final suggestions = (searchResults['suggestions'] as List)
                .cast<FriendSuggestionEntity>();
            final total = searchResults['total'] as int? ?? suggestions.length;
            emit(FriendSearchLoaded(
              searchResults: suggestions,
              totalResults: total,
              currentPage: event.page,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error during search', e);
      emit(FriendSearchError(
        message: 'Failed to search users: ${e.toString()}',
        query: event.query,
      ));
    } finally {
      _isSearching = false;
    }
  }

  Future<void> _onSearchAllUsers(
    SearchAllUsersEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isSearching) {
      Logger.info('. Search already in progress, ignoring duplicate request');
      return;
    }

    _isSearching = true;

    try {
      Logger.info('. Searching all users');
      emit(const FriendSearchLoading());

      final result = await searchAllUsers(SearchAllUsersParams(
        query: event.query,
        page: event.page,
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('. Search all users failed: ${failure.message}');
          emit(FriendSearchError(
            message: failure.message,
            query: event.query,
          ));
        },
        (searchResults) {
          Logger.info('. Found ${searchResults.length} users');
          
          if (searchResults.isEmpty) {
            emit(FriendSearchEmpty(query: event.query));
          } else {
            final suggestions = (searchResults['suggestions'] as List)
                .cast<FriendSuggestionEntity>();
            final total = searchResults['total'] as int? ?? suggestions.length;
            emit(FriendSearchLoaded(
              searchResults: suggestions,
              totalResults: total,
              currentPage: event.page,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error during search all users', e);
      emit(FriendSearchError(
        message: 'Failed to search all users: ${e.toString()}',
        query: event.query,
      ));
    } finally {
      _isSearching = false;
    }
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<FriendState> emit,
  ) async {
    Logger.info('🧹 Clearing search results');
    
    if (state is FriendsLoaded) {
      return;
    } else {
      add(const LoadFriendsEvent());
    }
  }


  Future<void> _onCancelFriendRequest(
    CancelFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    try {
      Logger.info('. Cancelling friend request to: ${event.userId}');
      print('. _onCancelFriendRequest - event.userId: ${event.userId}');
      print('. _onCancelFriendRequest - event.userId length: ${event.userId.length}');
      print('. _onCancelFriendRequest - event.userId isEmpty: ${event.userId.isEmpty}');

      if (event.userId.isEmpty) {
        Logger.error('. Cancel friend request failed: userId is empty');
        emit(FriendError(
          message: 'Invalid user ID for friend request cancellation',
          errorType: 'cancel_request',
        ));
        return;
      }

      FriendsLoaded? currentState;
      if (state is FriendsLoaded) {
        currentState = state as FriendsLoaded;
        final updatedSentRequests = currentState.sentRequests
            .where((request) => request.userId != event.userId)
            .toList();
        
        final updatedPendingRequests = {
          'sent': updatedSentRequests,
          'received': currentState.receivedRequests,
        };
        
        emit(FriendRequestActionLoading(
          actionType: 'cancel',
          targetUserId: event.userId,
          friends: currentState.friends,
          suggestions: currentState.suggestions,
          pendingRequests: updatedPendingRequests,
          hasMoreFriends: currentState.hasMoreFriends,
        ));
      }

      final result = await cancelFriendRequest(CancelFriendRequestParams(
        userId: event.userId,
      ));

      result.fold(
        (failure) {
          Logger.error('. Cancel friend request failed: ${failure.message}');
          
          if (state is FriendRequestActionLoading) {
            final currentState = state as FriendRequestActionLoading;
            _silentRefreshPendingRequests();
          }
          
          emit(FriendError(
            message: failure.message,
            errorType: 'cancel_request',
          ));
        },
        (success) {
          if (success) {
            Logger.info('. Friend request cancelled successfully');
            
            if (currentState != null) {
              final updatedSentRequests = currentState.sentRequests
                  .where((req) => req.userId != event.userId)
                  .toList();
              
              final updatedPendingRequests = {
                'sent': updatedSentRequests,
                'received': currentState.receivedRequests,
              };
              
              emit(FriendRequestActionSuccess(
                message: 'Friend request cancelled successfully',
                actionType: 'cancel',
                targetUserId: event.userId,
                friends: currentState.friends,
                suggestions: currentState.suggestions,
                pendingRequests: updatedPendingRequests,
                hasMoreFriends: currentState.hasMoreFriends,
              ));
              
              Future.delayed(const Duration(seconds: 2), () {
                _silentRefreshPendingRequests();
              });
            }
          } else {
            _silentRefreshPendingRequests();
            emit(const FriendError(
              message: 'Failed to cancel friend request',
              errorType: 'cancel_request',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error cancelling friend request', e);
      _silentRefreshPendingRequests();
      emit(FriendError(
        message: 'Failed to cancel friend request: ${e.toString()}',
        errorType: 'cancel_request',
      ));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isSendingFriendRequest) {
      Logger.info('📤 Friend request already in progress, ignoring duplicate request');
      return;
    }

    _isSendingFriendRequest = true;

    try {
      Logger.info('📤 Sending friend request to: ${event.userId}');

      FriendsLoaded? currentState;
      if (state is FriendsLoaded) {
        currentState = state as FriendsLoaded;
        
        final suggestionToMove = currentState.suggestions
            .where((s) => s.id == event.userId)
            .firstOrNull;
        
        if (suggestionToMove != null) {
          final newRequest = FriendRequestEntity(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            userId: suggestionToMove.id,
            username: suggestionToMove.username,
            displayName: suggestionToMove.displayName,
            selectedAvatar: suggestionToMove.selectedAvatar,
            location: suggestionToMove.location,
            createdAt: DateTime.now(),
            type: 'sent',
            mutualFriends: suggestionToMove.mutualFriends,
          );
          
          final updatedSuggestions = currentState.suggestions
              .where((s) => s.id != event.userId)
              .toList();
          
          final updatedSentRequests = [...currentState.sentRequests, newRequest];
          
          final updatedPendingRequests = {
            'sent': updatedSentRequests,
            'received': currentState.receivedRequests,
          };
          
          emit(FriendRequestActionLoading(
            actionType: 'send',
            targetUserId: event.userId,
            friends: currentState.friends,
            suggestions: updatedSuggestions,
            pendingRequests: updatedPendingRequests,
            hasMoreFriends: currentState.hasMoreFriends,
          ));
        }
      }

      final result = await sendFriendRequest(SendFriendRequestParams(
        userId: event.userId,
      ));

      result.fold(
        (failure) {
          Logger.error('. Send friend request failed: ${failure.message}');
          
          _silentRefreshData();
          
          if (failure is DuplicateFriendRequestException) {
            emit(FriendError(
              message: 'You have already sent a friend request to this user',
              errorType: 'already_sent',
            ));
          } else if (failure is FriendRequestException) {
            emit(FriendError(
              message: 'You are already friends with this user',
              errorType: 'already_friends',
            ));
          } else if (failure is RateLimitException) {
            emit(FriendError(
              message: failure.message,
              errorType: 'rate_limit',
            ));
          } else if (failure is TimeoutException) {
            emit(FriendError(
              message: failure.message,
              errorType: 'timeout',
            ));
          } else {
            emit(FriendError(
              message: failure.message,
              errorType: 'send_request',
            ));
          }
        },
        (success) {
          if (success) {
            Logger.info('. Friend request sent successfully');
            
            if (currentState != null) {
              final suggestionToMove = currentState.suggestions
                  .where((s) => s.id == event.userId)
                  .firstOrNull;
              
              if (suggestionToMove != null) {
                final newRequest = FriendRequestEntity(
                  id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  userId: suggestionToMove.id,
                  username: suggestionToMove.username,
                  displayName: suggestionToMove.displayName,
                  selectedAvatar: suggestionToMove.selectedAvatar,
                  location: suggestionToMove.location,
                  createdAt: DateTime.now(),
                  type: 'sent',
                  mutualFriends: suggestionToMove.mutualFriends,
                );
                
                final updatedSuggestions = currentState.suggestions
                    .where((s) => s.id != event.userId)
                    .toList();
                
                final updatedSentRequests = [...currentState.sentRequests, newRequest];
                
                final updatedPendingRequests = {
                  'sent': updatedSentRequests,
                  'received': currentState.receivedRequests,
                };
                
                Logger.info('🎯 Emitting FriendRequestActionSuccess for send request');
                Logger.info('. Updated suggestions count: ${updatedSuggestions.length}');
                Logger.info('. Updated sent requests count: ${updatedSentRequests.length}');
                
                emit(FriendRequestActionSuccess(
                  message: 'Friend request sent successfully!',
                  actionType: 'send',
                  targetUserId: event.userId,
                  friends: currentState.friends,
                  suggestions: updatedSuggestions,
                  pendingRequests: updatedPendingRequests,
                  hasMoreFriends: currentState.hasMoreFriends,
                ));
                
                Future.delayed(const Duration(seconds: 2), () {
                  _silentRefreshData();
                });
              }
            }
          } else {
            _silentRefreshData();
            emit(const FriendError(
              message: 'Failed to send friend request',
              errorType: 'send_request',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error sending friend request', e);
      _silentRefreshData();
      if (e is RateLimitException) {
        emit(FriendError(
          message: e.message,
          errorType: 'rate_limit',
        ));
      } else if (e is TimeoutException) {
        emit(FriendError(
          message: e.message,
          errorType: 'timeout',
        ));
      } else {
        emit(FriendError(
          message: 'Failed to send friend request: ${e.toString()}',
          errorType: 'send_request',
        ));
      }
    } finally {
      _isSendingFriendRequest = false;
    }
  }

  Future<void> _onRespondToFriendRequest(
    RespondToFriendRequestEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isRespondingToFriendRequest) {
      Logger.info('📝 Friend request response already in progress, ignoring duplicate');
      return;
    }

    _isRespondingToFriendRequest = true;

    try {
      Logger.info('📝 Responding to friend request: ${event.action}');

      if (state is FriendsLoaded) {
        final currentState = state as FriendsLoaded;
        
        if (event.action == 'accept') {
          final requestToAccept = currentState.receivedRequests
              .where((r) => r.userId == event.requestUserId)
              .firstOrNull;
          
          if (requestToAccept != null) {
            final newFriend = FriendEntity(
              id: requestToAccept.userId,
              username: requestToAccept.username,
              displayName: requestToAccept.displayName,
              selectedAvatar: requestToAccept.selectedAvatar,
              location: requestToAccept.location,
              isOnline: false,
              lastActiveAt: DateTime.now(),
              friendshipDate: DateTime.now(),
              status: 'accepted',
              mutualFriends: requestToAccept.mutualFriends,
            );
            
            final updatedReceivedRequests = currentState.receivedRequests
                .where((r) => r.userId != event.requestUserId)
                .toList();
            
            final updatedFriends = [...currentState.friends, newFriend];
            
            final updatedPendingRequests = {
              'sent': currentState.sentRequests,
              'received': updatedReceivedRequests,
            };
            
            emit(FriendRequestActionLoading(
              actionType: 'accept',
              targetUserId: event.requestUserId,
              friends: updatedFriends,
              suggestions: currentState.suggestions,
              pendingRequests: updatedPendingRequests,
              hasMoreFriends: currentState.hasMoreFriends,
            ));
          }
        } else if (event.action == 'reject') {
          final updatedReceivedRequests = currentState.receivedRequests
              .where((r) => r.userId != event.requestUserId)
              .toList();
          
          final updatedPendingRequests = {
            'sent': currentState.sentRequests,
            'received': updatedReceivedRequests,
          };
          
          emit(FriendRequestActionLoading(
            actionType: 'reject',
            targetUserId: event.requestUserId,
            friends: currentState.friends,
            suggestions: currentState.suggestions,
            pendingRequests: updatedPendingRequests,
            hasMoreFriends: currentState.hasMoreFriends,
          ));
        }
      }

      final result = await respondToFriendRequest(RespondToFriendRequestParams(
        requestUserId: event.requestUserId,
        action: event.action,
      ));

      result.fold(
        (failure) {
          Logger.error('. Respond to friend request failed: ${failure.message}');
          
          _silentRefreshData();
          
          if (failure is RateLimitException) {
            emit(FriendError(
              message: failure.message,
              errorType: 'rate_limit',
            ));
          } else if (failure is TimeoutException) {
            emit(FriendError(
              message: failure.message,
              errorType: 'timeout',
            ));
          } else {
            emit(FriendError(
              message: failure.message,
              errorType: 'respond_request',
            ));
          }
        },
        (success) {
          if (success) {
            Logger.info('. Friend request response sent successfully');
            
            _silentRefreshData();
            
            final actionMessage = event.action == 'accept' 
                ? 'Friend request accepted!' 
                : 'Friend request rejected';
                
            if (state is FriendRequestActionLoading) {
              final currentState = state as FriendRequestActionLoading;
              emit(FriendRequestActionSuccess(
                message: actionMessage,
                actionType: event.action,
                targetUserId: event.requestUserId,
                friends: currentState.friends,
                suggestions: currentState.suggestions,
                pendingRequests: currentState.pendingRequests,
                hasMoreFriends: currentState.hasMoreFriends,
              ));
            }
          } else {
            _silentRefreshData();
            emit(FriendError(
              message: 'Failed to ${event.action} friend request',
              errorType: 'respond_request',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error responding to friend request', e);
      _silentRefreshData();
      if (e is RateLimitException) {
        emit(FriendError(
          message: e.message,
          errorType: 'rate_limit',
        ));
      } else if (e is TimeoutException) {
        emit(FriendError(
          message: e.message,
          errorType: 'timeout',
        ));
      } else {
        emit(FriendError(
          message: 'Failed to respond to friend request: ${e.toString()}',
          errorType: 'respond_request',
        ));
      }
    } finally {
      _isRespondingToFriendRequest = false;
    }
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequestsEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isLoadingRequests && !event.forceRefresh) {
      Logger.info('. Pending requests already loading');
      return;
    }

    _isLoadingRequests = true;

    try {
      Logger.info('. Loading pending friend requests');

      final result = await getPendingRequests(const NoParams());

      result.fold(
        (failure) {
          Logger.error('. Load pending requests failed: ${failure.message}');
          emit(FriendError(
            message: failure.message,
            errorType: 'load_requests',
          ));
        },
        (pendingRequests) {
          Logger.info('. Loaded pending requests: ${pendingRequests['sent']?.length ?? 0} sent, ${pendingRequests['received']?.length ?? 0} received');
          
          if (state is FriendsLoaded) {
            final currentState = state as FriendsLoaded;
            emit(currentState.copyWith(
              pendingRequests: pendingRequests,
              isRefreshing: false,
            ));
          } else {
            add(const LoadFriendsEvent(forceRefresh: true));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error loading pending requests', e);
      emit(FriendError(
        message: 'Failed to load pending requests: ${e.toString()}',
        errorType: 'load_requests',
      ));
    } finally {
      _isLoadingRequests = false;
    }
  }


  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<FriendState> emit,
  ) async {
    if (_isLoadingFriends && !event.forceRefresh) {
      Logger.info('👫 Friends already loading');
      return;
    }

    _isLoadingFriends = true;

    try {
      Logger.info('👫 Loading friends list');

      if (event.page == 1) {
        emit(const FriendLoading());
      }

      final friendsResult = getFriends(GetFriendsParams(
        page: event.page,
        limit: event.limit,
      ));

      final suggestionsResult = getFriendSuggestions(const GetFriendSuggestionsParams());
      
      final requestsResult = getPendingRequests(const NoParams());

      final results = await Future.wait([
        friendsResult,
        suggestionsResult,
        requestsResult,
      ]);

      final friends = results[0];
      final suggestions = results[1];
      final requests = results[2];

      friends.fold(
        (failure) {
          Logger.error('. Load friends failed: ${failure.message}');
          emit(FriendError(
            message: failure.message,
            errorType: 'load_friends',
          ));
        },
        (friendsList) {
          suggestions.fold(
            (suggestionsFailure) {
              Logger.warning('. Load suggestions failed: ${suggestionsFailure.message}');
              _emitFriendsLoadedState(friendsList, [], {}, event, emit);
            },
            (suggestionsList) {
              requests.fold(
                (requestsFailure) {
                  Logger.warning('. Load requests failed: ${requestsFailure.message}');
                  _emitFriendsLoadedState(friendsList, suggestionsList, {}, event, emit);
                },
                (requestsMap) {
                  _emitFriendsLoadedState(friendsList, suggestionsList, requestsMap, event, emit);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error loading friends', e);
      emit(FriendError(
        message: 'Failed to load friends: ${e.toString()}',
        errorType: 'load_friends',
      ));
    } finally {
      _isLoadingFriends = false;
    }
  }

  void _emitFriendsLoadedState(
    friends,
    suggestions,
    requests,
    LoadFriendsEvent event,
    Emitter<FriendState> emit,
  ) {
    Logger.info('. Loaded friends data: ${friends.length} friends, ${suggestions.length} suggestions');
    
    emit(FriendsLoaded(
      friends: friends,
      suggestions: suggestions,
      pendingRequests: requests,
      hasMoreFriends: friends.length >= event.limit,
      isRefreshing: false,
    ));
  }

  Future<void> _onRemoveFriend(
    RemoveFriendEvent event,
    Emitter<FriendState> emit,
  ) async {
    try {
      Logger.info('🗑️ Removing friend: ${event.friendUserId}');

      if (state is FriendsLoaded) {
        final currentState = state as FriendsLoaded;
        final updatedFriends = currentState.friends
            .where((f) => f.id != event.friendUserId)
            .toList();
        
        emit(FriendRequestActionLoading(
          actionType: 'remove',
          targetUserId: event.friendUserId,
          friends: updatedFriends,
          suggestions: currentState.suggestions,
          pendingRequests: currentState.pendingRequests,
          hasMoreFriends: currentState.hasMoreFriends,
        ));
      }

      final result = await removeFriend(RemoveFriendParams(
        friendUserId: event.friendUserId,
      ));

      result.fold(
        (failure) {
          Logger.error('. Remove friend failed: ${failure.message}');
          
          _silentRefreshData();
          
          emit(FriendError(
            message: failure.message,
            errorType: 'remove_friend',
          ));
        },
        (success) {
          if (success) {
            Logger.info('. Friend removed successfully');
            
            _silentRefreshData();
            
            if (state is FriendRequestActionLoading) {
              final currentState = state as FriendRequestActionLoading;
              emit(FriendRequestActionSuccess(
                message: 'Friend removed successfully',
                actionType: 'remove',
                targetUserId: event.friendUserId,
                friends: currentState.friends,
                suggestions: currentState.suggestions,
                pendingRequests: currentState.pendingRequests,
                hasMoreFriends: currentState.hasMoreFriends,
              ));
            }
          } else {
            _silentRefreshData();
            emit(const FriendError(
              message: 'Failed to remove friend',
              errorType: 'remove_friend',
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error removing friend', e);
      _silentRefreshData();
      emit(FriendError(
        message: 'Failed to remove friend: ${e.toString()}',
        errorType: 'remove_friend',
      ));
    }
  }

  Future<void> _onLoadFriendSuggestions(
    LoadFriendSuggestionsEvent event,
    Emitter<FriendState> emit,
  ) async {
    try {
      Logger.info('💡 Loading friend suggestions');

      final result = await getFriendSuggestions(GetFriendSuggestionsParams(
        limit: event.limit,
      ));

      result.fold(
        (failure) {
          Logger.error('. Load friend suggestions failed: ${failure.message}');
          Logger.warning('. Could not load friend suggestions');
        },
        (suggestions) {
          Logger.info('. Loaded ${suggestions.length} friend suggestions');
          
          if (state is FriendsLoaded) {
            final currentState = state as FriendsLoaded;
            emit(currentState.copyWith(
              suggestions: suggestions,
              isRefreshing: false,
            ));
          }
        },
      );
    } catch (e) {
      Logger.error('. Unexpected error loading friend suggestions', e);
    }
  }


  Future<void> _onRefreshFriendsData(
    RefreshFriendsDataEvent event,
    Emitter<FriendState> emit,
  ) async {
    Logger.info('🔄 Refreshing all friends data');
    
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }
    
    add(const LoadFriendsEvent(forceRefresh: true));
  }

  Future<void> _onClearFriendError(
    ClearFriendErrorEvent event,
    Emitter<FriendState> emit,
  ) async {
    Logger.info('🧹 Clearing friend error state');
    
    add(const LoadFriendsEvent());
  }

  Future<void> _onResetFriendState(
    ResetFriendStateEvent event,
    Emitter<FriendState> emit,
  ) async {
    Logger.info('🔄 Resetting friend state to initial');
    
    _isSearching = false;
    _isLoadingFriends = false;
    _isLoadingRequests = false;
    
    emit(const FriendInitial());
  }


  void _silentRefreshPendingRequests() {
    Logger.info('🔄 Silent refresh: Pending requests');
    add(const LoadPendingRequestsEvent(forceRefresh: true));
  }

  void _silentRefreshData() {
    Logger.info('🔄 Silent refresh: All data');
    add(const LoadFriendsEvent(forceRefresh: true));
  }


  FriendRequestStatus getFriendRequestStatus(String userId) {
    Logger.info('. getFriendRequestStatus called for userId: $userId');
    Logger.info('. Current state type: ${state.runtimeType}');
    
    if (state is FriendRequestActionLoading) {
      final loadingState = state as FriendRequestActionLoading;
      if (loadingState.targetUserId == userId) {
        Logger.info('. Returning sending status for userId: $userId');
        return FriendRequestStatus.sending;
      }
    }

    if (state is FriendRequestActionSuccess) {
      final successState = state as FriendRequestActionSuccess;
      Logger.info('. Success state - actionType: ${successState.actionType}, targetUserId: ${successState.targetUserId}');
      if (successState.targetUserId == userId) {
        switch (successState.actionType) {
          case 'send':
            Logger.info('. Returning requested status for userId: $userId');
            return FriendRequestStatus.requested;
          case 'accept':
            Logger.info('. Returning accepted status for userId: $userId');
            return FriendRequestStatus.accepted;
          case 'cancel':
            Logger.info('. Returning notRequested status for userId: $userId');
            return FriendRequestStatus.notRequested;
          case 'reject':
            Logger.info('. Returning notRequested status for userId: $userId');
            return FriendRequestStatus.notRequested;
          case 'remove':
            Logger.info('. Returning notRequested status for userId: $userId');
            return FriendRequestStatus.notRequested;
        }
      }
    }

    if (state is FriendError) {
      final errorState = state as FriendError;
      if (errorState.errorType == 'send_request' || 
          errorState.errorType == 'cancel_request' ||
          errorState.errorType == 'respond_request' ||
          errorState.errorType == 'remove_friend') {
        return FriendRequestStatus.error;
      }
    }

    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      Logger.info('. FriendsLoaded state - friends: ${currentState.friends.length}, suggestions: ${currentState.suggestions.length}, sentRequests: ${currentState.sentRequests.length}');

      if (currentState.friends.any((f) => f.id == userId)) {
        Logger.info('. User $userId is already a friend');
        return FriendRequestStatus.friends;
      }

      if (currentState.sentRequests.any((req) => req.userId == userId)) {
        Logger.info('. User $userId has a sent request');
        return FriendRequestStatus.requested;
      }

      if (currentState.receivedRequests.any((req) => req.userId == userId)) {
        Logger.info('. User $userId has a received request');
        return FriendRequestStatus.requested;
      }
      
      Logger.info('. User $userId has no pending requests');
    }

    return FriendRequestStatus.notRequested;
  }


  int getFriendsCount() {
    if (state is FriendsLoaded) {
      return (state as FriendsLoaded).totalFriends;
    }
    return 0;
  }

  int getPendingRequestsCount() {
    if (state is FriendsLoaded) {
      return (state as FriendsLoaded).totalPendingRequests;
    }
    return 0;
  }

  bool isUserFriend(String userId) {
    if (state is FriendsLoaded) {
      final friendsState = state as FriendsLoaded;
      return friendsState.friends.any((friend) => friend.id == userId);
    }
    return false;
  }

  bool isFriendRequestPending(String userId) {
    if (state is FriendsLoaded) {
      final friendsState = state as FriendsLoaded;
      return friendsState.sentRequests.any((request) => request.userId == userId) ||
             friendsState.receivedRequests.any((request) => request.userId == userId);
    }
    return false;
  }

  @override
  void onTransition(Transition<FriendEvent, FriendState> transition) {
    super.onTransition(transition);
    Logger.info(
      '👫 Friend BLoC Transition: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.error('👫 Friend BLoC Error: $error', error, stackTrace);
  }

  @override
  Future<void> close() {
    _isSearching = false;
    _isLoadingFriends = false;
    _isLoadingRequests = false;
    return super.close();
  }
} 