import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/friend_entity.dart';

abstract class FriendRepository {
  // Search users for friend suggestions
  Future<Either<Failure, List<FriendSuggestionEntity>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  // Send friend request
  Future<Either<Failure, bool>> sendFriendRequest({
    required String userId,
  });

  // Respond to friend request (accept/reject)
  Future<Either<Failure, bool>> respondToFriendRequest({
    required String requestUserId,
    required String action, // 'accept' or 'reject'
  });

  // Get friends list
  Future<Either<Failure, List<FriendEntity>>> getFriends({
    int page = 1,
    int limit = 20,
  });

  // Get pending friend requests (sent and received)
  Future<Either<Failure, Map<String, List<FriendRequestEntity>>>> getPendingRequests();

  // Cancel sent friend request
  Future<Either<Failure, bool>> cancelFriendRequest({
    required String userId,
  });

  // Remove friend
  Future<Either<Failure, bool>> removeFriend({
    required String friendUserId,
  });

  // Get friend suggestions based on mutual friends
  Future<Either<Failure, List<FriendSuggestionEntity>>> getFriendSuggestions({
    int limit = 10,
  });
} 