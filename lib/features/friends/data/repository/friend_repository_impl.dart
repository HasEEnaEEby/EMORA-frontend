// lib/features/friends/data/repository/friend_repository_impl.dart
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/friends/data/data_source/remote/friend_remote_data_source.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_insights_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/emotion_story_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/repository/friend_repository.dart';
import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendRemoteDataSource _remoteDataSource;

  FriendRepositoryImpl({required FriendRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  // ============================================================================
  // EXISTING METHODS
  // ============================================================================

  @override
  Future<List<FriendEntity>> getFriendsList({int page = 1, int limit = 20}) async {
    try {
      Logger.info('📋 Repository: Getting friends list');
      
      final response = await _remoteDataSource.getFriendsList(
        page: page,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final friendsData = response['data']['friends'] as List;
        final friends = friendsData
            .map((friend) => FriendEntity.fromJson(friend))
            .toList();

        Logger.info('✅ Repository: Friends list retrieved successfully (${friends.length} friends)');
        return friends;
      } else {
        Logger.error('❌ Repository: Failed to get friends list - Invalid response format');
        throw ServerFailure(message: 'Failed to get friends list');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting friends list', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting friends list', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting friends list', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting friends list', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<FriendEntity>> getFriendSuggestions({int limit = 10}) async {
    try {
      Logger.info('💡 Repository: Getting friend suggestions');
      
      final response = await _remoteDataSource.getFriendSuggestions(limit: limit);

      if (response['success'] == true && response['data'] != null) {
        final suggestionsData = response['data']['suggestions'] as List;
        final suggestions = suggestionsData
            .map((suggestion) => FriendEntity.fromJson(suggestion))
            .toList();

        Logger.info('✅ Repository: Friend suggestions retrieved successfully (${suggestions.length} suggestions)');
        return suggestions;
      } else {
        Logger.error('❌ Repository: Failed to get friend suggestions - Invalid response format');
        throw ServerFailure(message: 'Failed to get friend suggestions');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting friend suggestions', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting friend suggestions', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting friend suggestions', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting friend suggestions', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<FriendEntity>> searchUsers({required String query, int page = 1, int limit = 10}) async {
    try {
      Logger.info('🔍 Repository: Searching users with query: "$query"');
      
      final response = await _remoteDataSource.searchUsers(
        query: query,
        page: page,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final usersData = response['data']['users'] as List;
        final users = usersData
            .map((user) => FriendEntity.fromJson(user))
            .toList();

        Logger.info('✅ Repository: User search completed successfully (${users.length} users found)');
        return users;
      } else {
        Logger.error('❌ Repository: Failed to search users - Invalid response format');
        throw ServerFailure(message: 'Failed to search users');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while searching users', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while searching users', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while searching users', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while searching users', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<FriendEntity>> searchAllUsers({required String query, int page = 1, int limit = 10}) async {
    try {
      Logger.info('🔍 Repository: Searching all users with query: "$query"');
      
      final response = await _remoteDataSource.searchAllUsers(
        query: query,
        page: page,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final usersData = response['data']['users'] as List;
        final users = <FriendEntity>[];
        
        for (final userData in usersData) {
          try {
            // Create a FriendEntity with safe defaults for missing fields
            final user = FriendEntity(
              id: userData['id']?.toString() ?? '',
              username: userData['username']?.toString() ?? '',
              displayName: userData['displayName']?.toString() ?? userData['username']?.toString() ?? '',
              selectedAvatar: userData['selectedAvatar']?.toString() ?? 'panda',
              location: _parseLocation(userData['location']),
              isOnline: userData['isOnline'] ?? false,
              lastActiveAt: null, // Not provided in search results
              friendshipDate: DateTime.now(), // Default for search results
              status: 'none', // Default for search results
              mutualFriends: 0, // Default for search results
              recentMood: null, // Not provided in search results
            );
            users.add(user);
          } catch (e) {
            Logger.warning('⚠️ Repository: Failed to parse user data: $e');
            Logger.warning('⚠️ Repository: User data: $userData');
            // Continue with next user instead of failing completely
            continue;
          }
        }

        Logger.info('✅ Repository: Global user search completed successfully (${users.length} users found)');
        return users;
      } else {
        Logger.error('❌ Repository: Failed to search all users - Invalid response format');
        throw ServerFailure(message: 'Failed to search all users');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while searching all users', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while searching all users', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while searching all users', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while searching all users', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  // Helper method for parsing location
  String? _parseLocation(dynamic location) {
    if (location == null) return null;
    if (location is String) return location;
    if (location is Map<String, dynamic>) {
      return location['name']?.toString() ?? 
             location['city']?.toString() ?? 
             location['country']?.toString();
    }
    return null;
  }

  @override
  Future<void> sendFriendRequest({required String recipientId, String? message}) async {
    try {
      Logger.info('📤 Repository: Sending friend request to: $recipientId');
      
      final response = await _remoteDataSource.sendFriendRequest(
        recipientId: recipientId,
        message: message,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friend request sent successfully');
      } else {
        Logger.error('❌ Repository: Failed to send friend request - Invalid response format');
        throw ServerFailure(message: 'Failed to send friend request');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while sending friend request', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while sending friend request', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while sending friend request', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while sending friend request', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> acceptFriendRequest({required String requestUserId}) async {
    try {
      Logger.info('✅ Repository: Accepting friend request from: $requestUserId');
      
      final response = await _remoteDataSource.acceptFriendRequest(
        requestUserId: requestUserId,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friend request accepted successfully');
      } else {
        Logger.error('❌ Repository: Failed to accept friend request - Invalid response format');
        throw ServerFailure(message: 'Failed to accept friend request');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while accepting friend request', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while accepting friend request', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while accepting friend request', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while accepting friend request', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> declineFriendRequest({required String requestUserId}) async {
    try {
      Logger.info('❌ Repository: Declining friend request from: $requestUserId');
      
      final response = await _remoteDataSource.declineFriendRequest(
        requestUserId: requestUserId,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friend request declined successfully');
      } else {
        Logger.error('❌ Repository: Failed to decline friend request - Invalid response format');
        throw ServerFailure(message: 'Failed to decline friend request');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while declining friend request', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while declining friend request', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while declining friend request', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while declining friend request', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> cancelFriendRequest({required String userId}) async {
    try {
      Logger.info('🚫 Repository: Cancelling friend request to: $userId');
      
      final response = await _remoteDataSource.cancelFriendRequest(userId: userId);

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friend request cancelled successfully');
      } else {
        Logger.error('❌ Repository: Failed to cancel friend request - Invalid response format');
        throw ServerFailure(message: 'Failed to cancel friend request');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while cancelling friend request', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while cancelling friend request', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while cancelling friend request', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while cancelling friend request', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> removeFriend({required String friendId}) async {
    try {
      Logger.info('🗑️ Repository: Removing friend: $friendId');
      
      final response = await _remoteDataSource.removeFriend(friendId: friendId);

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friend removed successfully');
      } else {
        Logger.error('❌ Repository: Failed to remove friend - Invalid response format');
        throw ServerFailure(message: 'Failed to remove friend');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while removing friend', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while removing friend', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while removing friend', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while removing friend', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  // ============================================================================
  // ENHANCED FRIEND MOOD ACTIVITY METHODS
  // ============================================================================

  @override
  Future<List<FriendMoodEntity>> getFriendMoods({
    required String friendId,
    int limit = 10,
    bool includeReactions = true,
  }) async {
    try {
      Logger.info('😊 Repository: Getting moods for friend: $friendId');
      
      final response = await _remoteDataSource.getFriendMoods(
        friendId: friendId,
        limit: limit,
        includeReactions: includeReactions,
      );

      if (response['success'] == true && response['data'] != null) {
        final moodsData = response['data']['moods'] as List;
        final moods = moodsData
            .map((mood) => FriendMoodEntity.fromJson(mood))
            .toList();

        Logger.info('✅ Repository: Friend moods retrieved successfully (${moods.length} moods)');
        return moods;
      } else {
        Logger.error('❌ Repository: Failed to get friend moods - Invalid response format');
        throw ServerFailure(message: 'Failed to get friend moods');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting friend moods', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting friend moods', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting friend moods', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting friend moods', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<FriendMoodEntity>> getFriendMoodActivityFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('📰 Repository: Getting friend mood activity feed');
      
      final response = await _remoteDataSource.getFriendMoodActivityFeed(
        page: page,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final activitiesData = response['data']['activities'] as List;
        final activities = activitiesData
            .where((activity) => activity['type'] == 'mood')
            .map((activity) => FriendMoodEntity.fromJson(activity))
            .toList();

        Logger.info('✅ Repository: Friend mood activity feed retrieved successfully (${activities.length} activities)');
        return activities;
      } else {
        Logger.error('❌ Repository: Failed to get friend mood activity feed - Invalid response format');
        throw ServerFailure(message: 'Failed to get friend mood activity feed');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting friend mood activity feed', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting friend mood activity feed', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting friend mood activity feed', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting friend mood activity feed', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> sendMoodReaction({
    required String moodId,
    required String reactionType,
    String? message,
    bool isAnonymous = false,
  }) async {
    try {
      Logger.info('💝 Repository: Sending $reactionType reaction to mood: $moodId');
      
      final response = await _remoteDataSource.sendMoodReaction(
        moodId: moodId,
        reactionType: reactionType,
        message: message,
        isAnonymous: isAnonymous,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Mood reaction sent successfully');
      } else {
        Logger.error('❌ Repository: Failed to send mood reaction - Invalid response format');
        throw ServerFailure(message: 'Failed to send mood reaction');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while sending mood reaction', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while sending mood reaction', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while sending mood reaction', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while sending mood reaction', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<FriendMoodInsightsEntity> getFriendMoodInsights({
    required String friendId,
    int days = 30,
  }) async {
    try {
      Logger.info('🧠 Repository: Getting mood insights for friend: $friendId');
      
      final response = await _remoteDataSource.getFriendMoodInsights(
        friendId: friendId,
        days: days,
      );

      if (response['success'] == true && response['data'] != null) {
        final insights = FriendMoodInsightsEntity.fromJson(response['data']);

        Logger.info('✅ Repository: Friend mood insights retrieved successfully');
        return insights;
      } else {
        Logger.error('❌ Repository: Failed to get friend mood insights - Invalid response format');
        throw ServerFailure(message: 'Failed to get friend mood insights');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting friend mood insights', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting friend mood insights', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting friend mood insights', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting friend mood insights', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  // ============================================================================
  // EMOTION STORY SHARING METHODS
  // ============================================================================

  @override
  Future<EmotionStoryEntity> createEmotionStory({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String privacy = 'friends',
    List<String>? tags,
    Map<String, dynamic>? settings,
  }) async {
    try {
      Logger.info('📖 Repository: Creating emotion story: $title');
      
      final response = await _remoteDataSource.createEmotionStory(
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        privacy: privacy,
        tags: tags,
        settings: settings,
      );

      if (response['success'] == true && response['data'] != null) {
        final story = EmotionStoryEntity.fromJson(response['data']['story']);

        Logger.info('✅ Repository: Emotion story created successfully');
        return story;
      } else {
        Logger.error('❌ Repository: Failed to create emotion story - Invalid response format');
        throw ServerFailure(message: 'Failed to create emotion story');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while creating emotion story', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while creating emotion story', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while creating emotion story', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while creating emotion story', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<EmotionStoryEntity>> getEmotionStories({
    int page = 1,
    int limit = 10,
    String status = 'all',
  }) async {
    try {
      Logger.info('📚 Repository: Getting emotion stories');
      
      final response = await _remoteDataSource.getEmotionStories(
        page: page,
        limit: limit,
        status: status,
      );

      if (response['success'] == true && response['data'] != null) {
        final storiesData = response['data']['stories'] as List;
        final stories = storiesData
            .map((story) => EmotionStoryEntity.fromJson(story))
            .toList();

        Logger.info('✅ Repository: Emotion stories retrieved successfully (${stories.length} stories)');
        return stories;
      } else {
        Logger.error('❌ Repository: Failed to get emotion stories - Invalid response format');
        throw ServerFailure(message: 'Failed to get emotion stories');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting emotion stories', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting emotion stories', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting emotion stories', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting emotion stories', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> inviteToEmotionStory({
    required String storyId,
    required List<String> friendIds,
  }) async {
    try {
      Logger.info('📨 Repository: Inviting friends to emotion story: $storyId');
      
      final response = await _remoteDataSource.inviteToEmotionStory(
        storyId: storyId,
        friendIds: friendIds,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Friends invited to emotion story successfully');
      } else {
        Logger.error('❌ Repository: Failed to invite to emotion story - Invalid response format');
        throw ServerFailure(message: 'Failed to invite to emotion story');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while inviting to emotion story', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while inviting to emotion story', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while inviting to emotion story', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while inviting to emotion story', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> respondToEmotionStoryInvitation({
    required String storyId,
    required String action,
  }) async {
    try {
      Logger.info('📝 Repository: Responding to emotion story invitation: $storyId ($action)');
      
      final response = await _remoteDataSource.respondToEmotionStoryInvitation(
        storyId: storyId,
        action: action,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Emotion story invitation response sent successfully');
      } else {
        Logger.error('❌ Repository: Failed to respond to emotion story invitation - Invalid response format');
        throw ServerFailure(message: 'Failed to respond to emotion story invitation');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while responding to emotion story invitation', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while responding to emotion story invitation', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while responding to emotion story invitation', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while responding to emotion story invitation', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> addEmotionStoryContribution({
    required String storyId,
    required String emotion,
    required int intensity,
    String? message,
    bool isAnonymous = false,
    Map<String, dynamic>? context,
    List<String>? tags,
    Map<String, dynamic>? media,
  }) async {
    try {
      Logger.info('✍️ Repository: Adding contribution to emotion story: $storyId');
      
      final response = await _remoteDataSource.addEmotionStoryContribution(
        storyId: storyId,
        emotion: emotion,
        intensity: intensity,
        message: message,
        isAnonymous: isAnonymous,
        context: context,
        tags: tags,
        media: media,
      );

      if (response['success'] == true) {
        Logger.info('✅ Repository: Emotion story contribution added successfully');
      } else {
        Logger.error('❌ Repository: Failed to add emotion story contribution - Invalid response format');
        throw ServerFailure(message: 'Failed to add emotion story contribution');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while adding emotion story contribution', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while adding emotion story contribution', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while adding emotion story contribution', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while adding emotion story contribution', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<List<StoryContributionEntity>> getEmotionStoryContributions({
    required String storyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Logger.info('📖 Repository: Getting contributions for emotion story: $storyId');
      
      final response = await _remoteDataSource.getEmotionStoryContributions(
        storyId: storyId,
        page: page,
        limit: limit,
      );

      if (response['success'] == true && response['data'] != null) {
        final contributionsData = response['data']['contributions'] as List;
        final contributions = contributionsData
            .map((contribution) => StoryContributionEntity.fromJson(contribution))
            .toList();

        Logger.info('✅ Repository: Emotion story contributions retrieved successfully (${contributions.length} contributions)');
        return contributions;
      } else {
        Logger.error('❌ Repository: Failed to get emotion story contributions - Invalid response format');
        throw ServerFailure(message: 'Failed to get emotion story contributions');
      }
    } on ServerException catch (e) {
      Logger.error('❌ Repository: Server exception while getting emotion story contributions', e);
      throw ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      Logger.error('❌ Repository: Network exception while getting emotion story contributions', e);
      throw NetworkFailure(message: e.message);
    } on ValidationException catch (e) {
      Logger.error('❌ Repository: Validation exception while getting emotion story contributions', e);
      throw ValidationFailure(message: e.message);
    } catch (e) {
      Logger.error('❌ Repository: Unexpected error while getting emotion story contributions', e);
      throw ServerFailure(message: 'Unexpected error occurred');
    }
  }
} 