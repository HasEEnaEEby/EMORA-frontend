import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileDialog {
  static void show(
    BuildContext context,
    dynamic profile, {
    required Function(Map<String, dynamic>) onSave,
  }) {
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
  late TextEditingController bioController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool isPrivate = false;
  String selectedAvatar = 'fox';
  String username = '';
  String selectedPronouns = 'They / Them';
  String selectedAgeGroup = '18-24';
  String selectedThemeColor = '#8B5CF6';
  bool isLoading = false;

  final List<String> pronounsOptions = [
    'They / Them',
    'He / Him',
    'She / Her',
    'Prefer not to say',
  ];

  final List<String> ageGroupOptions = [
    '13-17',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
    'Prefer not to say',
  ];

  final List<Map<String, String>> themeColorOptions = [
    {'name': 'Cosmic Purple', 'value': '#8B5CF6'},
    {'name': 'Ocean Blue', 'value': '#3B82F6'},
    {'name': 'Indigo Blue', 'value': '#6366F1'},
    {'name': 'Emerald Green', 'value': '#10B981'},
    {'name': 'Sunset Orange', 'value': '#F59E0B'},
    {'name': 'Rose Pink', 'value': '#EC4899'},
    {'name': 'Slate Gray', 'value': '#64748B'},
  ];

  @override
  void initState() {
    super.initState();
    
    nameController = TextEditingController(
      text: _safeNameAccess(widget.profile),
    );
    emailController = TextEditingController(
      text: _safeEmailAccess(widget.profile),
    );
    bioController = TextEditingController(
      text: _safeBioAccess(widget.profile),
    );
    
    isPrivate = _safePrivateAccess(widget.profile);
    selectedAvatar = _safeAvatarAccess(widget.profile);
    username = _safeUsernameAccess(widget.profile);
    selectedPronouns = _safePronounsAccess(widget.profile);
    selectedAgeGroup = _safeAgeGroupAccess(widget.profile);
    selectedThemeColor = _safeThemeColorAccess(widget.profile);
    
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
    
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
return Material( 
      color: Colors.transparent,
      child: BlocListener<ProfileBloc, ProfileState>(
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

            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenWidth < 380;
                
                return Column(
                  children: [
                    Column(
                      children: [
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
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 18 : 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _buildHeaderButton(
                            'Cancel',
                            Icons.close_rounded,
                            onPressed: () => _handleCancel(),
                            isPrimary: false,
                            isCompact: isSmallScreen,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Flexible(
                          child: _buildHeaderButton(
                            'Save',
                            Icons.check_rounded,
                            onPressed: () => _handleSave(),
                            isPrimary: true,
                            isCompact: isSmallScreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
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
    bool isCompact = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 16 : 20,
          vertical: isCompact ? 10 : 12,
        ),
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
              size: isCompact ? 16 : 18,
            ),
            SizedBox(width: isCompact ? 6 : 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: isCompact ? 14 : 16,
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
        const SizedBox(height: 24),

        _buildEnhancedTextField(
          controller: bioController,
          label: 'Bio',
          icon: CupertinoIcons.quote_bubble_fill,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          helperText: 'Tell others about yourself',
        ),
        const SizedBox(height: 24),

        _buildSelectionField(
          label: 'Pronouns',
          icon: CupertinoIcons.person_2_fill,
          value: selectedPronouns,
          options: pronounsOptions,
          onChanged: (value) {
            setState(() {
              selectedPronouns = value;
            });
            HapticFeedback.selectionClick();
          },
          helperText: 'Your preferred pronouns',
        ),
        const SizedBox(height: 24),

        _buildSelectionField(
          label: 'Age Group',
          icon: CupertinoIcons.person_3_fill,
          value: selectedAgeGroup,
          options: ageGroupOptions,
          onChanged: (value) {
            setState(() {
              selectedAgeGroup = value;
            });
            HapticFeedback.selectionClick();
          },
          helperText: 'Your age group',
        ),
        const SizedBox(height: 24),

        _buildThemeColorField(),
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
    int? maxLines,
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
                  maxLines: maxLines,
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

  Widget _buildSelectionField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    String? helperText,
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
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showSelectionDialog(label, value, options, onChanged),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E1B4B).withOpacity(0.8),
                  const Color(0xFF312E81).withOpacity(0.6),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_down,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
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

  Widget _buildThemeColorField() {
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
              child: Icon(CupertinoIcons.paintbrush_fill, color: const Color(0xFF8B5CF6), size: 18),
            ),
            const SizedBox(width: 12),
            const Text(
              'Theme Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E1B4B).withOpacity(0.8),
                const Color(0xFF312E81).withOpacity(0.6),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(int.parse(selectedThemeColor.replaceAll('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        themeColorOptions.firstWhere(
                          (option) => option['value'] == selectedThemeColor,
                          orElse: () => {'name': 'Cosmic Purple', 'value': '#8B5CF6'},
                        )['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_down,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: themeColorOptions.length,
                  itemBuilder: (context, index) {
                    final option = themeColorOptions[index];
                    final isSelected = option['value'] == selectedThemeColor;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedThemeColor = option['value']!;
                        });
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Color(int.parse(option['value']!.replaceAll('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: isSelected ? 3 : 0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Color(int.parse(option['value']!.replaceAll('#', '0xFF'))).withOpacity(0.5),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
                'Your preferred theme color',
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
    );
  }

  void _showSelectionDialog(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50,
                onSelectedItemChanged: (index) {
                  onChanged(options[index]);
                },
                children: options.map((option) {
                  return Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: option == currentValue ? const Color(0xFF8B5CF6) : Colors.white,
                        fontSize: 16,
                        fontWeight: option == currentValue ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
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
          Material(
            color: Colors.transparent,
            child: Transform.scale(
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
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final bio = bioController.text.trim();

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

    if (bio.length > 200) {
      _showValidationError('Bio must be less than 200 characters');
      return;
    }

    final updatedData = {
      'name': name,
      'email': email,
      'avatar': selectedAvatar,
      'isPrivate': isPrivate,
      'pronouns': selectedPronouns,
      'ageGroup': selectedAgeGroup,
      'profile': {
        'displayName': name,
        'bio': bio,
        'themeColor': selectedThemeColor,
      },
      'updatedAt': DateTime.now().toIso8601String(),
    };

    context.read<ProfileBloc>().add(UpdateProfile(profileData: updatedData));
    
    HapticFeedback.lightImpact();
  }

  void _showValidationError(String message) {
    HapticFeedback.heavyImpact();
    DialogUtils.showErrorSnackBar(context, message);
  }

  String _safeNameAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        final profileObj = profile['profile'];
        if (profileObj is Map<String, dynamic>) {
          final displayName = profileObj['displayName'];
          if (displayName != null && displayName.toString().isNotEmpty) {
            return displayName.toString();
          }
        }
        return profile['name']?.toString() ?? 
               profile['displayName']?.toString() ??
               profile['username']?.toString() ??
               '';
      }
      return profile.name?.toString() ?? '';
    } catch (e) {
      print('Error accessing name: $e');
      return '';
    }
  }

  String _safeUsernameAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['username']?.toString() ?? '';
      }
      return profile.username?.toString() ?? '';
    } catch (e) {
      print('Error accessing username: $e');
      return '';
    }
  }

  String _safeEmailAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['email']?.toString() ?? '';
      }
      return profile.email?.toString() ?? '';
    } catch (e) {
      print('Error accessing email: $e');
      return '';
    }
  }

  String _safeAvatarAccess(dynamic profile) {
    try {
      if (profile == null) return 'fox';
      if (profile is Map<String, dynamic>) {
        return profile['selectedAvatar']?.toString() ?? 
               profile['avatar']?.toString() ?? 
               'fox';
      }
      return profile.avatar?.toString() ?? 'fox';
    } catch (e) {
      print('Error accessing avatar: $e');
      return 'fox';
    }
  }

  bool _safePrivateAccess(dynamic profile) {
    try {
      if (profile == null) return false;
      if (profile is Map<String, dynamic>) {
        final preferences = profile['preferences'];
        if (preferences is Map<String, dynamic>) {
          final moodPrivacy = preferences['moodPrivacy'];
          if (moodPrivacy == 'private') return true;
        }
        return profile['isPrivate'] == true;
      }
      return profile.isPrivate == true;
    } catch (e) {
      print('Error accessing isPrivate: $e');
      return false;
    }
  }

  String _safePronounsAccess(dynamic profile) {
    try {
      if (profile == null) return 'They / Them';
      if (profile is Map<String, dynamic>) {
        return profile['pronouns']?.toString() ?? 'They / Them';
      }
      return profile.pronouns?.toString() ?? 'They / Them';
    } catch (e) {
      print('Error accessing pronouns: $e');
      return 'They / Them';
    }
  }

  String _safeAgeGroupAccess(dynamic profile) {
    try {
      if (profile == null) return '18-24';
      if (profile is Map<String, dynamic>) {
        return profile['ageGroup']?.toString() ?? '18-24';
      }
      return profile.ageGroup?.toString() ?? '18-24';
    } catch (e) {
      print('Error accessing ageGroup: $e');
      return '18-24';
    }
  }

  String _safeThemeColorAccess(dynamic profile) {
    try {
      if (profile == null) return '#8B5CF6';
      if (profile is Map<String, dynamic>) {
        final profileObj = profile['profile'];
        if (profileObj is Map<String, dynamic>) {
          final themeColor = profileObj['themeColor'];
          if (themeColor != null && themeColor.toString().isNotEmpty) {
            final colorValue = themeColor.toString();
            final isValidColor = themeColorOptions.any((option) => option['value'] == colorValue);
            return isValidColor ? colorValue : '#8B5CF6';
          }
        }
        final directColor = profile['themeColor']?.toString();
        if (directColor != null && directColor.isNotEmpty) {
          final isValidColor = themeColorOptions.any((option) => option['value'] == directColor);
          return isValidColor ? directColor : '#8B5CF6';
        }
        return '#8B5CF6';
      }
      final themeColor = profile.themeColor?.toString();
      if (themeColor != null && themeColor.isNotEmpty) {
        final isValidColor = themeColorOptions.any((option) => option['value'] == themeColor);
        return isValidColor ? themeColor : '#8B5CF6';
      }
      return '#8B5CF6';
    } catch (e) {
      print('Error accessing themeColor: $e');
      return '#8B5CF6';
    }
  }

  String _safeBioAccess(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        final profileObj = profile['profile'];
        if (profileObj is Map<String, dynamic>) {
          final bio = profileObj['bio'];
          if (bio != null && bio.toString().isNotEmpty) {
            return bio.toString();
          }
        }
        return profile['bio']?.toString() ?? '';
      }
      return profile.bio?.toString() ?? '';
    } catch (e) {
      print('Error accessing bio: $e');
      return '';
    }
  }
}