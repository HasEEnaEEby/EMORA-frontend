import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
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

import '../../widget/profile_achievements_widget.dart';
import '../../widget/profile_floating_button.dart';
import '../../widget/profile_header_widget.dart';
import '../../widget/profile_settings_widget.dart';
import '../../widget/profile_stats_widget.dart';
import '../../widget/dialog/edit_profile_dialog.dart';
import '../../../../../core/navigation/navigation_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _floatingController;
  late AnimationController _cardAnimationController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadProfile());
      }
    });
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _cardAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _floatingController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      // Add app bar with back navigation
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
        ),
        actions: [
          // Dashboard navigation button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              NavigationService.pushNamed('/dashboard');
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFF8B5CF6),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: _handleBlocListener,
          builder: (context, state) {
            return _buildMainContent(state);
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  void _handleBlocListener(BuildContext context, ProfileState state) {
    if (state is ProfileError) {
      _showErrorSnackBar(state.message);
    } else if (state is ProfileDataExported) {
      _showSuccessSnackBar('Data export started! Check your email.');
    }
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
      // Handle all states that have profile data
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.3),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
            ).createShader(bounds),
            child: const Text(
              'Loading Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing your emotional journey...',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_off_outlined,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Failed to Load Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t load your profile data.\nPlease check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.read<ProfileBloc>().add(const LoadProfile());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Go Back',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ],
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
    // Create default preferences if null
    final effectivePreferences = preferences ?? const UserPreferencesEntity();

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: const Color(0xFF1A1A2E),
      color: const Color(0xFF8B5CF6),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            ProfileHeaderWidget(
              profile: profile,
              onEditProfile: () => _showEditProfileDialog(profile),
              onAvatarTap: () => _showEditProfileDialog(profile),
            ),

            const SizedBox(height: 20),

            // Profile Stats
            ProfileStatsWidget(profile: profile, cardAnimation: _cardAnimation),

            const SizedBox(height: 24),

            // Achievements Section
            ProfileAchievementsWidget(
              achievements: achievements,
              isLoading: state is ProfileAchievementsLoading,
            ),

            const SizedBox(height: 24),

            // Settings Section
            ProfileSettingsWidget(
              notificationsEnabled: effectivePreferences.notificationsEnabled,
              sharingEnabled: effectivePreferences.sharingEnabled,
              selectedLanguage: effectivePreferences.language,
              selectedTheme: effectivePreferences.theme,
              isUpdating: state is ProfilePreferencesUpdating,
              onNotificationsChanged: (value) {
                HapticFeedback.lightImpact();
                _updateSettings({
                  'notificationsEnabled': value,
                  'dataSharingEnabled': effectivePreferences.sharingEnabled,
                  'language': effectivePreferences.language,
                  'theme': effectivePreferences.theme,
                  'updatedAt': DateTime.now().toIso8601String(),
                });
              },
              onSharingChanged: (value) {
                HapticFeedback.lightImpact();
                _updateSettings({
                  'notificationsEnabled':
                      effectivePreferences.notificationsEnabled,
                  'dataSharingEnabled': value,
                  'language': effectivePreferences.language,
                  'theme': effectivePreferences.theme,
                  'updatedAt': DateTime.now().toIso8601String(),
                });
              },
              onLanguageChanged: (language) {
                HapticFeedback.lightImpact();
                _updateSettings({
                  'notificationsEnabled':
                      effectivePreferences.notificationsEnabled,
                  'dataSharingEnabled': effectivePreferences.sharingEnabled,
                  'language': language,
                  'theme': effectivePreferences.theme,
                  'updatedAt': DateTime.now().toIso8601String(),
                });
              },
              onThemeChanged: (theme) {
                HapticFeedback.lightImpact();
                _updateSettings({
                  'notificationsEnabled':
                      effectivePreferences.notificationsEnabled,
                  'dataSharingEnabled': effectivePreferences.sharingEnabled,
                  'language': effectivePreferences.language,
                  'theme': theme,
                  'updatedAt': DateTime.now().toIso8601String(),
                });
              },
            ),

            const SizedBox(height: 24),

            // Account Management Section
            _buildAccountSection(profile, state),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(ProfileEntity profile, ProfileState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withOpacity(0.6),
            const Color(0xFF312E81).withOpacity(0.4),
          ],
        ),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.person_crop_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your account settings and data',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Actions
            Column(
              children: [
                _buildAccountButton(
                  icon: CupertinoIcons.arrow_down_to_line,
                  title: 'Export Data',
                  subtitle: 'Download your personal data',
                  color: const Color(0xFF10B981),
                  onTap: _exportData,
                  isLoading: state is ProfileDataExporting,
                ),

                const SizedBox(height: 16),

                _buildAccountButton(
                  icon: CupertinoIcons.arrow_right_square,
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  color: const Color(0xFFF59E0B),
                  onTap: _handleSignOut,
                ),

                const SizedBox(height: 16),

                _buildAccountButton(
                  icon: CupertinoIcons.delete,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account',
                  color: const Color(0xFFEF4444),
                  onTap: () =>
                      _showSimpleMessage('Account deletion coming soon'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withOpacity(0.2),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    )
                  : Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded ||
            state is ProfileUpdating ||
            state is ProfilePreferencesUpdating ||
            state is ProfileAchievementsLoading ||
            state is ProfileDataExporting ||
            state is ProfileDataExported) {
          ProfileEntity? profile;

          if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileUpdating) {
            profile = state.profile;
          } else if (state is ProfilePreferencesUpdating) {
            profile = state.profile;
          } else if (state is ProfileAchievementsLoading) {
            profile = state.profile;
          } else if (state is ProfileDataExporting) {
            profile = state.profile;
          } else if (state is ProfileDataExported) {
            profile = state.profile;
          }

          if (profile != null) {
            return ProfileFloatingButton(
              floatingAnimation: _floatingAnimation,
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showSimpleMessage('QR code sharing coming soon');
              },
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Event Handlers
  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    _headerAnimationController.reset();
    _cardAnimationController.reset();
    context.read<ProfileBloc>().add(const RefreshProfile());
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _startAnimations();
      _showSuccessSnackBar('Profile refreshed!');
    }
  }

  void _updateSettings(Map<String, dynamic> settings) {
    context.read<ProfileBloc>().add(UpdateSettings(settings: settings));
  }

  void _showEditProfileDialog(ProfileEntity profile) {
    HapticFeedback.lightImpact();
    
    // Call the edit profile dialog directly with proper context
    EditProfileDialog.show(
      context,
      profile,
      onSave: (updatedData) {
        _showSuccessSnackBar('Profile updated successfully! ✨');
        // Trigger a refresh of the profile
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

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // ✅ Check if BLoC is still mounted and not closed before adding event
              if (mounted) {
                final authBloc = context.read<AuthBloc>();
                if (!authBloc.isClosed) {
                  authBloc.add(const AuthLogout());
                  _showSimpleMessage('Signing out...');
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSimpleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF8B5CF6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
