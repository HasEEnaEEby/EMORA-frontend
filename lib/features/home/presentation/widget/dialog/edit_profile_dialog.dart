// lib/features/home/presentation/widget/dialogs/edit_profile_dialog.dart - ENHANCED VERSION
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enhanced profile editing dialog with beautiful UI and proper BLoC integration
///
/// Features:
/// - Stunning gradient backgrounds and animations
/// - Real-time avatar preview
/// - Smooth state transitions
/// - Proper validation and error handling
/// - BLoC state management
/// - Haptic feedback
/// - Accessibility support
class EditProfileDialog {
  /// Shows the enhanced edit profile dialog
  static void show(
    BuildContext context,
    dynamic profile, {
    required Function(Map<String, dynamic>) onSave,
  }) {
    // Store the ProfileBloc reference before opening the modal
    final profileBloc = context.read<ProfileBloc>();
    
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: profileBloc,
        child: _EditProfileDialogContent(
          profile: profile,
          onSave: onSave,
        ),
      ),
    );
  }
}

class _EditProfileDialogContent extends StatefulWidget {
  final dynamic profile;
  final Function(Map<String, dynamic>) onSave;

  const _EditProfileDialogContent({
    required this.profile,
    required this.onSave,
  });

  @override
  State<_EditProfileDialogContent> createState() => _EditProfileDialogContentState();
}

class _EditProfileDialogContentState extends State<_EditProfileDialogContent>
    with TickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool isPrivate = false;
  String selectedAvatar = 'fox';
  String username = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with safe access
    nameController = TextEditingController(
      text: _safeNameAccess(widget.profile),
    );
    emailController = TextEditingController(
      text: _safeEmailAccess(widget.profile),
    );
    
    // Initialize state
    isPrivate = _safePrivateAccess(widget.profile);
    selectedAvatar = _safeAvatarAccess(widget.profile);
    username = _safeUsernameAccess(widget.profile);
    
    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() => isLoading = false);
          Navigator.pop(context);
          DialogUtils.showSuccessSnackBar(
            context,
            'Profile updated successfully! ✨',
          );
          HapticFeedback.lightImpact();
          widget.onSave({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'avatar': selectedAvatar,
            'isPrivate': isPrivate,
          });
        } else if (state is ProfileError) {
          setState(() => isLoading = false);
          DialogUtils.showErrorSnackBar(
            context,
            state.message,
          );
          HapticFeedback.heavyImpact();
        } else if (state is ProfileUpdating) {
          setState(() => isLoading = true);
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F0F23),
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E).withOpacity(0.95),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 0,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.5,
                            colors: [
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                              Colors.transparent,
                              const Color(0xFF6366F1).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                      ),
                    ),
                    
                    // Main content
                    Column(
                      children: [
                        _buildEnhancedHeader(),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _buildAvatarSection(),
                                const SizedBox(height: 32),
                                _buildFormFields(),
                                const SizedBox(height: 32),
                                _buildPrivacyToggle(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Loading overlay
                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoActivityIndicator(
                                  radius: 20,
                                  color: Color(0xFF8B5CF6),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Updating profile...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.15),
            const Color(0xFF6366F1).withOpacity(0.08),
            Colors.transparent,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF8B5CF6).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Handle bar with glow effect
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Header content with enhanced styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderButton(
                  'Cancel',
                  Icons.close_rounded,
                  onPressed: () => _handleCancel(),
                  isPrimary: false,
                ),
                
                Column(
                  children: [
                    // Animated avatar preview
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CF6).withOpacity(0.3),
                                  const Color(0xFF6366F1).withOpacity(0.2),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              DialogUtils.getEmojiForAvatar(selectedAvatar),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFFD8A5FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                _buildHeaderButton(
                  'Save',
                  Icons.check_rounded,
                  onPressed: () => _handleSave(),
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(
    String text,
    IconData icon, {
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final availableAvatars = DialogUtils.getAvailableAvatars();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Choose Your Avatar',
          '✨',
          'Select an avatar that represents you',
        ),
        const SizedBox(height: 20),
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1B4B).withOpacity(0.8),
                const Color(0xFF312E81).withOpacity(0.6),
                const Color(0xFF4C1D95).withOpacity(0.4),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: availableAvatars.length,
            itemBuilder: (context, index) {
              final avatar = availableAvatars[index];
              final isSelected = selectedAvatar == avatar['name'];
              
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 200 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = avatar['name']!;
                        });
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF2A2A3E),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[600]!.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: isSelected ? 1.1 : 1.0,
                            child: Text(
                              avatar['emoji']!,
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildEnhancedTextField(
          controller: nameController,
          label: 'Display Name',
          icon: CupertinoIcons.person_fill,
          required: true,
          helperText: 'This name will be shown to other users',
        ),
        const SizedBox(height: 24),

        _buildEnhancedTextField(
          controller: null,
          label: 'Username',
          icon: CupertinoIcons.at,
          enabled: false,
          value: username,
          helperText: 'Username cannot be changed',
        ),
        const SizedBox(height: 24),

        _buildEnhancedTextField(
          controller: emailController,
          label: 'Email Address',
          icon: CupertinoIcons.mail_solid,
          keyboardType: TextInputType.emailAddress,
          required: true,
          helperText: 'Used for account recovery and notifications',
        ),
      ],
    );
  }

  Widget _buildEnhancedTextField({
    TextEditingController? controller,
    required String label,
    required IconData icon,
    String? value,
    bool enabled = true,
    bool required = false,
    String? helperText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.2),
                    const Color(0xFF6366F1).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                ),
              ),
              child: Icon(icon, color: const Color(0xFF8B5CF6), size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: enabled
                  ? [
                      const Color(0xFF1E1B4B).withOpacity(0.8),
                      const Color(0xFF312E81).withOpacity(0.6),
                    ]
                  : [
                      Colors.grey[800]!.withOpacity(0.6),
                      Colors.grey[700]!.withOpacity(0.4),
                    ],
            ),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF8B5CF6).withOpacity(0.4)
                  : Colors.grey[600]!.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: enabled
                    ? const Color(0xFF8B5CF6).withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: enabled && controller != null
              ? CupertinoTextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  placeholderStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                  placeholder: 'Enter ${label.toLowerCase()}',
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Text(
                    value ?? 'Not available',
                    style: TextStyle(
                      color: enabled ? Colors.white : Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: Colors.grey[500],
                size: 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  helperText,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1B4B).withOpacity(0.8),
            const Color(0xFF312E81).withOpacity(0.6),
            const Color(0xFF4C1D95).withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isPrivate
                    ? [
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                        const Color(0xFF6366F1).withOpacity(0.2),
                      ]
                    : [
                        Colors.grey[600]!.withOpacity(0.3),
                        Colors.grey[700]!.withOpacity(0.2),
                      ],
              ),
            ),
            child: Icon(
              isPrivate
                  ? CupertinoIcons.lock_fill
                  : CupertinoIcons.lock_open_fill,
              color: isPrivate ? const Color(0xFF8B5CF6) : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Private Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPrivate
                      ? 'Only you can see your emotional data and insights'
                      : 'Your profile and insights are visible to other users',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Transform.scale(
            scale: 1.2,
            child: Switch.adaptive(
              value: isPrivate,
              onChanged: (value) {
                setState(() {
                  isPrivate = value;
                });
                HapticFeedback.selectionClick();
              },
              activeColor: const Color(0xFF8B5CF6),
              activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String emoji, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  void _handleSave() {
    // Validation
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      _showValidationError('Display name is required');
      return;
    }

    if (name.length < 2) {
      _showValidationError('Display name must be at least 2 characters');
      return;
    }

    if (name.length > 50) {
      _showValidationError('Display name must be less than 50 characters');
      return;
    }

    if (email.isNotEmpty && !DialogUtils.isValidEmail(email)) {
      _showValidationError('Please enter a valid email address');
      return;
    }

    // Prepare updated data
    final updatedData = {
      'name': name, // This will update the display name
      'email': email,
      'avatar': selectedAvatar,
      'isPrivate': isPrivate,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Trigger ProfileBloc update
    context.read<ProfileBloc>().add(UpdateProfile(profileData: updatedData));
    
    HapticFeedback.lightImpact();
  }

  void _showValidationError(String message) {
    HapticFeedback.heavyImpact();
    DialogUtils.showErrorSnackBar(context, message);
  }

  // MARK: - Safe Property Access Helpers

  String _safeNameAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['name'] ?? 
            profile['displayName'] ??
            profile['username'] ??
            '';
      }
      return profile.name ?? '';
    } catch (e) {
      print('Error accessing name: $e');
      return '';
    }
  }

  String _safeUsernameAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['username'] ?? '';
      }
      return profile.username ?? '';
    } catch (e) {
      print('Error accessing username: $e');
      return '';
    }
  }

  String _safeEmailAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['email'] ?? '';
      }
      return profile.email ?? '';
    } catch (e) {
      print('Error accessing email: $e');
      return '';
    }
  }

  String _safeAvatarAccess(dynamic profile) {
    try {
      if (profile == null) return 'fox';
      if (profile is Map<String, dynamic>) {
        return profile['avatar'] ?? 'fox';
      }
      return profile.avatar ?? 'fox';
    } catch (e) {
      print('Error accessing avatar: $e');
      return 'fox';
    }
  }

  bool _safePrivateAccess(dynamic profile) {
    try {
      if (profile == null) return false;
      if (profile is Map<String, dynamic>) {
        return profile['isPrivate'] ?? false;
      }
      return profile.isPrivate ?? false;
    } catch (e) {
      print('Error accessing isPrivate: $e');
      return false;
    }
  }
}