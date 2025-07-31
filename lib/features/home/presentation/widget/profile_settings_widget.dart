import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/core/services/logout_service.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/edit_profile_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/language_selector_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/theme_selector_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSettingsWidget extends StatelessWidget {
  final bool notificationsEnabled;
  final bool sharingEnabled;
  final String selectedLanguage;
  final String selectedTheme;
  final bool isUpdating;
final dynamic userProfile; 
  final Function(bool) onNotificationsChanged;
  final Function(bool) onSharingChanged;
  final Function(String) onLanguageChanged;
  final Function(String) onThemeChanged;
  final Function(Map<String, dynamic>)?
onProfileUpdated; 

  const ProfileSettingsWidget({
    super.key,
    required this.notificationsEnabled,
    required this.sharingEnabled,
    required this.selectedLanguage,
    required this.selectedTheme,
    this.isUpdating = false,
    this.userProfile,
    required this.onNotificationsChanged,
    required this.onSharingChanged,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    this.onProfileUpdated,
  });

  static const List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
  ];

  static const List<Map<String, dynamic>> _themes = [
    {'name': 'Cosmic Purple', 'color': Color(0xFF8B5CF6)},
    {'name': 'Ocean Blue', 'color': Color(0xFF3B82F6)},
    {'name': 'Forest Green', 'color': Color(0xFF10B981)},
    {'name': 'Sunset Orange', 'color': Color(0xFFFF6B35)},
    {'name': 'Rose Pink', 'color': Color(0xFFFF69B4)},
    {'name': 'Golden Yellow', 'color': Color(0xFFFFD700)},
    {'name': 'Cherry Blossom', 'color': Color(0xFFEC4899)},
    {'name': 'Fire Red', 'color': Color(0xFFEF4444)},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSettingsCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        if (isUpdating)
          SizedBox(
            width: 16,
            height: 16,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF8B5CF6),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(
              0xFF1A1A2E,
).withOpacity(0.8), 
            const Color(
              0xFF16213E,
).withOpacity(0.6), 
          ],
        ),
        border: Border.all(
          color: const Color(
            0xFF8B5CF6,
).withOpacity(0.2), 
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEditProfileSetting(context),
            _buildDivider(),
            _buildNotificationsSetting(),
            _buildDivider(),
            _buildSharingSetting(),
            _buildDivider(),
            _buildLanguageSetting(context),
            _buildDivider(),
            _buildThemeSetting(context),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileSetting(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : () => _showEditProfileDialog(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(
                0xFF8B5CF6,
).withOpacity(0.2), 
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Update your profile information',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsSetting() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(
              0xFF8B5CF6,
).withOpacity(0.2), 
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Get reminders and updates',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Switch(
            value: notificationsEnabled,
            onChanged: isUpdating
                ? null
                : (value) {
                    HapticFeedback.lightImpact();
                    onNotificationsChanged(value);
                  },
            activeColor: const Color(0xFF8B5CF6),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSharingSetting() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(
              0xFF8B5CF6,
).withOpacity(0.2), 
          ),
          child: const Icon(
            Icons.share_outlined,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Sharing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Share anonymous usage data',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Switch(
            value: sharingEnabled,
            onChanged: isUpdating
                ? null
                : (value) {
                    HapticFeedback.lightImpact();
                    onSharingChanged(value);
                  },
            activeColor: const Color(0xFF8B5CF6),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : () => _showLanguagePicker(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(
                0xFF8B5CF6,
).withOpacity(0.2), 
            ),
            child: const Icon(
              Icons.language_outlined,
              color: Color(0xFF8B5CF6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedLanguage,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    final selectedThemeData = _themes.firstWhere(
      (theme) => theme['name'] == selectedTheme,
      orElse: () => _themes.first,
    );

    return GestureDetector(
      onTap: isUpdating ? null : () => _showThemePicker(context),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedThemeData['color'].withOpacity(
                0.2,
), 
            ),
            child: Icon(
              Icons.palette_outlined,
              color: selectedThemeData['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  selectedTheme,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Colors.grey[800],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    EditProfileDialog.show(
      context,
      userProfile,
      onSave: (updatedProfile) {
        if (onProfileUpdated != null) {
          onProfileUpdated!(updatedProfile);
        }
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    HapticFeedback.selectionClick();
    LanguageSelectorDialog.show(context, selectedLanguage, onLanguageChanged);
  }

  void _showThemePicker(BuildContext context) {
    HapticFeedback.selectionClick();
    ThemeSelectorDialog.show(context, selectedTheme, onThemeChanged);
  }

  void _showLogoutConfirmation(BuildContext context) {
    HapticFeedback.selectionClick();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(
                  0.1,
), 
              ),
              child: const Icon(
                Icons.logout_outlined,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Text(
                'Are you sure you want to sign out?',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll need to sign in again to access your account.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: CupertinoColors.systemBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    LogoutService.performLogout(context);
  }
}
