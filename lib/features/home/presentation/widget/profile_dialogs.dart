// lib/features/home/presentation/widget/profile_dialogs.dart
import 'package:emora_mobile_app/core/utils/dialog_utils.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/account_management_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/achievements_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/avatar_picker_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/edit_profile_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/export_data_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/language_selector_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/qr_code_dialog.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/dialog/theme_selector_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Main ProfileDialogs class that serves as the entry point for all profile-related dialogs
///
/// This class delegates to specific dialog implementations for better organization
/// and easier debugging/maintenance.
///
/// Features:
/// - Profile management (edit, avatar selection)
/// - Achievements display and sharing
/// - QR code generation and sharing
/// - Settings and preferences
/// - Data export with multiple options
/// - Account management and security
/// - All dialogs use iOS-native components
/// - Comprehensive error handling
/// - Haptic feedback throughout
/// - Robust handling of missing profile properties
class ProfileDialogs {
  // MARK: - Profile Management

  /// Shows the edit profile dialog with avatar selection, form fields, and privacy settings
  /// Handles missing profile properties gracefully
  static void showEditProfileDialog(
    BuildContext context,
    dynamic profile, {
    required Function(Map<String, dynamic>) onSave,
  }) {
    try {
      EditProfileDialog.show(context, profile, onSave: onSave);
    } catch (e) {
      _handleDialogError(context, 'Failed to open edit profile dialog', e);
    }
  }

  /// Shows the avatar picker with all available avatars
  static void showAvatarPicker(
    BuildContext context,
    String currentAvatar,
    ValueChanged<String> onAvatarChanged,
  ) {
    try {
      AvatarPickerDialog.show(context, currentAvatar, onAvatarChanged);
    } catch (e) {
      _handleDialogError(context, 'Failed to open avatar picker', e);
    }
  }

  // MARK: - Achievements

  /// Shows all achievements in a scrollable bottom sheet
  static void showAllAchievements(
    BuildContext context,
    List<dynamic> achievements,
  ) {
    try {
      // Use the fixed achievements dialog with robust data handling
      FixedAchievementsDialog.showAll(context, achievements);
    } catch (e) {
      _handleDialogError(context, 'Failed to load achievements', e);
    }
  }

  /// Shows detailed view of a specific achievement
  static void showAchievementDetail(BuildContext context, dynamic achievement) {
    try {
      // Use the fixed achievements dialog with safe data access
      FixedAchievementsDialog.showDetail(context, achievement);
    } catch (e) {
      _handleDialogError(context, 'Failed to show achievement details', e);
    }
  }

  // MARK: - QR Code

  /// Shows QR code dialog with save and share options
  /// Handles potential QR generation errors gracefully
  static void showQRCode(BuildContext context, dynamic profile) {
    try {
      if (profile == null) {
        DialogUtils.showErrorSnackBar(context, 'Profile data not available');
        return;
      }
      // Use the safer QR dialog implementation
      SafeQRCodeDialog.show(context, profile);
    } catch (e) {
      _handleDialogError(context, 'Failed to generate QR code', e);
      // Fallback to simple QR dialog
      try {
        SafeQRCodeDialog.showSimpleQRDialog(context, profile);
      } catch (fallbackError) {
        _handleDialogError(
          context,
          'QR code generation unavailable',
          fallbackError,
        );
      }
    }
  }

  // MARK: - Settings & Preferences

  /// Shows language selection dialog
  static void showLanguageSelector(
    BuildContext context,
    String selectedLanguage,
    ValueChanged<String> onLanguageChanged,
  ) {
    try {
      LanguageSelectorDialog.show(context, selectedLanguage, onLanguageChanged);
    } catch (e) {
      _handleDialogError(context, 'Failed to open language selector', e);
    }
  }

  /// Shows theme selection dialog with enhanced UI
  static void showThemeSelector(
    BuildContext context,
    String selectedTheme,
    ValueChanged<String> onThemeChanged,
  ) {
    try {
      // Use the enhanced theme selector with beautiful UI
      ThemeSelectorDialog.show(context, selectedTheme, onThemeChanged);
    } catch (e) {
      _handleDialogError(context, 'Failed to open theme selector', e);
      // Fallback to simple theme selector
      try {
        _showSimpleThemeSelector(context, selectedTheme, onThemeChanged);
      } catch (fallbackError) {
        _handleDialogError(
          context,
          'Theme selector unavailable',
          fallbackError,
        );
      }
    }
  }

  /// Shows theme preview dialog
  static void showThemePreview(
    BuildContext context,
    Map<String, dynamic> theme,
  ) {
    try {
      ThemeSelectorDialog.showThemePreview(context, theme);
    } catch (e) {
      _handleDialogError(context, 'Failed to show theme preview', e);
    }
  }

  // MARK: - Data Export

  /// Shows data export options dialog
  static void showExportDialog(
    BuildContext context, {
    required VoidCallback onExport,
  }) {
    try {
      ExportDataDialog.show(context, onExport: onExport);
    } catch (e) {
      _handleDialogError(context, 'Failed to open export dialog', e);
    }
  }

  /// Shows detailed export options
  static void showDetailedExportOptions(BuildContext context) {
    try {
      ExportDataDialog.showDetailedExportOptions(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to open detailed export options', e);
    }
  }

  // MARK: - Account Management

  /// Shows sign out confirmation dialog
  static void showSignOutDialog(BuildContext context) {
    try {
      AccountManagementDialog.showSignOut(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to open sign out dialog', e);
    }
  }

  /// Shows delete account confirmation dialog
  static void showDeleteAccountDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    try {
      AccountManagementDialog.showDeleteAccount(context, onConfirm: onConfirm);
    } catch (e) {
      _handleDialogError(context, 'Failed to open delete account dialog', e);
    }
  }

  /// Shows coming soon dialog for features under development
  static void showComingSoonDialog(BuildContext context, String feature) {
    try {
      AccountManagementDialog.showComingSoon(context, feature);
    } catch (e) {
      _handleDialogError(context, 'Failed to show coming soon dialog', e);
    }
  }

  /// Shows account security information
  static void showAccountSecurity(BuildContext context) {
    try {
      AccountManagementDialog.showAccountSecurity(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show account security', e);
    }
  }

  /// Shows privacy settings
  static void showPrivacySettings(BuildContext context) {
    try {
      AccountManagementDialog.showPrivacySettings(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show privacy settings', e);
    }
  }

  /// Shows support and help options
  static void showSupportHelp(BuildContext context) {
    try {
      AccountManagementDialog.showSupportHelp(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show support options', e);
    }
  }

  // MARK: - Error Handling

  /// Handles dialog errors gracefully with user feedback
  static void _handleDialogError(
    BuildContext context,
    String userMessage,
    dynamic error,
  ) {
    // Log the error for debugging
    debugPrint('ProfileDialogs Error: $userMessage - $error');

    // Provide haptic feedback
    HapticFeedback.heavyImpact();

    // Show user-friendly error message
    DialogUtils.showErrorSnackBar(context, userMessage);

    // Optionally show detailed error in debug mode
    if (const bool.fromEnvironment('DEBUG', defaultValue: false)) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Debug Error'),
          content: Text('$userMessage\n\nDetails: $error'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // MARK: - Safe Profile Property Access

  /// Safely extract username from profile object
  static String getSafeUsername(dynamic profile) {
    try {
      if (profile == null) return 'User';
      if (profile is Map<String, dynamic>) {
        return profile['username'] ?? profile['name'] ?? 'User';
      }
      return profile?.username ?? profile?.name ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  /// Safely extract avatar from profile object
  static String getSafeAvatar(dynamic profile) {
    try {
      if (profile == null) return 'fox';
      if (profile is Map<String, dynamic>) {
        return profile['avatar'] ?? 'fox';
      }
      return profile?.avatar ?? 'fox';
    } catch (e) {
      return 'fox';
    }
  }

  /// Safely extract email from profile object
  static String getSafeEmail(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['email'] ?? '';
      }
      return profile?.email ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Safely extract bio from profile object
  static String getSafeBio(dynamic profile) {
    try {
      if (profile == null) return '';
      if (profile is Map<String, dynamic>) {
        return profile['bio'] ?? '';
      }
      return profile?.bio ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Safely extract private setting from profile object
  static bool getSafePrivate(dynamic profile) {
    try {
      if (profile == null) return false;
      if (profile is Map<String, dynamic>) {
        return profile['isPrivate'] ?? false;
      }
      return profile?.isPrivate ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Safely extract achievement earned status
  static bool getSafeAchievementEarned(dynamic achievement) {
    try {
      if (achievement == null) return false;
      if (achievement is Map<String, dynamic>) {
        return achievement['isEarned'] ??
            achievement['earned'] ??
            achievement['completed'] ??
            false;
      }
      return achievement?.isEarned ??
          achievement?.earned ??
          achievement?.completed ??
          false;
    } catch (e) {
      return false;
    }
  }

  /// Safely extract achievement progress
  static double getSafeAchievementProgress(dynamic achievement) {
    try {
      if (achievement == null) return 0.0;
      if (achievement is Map<String, dynamic>) {
        final progress = achievement['progress'] ?? 0;
        return (progress is int)
            ? progress.toDouble()
            : (progress as double? ?? 0.0);
      }
      final progress = achievement?.progress ?? 0;
      return (progress is int)
          ? progress.toDouble()
          : (progress as double? ?? 0.0);
    } catch (e) {
      return 0.0;
    }
  }

  // MARK: - Fallback Implementations

  /// Simple theme selector fallback
  static void _showSimpleThemeSelector(
    BuildContext context,
    String selectedTheme,
    ValueChanged<String> onThemeChanged,
  ) {
    final themes = ['Light', 'Dark', 'System'];

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: themes.map((theme) {
          final isSelected = selectedTheme == theme;
          return CupertinoActionSheetAction(
            onPressed: () {
              onThemeChanged(theme);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) const Icon(CupertinoIcons.checkmark, size: 20),
                if (isSelected) const SizedBox(width: 8),
                Text(theme),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // MARK: - Utility Methods for BLoC Integration

  /// Updates profile using ProfileBloc with error handling
  static void updateProfileWithBloc(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    try {
      DialogUtils.updateProfileWithBloc(context, profileData);
    } catch (e) {
      _handleDialogError(context, 'Failed to update profile', e);
    }
  }

  /// Updates preferences using ProfileBloc with error handling
  static void updatePreferencesWithBloc(
    BuildContext context,
    Map<String, dynamic> preferences,
  ) {
    try {
      DialogUtils.updatePreferencesWithBloc(context, preferences);
    } catch (e) {
      _handleDialogError(context, 'Failed to update preferences', e);
    }
  }

  /// Exports data using ProfileBloc with error handling
  static void exportDataWithBloc(BuildContext context) {
    try {
      DialogUtils.exportDataWithBloc(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to export data', e);
    }
  }

  static void signOutWithBloc(BuildContext context) {
    try {
      DialogUtils.signOutWithBloc(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to sign out', e);
    }
  }

  // MARK: - Helper Methods

  /// Shows success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    DialogUtils.showSuccessSnackBar(context, message);
  }

  /// Shows error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    DialogUtils.showErrorSnackBar(context, message);
  }

  /// Shows info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    DialogUtils.showInfoSnackBar(context, message);
  }

  // MARK: - Data Access Helpers

  /// Gets available avatars list
  static List<Map<String, String>> getAvailableAvatars() {
    return DialogUtils.getAvailableAvatars();
  }

  /// Gets available languages list
  static List<Map<String, String>> getAvailableLanguages() {
    return DialogUtils.getAvailableLanguages();
  }

  /// Gets available themes list
  static List<Map<String, dynamic>> getAvailableThemes() {
    return DialogUtils.getAvailableThemes();
  }

  /// Gets emoji for avatar name
  static String getEmojiForAvatar(String avatarName) {
    return DialogUtils.getEmojiForAvatar(avatarName);
  }

  /// Gets achievement color by category
  static Color getAchievementColor(String category) {
    return DialogUtils.getAchievementColor(category);
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    return DialogUtils.isValidEmail(email);
  }

  /// Formats date with relative time
  static String formatDate(DateTime date) {
    return DialogUtils.formatDate(date);
  }

  /// Gets valid CupertinoIcons for themes
  static List<Map<String, dynamic>> getValidThemeIcons() {
    return [
      {
        'name': 'Cosmic Purple',
        'icon': CupertinoIcons.sparkles, // ✓ Valid
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Ocean Blue',
        'icon': CupertinoIcons.drop_fill, // ✓ Valid
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Forest Green',
        'icon': CupertinoIcons.leaf_arrow_circlepath, // ✓ Valid
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Sunset Orange',
        'icon': CupertinoIcons.sun_max_fill, // ✓ Valid
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Cherry Blossom',
        'icon': CupertinoIcons.heart_fill, // ✓ Valid
        'color': const Color(0xFFEC4899),
      },
      {
        'name': 'Fire Red',
        'icon': CupertinoIcons.flame_fill, // ✓ Valid
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'Mystic Teal',
        'icon': CupertinoIcons.waveform, // ✓ Valid
        'color': const Color(0xFF14B8A6),
      },
      {
        'name': 'Royal Indigo',
        'icon': CupertinoIcons.star_fill, // ✓ Valid (alternative to crown_fill)
        'color': const Color(0xFF6366F1),
      },
    ];
  }
}
