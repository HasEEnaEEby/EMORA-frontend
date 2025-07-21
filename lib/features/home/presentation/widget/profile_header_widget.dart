// lib/features/profile/presentation/widget/profile_header_widget.dart - BACKEND CONNECTED VERSION
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileEntity profile;
  final VoidCallback? onEditProfile;
  final VoidCallback? onAvatarTap;
  final Function(String)? onAvatarChanged;
  final bool isLoading; // New: Loading state for stats

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    this.onEditProfile,
    this.onAvatarTap,
    this.onAvatarChanged,
    this.isLoading = false,
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
            profile.themeColorAsColor.withValues(alpha: 0.15),
            profile.themeColorAsColor.withValues(alpha: 0.05),
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
          _buildStatsRow(context), // Connected to backend data
          const SizedBox(height: 16),
          _buildLevelBadge(context),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return GestureDetector(
      onTap: onAvatarTap ?? () {
        HapticFeedback.lightImpact();
        _showAvatarSelectionDialog(context);
      },
          child: Container(
        padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
              profile.themeColorAsColor.withValues(alpha: 0.3),
              profile.themeColorAsColor.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
              color: profile.themeColorAsColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
                ),
              ],
            ),
              child: Container(
          width: 80,
          height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
                         child: Text(
               DialogUtils.getEmojiForAvatar(profile.avatar ?? 'fox'),
               style: const TextStyle(fontSize: 40),
             ),
              ),
            ),
          ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        Text(
          profile.effectiveDisplayName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
              Text(
          '@${profile.username}',
                style: TextStyle(
                  color: Colors.grey[400],
            fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            profile.bio!,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
              fontWeight: FontWeight.w400,
                    ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// ✅ BACKEND CONNECTED: Stats row with real data from your API
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading
          ? _buildLoadingStatsRow()
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            'Entries',
                  _formatStatValue(profile.totalEntries),
            Icons.edit_note,
            const Color(0xFF10B981),
                  subtitle: _getEntriesSubtitle(),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Streak',
                  _formatStatValue(profile.currentStreak),
            Icons.local_fire_department,
            const Color(0xFFF59E0B),
                  subtitle: _getStreakSubtitle(),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Friends',
                  _formatStatValue(profile.totalFriends),
            Icons.people,
            const Color(0xFF3B82F6),
                  subtitle: _getFriendsSubtitle(),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            context,
            'Badges',
                  _formatStatValue(profile.badgesEarned),
            Icons.emoji_events,
            const Color(0xFFEF4444),
                  subtitle: _getBadgesSubtitle(),
          ),
        ],
      ),
    );
  }

  /// Loading state for stats
  Widget _buildLoadingStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLoadingStatItem(),
        _buildVerticalDivider(),
        _buildLoadingStatItem(),
        _buildVerticalDivider(),
        _buildLoadingStatItem(),
        _buildVerticalDivider(),
        _buildLoadingStatItem(),
      ],
    );
  }

  Widget _buildLoadingStatItem() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[700]?.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 24,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  /// Enhanced stat item with backend data and optional subtitle
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onStatTapped(context, label, value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
      children: [
              // Icon with animated background
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
          ),
          child: Icon(icon, size: 20, color: color),
                    ),
                  );
                },
        ),
        const SizedBox(height: 6),
              
              // Value with number animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(
                  begin: 0.0, 
                  end: double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
                ),
                builder: (context, animatedValue, child) {
                  return Text(
                    _formatAnimatedValue(animatedValue, value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
          ),
                  );
                },
        ),
              
              // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
              
              // Optional subtitle for additional context
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Handle stat item taps for detailed views
  void _onStatTapped(BuildContext context, String label, String value) {
    HapticFeedback.lightImpact();
    
    String message = '';
    switch (label.toLowerCase()) {
      case 'entries':
        message = 'You\'ve logged $value emotion entries! Keep tracking your emotional journey.';
        break;
      case 'streak':
        message = profile.currentStreak > 0 
            ? 'Amazing! You\'re on a $value day streak. Keep it up!'
            : 'Start logging daily to build your streak!';
        break;
      case 'friends':
        message = profile.totalFriends > 0
            ? 'You have $value friends supporting your journey!'
            : 'Connect with friends to share your emotional wellness journey!';
        break;
      case 'badges':
        message = profile.badgesEarned > 0
            ? 'You\'ve earned $value achievement badges! Check your achievements for more.'
            : 'Complete activities to earn your first achievement badge!';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: profile.themeColorAsColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            profile.themeColorAsColor.withValues(alpha: 0.2),
            profile.themeColorAsColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: profile.themeColorAsColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: profile.themeColorAsColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            profile.level,
            style: TextStyle(
              color: profile.themeColorAsColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarSelectionDialog(BuildContext context) {
    // Implementation for avatar selection dialog
    // This would show available avatars for selection
  }

  /// ✅ HELPER METHODS for backend data formatting

  /// Format stat values with appropriate units
  String _formatStatValue(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toString();
                      }

  /// Format animated values during transitions
  String _formatAnimatedValue(double animatedValue, String originalValue) {
    if (originalValue.contains('k')) {
      return '${(animatedValue / 1000).toStringAsFixed(1)}k';
    }
    return animatedValue.round().toString();
  }

  /// Get contextual subtitles for each stat
  String? _getEntriesSubtitle() {
    if (profile.totalEntries == 0) return 'Start logging';
    if (profile.totalEntries < 5) return 'Getting started';
    if (profile.totalEntries < 30) return 'Building habits';
    if (profile.totalEntries < 100) return 'Great progress';
    return 'Expert tracker';
  }

  String? _getStreakSubtitle() {
    if (profile.currentStreak == 0) return 'No streak yet';
    if (profile.currentStreak == 1) return 'Good start!';
    if (profile.currentStreak < 7) return 'Building up';
    if (profile.currentStreak < 30) return 'On fire! 🔥';
    return 'Legendary! 🏆';
  }

  String? _getFriendsSubtitle() {
    if (profile.totalFriends == 0) return 'Add friends';
    if (profile.totalFriends < 5) return 'Growing network';
    if (profile.totalFriends < 10) return 'Social butterfly';
    return 'Community leader';
  }

  String? _getBadgesSubtitle() {
    if (profile.badgesEarned == 0) return 'Earn your first';
    if (profile.badgesEarned < 5) return 'Collecting badges';
    if (profile.badgesEarned < 10) return 'Achievement hunter';
    return 'Badge master';
  }
}