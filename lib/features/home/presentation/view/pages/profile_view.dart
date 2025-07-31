import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_state.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/achievement_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/profile_entity.dart';
import 'package:emora_mobile_app/features/profile/domain/entity/user_preferences_entity.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widget/dialog/edit_profile_dialog.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/services/logout_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadProfile());
        _startAnimations();
      }
    });
  }

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: const Color(0xFF0A0A0F), 
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: _handleBlocListener,
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: _handleAuthListener,
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return _buildMainContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(ProfileState state) {
    if (state is ProfileLoading) {
      return _buildLoadingView();
    } else if (state is ProfileLoaded ||
        state is ProfileUpdating ||
        state is ProfilePreferencesUpdating ||
        state is ProfileAchievementsLoading ||
        state is ProfileDataExporting ||
        state is ProfileDataExported) {
      
      ProfileEntity profile;
      UserPreferencesEntity? preferences;
      List<AchievementEntity> achievements = [];

      if (state is ProfileLoaded) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else if (state is ProfileUpdating) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else if (state is ProfilePreferencesUpdating) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else if (state is ProfileAchievementsLoading) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else if (state is ProfileDataExporting) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else if (state is ProfileDataExported) {
        profile = state.profile;
        preferences = state.preferences;
        achievements = state.achievements;
      } else {
        return _buildErrorView();
      }

      return _buildProfileContent(profile, preferences, achievements, state);
    } else if (state is ProfileError && state.profile != null) {
      return _buildProfileContent(
        state.profile!,
        state.preferences,
        state.achievements ?? [],
        state,
      );
    } else {
      return _buildErrorView();
    }
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF8B5CF6),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Profile...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We couldn\'t load your profile. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(const LoadProfile());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    ProfileEntity profile,
    UserPreferencesEntity? preferences,
    List<AchievementEntity> achievements,
    ProfileState state,
  ) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF8B5CF6),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0F),
            foregroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              profile.username.isNotEmpty ? profile.username : 'Profile',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onPressed: () => _showMoreOptions(context, profile, state),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildProfileHeader(profile),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildAchievementsSection(achievements, state),
                    const SizedBox(height: 24),
                    _buildAboutSection(profile),
                    const SizedBox(height: 24),
                    _buildSettingsSection(preferences ?? const UserPreferencesEntity(), state),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileEntity profile) {
    return Container(
      color: const Color(0xFF0A0A0F),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFFEC4899),
                      const Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0A0A0F),
                    border: Border.all(color: const Color(0xFF0A0A0F), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                    child: Text(
                      _getAvatarEmoji(profile.effectiveAvatar),
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 32),
              
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('${profile.totalEntries}', 'Entries'),
                    _buildStatColumn('${profile.totalFriends}', 'Friends'),
                    _buildStatColumn('${profile.currentStreak}', 'Streak'),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  profile.effectiveDisplayName.isNotEmpty
                      ? profile.effectiveDisplayName
                      : (profile.username.isNotEmpty ? profile.username : 'User'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              if (profile.pronouns != null && profile.pronouns!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  profile.pronouns!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              
              if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
color: const Color(0xFF1E1B3A), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    profile.bio!,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[300],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green[400],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active ${_formatLastActive(profile.lastActive ?? DateTime.now())}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6),
                        const Color(0xFF7C3AED),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showSimpleMessage('Share coming soon!'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<AchievementEntity> achievements, ProfileState state) {
    final earnedAchievements = achievements.where((a) => a.earned).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Achievements (${earnedAchievements.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (achievements.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No achievements yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start logging emotions to earn badges!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: earnedAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = earnedAchievements[index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getAchievementColor(achievement.color).withOpacity(0.1),
                            border: Border.all(
                              color: _getAchievementColor(achievement.color),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _getAchievementIcon(achievement.icon),
                            color: _getAchievementColor(achievement.color),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProfileEntity profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: const Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAboutItem(
            Icons.email_outlined,
            'Email',
            profile.email ?? 'Not provided',
          ),
          const SizedBox(height: 16),
          _buildAboutItem(
            Icons.calendar_today_rounded,
            'Joined',
            _formatJoinDate(profile.joinDate),
          ),
          if (profile.favoriteEmotion != null) ...[
            const SizedBox(height: 16),
            _buildAboutItem(
              Icons.favorite_rounded,
              'Favorite Emotion',
              profile.favoriteEmotion!.toUpperCase(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(UserPreferencesEntity preferences, ProfileState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: const Color(0xFFEC4899),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Settings & Privacy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSettingsItem(
            'Notifications',
            'Push notifications and alerts',
            Icons.notifications_rounded,
            preferences.notificationsEnabled,
            (value) => _updateSettings({
              'notificationsEnabled': value,
              'dataSharingEnabled': preferences.sharingEnabled,
              'language': preferences.language,
              'theme': preferences.theme,
            }),
            state is ProfilePreferencesUpdating,
          ),
          const SizedBox(height: 20),
          _buildSettingsItem(
            'Share Data',
            'Allow friends to see your journey',
            Icons.share_rounded,
            preferences.sharingEnabled,
            (value) => _updateSettings({
              'notificationsEnabled': preferences.notificationsEnabled,
              'dataSharingEnabled': value,
              'language': preferences.language,
              'theme': preferences.theme,
            }),
            state is ProfilePreferencesUpdating,
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey[800]),
          const SizedBox(height: 24),
          _buildActionItem(
            'Export Data',
            'Download your information',
            Icons.download_rounded,
            const Color(0xFF8B5CF6),
            _exportData,
            state is ProfileDataExporting,
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            'Sign Out',
            'Securely sign out of your account',
            Icons.logout_rounded,
            const Color(0xFFEC4899),
            _handleSignOut,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isUpdating,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2442),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[400], size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        if (isUpdating)
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF8B5CF6),
            ),
          )
        else
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.grey[800],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    bool isLoading,
  ) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    )
                  : Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, ProfileEntity profile, ProfileState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildBottomSheetItem(
              Icons.edit,
              'Edit Profile',
              () {
                Navigator.pop(context);
                _showEditProfileDialog(profile);
              },
            ),
            _buildBottomSheetItem(
              Icons.qr_code,
              'Share Profile',
              () {
                Navigator.pop(context);
                _showSimpleMessage('QR sharing coming soon!');
              },
            ),
            _buildBottomSheetItem(
              Icons.download,
              'Export Data',
              () {
                Navigator.pop(context);
                _exportData();
              },
            ),
            _buildBottomSheetItem(
              Icons.settings,
              'Advanced Settings',
              () {
                Navigator.pop(context);
                _showSimpleMessage('Advanced settings coming soon!');
              },
            ),
            Divider(color: Colors.grey[700], height: 32),
            _buildBottomSheetItem(
              Icons.logout,
              'Sign Out',
              () {
                Navigator.pop(context);
                _handleSignOut();
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
            ? Colors.red.withOpacity(0.1) 
            : const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF8B5CF6),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.white,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  void _handleBlocListener(BuildContext context, ProfileState state) {
    if (state is ProfileError) {
      Logger.error('❌ Profile error: ${state.message}');
      _showErrorSnackBar(state.message);
    } else if (state is ProfileDataExported) {
      _showSuccessSnackBar('Data export started! Check your email.');
    } else if (state is ProfileLoaded) {
      Logger.info('✅ Profile loaded successfully: ${state.profile.name}');
    }
  }

  void _handleAuthListener(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated) {
      Logger.info('🚪 User logged out, navigating to auth wrapper');
      NavigationService.safeNavigate(
        AppRouter.auth,
        clearStack: true,
      );
    } else if (state is AuthSessionExpired) {
      Logger.info('🔄 Session expired, navigating to auth wrapper');
      NavigationService.showErrorSnackBar(state.message);
      NavigationService.safeNavigate(
        AppRouter.auth,
        clearStack: true,
      );
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    context.read<ProfileBloc>().add(const RefreshProfile());
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _showSuccessSnackBar('Profile refreshed!');
    }
  }

  void _updateSettings(Map<String, dynamic> settings) {
    Logger.info('📝 Updating settings: $settings');
    context.read<ProfileBloc>().add(UpdateSettings(settings: settings));
  }

  void _showEditProfileDialog(ProfileEntity profile) {
    HapticFeedback.lightImpact();
    EditProfileDialog.show(
      context,
      profile,
      onSave: (updatedData) {
        _showSuccessSnackBar('Profile updated successfully!');
        context.read<ProfileBloc>().add(const RefreshProfile());
      },
    );
  }

  void _exportData() {
    HapticFeedback.lightImpact();
    context.read<ProfileBloc>().add(const ExportData());
  }

  void _handleSignOut() {
    HapticFeedback.lightImpact();
    LogoutService.showLogoutConfirmation(context);
  }

  void _showSimpleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getAvatarEmoji(String avatarName) {
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

  Color _getAchievementColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF8B5CF6);
    }
  }

  IconData _getAchievementIcon(String iconName) {
    const iconMap = {
      'emoji_emotions': Icons.emoji_emotions_rounded,
      'trending_up': Icons.trending_up_rounded,
      'explore': Icons.explore_rounded,
      'psychology': Icons.psychology_rounded,
      'local_fire_department': Icons.local_fire_department_rounded,
      'military_tech': Icons.military_tech_rounded,
      'schedule': Icons.schedule_rounded,
      'palette': Icons.palette_rounded,
      'people': Icons.people_rounded,
      'favorite': Icons.favorite_rounded,
      'verified': Icons.verified_rounded,
      'star': Icons.star_rounded,
      'emoji_events': Icons.emoji_events_rounded,
      'workspace_premium': Icons.workspace_premium_rounded,
      'rocket_launch': Icons.rocket_launch_rounded,
      'account_circle': Icons.account_circle_rounded,
    };
    return iconMap[iconName] ?? Icons.star_rounded;
  }

  String _formatJoinDate(DateTime joinDate) {
    final now = DateTime.now();
    final difference = now.difference(joinDate);
    
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    
    if (difference.inMinutes < 5) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    }
  }
}