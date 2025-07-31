import 'package:dartz/dartz.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';

import '../entity/friend_entity.dart';

abstract class FriendRepository {
  Future<Either<Failure, Map<String, dynamic>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Map<String, dynamic>>> searchAllUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, bool>> sendFriendRequest({
    required String userId,
  });

  Future<Either<Failure, bool>> respondToFriendRequest({
    required String requestUserId,
required String action, 
  });

  Future<Either<Failure, List<FriendEntity>>> getFriends({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Map<String, List<FriendRequestEntity>>>> getPendingRequests();

  Future<Either<Failure, bool>> cancelFriendRequest({
    required String userId,
  });

  Future<Either<Failure, bool>> removeFriend({
    required String friendUserId,
  });

  Future<Either<Failure, List<FriendSuggestionEntity>>> getFriendSuggestions({
    int limit = 10,
  });
} 