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

class ProfileDialogs {

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


  static void showAllAchievements(
    BuildContext context,
    List<dynamic> achievements,
  ) {
    try {
      FixedAchievementsDialog.showAll(context, achievements);
    } catch (e) {
      _handleDialogError(context, 'Failed to load achievements', e);
    }
  }

  static void showAchievementDetail(BuildContext context, dynamic achievement) {
    try {
      FixedAchievementsDialog.showDetail(context, achievement);
    } catch (e) {
      _handleDialogError(context, 'Failed to show achievement details', e);
    }
  }


  static void showQRCode(BuildContext context, dynamic profile) {
    try {
      if (profile == null) {
        DialogUtils.showErrorSnackBar(context, 'Profile data not available');
        return;
      }
      SafeQRCodeDialog.show(context, profile);
    } catch (e) {
      _handleDialogError(context, 'Failed to generate QR code', e);
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

  static void showThemeSelector(
    BuildContext context,
    String selectedTheme,
    ValueChanged<String> onThemeChanged,
  ) {
    try {
      ThemeSelectorDialog.show(context, selectedTheme, onThemeChanged);
    } catch (e) {
      _handleDialogError(context, 'Failed to open theme selector', e);
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

  static void showDetailedExportOptions(BuildContext context) {
    try {
      ExportDataDialog.showDetailedExportOptions(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to open detailed export options', e);
    }
  }


  static void showSignOutDialog(BuildContext context) {
    try {
      AccountManagementDialog.showSignOut(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to open sign out dialog', e);
    }
  }

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

  static void showComingSoonDialog(BuildContext context, String feature) {
    try {
      AccountManagementDialog.showComingSoon(context, feature);
    } catch (e) {
      _handleDialogError(context, 'Failed to show coming soon dialog', e);
    }
  }

  static void showAccountSecurity(BuildContext context) {
    try {
      AccountManagementDialog.showAccountSecurity(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show account security', e);
    }
  }

  static void showPrivacySettings(BuildContext context) {
    try {
      AccountManagementDialog.showPrivacySettings(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show privacy settings', e);
    }
  }

  static void showSupportHelp(BuildContext context) {
    try {
      AccountManagementDialog.showSupportHelp(context);
    } catch (e) {
      _handleDialogError(context, 'Failed to show support options', e);
    }
  }


  static void _handleDialogError(
    BuildContext context,
    String userMessage,
    dynamic error,
  ) {
    debugPrint('ProfileDialogs Error: $userMessage - $error');

    HapticFeedback.heavyImpact();

    DialogUtils.showErrorSnackBar(context, userMessage);

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


  static void showSuccessSnackBar(BuildContext context, String message) {
    DialogUtils.showSuccessSnackBar(context, message);
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    DialogUtils.showErrorSnackBar(context, message);
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    DialogUtils.showInfoSnackBar(context, message);
  }


  static List<Map<String, String>> getAvailableAvatars() {
    return DialogUtils.getAvailableAvatars();
  }

  static List<Map<String, String>> getAvailableLanguages() {
    return DialogUtils.getAvailableLanguages();
  }

  static List<Map<String, dynamic>> getAvailableThemes() {
    return DialogUtils.getAvailableThemes();
  }

  static String getEmojiForAvatar(String avatarName) {
    return DialogUtils.getEmojiForAvatar(avatarName);
  }

  static Color getAchievementColor(String category) {
    return DialogUtils.getAchievementColor(category);
  }

  static bool isValidEmail(String email) {
    return DialogUtils.isValidEmail(email);
  }

  static String formatDate(DateTime date) {
    return DialogUtils.formatDate(date);
  }

  static List<Map<String, dynamic>> getValidThemeIcons() {
    return [
      {
        'name': 'Cosmic Purple',
'icon': CupertinoIcons.sparkles, 
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Ocean Blue',
'icon': CupertinoIcons.drop_fill, 
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Forest Green',
'icon': CupertinoIcons.leaf_arrow_circlepath, 
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Sunset Orange',
'icon': CupertinoIcons.sun_max_fill, 
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Cherry Blossom',
'icon': CupertinoIcons.heart_fill, 
        'color': const Color(0xFFEC4899),
      },
      {
        'name': 'Fire Red',
'icon': CupertinoIcons.flame_fill, 
        'color': const Color(0xFFEF4444),
      },
      {
        'name': 'Mystic Teal',
'icon': CupertinoIcons.waveform, 
        'color': const Color(0xFF14B8A6),
      },
      {
        'name': 'Royal Indigo',
'icon': CupertinoIcons.star_fill, 
        'color': const Color(0xFF6366F1),
      },
    ];
  }
}
