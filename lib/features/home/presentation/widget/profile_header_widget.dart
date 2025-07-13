// lib/features/profile/presentation/widget/profile_header_widget.dart
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAvatarTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    this.onEditProfile,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            const Color(0xFF8B5CF6).withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildAvatarSection(context),
          const SizedBox(height: 16),
          _buildUserInfo(context),
          const SizedBox(height: 16),
          _buildStatsRow(context),
          const SizedBox(height: 16),
          _buildLevelBadge(context),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getAvatarEmoji(profile.avatar),
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
        ),
        if (onEditProfile != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditProfile,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0A0F), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        // Display displayName only (no fallback)
        if (profile.displayName != null)
          Text(
            profile.displayName!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              profile.bio!,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 6),

        // Username as secondary info (read-only)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alternate_email, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                profile.username,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Display email from database
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.email_outlined, size: 16, color: Colors.grey[300]),
              const SizedBox(width: 8),
              Text(
                profile.email,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Display join date (createdAt from database)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              'Joined ${_formatJoinDate(profile.joinDate)}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'Entries',
            profile.totalEntries.toString(),
            Icons.edit_note,
            const Color(0xFF10B981),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Streak',
            profile.currentStreak.toString(),
            Icons.local_fire_department,
            const Color(0xFFF59E0B),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Friends',
            profile.totalFriends.toString(),
            Icons.people,
            const Color(0xFF3B82F6),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Badges',
            profile.badgesEarned.toString(),
            Icons.emoji_events,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF8B5CF6), const Color(0xFFD8A5FF)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getLevelIcon(profile.level), size: 22, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            profile.level,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Maps database avatar names to emojis
  /// Supports all avatars from your database: fox, rabbit, panda, elephant, horse, zebra, bear, pig, raccoon, cat, dog, owl, penguin
  String _getAvatarEmoji(String? avatarName) {
    final avatarMap = {
      // Your database avatars
      'fox': '🦊',
      'rabbit': '🐰',
      'panda': '🐼',
      'elephant': '🐘',
      'horse': '🐴',
      'zebra': '🦓',
      'bear': '🐻',
      'pig': '🐷',
      'raccoon': '🦝',
      'cat': '🐱',
      'dog': '🐶',
      'owl': '🦉',
      'penguin': '🐧',

      // Additional fallback avatars
      'tiger': '🐯',
      'lion': '🦁',
      'monkey': '🐵',
      'koala': '🐨',
      'wolf': '🐺',
      'hamster': '🐹',
      'mouse': '🐭',
      'bird': '🐦',
      'duck': '🦆',
      'chicken': '🐔',
      'turtle': '🐢',
      'fish': '🐠',
      'dolphin': '🐬',
      'whale': '🐳',
      'octopus': '🐙',

      // Emoji-style avatars (fallback)
      'happy': '😊',
      'excited': '🤩',
      'calm': '😌',
      'peaceful': '🕊️',
      'energetic': '⚡',
      'creative': '🎨',
      'wise': '🦉',
      'brave': '🦁',
      'gentle': '🐱',
      'playful': '🐶',
      'mystical': '🦄',
      'nature': '🌸',
      'ocean': '🌊',
      'mountain': '🏔️',
      'star': '⭐',
      'moon': '🌙',
      'sun': '☀️',
      'rainbow': '🌈',
      'butterfly': '🦋',
      'tree': '🌳',
    };

    return avatarMap[avatarName?.toLowerCase()] ?? '🦊'; // Default to fox
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'emotion master':
        return Icons.psychology;
      case 'mindful sage':
        return Icons.auto_awesome;
      case 'feeling guide':
        return Icons.explore;
      case 'emotion seeker':
        return Icons.search;
      case 'mindful beginner':
        return Icons.school;
      case 'new explorer':
        return Icons.explore_outlined;
      default:
        return Icons.star;
    }
  }

  String _formatJoinDate(DateTime joinDate) {
    final now = DateTime.now();
    final difference = now.difference(joinDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1
          ? '1 day ago'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1
          ? '1 minute ago'
          : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
