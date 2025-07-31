
import 'dart:async';
import 'package:emora_mobile_app/core/utils/friends_utils.dart';
import 'package:emora_mobile_app/features/home/presentation/view/pages/components/friends_tab_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entity/friend_entity.dart';
import '../../view_model/bloc/community_bloc.dart';
import '../../view_model/bloc/community_event.dart';
import '../../view_model/bloc/friend_bloc.dart';
import '../../view_model/bloc/friend_event.dart';
import '../../view_model/bloc/friend_state.dart';


enum FriendRequestStatus {
  notRequested,
  sending,
  requested,
  friends,
  accepted,
  error,
}


class EnhancedFriendRequestButton extends StatefulWidget {
  final String userId;
  final FriendRequestStatus status;
  final VoidCallback? onPressed;
  final bool isCompact;

  const EnhancedFriendRequestButton({
    super.key,
    required this.userId,
    required this.status,
    this.onPressed,
    this.isCompact = true,
  });

  @override
  State<EnhancedFriendRequestButton> createState() => _EnhancedFriendRequestButtonState();
}

class _EnhancedFriendRequestButtonState extends State<EnhancedFriendRequestButton>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.status == FriendRequestStatus.notRequested) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(EnhancedFriendRequestButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.status != oldWidget.status) {
      if (widget.status == FriendRequestStatus.notRequested) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: _buildButton(),
        );
      },
    );
  }
  
  Widget _buildButton() {
    final config = _getButtonConfig();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: config.isEnabled && widget.onPressed != null ? widget.onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.textColor,
          padding: widget.isCompact 
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
            side: config.borderColor != null 
                ? BorderSide(color: config.borderColor!, width: 1.5)
                : BorderSide.none,
          ),
          elevation: config.isEnabled ? 2 : 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.isLoading) ...[
              SizedBox(
                width: widget.isCompact ? 14 : 16,
                height: widget.isCompact ? 14 : 16,
                child: CircularProgressIndicator(
                  color: config.textColor,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 8),
            ] else if (config.icon != null) ...[
              Icon(
                config.icon,
                size: widget.isCompact ? 16 : 18,
                color: config.textColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              config.text,
              style: TextStyle(
                fontSize: widget.isCompact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: config.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  _ButtonConfig _getButtonConfig() {
    switch (widget.status) {
      case FriendRequestStatus.notRequested:
        return _ButtonConfig(
          text: 'Add Friend',
          icon: Icons.person_add_rounded,
          backgroundColor: const Color(0xFF8B5CF6),
          textColor: Colors.white,
          isEnabled: true,
        );
        
      case FriendRequestStatus.sending:
        return _ButtonConfig(
          text: 'Sending...',
          backgroundColor: const Color(0xFF6B7280),
          textColor: Colors.white,
          isEnabled: false,
          isLoading: true,
        );
        
      case FriendRequestStatus.requested:
        return _ButtonConfig(
          text: 'Requested',
          icon: Icons.schedule_rounded,
          backgroundColor: const Color(0xFFFFD700),
          textColor: Colors.black,
          isEnabled: false,
        );
        
      case FriendRequestStatus.friends:
        return _ButtonConfig(
          text: 'Friends',
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
          isEnabled: false,
        );
        
      case FriendRequestStatus.accepted:
        return _ButtonConfig(
          text: 'Friends',
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFF10B981),
          textColor: Colors.white,
          isEnabled: false,
        );
        
      case FriendRequestStatus.error:
        return _ButtonConfig(
          text: 'Try Again',
          icon: Icons.refresh_rounded,
          backgroundColor: Colors.transparent,
          textColor: const Color(0xFFEF4444),
          borderColor: const Color(0xFFEF4444),
          isEnabled: true,
        );
    }
  }
}

class _ButtonConfig {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool isEnabled;
  final bool isLoading;

  _ButtonConfig({
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.isEnabled,
    this.isLoading = false,
  });
}


class EnhancedFriendsTabBar extends StatelessWidget {
  final TabController controller;

  const EnhancedFriendsTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[400],
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              const Tab(text: 'My Friends'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sent'),
                    if (sentCount > 0) ...[
                      const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
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


class EnhancedFloatingButton extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const EnhancedFloatingButton({super.key, required this.animation, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value * 0.5),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: const Color(0xFF8B5CF6),
              elevation: 0,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),
        );
      },
    );
  }
}


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
  late TextEditingController _searchController;

  String _searchQuery = '';
  bool _showSearch = false;
  Timer? _searchDebounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  late FriendBloc _friendBloc;
  late CommunityBloc _communityBloc;

  @override
  void initState() {
    super.initState();
_tabController = TabController(length: 4, vsync: this); 
    _searchController = TextEditingController();
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
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
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
                EnhancedFriendsHeader(
                  showSearch: _showSearch,
                  searchQuery: _searchQuery,
                  searchController: _searchController,
                  onSearchToggle: _toggleSearch,
                  onSearchChanged: _handleSearchChanged,
                  onSearchClear: _handleSearchClear,
                ),
                EnhancedFriendsTabBar(
                  controller: _tabController,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      FriendsTabContent.myFriends(_handleRefresh, _tabController),
                      FriendsTabContent.sentRequests(_handleRefresh, _cancelFriendRequest),
                      FriendsTabContent.receivedRequests(_handleRefresh, _respondToFriendRequest),
                      BlocProvider.value(
                        value: _friendBloc,
                        child: EnhancedDiscoverTab(
                        isSearching: _showSearch,
                        searchQuery: _searchQuery,
                        onSendFriendRequest: _sendFriendRequest,
                        friendBloc: _friendBloc,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ),
      ),
    );
  }


  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    
    if (!_showSearch) {
      _handleSearchClear();
    }
  }

  void _handleSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _searchController.text = value;
    
    _searchDebounceTimer?.cancel();
    
    if (value.trim().isNotEmpty) {
      if (_tabController.index != 3) {
        _tabController.animateTo(3);
      }
      
      _searchDebounceTimer = Timer(_debounceDuration, () {
        print('🔍 Executing global search for: "${value.trim()}"');
        _friendBloc.add(SearchAllUsersEvent(query: value.trim()));
      });
    } else {
      _friendBloc.add(const ClearSearchEvent());
    }
  }

  void _handleSearchClear() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
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
          content: const Row(
            children: [
              Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Feed refreshed!', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
              ),
            );
    }
  }

  void _sendFriendRequest(String userId) {
    print('🚀 Sending friend request to: $userId');
    if (userId.isEmpty) return;
    
    final currentState = _friendBloc.state;
    if (currentState is FriendsLoaded) {
      final isAlreadySent = currentState.sentRequests.any((req) => req.userId == userId);
      if (isAlreadySent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Friend request already sent to this user'),
            backgroundColor: Color(0xFFFFD700),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    
    _friendBloc.add(SendFriendRequestEvent(userId: userId));
    HapticFeedback.mediumImpact();
  }

  void _cancelFriendRequest(String userId) {
    print('❌ Attempting to cancel friend request - userId: $userId');
    
    if (userId.isEmpty) {
      _showErrorSnackBar('Invalid user data. Please refresh and try again.');
      return;
    }
    
    _showCancelConfirmationDialog(userId);
  }

  void _showCancelConfirmationDialog(String userId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                ),
                child: const Icon(Icons.cancel_outlined, color: Color(0xFFFF6B6B), size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                'Cancel Request?',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Text(
              'Are you sure you want to cancel this friend request? This action cannot be undone and you\'ll need to send a new request later.',
              style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Keep Request',
                style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _executeCancelRequest(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: const Text(
                'Cancel Request',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _executeCancelRequest(String userId) {
    print('🔄 Executing cancel request for userId: $userId');
    _friendBloc.add(CancelFriendRequestEvent(userId: userId));
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Canceling friend request...', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
                ),
              );
            }

  void _respondToFriendRequest(String userId, String action) {
    print('📨 Responding to friend request - userId: $userId, action: $action');
    if (userId.isEmpty) return;
    
    _friendBloc.add(RespondToFriendRequestEvent(requestUserId: userId, action: action));
    HapticFeedback.mediumImpact();
  }

  void _showCelebrationOverlay() {
    FriendsUtils.showCelebrationOverlay(context);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getAvatarEmoji(String avatarName) {
    const avatarEmojis = {
      'panda': '🐼', 'elephant': '🐘', 'horse': '🐴', 'rabbit': '🐰',
      'fox': '��', 'zebra': '🦓', 'bear': '🐻', 'pig': '🐷',
      'raccoon': '🦝', 'cat': '🐱', 'dog': '🐶', 'owl': '🦉', 'penguin': '🐧',
    };
    return avatarEmojis[avatarName.toLowerCase()] ?? '🐾';
  }
}


class EnhancedFriendsHeader extends StatefulWidget {
  final bool showSearch;
  final String searchQuery;
  final TextEditingController searchController;
  final VoidCallback onSearchToggle;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchClear;

  const EnhancedFriendsHeader({
    super.key,
    required this.showSearch,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  @override
  State<EnhancedFriendsHeader> createState() => _EnhancedFriendsHeaderState();
}

class _EnhancedFriendsHeaderState extends State<EnhancedFriendsHeader>
    with TickerProviderStateMixin {
  
  late AnimationController _searchAnimController;
  late Animation<double> _searchAnimation;
  
  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOut,
    );
    
    if (widget.showSearch) {
      _searchAnimController.forward();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedFriendsHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showSearch != oldWidget.showSearch) {
      if (widget.showSearch) {
        _searchAnimController.forward();
      } else {
        _searchAnimController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMainHeader(),
          AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _searchAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: _buildEnhancedSearchBar(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeader() {
    return Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF8B5CF6), size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                    ),
                    BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, state) {
                  String subtitle = 'Connect with the global emotional community';
                  
                  if (state is FriendSearchLoaded && widget.showSearch) {
                    final count = state.searchResults.length;
                    final total = state.totalResults;
                    subtitle = count > 0 ? '$count of $total users found' : 'No users found';
                  } else if (state is FriendsLoaded) {
                    final friendCount = state.friends.length;
                    subtitle = friendCount > 0 
                        ? '$friendCount friends connected' 
                        : 'Start building your community';
                  }
                  
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      subtitle,
                      key: ValueKey(subtitle),
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
        _buildSearchToggleButton(),
      ],
    );
  }

  Widget _buildSearchToggleButton() {
    return GestureDetector(
      onTap: widget.onSearchToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
          color: widget.showSearch 
              ? const Color(0xFF8B5CF6).withOpacity(0.2)
              : const Color(0xFF8B5CF6).withOpacity(0.1),
          border: Border.all(
            color: widget.showSearch 
                ? const Color(0xFF8B5CF6).withOpacity(0.5)
                : const Color(0xFF8B5CF6).withOpacity(0.3),
          ),
        ),
        child: Icon(
          widget.showSearch ? Icons.close : Icons.search,
          color: const Color(0xFF8B5CF6),
                      size: 20,
                    ),
      ),
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF16213E).withOpacity(0.6),
          ],
        ),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: const Color(0xFF8B5CF6).withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search by username or display name...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => widget.onSearchChanged(value.trim()),
            ),
          ),
          if (widget.searchController.text.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                widget.searchController.clear();
                widget.onSearchClear();
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[600]?.withOpacity(0.3),
                ),
                child: const Icon(Icons.close, color: Colors.grey, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}



class EnhancedDiscoverTab extends StatefulWidget {
  final bool isSearching;
  final String searchQuery;
  final Function(String) onSendFriendRequest;
  final FriendBloc friendBloc;

  const EnhancedDiscoverTab({
    super.key,
    required this.isSearching,
    required this.searchQuery,
    required this.onSendFriendRequest,
    required this.friendBloc,
  });

  @override
  State<EnhancedDiscoverTab> createState() => _EnhancedDiscoverTabState();
}

class _EnhancedDiscoverTabState extends State<EnhancedDiscoverTab>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocBuilder<FriendBloc, FriendState>(
      builder: (context, state) {
        if (widget.isSearching && widget.searchQuery.isNotEmpty) {
          return _buildSearchContent(state);
        }
        return _buildDiscoverContent(state);
      },
    );
  }

  Widget _buildSearchContent(FriendState state) {
    if (state is FriendSearchLoading) {
      return _buildSearchLoadingState();
    } else if (state is FriendSearchLoaded) {
      return _buildSearchResults(state);
    } else if (state is FriendSearchEmpty) {
      return _buildSearchEmptyState();
    } else if (state is FriendSearchError) {
      return _buildSearchErrorState(state);
    }
    return _buildSearchLoadingState();
  }

  Widget _buildDiscoverContent(FriendState state) {
    if (state is FriendsLoaded) {
      return _buildSuggestionsList(state.suggestions);
    } else if (state is FriendLoading) {
      return _buildSuggestionsLoadingState();
    } else if (state is FriendError) {
      return _buildErrorState(state.message);
    }
    return _buildSuggestionsLoadingState();
  }

  Widget _buildSuggestionsList(List<FriendSuggestionEntity> suggestions) {
    if (suggestions.isEmpty) {
      return _buildEmptyDiscoverState();
    }
    
    return RefreshIndicator(
      color: const Color(0xFF8B5CF6),
      backgroundColor: const Color(0xFF1A1A2E),
      onRefresh: () async {
        widget.friendBloc.add(const LoadFriendSuggestionsEvent(forceRefresh: true));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EnhancedUserSuggestionCard(
                      suggestion: suggestions[index],
                      onSendRequest: () => widget.onSendFriendRequest(suggestions[index].id),
                      friendBloc: widget.friendBloc,
                    ),
                  );
                },
                childCount: suggestions.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(
child: SizedBox(height: 100), 
          ),
        ],
      ),
    );
  }


  Widget _buildSearchResults(FriendSearchLoaded state) {
    if (state.searchResults.isEmpty) {
      return _buildSearchEmptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFF8B5CF6),
      backgroundColor: const Color(0xFF1A1A2E),
      onRefresh: () async {
        widget.friendBloc.add(SearchUsersEvent(
          query: widget.searchQuery,
          page: state.currentPage,
          limit: state.searchResults.length,
        ));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: _buildSearchResultsHeader(state),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: EnhancedUserSuggestionCard(
                      suggestion: state.searchResults[index],
                      onSendRequest: () => widget.onSendFriendRequest(state.searchResults[index].id),
                      friendBloc: widget.friendBloc,
                    ),
                  );
                },
                childCount: state.searchResults.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSearchResultsHeader(FriendSearchLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    children: [
                      const TextSpan(text: 'Results for "'),
                      TextSpan(
                        text: widget.searchQuery,
                        style: const TextStyle(color: Color(0xFF8B5CF6)),
                      ),
                      const TextSpan(text: '"'),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.searchResults.length} of ${state.totalResults} users found',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Searching for users...',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Finding people in the community',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF8B5CF6), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Loading suggestions...',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchEmptyState() {
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
                    const Color(0xFF8B5CF6).withOpacity(0.3),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: const Icon(Icons.search_off_rounded, size: 50, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Users Found',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'No users match "${widget.searchQuery}"\nTry different keywords or check spelling.',
              style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.friendBloc.add(const LoadFriendSuggestionsEvent(forceRefresh: true));
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Browse Suggestions',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDiscoverState() {
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
                    const Color(0xFF8B5CF6).withOpacity(0.3),
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: const Icon(Icons.explore_outlined, size: 50, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Suggestions Available',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'We\'re working on finding great people for you to connect with.\nCheck back soon!',
              style: TextStyle(color: Colors.grey[400], fontSize: 15, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.friendBloc.add(const LoadFriendSuggestionsEvent(forceRefresh: true));
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchErrorState(FriendSearchError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Icon(Icons.error_outline_rounded, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Search Failed',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.friendBloc.add(SearchUsersEvent(query: widget.searchQuery));
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                widget.friendBloc.add(const LoadFriendSuggestionsEvent(forceRefresh: true));
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class EnhancedUserSuggestionCard extends StatefulWidget {
  final FriendSuggestionEntity suggestion;
  final VoidCallback onSendRequest;
  final FriendBloc friendBloc;

  const EnhancedUserSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onSendRequest,
    required this.friendBloc,
  });

  @override
  State<EnhancedUserSuggestionCard> createState() => _EnhancedUserSuggestionCardState();
}

class _EnhancedUserSuggestionCardState extends State<EnhancedUserSuggestionCard>
    with TickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.9),
                  const Color(0xFF16213E).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  blurRadius: 15 + _elevationAnimation.value,
                  offset: Offset(0, 8 + _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showUserProfile(context),
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildProfileAvatar(),
                          const SizedBox(width: 16),
                          Expanded(child: _buildUserInfo()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActionSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfileAvatar() {
    return Hero(
      tag: 'avatar_${widget.suggestion.id}',
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.3),
              const Color(0xFF8B5CF6).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4), width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getAvatarEmoji(widget.suggestion.selectedAvatar),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.suggestion.displayName.isNotEmpty 
                    ? widget.suggestion.displayName 
                    : widget.suggestion.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
          ),
          child: Text(
            '@${widget.suggestion.username}',
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.grey[500], size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _formatLocation(widget.suggestion.location),
                style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        if (widget.suggestion.mutualFriends > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF10B981).withOpacity(0.1),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline_rounded, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${widget.suggestion.mutualFriends} mutual friend${widget.suggestion.mutualFriends > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildActionSection() {
    return Column(
      children: [
        if (widget.suggestion.commonInterests.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Common Interests',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.suggestion.commonInterests.take(4).map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: Text(
                  interest,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        SizedBox(
          width: double.infinity,
          child: BlocBuilder<FriendBloc, FriendState>(
            bloc: widget.friendBloc,
            builder: (context, state) {
              final status = _getButtonStatus(widget.friendBloc, state);
              
              return EnhancedFriendRequestButton(
                userId: widget.suggestion.id,
                status: status,
                onPressed: status == FriendRequestStatus.notRequested ? widget.onSendRequest : null,
                isCompact: false,
              );
            },
          ),
        ),
      ],
    );
  }

  FriendRequestStatus _getButtonStatus(FriendBloc friendBloc, FriendState state) {
    if (state is FriendRequestActionLoading && state.targetUserId == widget.suggestion.id) {
      return FriendRequestStatus.sending;
    }
    
    if (state is FriendsLoaded && state.friends.any((f) => f.id == widget.suggestion.id)) {
      return FriendRequestStatus.friends;
    }
    
    if (state is FriendsLoaded && 
        state.sentRequests.any((req) => req.userId == widget.suggestion.id)) {
      return FriendRequestStatus.requested;
    }
    
    if (state is FriendsLoaded && 
        state.receivedRequests.any((req) => req.userId == widget.suggestion.id)) {
      return FriendRequestStatus.requested;
    }
    
    if (widget.suggestion.isRequested) {
      return FriendRequestStatus.requested;
    }
    
    return FriendRequestStatus.notRequested;
  }
  
  void _showUserProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: widget.friendBloc,
        child: UserProfileModal(
        user: widget.suggestion,
        friendBloc: widget.friendBloc,
        ),
      ),
    );
  }
  
  String _getAvatarEmoji(String avatarName) {
    const avatarEmojis = {
      'panda': '🐼', 'elephant': '🐘', 'horse': '🐴', 'rabbit': '🐰',
      'fox': '🦊', 'zebra': '🦓', 'bear': '🐻', 'pig': '🐷',
      'raccoon': '🦝', 'cat': '🐱', 'dog': '🐶', 'owl': '🦉', 'penguin': '🐧',
    };
    return avatarEmojis[avatarName.toLowerCase()] ?? '🐾';
  }
  
  String _formatLocation(String? location) {
    if (location == null || location.isEmpty || location == 'Unknown') {
      return 'Location not specified';
    }
    return location;
  }
}




class EnhancedSearchResultCard extends StatefulWidget {
  final FriendSuggestionEntity suggestion;
  final VoidCallback onSendRequest;
  final FriendBloc friendBloc;

  const EnhancedSearchResultCard({
    super.key,
    required this.suggestion,
    required this.onSendRequest,
    required this.friendBloc,
  });

  @override
  State<EnhancedSearchResultCard> createState() => _EnhancedSearchResultCardState();
}

class _EnhancedSearchResultCardState extends State<EnhancedSearchResultCard>
    with TickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1A1A2E).withOpacity(0.9),
                  const Color(0xFF16213E).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  blurRadius: 10 + _elevationAnimation.value,
                  offset: Offset(0, 4 + _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showUserProfile(context),
                onTapDown: (_) => _hoverController.forward(),
                onTapUp: (_) => _hoverController.reverse(),
                onTapCancel: () => _hoverController.reverse(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildProfileAvatar(),
                      const SizedBox(width: 16),
                      Expanded(child: _buildUserInfo()),
                      const SizedBox(width: 12),
                      _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildProfileAvatar() {
    return Hero(
      tag: 'avatar_${widget.suggestion.id}',
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.3),
              const Color(0xFF8B5CF6).withOpacity(0.1),
              Colors.transparent,
            ],
          ),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getAvatarEmoji(widget.suggestion.selectedAvatar),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.suggestion.displayName.isNotEmpty 
                    ? widget.suggestion.displayName 
                    : widget.suggestion.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                ),
                child: Text(
                  '@${widget.suggestion.username}',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.grey[500], size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _formatLocation(widget.suggestion.location),
                style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (widget.suggestion.mutualFriends > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Text(
                  '${widget.suggestion.mutualFriends} mutual friend${widget.suggestion.mutualFriends > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildActionButton() {
    return BlocBuilder<FriendBloc, FriendState>(
      bloc: widget.friendBloc,
      builder: (context, state) {
        final status = _getButtonStatus(widget.friendBloc, state);
        
        return EnhancedFriendRequestButton(
          userId: widget.suggestion.id,
          status: status,
          onPressed: status == FriendRequestStatus.notRequested ? widget.onSendRequest : null,
          isCompact: false,
        );
      },
    );
  }

  FriendRequestStatus _getButtonStatus(FriendBloc friendBloc, FriendState state) {
    if (state is FriendRequestActionLoading && state.targetUserId == widget.suggestion.id) {
      return FriendRequestStatus.sending;
    }
    
    if (state is FriendsLoaded && state.friends.any((f) => f.id == widget.suggestion.id)) {
      return FriendRequestStatus.friends;
    }
    
    if (state is FriendsLoaded && 
        state.sentRequests.any((req) => req.userId == widget.suggestion.id)) {
      return FriendRequestStatus.requested;
    }
    
    if (state is FriendsLoaded && 
        state.receivedRequests.any((req) => req.userId == widget.suggestion.id)) {
      return FriendRequestStatus.requested;
    }
    
    if (widget.suggestion.isRequested) {
      return FriendRequestStatus.requested;
    }
    
    return FriendRequestStatus.notRequested;
  }
  
  void _showUserProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: widget.friendBloc,
        child: UserProfileModal(
        user: widget.suggestion,
        friendBloc: widget.friendBloc,
        ),
      ),
    );
  }
  
  String _getAvatarEmoji(String avatarName) {
    const avatarEmojis = {
      'panda': '🐼', 'elephant': '🐘', 'horse': '🐴', 'rabbit': '🐰',
      'fox': '🦊', 'zebra': '🦓', 'bear': '🐻', 'pig': '🐷',
      'raccoon': '🦝', 'cat': '🐱', 'dog': '🐶', 'owl': '🦉', 'penguin': '🐧',
    };
    return avatarEmojis[avatarName.toLowerCase()] ?? '🐾';
  }
  
  String _formatLocation(String? location) {
    if (location == null || location.isEmpty || location == 'Unknown') {
      return 'Location not specified';
    }
    return location;
  }
}


class UserProfileModal extends StatelessWidget {
  final FriendSuggestionEntity user;
  final FriendBloc friendBloc;

  const UserProfileModal({super.key, required this.user, required this.friendBloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildProfileContent(),
            ),
          ),
          _buildActionBar(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.9),
            const Color(0xFF16213E).withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Text(
            'User Profile',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.8),
                const Color(0xFF16213E).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Hero(
                tag: 'avatar_${user.id}',
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.4), width: 3),
                  ),
                  child: Center(
                    child: Text(
                      _getAvatarEmoji(user.selectedAvatar),
                      style: const TextStyle(fontSize: 50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName.isNotEmpty ? user.displayName : user.username,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailSection('Location', user.location ?? 'Not specified', Icons.location_on_rounded),
        if (user.mutualFriends > 0) ...[
          const SizedBox(height: 16),
          _buildDetailSection(
            'Mutual Friends',
            '${user.mutualFriends} friend${user.mutualFriends > 1 ? 's' : ''} in common',
            Icons.people_outline_rounded,
          ),
        ],
        if (user.commonInterests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInterestsSection(),
        ],
      ],
    );
  }
  
  Widget _buildDetailSection(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
      ),
      child: Row(
          children: [
            Container(
          padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
        Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                title,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 2),
              Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      ],
      ),
    );
  }
  
  Widget _buildInterestsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.interests_outlined, color: Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Common Interests',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
            ),
                            ],
                          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.commonInterests.take(5).map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Text(
                  interest,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
                    ),
          if (user.commonInterests.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '+${user.commonInterests.length - 5} more',
              style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
                  ],
                ),
    );
  }
  
  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.9),
        border: Border(top: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<FriendBloc, FriendState>(
              builder: (context, state) {
                final status = _getButtonStatus(state);
                
                return EnhancedFriendRequestButton(
                  userId: user.id,
                  status: status,
                  onPressed: () {
                    friendBloc.add(SendFriendRequestEvent(userId: user.id));
                    Navigator.pop(context);
                  },
                  isCompact: false,
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }

  FriendRequestStatus _getButtonStatus(FriendState state) {
    if (state is FriendRequestActionLoading && state.targetUserId == user.id) {
      return FriendRequestStatus.sending;
    }
    
    if (state is FriendsLoaded && state.friends.any((f) => f.id == user.id)) {
      return FriendRequestStatus.friends;
    }
    
    if (state is FriendsLoaded && 
        state.pendingRequests['sent']?.any((req) => req.userId == user.id) == true) {
      return FriendRequestStatus.requested;
    }
    
    if (user.isRequested) {
      return FriendRequestStatus.requested;
    }
    
    return FriendRequestStatus.notRequested;
  }
  
  String _getAvatarEmoji(String avatarName) {
    const avatarEmojis = {
      'panda': '🐼', 'elephant': '🐘', 'horse': '🐴', 'rabbit': '🐰',
      'fox': '🦊', 'zebra': '🦓', 'bear': '🐻', 'pig': '🐷',
      'raccoon': '🦝', 'cat': '🐱', 'dog': '🐶', 'owl': '🦉', 'penguin': '🐧',
    };
    return avatarEmojis[avatarName.toLowerCase()] ?? '🐾';
  }
}


class ChatView extends StatelessWidget {
  final String friendId;
  final String friendName;
  const ChatView({required this.friendId, required this.friendName, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with $friendName')),
      body: Center(child: Text('Chat with $friendName (Coming soon)')),
    );
  }
}