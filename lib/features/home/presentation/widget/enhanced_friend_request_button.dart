
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FriendRequestStatus {
  notRequested,
  sending,
  requested,
  accepted,
  friends,
  error
}

class EnhancedFriendRequestButton extends StatefulWidget {
  final String userId;
  final FriendRequestStatus status;
  final VoidCallback onPressed;
  final String? errorMessage;
  final bool isCompact;

  const EnhancedFriendRequestButton({
    super.key,
    required this.userId,
    required this.status,
    required this.onPressed,
    this.errorMessage,
    this.isCompact = false,
  });

  @override
  State<EnhancedFriendRequestButton> createState() => _EnhancedFriendRequestButtonState();
}

class _EnhancedFriendRequestButtonState extends State<EnhancedFriendRequestButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void didUpdateWidget(EnhancedFriendRequestButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleStatusChange(oldWidget.status, widget.status);
  }

  void _handleStatusChange(FriendRequestStatus oldStatus, FriendRequestStatus newStatus) {
    _pulseController.stop();
    _successController.stop();
    _shimmerController.stop();

    switch (newStatus) {
      case FriendRequestStatus.sending:
        _pulseController.repeat(reverse: true);
        break;
      case FriendRequestStatus.requested:
        _shimmerController.repeat();
        break;
      case FriendRequestStatus.accepted:
      case FriendRequestStatus.friends:
        _successController.forward();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _buildButtonByStatus(),
    );
  }

  Widget _buildButtonByStatus() {
    switch (widget.status) {
      case FriendRequestStatus.notRequested:
        return _buildDefaultButton();
      case FriendRequestStatus.sending:
        return _buildSendingButton();
      case FriendRequestStatus.requested:
        return _buildRequestedButton();
      case FriendRequestStatus.accepted:
        return _buildAcceptedButton();
      case FriendRequestStatus.friends:
        return _buildFriendsButton();
      case FriendRequestStatus.error:
        return _buildErrorButton();
    }
  }

  Widget _buildDefaultButton() {
    return _buildBaseButton(
      text: widget.isCompact ? 'Add' : 'Add Friend',
      icon: Icons.person_add_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onPressed();
      },
    );
  }

  Widget _buildSendingButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: _buildBaseButton(
            text: widget.isCompact ? 'Sending...' : 'Sending Request...',
            icon: null,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.8),
                const Color(0xFF6366F1).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
onTap: null, 
          ),
        );
      },
    );
  }

  Widget _buildRequestedButton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              _buildBaseButton(
                text: widget.isCompact ? 'Pending' : 'Request Sent',
                icon: Icons.schedule_outlined,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
onTap: null, 
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
                  child: Transform.translate(
                    offset: Offset(_shimmerAnimation.value * 100, 0),
                    child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAcceptedButton() {
    return AnimatedBuilder(
      animation: _successAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_successAnimation.value * 0.1),
          child: _buildBaseButton(
            text: widget.isCompact ? 'Accepted!' : 'Request Accepted!',
            icon: Icons.check_circle_outline,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
onTap: null, 
          ),
        );
      },
    );
  }

  Widget _buildFriendsButton() {
    return _buildBaseButton(
      text: widget.isCompact ? 'Friends' : 'Already Friends',
      icon: Icons.people_outline,
      gradient: const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF059669)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
onTap: null, 
    );
  }

  Widget _buildErrorButton() {
    return _buildBaseButton(
      text: widget.isCompact ? 'Retry' : 'Try Again',
      icon: Icons.refresh_outlined,
      gradient: const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
    );
  }

  Widget _buildBaseButton({
    required String text,
    IconData? icon,
    required Gradient gradient,
    required VoidCallback? onTap,
    Widget? child,
  }) {
    final bool isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.7,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 12 : 16,
            vertical: widget.isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(widget.isCompact ? 8 : 12),
            boxShadow: isEnabled ? [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (child != null) 
                child
              else if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: widget.isCompact ? 14 : 16,
                ),
                if (!widget.isCompact) const SizedBox(width: 8),
              ],
              if (!widget.isCompact || child == null)
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isCompact ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendRequestStatusNotification extends StatelessWidget {
  final String message;
  final FriendRequestStatus status;
  final VoidCallback? onTap;

  const FriendRequestStatusNotification({
    super.key,
    required this.message,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    
    switch (status) {
      case FriendRequestStatus.requested:
        backgroundColor = const Color(0xFFFFD700);
        icon = Icons.schedule;
        break;
      case FriendRequestStatus.accepted:
        backgroundColor = const Color(0xFF10B981);
        icon = Icons.check_circle;
        break;
      case FriendRequestStatus.error:
        backgroundColor = const Color(0xFFEF4444);
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = const Color(0xFF8B5CF6);
        icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
} 