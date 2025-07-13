// ============================================================================
// MAIN FRIENDS VIEW - friends_view.dart
// ============================================================================

import 'package:emora_mobile_app/features/home/presentation/view/pages/components/friends_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/entity/community_entity.dart';
import '../../../domain/entity/friend_entity.dart';
import '../../view_model/bloc/community_bloc.dart';
import '../../view_model/bloc/community_event.dart';
import '../../view_model/bloc/community_state.dart';
import '../../view_model/bloc/friend_bloc.dart';
import '../../view_model/bloc/friend_event.dart';
import '../../view_model/bloc/friend_state.dart';
import '../../widget/enhanced_friend_request_button.dart';


class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  String _searchQuery = '';
  bool _showSearch = false;

  // BLoC instances
  late FriendBloc _friendBloc;
  late CommunityBloc _communityBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeAnimations();
    _initializeBloCs();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _initializeBloCs() {
    _friendBloc = GetIt.instance<FriendBloc>();
    _communityBloc = GetIt.instance<CommunityBloc>();
  }

  void _loadInitialData() {
    _friendBloc.add(const LoadFriendsEvent());
    _friendBloc.add(const LoadPendingRequestsEvent());
    _friendBloc.add(const LoadFriendSuggestionsEvent());
    _communityBloc.add(const LoadGlobalFeedEvent());
    _communityBloc.add(const LoadGlobalStatsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _friendBloc),
        BlocProvider.value(value: _communityBloc),
      ],
      child: BlocListener<FriendBloc, FriendState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          if (state is FriendRequestActionSuccess) {
            FriendsUtils.handleSuccessState(context, state, _showCelebrationOverlay);
          } else if (state is FriendError) {
            FriendsUtils.handleErrorState(context, state, _friendBloc);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          body: SafeArea(
            child: Column(
              children: [
                FriendsHeader(
                  showSearch: _showSearch,
                  searchQuery: _searchQuery,
                  onSearchToggle: () => setState(() => _showSearch = !_showSearch),
                  onSearchChanged: _handleSearchChanged,
                  onSearchClear: _handleSearchClear,
                ),
                FriendsTabBar(
                  controller: _tabController,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      FriendsTabContent.globalFeed(_handleRefresh),
                      FriendsTabContent.myFriends(_handleRefresh, _tabController),
                      FriendsTabContent.sentRequests(_handleRefresh, _cancelFriendRequest),
                      FriendsTabContent.receivedRequests(_handleRefresh, _respondToFriendRequest),
                      FriendsTabContent.discover(_sendFriendRequest),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FriendsFloatingButton(
            animation: _floatingAnimation,
            onPressed: _showCreatePostDialog,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // ACTION METHODS
  // ============================================================================

  void _handleSearchChanged(String value) {
    setState(() => _searchQuery = value);
    if (value.isNotEmpty) {
      _friendBloc.add(SearchUsersEvent(query: value));
    } else {
      _friendBloc.add(const ClearSearchEvent());
    }
  }

  void _handleSearchClear() {
    setState(() {
      _searchQuery = '';
      _showSearch = false;
    });
    _friendBloc.add(const ClearSearchEvent());
  }

  Future<void> _handleRefresh() async {
    _refreshController.forward();
    HapticFeedback.mediumImpact();

    _friendBloc.add(const RefreshFriendsDataEvent());
    _communityBloc.add(const RefreshCommunityDataEvent());

    await Future.delayed(const Duration(milliseconds: 1500));
    _refreshController.reset();

    if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
          content: const Text('Feed refreshed!'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
              ),
            );
    }
  }

  void _sendFriendRequest(String userId) {
    _friendBloc.add(SendFriendRequestEvent(userId: userId));
    HapticFeedback.mediumImpact();
    // ✅ BLoC handles optimistic updates automatically!
  }

  void _cancelFriendRequest(String userId) {
    print('🔍 _cancelFriendRequest - userId: $userId');
    print('🔍 _cancelFriendRequest - userId length: ${userId.length}');
    print('🔍 _cancelFriendRequest - userId isEmpty: ${userId.isEmpty}');
    
    // Validate userId before showing confirmation
    if (userId.isEmpty) {
      print('❌ _cancelFriendRequest - userId is empty, not showing confirmation');
              ScaffoldMessenger.of(context).showSnackBar(
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
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Color(0xFFFF6B6B),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cancel Request?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to cancel this friend request? This action cannot be undone.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Keep Request',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executeCancelRequest(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel Request',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeCancelRequest(String userId) {
    _friendBloc.add(CancelFriendRequestEvent(userId: userId));
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.schedule, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Canceling friend request...'),
          ],
        ),
        backgroundColor: const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
                ),
              );
            }

  void _respondToFriendRequest(String userId, String action) {
    _friendBloc.add(RespondToFriendRequestEvent(
      requestUserId: userId,
      action: action,
    ));
    HapticFeedback.mediumImpact();
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.only(top: 50),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
                    children: [
                const Text(
                  'Share Your Mood',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Center(
                child: Text(
                  'Mood sharing feature coming soon!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebrationOverlay() {
    FriendsUtils.showCelebrationOverlay(context);
  }
}

// ============================================================================
// FRIENDS HEADER COMPONENT - components/friends_header.dart
// ============================================================================

class FriendsHeader extends StatelessWidget {
  final bool showSearch;
  final String searchQuery;
  final VoidCallback onSearchToggle;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchClear;

  const FriendsHeader({
    super.key,
    required this.showSearch,
    required this.searchQuery,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, state) {
                        if (state is FriendsLoaded) {
                          return Text(
                            'Connect with the global emotional community',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          );
                        }
                        return Text(
                          'Connect with the global emotional community',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (!showSearch)
                GestureDetector(
                  onTap: onSearchToggle,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (showSearch) ...[
            const SizedBox(height: 16),
            _buildSearchBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search for friends...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: onSearchClear,
              child: const Icon(Icons.close, color: Colors.grey, size: 20),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// FRIENDS TAB BAR COMPONENT - components/friends_tab_bar.dart
// ============================================================================

class FriendsTabBar extends StatelessWidget {
  final TabController controller;

  const FriendsTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50, // Fixed height for consistent look
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25), // More rounded like in the image
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
        ),
      ),
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, state) {
          int sentCount = 0;
          int receivedCount = 0;
          
          if (state is FriendsLoaded) {
            sentCount = state.sentRequests.length;
            receivedCount = state.receivedRequests.length;
          }
          
          return TabBar(
            controller: controller,
        indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25), // Match container radius
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[400],
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12, // Slightly larger for better readability
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            isScrollable: true, // Enable scrolling like in the image
            tabAlignment: TabAlignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              const Tab(text: 'Global Feed'),
              const Tab(text: 'My Friends'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sent'),
                    if (sentCount > 0) ...[
                      const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10),
                            ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          '$sentCount',
            style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
              ),
                    ],
            ],
          ),
      ),
              Tab(
      child: Row(
                  mainAxisSize: MainAxisSize.min,
        children: [
                    const Text('Requests'),
                    if (receivedCount > 0) ...[
                      const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(10),
                      ),
                        constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                          '$receivedCount',
                        style: const TextStyle(
                          color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                        ),
                          textAlign: TextAlign.center,
        ),
                      ),
                    ],
        ],
      ),
              ),
              const Tab(text: 'Discover'),
            ],
          );
              },
      ),
    );
  }
}

// ============================================================================
// FRIENDS FLOATING BUTTON - components/friends_floating_button.dart
// ============================================================================

class FriendsFloatingButton extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const FriendsFloatingButton({
    super.key,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value * 0.5),
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: const Color(0xFF8B5CF6),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }
  }

  // ============================================================================
// FRIENDS UTILS - utils/friends_utils.dart
  // ============================================================================

class FriendsUtils {
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  static void handleSuccessState(
    BuildContext context,
    FriendRequestActionSuccess state,
    VoidCallback showCelebrationOverlay,
  ) {
    String title;
    String message;
    Color backgroundColor;
    IconData icon;
    
    switch (state.actionType) {
      case 'send':
        title = 'Request Sent! 🎉';
        message = 'Your friend request is now pending. They\'ll be notified!';
        backgroundColor = const Color(0xFFFFD700);
        icon = Icons.schedule_outlined;
        break;
      case 'cancel':
        title = 'Request Cancelled! ❌';
        message = 'Friend request has been cancelled successfully.';
        backgroundColor = const Color(0xFF6B7280);
        icon = Icons.cancel_outlined;
        break;
      case 'accept':
        title = 'New Friend Added! 💝';
        message = 'You\'re now connected! Start sharing your emotional journey.';
        backgroundColor = const Color(0xFF10B981);
        icon = Icons.people_outlined;
        break;
      case 'reject':
        title = 'Request Declined';
        message = 'The friend request has been politely declined.';
        backgroundColor = const Color(0xFF6B7280);
        icon = Icons.person_remove_outlined;
        break;
      default:
        title = 'Action Completed';
        message = state.message;
        backgroundColor = const Color(0xFF8B5CF6);
        icon = Icons.check_circle_outlined;
    }
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: buildEnhancedSnackBarContent(title, message, icon),
        backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(20),
        elevation: 8,
      ),
    );
    
    if (state.actionType == 'accept') {
      HapticFeedback.heavyImpact();
      showCelebrationOverlay();
    } else {
      HapticFeedback.mediumImpact();
  }
  }

  static void handleErrorState(
    BuildContext context, 
    FriendError state, 
    FriendBloc friendBloc,
  ) {
    String title;
    String message;
    Color backgroundColor = const Color(0xFFEF4444);
    
    switch (state.errorType) {
      case 'already_sent':
        title = 'Request Already Sent! 📤';
        message = 'You\'ve already sent a friend request to this user. Check your sent requests tab.';
        backgroundColor = const Color(0xFFFFD700);
        break;
      case 'already_friends':
        title = 'Already Connected! 👥';
        message = 'You\'re already friends with this person.';
        backgroundColor = const Color(0xFF10B981);
        break;
      case 'cancel_request':
        title = 'Cancel Failed ❌';
        message = 'Failed to cancel friend request. Please try again.';
        backgroundColor = const Color(0xFFFF6B6B);
        break;
      case 'rate_limit':
        title = 'Slow Down! 🐌';
        message = 'You\'re sending requests too quickly. Take a breath and try again in a moment.';
        break;
      case 'timeout':
        title = 'Connection Timeout 🌐';
        message = 'Request took too long. Check your connection and try again.';
        break;
      case 'user_not_found':
        title = 'User Not Found 🔍';
        message = 'This user might have deactivated their account.';
        break;
      default:
        title = 'Something Went Wrong 😔';
        message = state.message.isNotEmpty 
            ? state.message 
            : 'An unexpected error occurred. Please try again.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: buildEnhancedSnackBarContent(title, message, Icons.error_outline),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(20),
        elevation: 8,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            friendBloc.add(const LoadFriendsEvent(forceRefresh: true));
          },
        ),
      ),
    );
    
    HapticFeedback.lightImpact();
  }

  static Widget buildEnhancedSnackBarContent(String title, String message, IconData icon) {
    return Row(
          children: [
            Container(
          padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      ],
    );
  }

  static void showCelebrationOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            child: Stack(
            children: [
                // Celebration particles effect
                ...List.generate(20, (index) => Positioned(
                  left: MediaQuery.of(context).size.width * (index * 0.05),
                  top: MediaQuery.of(context).size.height * 0.3 + (index * 20),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 800 + (index * 50)),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -value * 200),
                        child: Opacity(
                          opacity: 1.0 - value,
                          child: Text(
                            ['💝', '🎉', '✨', '🌟', '💫'][index % 5],
                            style: const TextStyle(fontSize: 24),
                          ),
          ),
        );
      },
                  ),
                )),
                
                // Central celebration message
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
      ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
            ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
              children: [
                              Text('💝', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 12),
                    Text(
                                'New Friend Added!',
                                style: TextStyle(
                        color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                ),
                      );
                    },
            ),
          ),
        ],
      ),
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Remove after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static FriendRequestStatus determineButtonStatus(FriendState state, FriendSuggestionEntity suggestion) {
    // ✅ Use centralized status check from BLoC
    // This method is now deprecated in favor of BLoC's getFriendRequestStatus method
    // Keep for backward compatibility with existing UI components
    
    // Check if currently loading for this specific user
    if (state is FriendRequestActionLoading && state.targetUserId == suggestion.id) {
      return FriendRequestStatus.sending;
    }
    
    // Check if already friends
    if (state is FriendsLoaded && state.friends.any((f) => f.id == suggestion.id)) {
      return FriendRequestStatus.friends;
    }
    
    // Check if request was recently sent successfully
    if (state is FriendRequestActionSuccess && 
        state.actionType == 'send' && 
        state.targetUserId == suggestion.id) {
      return FriendRequestStatus.requested;
    }
    
    // Check if request was accepted
    if (state is FriendRequestActionSuccess && 
        state.actionType == 'accept' && 
        state.targetUserId == suggestion.id) {
      return FriendRequestStatus.accepted;
    }

    // Check if request already exists in pending
    if (state is FriendsLoaded && 
        state.pendingRequests['sent']?.any((req) => req.userId == suggestion.id) == true) {
      return FriendRequestStatus.requested;
    }
    
    // Check if there was an error for this user
    if (state is FriendError && 
        state.errorType == 'send_request') {
      return FriendRequestStatus.error;
    }
    
    // Check if this suggestion is already marked as requested
    if (suggestion.isRequested) {
      return FriendRequestStatus.requested;
    }
    
    // Default state
    return FriendRequestStatus.notRequested;
  }
}