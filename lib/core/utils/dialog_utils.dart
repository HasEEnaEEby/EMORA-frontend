import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DialogUtils {

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
backgroundColor: const Color(0xFF10B981), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
backgroundColor: const Color(0xFFEF4444), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
duration: const Duration(seconds: 4), 
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.info_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
backgroundColor: const Color(0xFF3B82F6), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
backgroundColor: const Color(0xFFF59E0B), 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      ),
    );
  }


  static String getEmojiForAvatar(String avatar) {
    const avatarMap = {
      'fox': '🦊',
      'cat': '🐱',
      'dog': '🐶',
      'owl': '🦉',
      'pig': '🐷',
      'dragon': '🐲',
      'elephant': '🐘',
      'lion': '🦁',
      'tiger': '🐯',
      'bear': '🐻',
      'panda': '🐼',
      'koala': '🐨',
      'monkey': '🐵',
      'rabbit': '🐰',
      'hamster': '🐹',
      'mouse': '🐭',
      'horse': '🐴',
      'unicorn': '🦄',
      'cow': '🐮',
      'sheep': '🐑',
      'goat': '🐐',
      'deer': '🦌',
      'giraffe': '🦒',
      'zebra': '🦓',
      'rhino': '🦏',
      'hippo': '🦛',
      'crocodile': '🐊',
      'turtle': '🐢',
      'lizard': '🦎',
      'snake': '🐍',
      'frog': '🐸',
      'octopus': '🐙',
      'fish': '🐟',
      'dolphin': '🐬',
      'whale': '🐳',
      'shark': '🦈',
      'butterfly': '🦋',
      'bee': '🐝',
      'ladybug': '🐞',
      'spider': '🕷️',
      'scorpion': '🦂',
      'crab': '🦀',
      'lobster': '🦞',
      'shrimp': '🦐',
      'squid': '🦑',
      'penguin': '🐧',
      'chicken': '🐔',
      'rooster': '🐓',
      'duck': '🦆',
      'swan': '🦢',
      'eagle': '🦅',
      'hawk': '🦆',
      'parrot': '🦜',
      'flamingo': '🦩',
    };
    return avatarMap[avatar] ?? '🦊';
  }

  static List<Map<String, String>> getAvailableAvatars() {
    return [
      {'name': 'fox', 'emoji': '🦊'},
      {'name': 'cat', 'emoji': '🐱'},
      {'name': 'dog', 'emoji': '🐶'},
      {'name': 'owl', 'emoji': '🦉'},
      {'name': 'pig', 'emoji': '🐷'},
      {'name': 'dragon', 'emoji': '🐲'},
      {'name': 'elephant', 'emoji': '🐘'},
      {'name': 'lion', 'emoji': '🦁'},
      {'name': 'tiger', 'emoji': '🐯'},
      {'name': 'bear', 'emoji': '🐻'},
      {'name': 'panda', 'emoji': '🐼'},
      {'name': 'koala', 'emoji': '🐨'},
      {'name': 'monkey', 'emoji': '🐵'},
      {'name': 'rabbit', 'emoji': '🐰'},
      {'name': 'hamster', 'emoji': '🐹'},
      {'name': 'mouse', 'emoji': '🐭'},
      {'name': 'horse', 'emoji': '🐴'},
      {'name': 'unicorn', 'emoji': '🦄'},
      {'name': 'cow', 'emoji': '🐮'},
      {'name': 'sheep', 'emoji': '🐑'},
      {'name': 'goat', 'emoji': '🐐'},
      {'name': 'deer', 'emoji': '🦌'},
      {'name': 'giraffe', 'emoji': '🦒'},
      {'name': 'zebra', 'emoji': '🦓'},
      {'name': 'rhino', 'emoji': '🦏'},
      {'name': 'hippo', 'emoji': '🦛'},
      {'name': 'crocodile', 'emoji': '🐊'},
      {'name': 'turtle', 'emoji': '🐢'},
      {'name': 'lizard', 'emoji': '🦎'},
      {'name': 'snake', 'emoji': '🐍'},
      {'name': 'frog', 'emoji': '🐸'},
      {'name': 'octopus', 'emoji': '🐙'},
      {'name': 'fish', 'emoji': '🐟'},
      {'name': 'dolphin', 'emoji': '🐬'},
      {'name': 'whale', 'emoji': '🐳'},
      {'name': 'shark', 'emoji': '🦈'},
      {'name': 'butterfly', 'emoji': '🦋'},
      {'name': 'bee', 'emoji': '🐝'},
      {'name': 'ladybug', 'emoji': '🐞'},
      {'name': 'penguin', 'emoji': '🐧'},
      {'name': 'chicken', 'emoji': '🐔'},
      {'name': 'duck', 'emoji': '🦆'},
      {'name': 'eagle', 'emoji': '🦅'},
      {'name': 'parrot', 'emoji': '🦜'},
      {'name': 'flamingo', 'emoji': '🦩'},
    ];
  }


  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
      {'name': 'Spanish', 'code': 'es', 'flag': '🇪🇸'},
      {'name': 'French', 'code': 'fr', 'flag': '🇫🇷'},
      {'name': 'German', 'code': 'de', 'flag': '🇩🇪'},
      {'name': 'Italian', 'code': 'it', 'flag': '🇮🇹'},
      {'name': 'Portuguese', 'code': 'pt', 'flag': '🇵🇹'},
      {'name': 'Russian', 'code': 'ru', 'flag': '🇷🇺'},
      {'name': 'Chinese', 'code': 'zh', 'flag': '🇨🇳'},
      {'name': 'Japanese', 'code': 'ja', 'flag': '🇯🇵'},
      {'name': 'Korean', 'code': 'ko', 'flag': '🇰🇷'},
      {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦'},
      {'name': 'Hindi', 'code': 'hi', 'flag': '🇮🇳'},
      {'name': 'Dutch', 'code': 'nl', 'flag': '🇳🇱'},
      {'name': 'Swedish', 'code': 'sv', 'flag': '🇸🇪'},
      {'name': 'Norwegian', 'code': 'no', 'flag': '🇳🇴'},
      {'name': 'Danish', 'code': 'da', 'flag': '🇩🇰'},
      {'name': 'Finnish', 'code': 'fi', 'flag': '🇫🇮'},
      {'name': 'Polish', 'code': 'pl', 'flag': '🇵🇱'},
      {'name': 'Turkish', 'code': 'tr', 'flag': '🇹🇷'},
      {'name': 'Thai', 'code': 'th', 'flag': '🇹🇭'},
      {'name': 'Vietnamese', 'code': 'vi', 'flag': '🇻🇳'},
      {'name': 'Indonesian', 'code': 'id', 'flag': '🇮🇩'},
      {'name': 'Malay', 'code': 'ms', 'flag': '🇲🇾'},
    ];
  }


  static List<Map<String, dynamic>> getAvailableThemes() {
    return [
      {
        'name': 'Cosmic Purple',
        'value': '#8B5CF6',
        'primaryColor': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      },
      {
        'name': 'Ocean Blue',
        'value': '#3B82F6',
        'primaryColor': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      },
      {
        'name': 'Forest Green',
        'value': '#10B981',
        'primaryColor': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
      {
        'name': 'Sunset Orange',
        'value': '#F59E0B',
        'primaryColor': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      },
      {
        'name': 'Cherry Blossom',
        'value': '#EC4899',
        'primaryColor': const Color(0xFFEC4899),
        'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      },
      {
        'name': 'Fire Red',
        'value': '#EF4444',
        'primaryColor': const Color(0xFFEF4444),
        'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      },
      {
        'name': 'Emerald Green',
        'value': '#10B981',
        'primaryColor': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
      {
        'name': 'Rose Pink',
        'value': '#EC4899',
        'primaryColor': const Color(0xFFEC4899),
        'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      },
      {
        'name': 'Slate Gray',
        'value': '#64748B',
        'primaryColor': const Color(0xFF64748B),
        'gradient': [const Color(0xFF64748B), const Color(0xFF475569)],
      },
      {
        'name': 'Indigo',
        'value': '#6366F1',
        'primaryColor': const Color(0xFF6366F1),
        'gradient': [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
      },
    ];
  }


  static Color getAchievementColor(String category) {
    switch (category.toLowerCase()) {
      case 'milestone':
return const Color(0xFFFFD700); 
      case 'streak':
return const Color(0xFFFF6B35); 
      case 'social':
return const Color(0xFF8B5CF6); 
      case 'discovery':
return const Color(0xFF06D6A0); 
      case 'wellness':
return const Color(0xFF118AB2); 
      case 'insights':
return const Color(0xFFEF476F); 
      case 'emotions':
return const Color(0xFFFF8E53); 
      case 'journal':
return const Color(0xFF9B59B6); 
      case 'mindfulness':
return const Color(0xFF1ABC9C); 
      case 'progress':
return const Color(0xFF3498DB); 
      case 'community':
return const Color(0xFFE74C3C); 
      case 'growth':
return const Color(0xFF27AE60); 
      case 'general':
      default:
return const Color(0xFF6C757D); 
    }
  }

  static IconData getAchievementIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'star':
        return CupertinoIcons.star_fill;
      case 'flame':
        return CupertinoIcons.flame_fill;
      case 'heart':
        return CupertinoIcons.heart_fill;
      case 'target':
        return CupertinoIcons.scope;
      case 'calendar':
        return CupertinoIcons.calendar;
      case 'brain':
        return CupertinoIcons.hand_draw_fill;
      case 'trophy':
        return CupertinoIcons.rosette;
      case 'medal':
        return CupertinoIcons.checkmark_seal_fill;
      case 'badge':
        return CupertinoIcons.shield_lefthalf_fill;
      case 'crown':
        return CupertinoIcons.star_fill;
      case 'diamond':
        return CupertinoIcons.rhombus_fill;
      case 'lightning':
        return CupertinoIcons.bolt_fill;
      case 'rocket':
        return CupertinoIcons.paperplane_fill;
      case 'thumbs_up':
        return CupertinoIcons.hand_thumbsup_fill;
      case 'clock':
        return CupertinoIcons.clock_fill;
      case 'check':
        return CupertinoIcons.checkmark_circle_fill;
      case 'gift':
        return CupertinoIcons.gift_fill;
      case 'book':
        return CupertinoIcons.book_fill;
      case 'pencil':
        return CupertinoIcons.pencil_circle_fill;
      case 'camera':
        return CupertinoIcons.camera_fill;
      case 'music':
        return CupertinoIcons.music_note;
      default:
        return CupertinoIcons.star_fill;
    }
  }


  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }
    
    if (value.trim().length > 50) {
      return 'Display name must be less than 50 characters';
    }
    
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.trim().length > 30) {
      return 'Username must be less than 30 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    if (!isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, lowercase letter, and number';
    }
    
    return null;
  }

  static String? validateBio(String? value) {
    if (value != null && value.length > 200) {
      return 'Bio must be less than 200 characters';
    }
    return null;
  }


  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  static String formatDateShort(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }

  static String formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }


  static String formatDisplayName(String? displayName, String fallbackName) {
    if (displayName?.isNotEmpty == true) {
      return displayName!;
    }
    return fallbackName;
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  static Color getThemeColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
return const Color(0xFF8B5CF6); 
    }
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }


  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(
                  radius: 20,
                  color: Color(0xFF8B5CF6),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            isDestructiveAction: isDestructive,
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(
              buttonText,
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> showTextInputDialog(
    BuildContext context, {
    required String title,
    required String placeholder,
    String? initialValue,
    int maxLength = 100,
    String confirmText = 'Save',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    
    return await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Column(
          children: [
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              maxLength: maxLength,
              style: const TextStyle(fontSize: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, null),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }


  static void updateProfileWithBloc(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(UpdateProfile(profileData: profileData));
    } catch (e) {
      showErrorSnackBar(context, 'Failed to update profile: ${e.toString()}');
    }
  }

  static void updatePreferencesWithBloc(
    BuildContext context,
    Map<String, dynamic> preferences,
  ) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(UpdatePreferences(preferences: preferences));
    } catch (e) {
      showErrorSnackBar(context, 'Failed to update preferences: ${e.toString()}');
    }
  }

  static void updateSettingsWithBloc(
    BuildContext context,
    Map<String, dynamic> settings,
  ) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(UpdateSettings(settings: settings));
    } catch (e) {
      showErrorSnackBar(context, 'Failed to update settings: ${e.toString()}');
    }
  }

  static void exportDataWithBloc(BuildContext context) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(const ExportData());
      showInfoSnackBar(context, 'Data export started...');
    } catch (e) {
      showErrorSnackBar(context, 'Failed to export data: ${e.toString()}');
    }
  }

  static void signOutWithBloc(BuildContext context) {
    try {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(const AuthLogout());
    } catch (e) {
      showErrorSnackBar(context, 'Failed to sign out: ${e.toString()}');
    }
  }

  static Future<void> deleteAccountWithBloc(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Delete Account',
      message: 'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
      confirmText: 'Delete Account',
      isDestructive: true,
    );

    if (confirmed) {
      try {
        showInfoSnackBar(context, 'Account deletion feature coming soon...');
      } catch (e) {
        showErrorSnackBar(context, 'Failed to delete account: ${e.toString()}');
      }
    }
  }

  static void loadProfileWithBloc(BuildContext context) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(const LoadProfile());
    } catch (e) {
      showErrorSnackBar(context, 'Failed to load profile: ${e.toString()}');
    }
  }

  static void refreshProfileWithBloc(BuildContext context) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(const RefreshProfile());
    } catch (e) {
      showErrorSnackBar(context, 'Failed to refresh profile: ${e.toString()}');
    }
  }


  static void lightHaptic() {
    HapticFeedback.lightImpact();
  }

  static void mediumHaptic() {
    HapticFeedback.mediumImpact();
  }

  static void heavyHaptic() {
    HapticFeedback.heavyImpact();
  }

  static void selectionHaptic() {
    HapticFeedback.selectionClick();
  }


  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  static void navigateToAchievements(BuildContext context) {
    Navigator.pushNamed(context, '/achievements');
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }


  static String getFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (errorLower.contains('server') || errorLower.contains('500')) {
      return 'Server is temporarily unavailable. Please try again later.';
    } else if (errorLower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorLower.contains('not found') || errorLower.contains('404')) {
      return 'Requested resource not found.';
    } else if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return 'You are not authorized to perform this action.';
    } else if (errorLower.contains('forbidden') || errorLower.contains('403')) {
      return 'Access to this resource is forbidden.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }


  static const List<String> defaultPronouns = [
    'They / Them',
    'He / Him',
    'She / Her',
    'Prefer not to say',
  ];

  static const List<String> defaultAgeGroups = [
    '13-17',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55-64',
    '65+',
    'Prefer not to say',
  ];

  static const String defaultThemeColor = '#8B5CF6';
  static const String defaultAvatar = 'fox';
  static const String defaultLanguage = 'English';
}