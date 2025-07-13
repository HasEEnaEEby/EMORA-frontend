import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/friend_entity.dart';
import '../../domain/repository/friend_repository.dart';
import '../data_source/remote/friend_remote_data_source.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FriendRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FriendSuggestionEntity>>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Logger.info('🔍 Searching users: $query');

      if (await networkInfo.isConnected) {
        final users = await remoteDataSource.searchUsers(
          query: query,
          page: page,
          limit: limit,
        );

        final entities = users.map((user) => user.toEntity()).toList();
        Logger.info('✅ Found ${entities.length} users');
        return Right(entities);
      } else {
        Logger.warning('⚠️ No network connection for user search');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error searching users', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error searching users', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('📤 Sending friend request to: $userId');

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.sendFriendRequest(
          userId: userId,
        );

        Logger.info('✅ Friend request result: $success');
        return Right(success);
      } else {
        Logger.warning('⚠️ No network connection for sending friend request');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error sending friend request', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error sending friend request', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> respondToFriendRequest({
    required String requestUserId,
    required String action,
  }) async {
    try {
      Logger.info('📝 Responding to friend request: $action');

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.respondToFriendRequest(
          requestUserId: requestUserId,
          action: action,
        );

        Logger.info('✅ Friend request response result: $success');
        return Right(success);
      } else {
        Logger.warning('⚠️ No network connection for responding to friend request');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error responding to friend request', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error responding to friend request', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FriendEntity>>> getFriends({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('👫 Fetching friends list');

      if (await networkInfo.isConnected) {
        final friends = await remoteDataSource.getFriends(
          page: page,
          limit: limit,
        );

        final entities = friends.map((friend) => friend.toEntity()).toList();
        Logger.info('✅ Found ${entities.length} friends');
        return Right(entities);
      } else {
        Logger.warning('⚠️ No network connection for fetching friends');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error fetching friends', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error fetching friends', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<FriendRequestEntity>>>> getPendingRequests() async {
    try {
      Logger.info('📋 Fetching pending friend requests');

      if (await networkInfo.isConnected) {
        final requests = await remoteDataSource.getPendingRequests();

        final result = <String, List<FriendRequestEntity>>{};
        
        // Filter out invalid requests and log any issues
        final validSentRequests = <FriendRequestEntity>[];
        final validReceivedRequests = <FriendRequestEntity>[];
        
        for (final req in requests['sent'] ?? []) {
          try {
            final entity = req.toEntity();
            if (entity.userId.isNotEmpty) {
              validSentRequests.add(entity);
            } else {
              Logger.warning('⚠️ Filtered out sent request with empty userId: ${req.id}');
            }
          } catch (e) {
            Logger.warning('⚠️ Filtered out invalid sent request: ${req.id}, error: $e');
          }
        }
        
        for (final req in requests['received'] ?? []) {
          try {
            final entity = req.toEntity();
            if (entity.userId.isNotEmpty) {
              validReceivedRequests.add(entity);
            } else {
              Logger.warning('⚠️ Filtered out received request with empty userId: ${req.id}');
            }
          } catch (e) {
            Logger.warning('⚠️ Filtered out invalid received request: ${req.id}, error: $e');
          }
        }
        
        result['sent'] = validSentRequests;
        result['received'] = validReceivedRequests;

        Logger.info('✅ Found ${result['sent']!.length} sent, ${result['received']!.length} received requests');
        return Right(result);
      } else {
        Logger.warning('⚠️ No network connection for fetching pending requests');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error fetching pending requests', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error fetching pending requests', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelFriendRequest({
    required String userId,
  }) async {
    try {
      Logger.info('❌ Cancelling friend request to: $userId');

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.cancelFriendRequest(
          userId: userId,
        );

        Logger.info('✅ Friend request cancellation result: $success');
        return Right(success);
      } else {
        Logger.warning('⚠️ No network connection for cancelling friend request');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error cancelling friend request', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error cancelling friend request', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFriend({
    required String friendUserId,
  }) async {
    try {
      Logger.info('🗑️ Removing friend: $friendUserId');

      if (await networkInfo.isConnected) {
        final success = await remoteDataSource.removeFriend(
          friendUserId: friendUserId,
        );

        Logger.info('✅ Friend removal result: $success');
        return Right(success);
      } else {
        Logger.warning('⚠️ No network connection for removing friend');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error removing friend', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error removing friend', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FriendSuggestionEntity>>> getFriendSuggestions({
    int limit = 10,
  }) async {
    try {
      Logger.info('💡 Fetching friend suggestions');

      if (await networkInfo.isConnected) {
        final suggestions = await remoteDataSource.getFriendSuggestions(
          limit: limit,
        );

        final entities = suggestions.map((suggestion) => suggestion.toEntity()).toList();
        Logger.info('✅ Found ${entities.length} friend suggestions');
        return Right(entities);
      } else {
        Logger.warning('⚠️ No network connection for fetching friend suggestions');
        return Left(
          NetworkFailure(
            message: 'No internet connection. Please check your network.',
          ),
        );
      }
    } on ServerException catch (e) {
      Logger.error('❌ Server error fetching friend suggestions', e);
      return Left(ServerFailure(message: e.message));
    } on NotFoundException catch (e) {
      Logger.error('❌ Endpoint not found', e);
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Unauthorized request', e);
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      Logger.error('❌ Unexpected error fetching friend suggestions', e);
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
} 