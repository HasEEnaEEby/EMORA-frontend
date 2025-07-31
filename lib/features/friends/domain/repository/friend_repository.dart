
import 'package:emora_mobile_app/features/home/domain/entity/friend_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_insights_entity.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/emotion_story_entity.dart';

abstract class FriendRepository {

  Future<List<FriendEntity>> getFriendsList({int page = 1, int limit = 20});

  Future<List<FriendEntity>> getFriendSuggestions({int limit = 10});

  Future<List<FriendEntity>> searchUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<List<FriendEntity>> searchAllUsers({
    required String query,
    int page = 1,
    int limit = 10,
  });

  Future<void> sendFriendRequest({
    required String recipientId,
    String? message,
  });

  Future<void> acceptFriendRequest({required String requestUserId});

  Future<void> declineFriendRequest({required String requestUserId});

  Future<void> cancelFriendRequest({required String userId});

  Future<void> removeFriend({required String friendId});


  Future<List<FriendMoodEntity>> getFriendMoods({
    required String friendId,
    int limit = 10,
    bool includeReactions = true,
  });

  Future<List<FriendMoodEntity>> getFriendMoodActivityFeed({
    int page = 1,
    int limit = 20,
  });

  Future<void> sendMoodReaction({
    required String moodId,
    required String reactionType,
    String? message,
    bool isAnonymous = false,
  });

  Future<FriendMoodInsightsEntity> getFriendMoodInsights({
    required String friendId,
    int days = 30,
  });


  Future<EmotionStoryEntity> createEmotionStory({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String privacy = 'friends',
    List<String>? tags,
    Map<String, dynamic>? settings,
  });

  Future<List<EmotionStoryEntity>> getEmotionStories({
    int page = 1,
    int limit = 10,
    String status = 'all',
  });

  Future<void> inviteToEmotionStory({
    required String storyId,
    required List<String> friendIds,
  });

  Future<void> respondToEmotionStoryInvitation({
    required String storyId,
required String action, 
  });

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

  Future<List<StoryContributionEntity>> getEmotionStoryContributions({
    required String storyId,
    int page = 1,
    int limit = 20,
  });
} 