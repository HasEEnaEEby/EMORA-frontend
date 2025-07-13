import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/community_entity.dart';
import '../view_model/bloc/community_bloc.dart';
import '../view_model/bloc/community_event.dart';
import '../view_model/bloc/community_state.dart';

class CommunityFeedWidget extends StatefulWidget {
  final VoidCallback onViewAllTapped;
  final bool isNewUser;

  const CommunityFeedWidget({
    super.key,
    required this.onViewAllTapped,
    this.isNewUser = false,
  });

  @override
  State<CommunityFeedWidget> createState() => _CommunityFeedWidgetState();
}

class _CommunityFeedWidgetState extends State<CommunityFeedWidget> {
  @override
  void initState() {
    super.initState();
    // Load community data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommunityData();
    });
  }

  void _loadCommunityData() {
    final communityBloc = context.read<CommunityBloc>();

    // Load global feed if not already loaded
    communityBloc.add(const LoadGlobalFeedEvent(forceRefresh: true));

    // Load global stats
    communityBloc.add(const LoadGlobalStatsEvent(forceRefresh: true));
  }

  List<Map<String, dynamic>> _convertPostsToMaps(
    List<CommunityPostEntity> posts,
  ) {
    print('🔍 Converting ${posts.length} posts to maps');

    return posts.take(3).map((post) {
      print('🔍 Post ID: ${post.id}');
      print('🔍 Post note: "${post.message}"');
      print('🔍 Post emoji: ${post.emoji}');
      print('🔍 Post reactions: ${post.reactions.length}');

      // Handle message content with fallback
      final messageContent = post.message.isNotEmpty
          ? post.message
          : 'Sharing a moment...'; // Better fallback text

      final displayMessage = messageContent.length > 60
          ? '${messageContent.substring(0, 60)}...'
          : messageContent;

      // Ensure we have a valid ID
      final postId = post.id.isNotEmpty ? post.id : 'temp_${DateTime.now().millisecondsSinceEpoch}';

      // Use reactions count, or fallback to 0 if empty
      final comfortsCount = post.reactions.isNotEmpty ? post.reactions.length : 0;

      return {
        'id': postId,
        'emotion': post.emoji.isNotEmpty ? post.emoji : '😊',
        'message': displayMessage,
        'comforts': comfortsCount,
        'time': _formatTimestamp(post.timestamp),
        'color': post.color,
        'username': post.username.isNotEmpty ? post.username : 'Anonymous',
        'displayName': post.displayName.isNotEmpty
            ? post.displayName
            : 'Community Member',
        'location': post.location.isNotEmpty ? post.location : 'Unknown',
      };
    }).toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCommunityContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Moments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Feel connected & supported',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onViewAllTapped,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF8B5CF6),
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityContent() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        print('🔍 CommunityFeedWidget state: ${state.runtimeType}');

        if (state is CommunityLoading) {
          return _buildLoadingState();
        } else if (state is CommunityFeedLoaded) {
          final posts = _convertPostsToMaps(state.globalPosts);
          print('🔍 Converted ${posts.length} posts for display');

          if (posts.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFeedList(posts);
        } else if (state is CommunityError) {
          return _buildErrorState(context);
        } else if (state is CommunityFeedError) {
          // Show error but keep existing data if available
          final posts = _convertPostsToMaps(state.globalPosts);
          if (posts.isNotEmpty) {
            return Column(
              children: [
                _buildErrorBanner(state.errorMessage),
                const SizedBox(height: 8),
                _buildFeedList(posts),
              ],
            );
          }
          return _buildErrorState(context);
        } else if (widget.isNewUser) {
          return _buildEmptyState();
        } else {
          // Initial state - trigger loading
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCommunityData();
          });
          return _buildLoadingState();
        }
      },
    );
  }

  Widget _buildFeedList(List<Map<String, dynamic>> posts) {
    return Column(
      children: [
        // Global stats banner
        BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            if (state is CommunityFeedLoaded && state.globalStats.isNotEmpty) {
              return _buildStatsBanner(state.globalStats);
            }
            return const SizedBox.shrink();
          },
        ),

        // Posts list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final postId = post['id'] as String? ?? '';

            print('🔍 Building post $index with ID: $postId');

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A1A2E).withOpacity(0.8),
                    const Color(0xFF2A2A3E).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPostHeader(post),
                  const SizedBox(height: 12),
                  _buildPostContent(post),
                  const SizedBox(height: 16),
                  _buildPostActions(post, postId),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsBanner(List<GlobalMoodStatsEntity> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: Color(0xFF8B5CF6), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Community is feeling ${stats.first.emotion} today',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${stats.first.percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Map<String, dynamic> post) {
    return Row(
      children: [
        // User avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: post['color'] as Color? ?? const Color(0xFF8B5CF6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Center(
            child: Text(
              (post['displayName'] as String? ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post['displayName'] as String? ?? 'Community Member',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${post['location']} • ${post['time']}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),

        // Emotion emoji
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            post['emotion'] as String? ?? '😊',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(Map<String, dynamic> post) {
    return Text(
      post['message'] as String? ?? 'Sharing a moment...',
      style: TextStyle(color: Colors.grey[200], fontSize: 15, height: 1.5),
    );
  }

  Widget _buildPostActions(Map<String, dynamic> post, String postId) {
    return Row(
      children: [
        // Comfort button
        GestureDetector(
          onTap: () {
            print('💖 Heart tapped for post: $postId');
            if (postId.isNotEmpty) {
              context.read<CommunityBloc>().add(
                ReactToPostEvent(postId: postId, emoji: '❤️', type: 'comfort'),
              );

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Comfort sent! 💖'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF8B5CF6),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            } else {
              print('❌ Cannot react: Post ID is empty');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post['comforts'] ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Comfort',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Reply button
        GestureDetector(
          onTap: () {
            print('💬 Reply tapped for post: $postId');
            // Show coming soon message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Comments feature coming soon! 💬'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.grey[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Share button
        GestureDetector(
          onTap: () {
            // Share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Share feature coming soon! 🔗'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.grey[700],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Colors.grey,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[300], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Connection issue: $errorMessage',
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: _loadCommunityData,
            child: Icon(Icons.refresh, color: Colors.red[300], size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF2A2A3E).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Color(0xFF8B5CF6),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No community moments yet',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your emotions with the community! Your feelings matter and others can find comfort in knowing they\'re not alone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onViewAllTapped,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFAB7DF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Explore Community',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Animated loading indicator
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF8B5CF6),
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading community moments...',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Connecting hearts and minds',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_outlined,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load community feed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to connect to the community. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _loadCommunityData,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFAB7DF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onViewAllTapped,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Go to Community',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
