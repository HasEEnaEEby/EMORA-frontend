// ============================================================================
// FRIENDS TAB CONTENT - components/friends_tab_content.dart
// ============================================================================

import 'package:emora_mobile_app/core/utils/friends_utils.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/friends_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entity/community_entity.dart';
import '../../../../domain/entity/friend_entity.dart';
import '../../../view_model/bloc/community_bloc.dart';
import '../../../view_model/bloc/community_state.dart';
import '../../../view_model/bloc/friend_bloc.dart';
import '../../../view_model/bloc/friend_state.dart';
import '../../../widget/enhanced_friend_request_button.dart' hide FriendRequestStatus, EnhancedFriendRequestButton;
import 'package:emora_mobile_app/features/friends/services/mood_reaction_service.dart';
import 'package:emora_mobile_app/features/friends/domain/entity/friend_mood_data.dart';
import 'package:emora_mobile_app/core/network/dio_client.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/core/navigation/navigation_service.dart';
// import 'package:emora_mobile_app/features/user/presentation/view/user_profile_page.dart';

class FriendsTabContent {
  // Service instance for mood reactions
  static final MoodReactionService _moodReactionService = MoodReactionService(DioClient.instance);

  // Global Feed Tab
  static Widget globalFeed(Future<void> Function() onRefresh) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        if (state is CommunityLoading) {
          return _buildLoadingState();
        } else if (state is CommunityError) {
          return _buildErrorState(state.message, onRefresh);
        } else if (state is CommunityFeedLoaded) {
          return _buildGlobalFeedContent(state, onRefresh);
        }
        return _buildLoadingState();
      },
    );
  }

  // My Friends Tab
  static Widget myFriends(Future<void> Function() onRefresh, TabController tabController) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        print('[DEBUG] FriendBloc state: $state');
        if (state is FriendLoading) {
          return _buildLoadingState();
        } else if (state is FriendError) {
          return _buildErrorState(state.message, onRefresh);
        } else if (state is FriendsLoaded) {
          return _buildMyFriendsContent(state, onRefresh, tabController);
        }
        return _buildLoadingState();
      },
    );
  }

  // Sent Requests Tab
  static Widget sentRequests(Future<void> Function() onRefresh, Function(String) onCancel) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state is FriendLoading) {
          return _buildLoadingState();
        } else if (state is FriendError) {
          return _buildErrorState(state.message, onRefresh);
        } else if (state is FriendsLoaded) {
          return _buildSentRequestsContent(state, onRefresh, onCancel);
        }
        return _buildLoadingState();
      },
    );
  }

  // Received Requests Tab
  static Widget receivedRequests(Future<void> Function() onRefresh, Function(String, String) onRespond) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state is FriendLoading) {
          return _buildLoadingState();
        } else if (state is FriendError) {
          return _buildErrorState(state.message, onRefresh);
        } else if (state is FriendsLoaded) {
          return _buildReceivedRequestsContent(state, onRefresh, onRespond);
        }
        return _buildLoadingState();
      },
    );
  }

  // Discover Tab
  static Widget discover(Function(String) onSendRequest) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (state is FriendSearchLoading) {
          return _buildLoadingState();
        } else if (state is FriendSearchLoaded) {
          return _buildSearchResults(state, onSendRequest);
        } else if (state is FriendsLoaded) {
          return _buildDiscoverContent(state, onSendRequest);
        } else if (state is FriendError) {
          return _buildErrorState(state.message, () async {});
        }
        return _buildLoadingState();
      },
    );
  }

  // ============================================================================
  // PRIVATE CONTENT BUILDERS
  // ============================================================================

  static Widget _buildGlobalFeedContent(CommunityFeedLoaded state, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.globalPosts.length,
        itemBuilder: (context, index) {
          return _buildMoodCard(state.globalPosts[index]);
        },
      ),
    );
  }

  static Widget _buildMyFriendsContent(FriendsLoaded state, Future<void> Function() onRefresh, TabController tabController) {
    if (state.friends.isEmpty) {
      return _buildEmptyFriendsState(tabController);
    }

    // DEBUG: Print all friends and their recentMood
    for (final friend in state.friends) {
      // ignore: avoid_print
      print('[DEBUG] Friend: ${friend.username} (id: ${friend.id}) recentMood: ${friend.recentMood}');
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.friends.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFriendsOverview(state);
          }
          return _buildFriendCard(state.friends[index - 1], context);
        },
      ),
    );
  }

  static Widget _buildSentRequestsContent(FriendsLoaded state, Future<void> Function() onRefresh, Function(String) onCancel) {
    final sentRequests = state.sentRequests;
    
    if (sentRequests.isEmpty) {
      return _buildEmptyState(
        'No Sent Requests',
        'You haven\'t sent any friend requests yet. Discover new friends to expand your network!',
        Icons.send_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: sentRequests.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSentRequestsHeader(sentRequests.length);
          }
          return _buildSentRequestCard(sentRequests[index - 1], onCancel);
        },
      ),
    );
  }

  static Widget _buildReceivedRequestsContent(FriendsLoaded state, Future<void> Function() onRefresh, Function(String, String) onRespond) {
    final receivedRequests = state.receivedRequests;
    
    if (receivedRequests.isEmpty) {
      return _buildEmptyState(
        'No Friend Requests',
        'No one has sent you friend requests yet. Share your profile to get discovered!',
        Icons.inbox_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: receivedRequests.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildReceivedRequestsHeader(receivedRequests.length);
          }
          return _buildReceivedRequestCard(receivedRequests[index - 1], onRespond);
        },
      ),
    );
  }

  static Widget _buildSearchResults(FriendSearchLoaded state, Function(String) onSendRequest) {
    if (state.searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _buildEmptyState(
          'No Users Found',
          'No users match your search. Try different keywords.',
          Icons.search_off,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) => _buildUserSuggestion(state.searchResults[index], onSendRequest),
    );
  }

  static Widget _buildDiscoverContent(FriendsLoaded state, Function(String) onSendRequest) {
    // Filter out suggestions that already have pending requests
    final availableSuggestions = state.suggestions.where((suggestion) {
      // Check if user is already a friend
      if (state.friends.any((friend) => friend.id == suggestion.id)) {
        return false;
      }
      
      // Check if there's already a sent request for this user
      if (state.sentRequests.any((request) => request.userId == suggestion.id)) {
        return false;
      }
      
      // Check if there's already a received request from this user
      if (state.receivedRequests.any((request) => request.userId == suggestion.id)) {
        return false;
      }
      
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggested Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (availableSuggestions.isEmpty)
            _buildEmptyState(
              'No New Suggestions',
              'You\'ve already sent requests to all available suggestions. Check your sent requests tab!',
              Icons.check_circle_outline,
            )
          else
            ...availableSuggestions.map((suggestion) => _buildUserSuggestion(suggestion, onSendRequest)),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================



  static Widget _buildMoodCard(CommunityPostEntity post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: post.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post.color.withValues(alpha: 0.2),
                child: Text(
                  post.selectedAvatar.toUpperCase(),
                  style: TextStyle(
                    color: post.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.displayName.isNotEmpty ? post.displayName : post.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${post.location} • ${FriendsUtils.formatTimestamp(post.timestamp)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: post.color.withValues(alpha: 0.1),
                ),
                child: Text(post.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            post.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFriendsOverview(FriendsLoaded state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Text(
            'Your Friends (${state.totalFriends})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFriendCard(FriendEntity friend, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.9),
            const Color(0xFF16213E).withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with friend info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                      child: Text(
                        _getAvatarEmoji(friend.selectedAvatar),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    if (friend.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0A0A0F), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName.isNotEmpty ? friend.displayName : friend.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            friend.isOnline ? Icons.circle : Icons.circle_outlined,
                            color: friend.isOnline ? const Color(0xFF10B981) : Colors.grey[500],
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            friend.status,
                            style: TextStyle(
                              color: friend.isOnline ? const Color(0xFF10B981) : Colors.grey[400],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (friend.mutualFriends > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline, color: Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${friend.mutualFriends}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Mood Activity Section
          _buildMoodActivitySection(friend, context),
          
          // Action Buttons
          _buildFriendActionButtons(friend, context),
        ],
      ),
    );
  }

  static Widget _buildMoodActivitySection(FriendEntity friend, BuildContext context) {
    // Use real mood data from friend entity
    final recentMood = friend.recentMood;
    final recentCommunityPost = friend.recentCommunityPost;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, color: Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Mood',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (recentMood != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: recentMood.color.withValues(alpha: 0.2),
                    border: Border.all(
                      color: recentMood.color.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    recentMood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recentMood.note ?? 'Feeling ${recentMood.emotion.toLowerCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recentMood.locationDisplay} • ${FriendsUtils.formatTimestamp(recentMood.timestamp)}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMoodReactions(recentMood),
          ] else if (recentCommunityPost != null) ...[
            GestureDetector(
              onTap: () => _viewCommunityPost(recentCommunityPost, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          recentCommunityPost.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recentCommunityPost.message ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FriendsUtils.formatTimestamp(recentCommunityPost.timestamp),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Community Post',
                      style: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No recent mood activity',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildMoodReactions(FriendMoodData mood) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
      children: [
        _buildReactionButton('💬', 'Hug', () => _sendReaction(mood.id, 'hug')),
        const SizedBox(width: 8),
        _buildReactionButton('🎵', 'Music', () => _sendReaction(mood.id, 'music')),
        const SizedBox(width: 8),
        _buildReactionButton('📩', 'Message', () => _sendReaction(mood.id, 'message')),
          const SizedBox(width: 8),
        _buildAnonymousSupportButton(mood.id),
      ],
      ),
    );
  }

  static Widget _buildReactionButton(String emoji, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildAnonymousSupportButton(String moodId) {
    return GestureDetector(
      onTap: () => _sendAnonymousSupport(moodId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF10B981).withValues(alpha: 0.1),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💜', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            const Text(
              'Support',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFriendActionButtons(FriendEntity friend, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'View Profile',
              Icons.person_outline,
              const Color(0xFF8B5CF6),
              () => _viewFriendProfile(friend, context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Send Message',
              Icons.chat_bubble_outline,
              const Color(0xFF10B981),
              () => _sendMessage(friend, context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              'Mood Map',
              Icons.map_outlined,
              const Color(0xFFFFD700),
              () => _viewFriendOnMap(friend, context),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  static Widget _buildSentRequestsHeader(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.1),
            const Color(0xFFFFA500).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.send, color: Color(0xFFFFD700), size: 24),
              const SizedBox(width: 12),
              Text(
                'Sent Requests ($count)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'These requests are awaiting response. You can cancel them if needed.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSentRequestCard(FriendRequestEntity request, Function(String) onCancel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
            child: Text(
              _getAvatarEmoji(request.selectedAvatar),
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.displayName.isNotEmpty 
                      ? request.displayName 
                      : request.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.grey[400],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sent ${FriendsUtils.formatTimestamp(request.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildCancelRequestButton(request.userId, onCancel),
        ],
      ),
    );
  }

  static Widget _buildCancelRequestButton(String userId, Function(String) onCancel) {
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        final isLoading = state is FriendRequestActionLoading && 
                          state.targetUserId == userId &&
                          state.actionType == 'cancel';
        
        return GestureDetector(
          onTap: isLoading ? null : () {
            print('. _buildCancelRequestButton - userId: $userId');
            print('. _buildCancelRequestButton - userId length: ${userId.length}');
            print('. _buildCancelRequestButton - userId isEmpty: ${userId.isEmpty}');
            
            // Validate userId before calling onCancel
            if (userId.isEmpty) {
              print('. _buildCancelRequestButton - userId is empty, not calling onCancel');
              ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
                SnackBar(
                  content: const Text('Invalid user data. Please refresh and try again.'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }
            
            onCancel(userId);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFEF4444),
                    ),
                  )
                else
                  const Icon(
                    Icons.cancel_outlined,
                    color: Color(0xFFEF4444),
                    size: 14,
                  ),
                const SizedBox(width: 6),
                Text(
                  isLoading ? 'Canceling...' : 'Cancel',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildReceivedRequestsHeader(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.1),
            const Color(0xFF059669).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inbox, color: Color(0xFF10B981), size: 24),
              const SizedBox(width: 12),
              Text(
                'Friend Requests ($count)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'People who want to connect with you. Accept to add them to your emotional support network.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReceivedRequestCard(FriendRequestEntity request, Function(String, String) onRespond) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                child: Text(
                  _getAvatarEmoji(request.selectedAvatar),
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.displayName.isNotEmpty 
                          ? request.displayName 
                          : request.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${request.username}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey[400],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sent ${FriendsUtils.formatTimestamp(request.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRequestActionButton(
                  'Accept',
                  Icons.check,
                  const Color(0xFF10B981),
                  () => onRespond(request.userId, 'accept'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRequestActionButton(
                  'Decline',
                  Icons.close,
                  const Color(0xFFEF4444),
                  () => onRespond(request.userId, 'reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildRequestActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildUserSuggestion(FriendSuggestionEntity suggestion, Function(String) onSendRequest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withValues(alpha: 0.8),
            const Color(0xFF16213E).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              child: Text(
                _getAvatarEmoji(suggestion.selectedAvatar),
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        suggestion.displayName.isNotEmpty 
                            ? suggestion.displayName 
                            : suggestion.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                      '@${suggestion.username}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[500],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        suggestion.location ?? 'Unknown Location',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (suggestion.mutualFriends > 0) ...[
                      const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${suggestion.mutualFriends} mutual',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (suggestion.commonInterests.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: suggestion.commonInterests.take(3).map((interest) => 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              const Color(0xFF6366F1).withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BlocBuilder<FriendBloc, FriendState>(
            builder: (context, state) {
              // . Use centralized status check from BLoC
              final friendBloc = context.read<FriendBloc>();
              FriendRequestStatus buttonStatus = friendBloc.getFriendRequestStatus(suggestion.id) as FriendRequestStatus;
              
              return EnhancedFriendRequestButton(
                userId: suggestion.id,
                status: buttonStatus,
                onPressed: () => onSendRequest(suggestion.id),
                isCompact: false,
              );
            },
          ),
        ],
        ),
      ),
    );
  }


  static String _getAvatarEmoji(String avatarName) {
    const avatarEmojis = {
      'panda': '🐼',
      'elephant': '🐘',
      'horse': '🐴',
      'rabbit': '🐰',
      'fox': '🦊',
      'zebra': '🦓',
      'bear': '🐻',
      'pig': '🐷',
      'raccoon': '🦝',
      'cat': '🐱',
      'dog': '🐶',
      'owl': '🦉',
      'penguin': '🐧',
    };

    return avatarEmojis[avatarName.toLowerCase()] ?? '🐾';
  }

  static Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, size: 50, color: const Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEmptyFriendsState(TabController tabController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEmptyState(
            'No Friends Yet',
            'Start connecting with people to see their moods here. Build your emotional support network!',
            Icons.people_outline,
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            'Find Friends',
            Icons.person_add,
            const Color(0xFF8B5CF6),
            () => tabController.animateTo(3), // Go to discover tab
          ),
        ],
      ),
    );
  }



  static Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  static Widget _buildErrorState(String message, Future<void> Function() onRefresh) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }



  static Future<void> _sendReaction(String moodId, String reactionType) async {
    try {
      Logger.info('💝 Sending $reactionType reaction to mood $moodId');
      
      final success = await _moodReactionService.sendReaction(
        moodId: moodId,
        reactionType: reactionType,
      );

      if (success) {
        Logger.info('✅ Reaction sent successfully');
        // Show success feedback to user
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text('$reactionType sent! 💝'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        Logger.warning('⚠️ Failed to send reaction');
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: const Text('Failed to send reaction. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ Error sending reaction: $e');
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: const Text('Error sending reaction. Please try again.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> _sendAnonymousSupport(String moodId) async {
    try {
      Logger.info('💜 Sending anonymous support to mood $moodId');
      
      final success = await _moodReactionService.sendReaction(
        moodId: moodId,
        reactionType: 'anonymous_support',
        isAnonymous: true,
      );

      if (success) {
        Logger.info('✅ Anonymous support sent successfully');
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: const Text('Anonymous support sent! 💜'),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        Logger.warning('⚠️ Failed to send anonymous support');
        ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: const Text('Failed to send support. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Logger.error('❌ Error sending anonymous support: $e');
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: const Text('Error sending support. Please try again.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<bool> _sendComfortMessageToBackend(String friendId, String message) async {
    try {
      final response = await DioClient.instance.post(
        '/api/messages/send',
        data: {
          'recipientId': friendId,
          'message': message,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ Comfort message sent to backend');
        return true;
      } else {
        Logger.warning('⚠️ Failed to send comfort message: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Logger.error('❌ Error sending comfort message: $e');
      return false;
    }
  }

  static void _viewFriendProfile(FriendEntity friend, BuildContext context) {
    print('Viewing profile for ${friend.username}');
    HapticFeedback.lightImpact();
    // Placeholder: Show a simple profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(friend.displayName.isNotEmpty ? friend.displayName : friend.username)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Username: ${friend.username}', style: TextStyle(fontSize: 18)),
                Text('Display Name: ${friend.displayName}', style: TextStyle(fontSize: 16)),
                Text('Avatar: ${friend.selectedAvatar}', style: TextStyle(fontSize: 16)),
                if (friend.location != null) Text('Location: ${friend.location}', style: TextStyle(fontSize: 16)),
                // Add more friend info as needed
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _sendMessage(FriendEntity friend, BuildContext context) async {
    print('Sending message to ${friend.username}');
    HapticFeedback.mediumImpact();
    String? message = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: Text('Send Comfort Message to ${friend.displayName.isNotEmpty ? friend.displayName : friend.username}'),
          content: TextField(
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(hintText: 'Type your message...'),
            onChanged: (val) => input = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input.trim()),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
    if (message != null && message.isNotEmpty) {
      final success = await _sendComfortMessageToBackend(friend.id, message);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Message sent to ${friend.displayName.isNotEmpty ? friend.displayName : friend.username}!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send message. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  static void _viewFriendOnMap(FriendEntity friend, BuildContext context) {
    print('Viewing ${friend.username} on map');
    HapticFeedback.mediumImpact();
    // TODO: Navigate to map with friend filter
  }

  static void _viewCommunityPost(CommunityPostEntity post, BuildContext context) {
    print('📝 Viewing community post: ${post.id}');
    HapticFeedback.lightImpact();
    // TODO: Implement navigation to a detailed post page
    // No SnackBar or message for now
  }
}