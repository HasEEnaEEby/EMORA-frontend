import 'package:emora_mobile_app/app/constants/emotion_constants.dart';
import 'package:flutter/material.dart';

class EnhancedDashboardHeader extends StatefulWidget {
  final String selectedMood;
  final String? selectedAvatar;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const EnhancedDashboardHeader({
    super.key,
    required this.selectedMood,
    this.selectedAvatar,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  State<EnhancedDashboardHeader> createState() =>
      _EnhancedDashboardHeaderState();
}

class _EnhancedDashboardHeaderState extends State<EnhancedDashboardHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(widget.selectedMood);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar with emotion-based styling
          _buildUserAvatar(emotion),

          // EMORA Title (centered)
          Expanded(
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [emotion['color'], emotion['color'].withOpacity(0.7)],
                ).createShader(bounds),
                child: const Text(
                  'EMORA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
                ),
              ),
            ),
          ),

          // Notification Icon
          _buildNotificationIcon(emotion),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(Map<String, dynamic> emotion) {
    return GestureDetector(
      onTap: widget.onAvatarTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    emotion['color'].withOpacity(0.8),
                    emotion['color'].withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: emotion['color'].withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: emotion['color'].withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: emotion['color'].withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getAvatarEmoji(widget.selectedAvatar ?? 'panda'),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationIcon(Map<String, dynamic> emotion) {
    return GestureDetector(
      onTap: widget.onNotificationTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          shape: BoxShape.circle,
          border: Border.all(
            color: emotion['color'].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                color: emotion['color'],
                size: 22,
              ),
            ),
            // Notification dot
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: emotion['color'],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: emotion['color'].withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAvatarEmoji(String avatar) {
    final avatarMap = {
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
      'lion': '🦁',
      'tiger': '🐯',
      'koala': '🐨',
      'monkey': '🐵',
    };
    return avatarMap[avatar] ?? '🐾';
  }
}

// Alternative Minimalistic Version (even simpler)
class MinimalDashboardHeader extends StatelessWidget {
  final String selectedMood;
  final String? selectedAvatar;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const MinimalDashboardHeader({
    super.key,
    required this.selectedMood,
    this.selectedAvatar,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(selectedMood);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Simple User Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emotion['color'].withOpacity(0.2),
                border: Border.all(
                  color: emotion['color'].withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getAvatarEmoji(selectedAvatar ?? 'panda'),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),

          // Clean EMORA Logo
          Text(
            'EMORA',
            style: TextStyle(
              color: emotion['color'],
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
            ),
          ),

          // Simple Notification
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: emotion['color'],
                        shape: BoxShape.circle,
                      ),
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

  String _getAvatarEmoji(String avatar) {
    final avatarMap = {
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
      'lion': '🦁',
      'tiger': '🐯',
      'koala': '🐨',
      'monkey': '🐵',
    };
    return avatarMap[avatar] ?? '🐾';
  }
}

// Ultra Minimal Version (closest to your design)
class UltraMinimalHeader extends StatelessWidget {
  final String selectedMood;
  final String? selectedAvatar;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationTap;

  const UltraMinimalHeader({
    super.key,
    required this.selectedMood,
    this.selectedAvatar,
    this.onAvatarTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = EmotionConstants.getEmotion(selectedMood);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Avatar - matches your design
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    emotion['color'].withOpacity(0.8),
                    emotion['color'].withOpacity(0.4),
                  ],
                ),
                border: Border.all(
                  color: emotion['color'].withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  _getAvatarEmoji(selectedAvatar ?? 'panda'),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),

          // Just EMORA text - clean and simple
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [emotion['color'], emotion['color'].withOpacity(0.8)],
            ).createShader(bounds),
            child: const Text(
              'EMORA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
          ),

          // Notification - matches your design
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A3E),
                border: Border.all(
                  color: emotion['color'].withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: emotion['color'],
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: emotion['color'],
                        shape: BoxShape.circle,
                      ),
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

  String _getAvatarEmoji(String avatar) {
    final avatarMap = {
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
      'lion': '🦁',
      'tiger': '🐯',
      'koala': '🐨',
      'monkey': '🐵',
    };
    return avatarMap[avatar] ?? '🐾';
  }
}
