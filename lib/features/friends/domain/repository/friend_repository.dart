// lib/features/friends/domain/repository/friend_repository.dart

import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_insights_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/emotion_story_entity.dart';

abstract class FriendRepository {
  // ============================================================================
  // EXISTING METHODS
  // ============================================================================

  /// Get friends list
  Future<List<FriendEntity>> getFriendsList({int page = 1, int limit = 20});

  /// Get friend suggestions
  Future<List<FriendEntity>> getFriendSuggestions({int limit = 10});

  /// Search users
  Future<List<FriendEntity>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  /// Search all users globally (including friends, excluding self)
  Future<List<FriendEntity>> searchAllUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  /// Send friend request
  Future<void> sendFriendRequest({
    required String recipientId,
    String? message,
  });

  /// Accept friend request
  Future<void> acceptFriendRequest({required String requestUserId});

  /// Decline friend request
  Future<void> declineFriendRequest({required String requestUserId});

  /// Cancel sent friend request
  Future<void> cancelFriendRequest({required String userId});

  /// Remove friend
  Future<void> removeFriend({required String friendId});

  // ============================================================================
  // ENHANCED FRIEND MOOD ACTIVITY METHODS
  // ============================================================================

  /// Get friend's moods with reactions
  Future<List<FriendMoodEntity>> getFriendMoods({
    required String friendId,
    int limit = 10,
    bool includeReactions = true,
  });

  /// Get friend mood activity feed
  Future<List<FriendMoodEntity>> getFriendMoodActivityFeed({
    int page = 1,
    int limit = 20,
  });

  /// Send mood reaction (hug, music, message, anonymous support)
  Future<void> sendMoodReaction({
    required String moodId,
    required String reactionType,
    String? message,
    bool isAnonymous = false,
  });

  /// Get friend mood insights and patterns
  Future<FriendMoodInsightsEntity> getFriendMoodInsights({
    required String friendId,
    int days = 30,
  });

  // ============================================================================
  // EMOTION STORY SHARING METHODS
  // ============================================================================

  /// Create emotion story
  Future<EmotionStoryEntity> createEmotionStory({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String privacy = 'friends',
    List<String>? tags,
    Map<String, dynamic>? settings,
  });

  /// Get user's emotion stories
  Future<List<EmotionStoryEntity>> getEmotionStories({
    int page = 1,
    int limit = 10,
    String status = 'all',
  });

  /// Invite friends to emotion story
  Future<void> inviteToEmotionStory({
    required String storyId,
    required List<String> friendIds,
  });

  /// Respond to emotion story invitation
  Future<void> respondToEmotionStoryInvitation({
    required String storyId,
    required String action, // 'accept' or 'decline'
  });

  /// Add contribution to emotion story
  Future<void> addEmotionStoryContribution({
    required String storyId,
    required String emotion,
    required int intensity,
    String? message,
    bool isAnonymous = false,
    Map<String, dynamic>? context,
    List<String>? tags,
    Map<String, dynamic>? media,
  });

  /// Get emotion story contributions
  Future<List<StoryContributionEntity>> getEmotionStoryContributions({
    required String storyId,
    int page = 1,
    int limit = 20,
  });
} 