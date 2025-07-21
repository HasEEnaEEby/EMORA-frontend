import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/friend_bloc.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/friend_event.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        title = 'Request Cancelled! ✅';
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
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
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
                            gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('💝', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 6),
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
}
