import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';

import '../entity/friend_entity.dart';
import '../repository/friend_repository.dart';

// ============================================================================
// SEARCH USERS USE CASE
// ============================================================================
class SearchUsersParams {
  final String query;
  final int page;
  final int limit;

  const SearchUsersParams({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });
}

class SearchUsers implements UseCase<Map<String, dynamic>, SearchUsersParams> {
  final FriendRepository repository;

  SearchUsers(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(SearchUsersParams params) async {
    return await repository.searchUsers(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// SEARCH ALL USERS USE CASE
// ============================================================================
class SearchAllUsersParams {
  final String query;
  final int page;
  final int limit;

  const SearchAllUsersParams({
    required this.query,
    this.page = 1,
    this.limit = 10,
  });
}

class SearchAllUsers implements UseCase<Map<String, dynamic>, SearchAllUsersParams> {
  final FriendRepository repository;

  SearchAllUsers(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(SearchAllUsersParams params) async {
    return await repository.searchAllUsers(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// SEND FRIEND REQUEST USE CASE
// ============================================================================
class SendFriendRequestParams {
  final String userId;

  const SendFriendRequestParams({required this.userId});
}

class SendFriendRequest implements UseCase<bool, SendFriendRequestParams> {
  final FriendRepository repository;

  SendFriendRequest(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendFriendRequestParams params) async {
    return await repository.sendFriendRequest(userId: params.userId);
  }
}

// ============================================================================
// RESPOND TO FRIEND REQUEST USE CASE
// ============================================================================
class RespondToFriendRequestParams {
  final String requestUserId;
  final String action; // 'accept' or 'reject'

  const RespondToFriendRequestParams({
    required this.requestUserId,
    required this.action,
  });
}

class RespondToFriendRequest implements UseCase<bool, RespondToFriendRequestParams> {
  final FriendRepository repository;

  RespondToFriendRequest(this.repository);

  @override
  Future<Either<Failure, bool>> call(RespondToFriendRequestParams params) async {
    return await repository.respondToFriendRequest(
      requestUserId: params.requestUserId,
      action: params.action,
    );
  }
}

// ============================================================================
// GET FRIENDS USE CASE
// ============================================================================
class GetFriendsParams {
  final int page;
  final int limit;

  const GetFriendsParams({
    this.page = 1,
    this.limit = 20,
  });
}

class GetFriends implements UseCase<List<FriendEntity>, GetFriendsParams> {
  final FriendRepository repository;

  GetFriends(this.repository);

  @override
  Future<Either<Failure, List<FriendEntity>>> call(GetFriendsParams params) async {
    return await repository.getFriends(
      page: params.page,
      limit: params.limit,
    );
  }
}

// ============================================================================
// GET PENDING REQUESTS USE CASE
// ============================================================================
class GetPendingRequests implements UseCase<Map<String, List<FriendRequestEntity>>, NoParams> {
  final FriendRepository repository;

  GetPendingRequests(this.repository);

  @override
  Future<Either<Failure, Map<String, List<FriendRequestEntity>>>> call(NoParams params) async {
    return await repository.getPendingRequests();
  }
}

// ============================================================================
// REMOVE FRIEND USE CASE
// ============================================================================
class RemoveFriendParams {
  final String friendUserId;

  const RemoveFriendParams({required this.friendUserId});
}

class RemoveFriend implements UseCase<bool, RemoveFriendParams> {
  final FriendRepository repository;

  RemoveFriend(this.repository);

  @override
  Future<Either<Failure, bool>> call(RemoveFriendParams params) async {
    return await repository.removeFriend(friendUserId: params.friendUserId);
  }
}

// ============================================================================
// CANCEL FRIEND REQUEST USE CASE
// ============================================================================
class CancelFriendRequestParams {
  final String userId;

  const CancelFriendRequestParams({required this.userId});
}

class CancelFriendRequest implements UseCase<bool, CancelFriendRequestParams> {
  final FriendRepository repository;

  CancelFriendRequest(this.repository);

  @override
  Future<Either<Failure, bool>> call(CancelFriendRequestParams params) async {
    return await repository.cancelFriendRequest(userId: params.userId);
  }
}

// ============================================================================
// GET FRIEND SUGGESTIONS USE CASE
// ============================================================================
class GetFriendSuggestionsParams {
  final int limit;

  const GetFriendSuggestionsParams({this.limit = 10});
}

class GetFriendSuggestions implements UseCase<List<FriendSuggestionEntity>, GetFriendSuggestionsParams> {
  final FriendRepository repository;

  GetFriendSuggestions(this.repository);

  @override
  Future<Either<Failure, List<FriendSuggestionEntity>>> call(GetFriendSuggestionsParams params) async {
    return await repository.getFriendSuggestions(limit: params.limit);
  }
} 