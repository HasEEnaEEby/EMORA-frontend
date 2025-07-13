import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_bloc.dart';
import 'package:emora_mobile_app/features/profile/presentation/view_model/profile_event.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Enhanced DialogUtils class with all required methods
class DialogUtils {
  // MARK: - SnackBar Methods

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
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
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.info_circle_fill, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // MARK: - Avatar Methods

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
    ];
  }

  // MARK: - Language Methods

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
    ];
  }

  // MARK: - Theme Methods

  static List<Map<String, dynamic>> getAvailableThemes() {
    return [
      {
        'name': 'Cosmic Purple',
        'primaryColor': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      },
      {
        'name': 'Ocean Blue',
        'primaryColor': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      },
      {
        'name': 'Forest Green',
        'primaryColor': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
      {
        'name': 'Sunset Orange',
        'primaryColor': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      },
      {
        'name': 'Cherry Blossom',
        'primaryColor': const Color(0xFFEC4899),
        'gradient': [const Color(0xFFEC4899), const Color(0xFFDB2777)],
      },
      {
        'name': 'Fire Red',
        'primaryColor': const Color(0xFFEF4444),
        'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      },
    ];
  }

  // MARK: - Achievement Methods

  static Color getAchievementColor(String category) {
    switch (category.toLowerCase()) {
      case 'milestone':
        return const Color(0xFFFFD700); // Gold
      case 'streak':
        return const Color(0xFFFF6B35); // Orange
      case 'social':
        return const Color(0xFF8B5CF6); // Purple
      case 'discovery':
        return const Color(0xFF06D6A0); // Teal
      case 'wellness':
        return const Color(0xFF118AB2); // Blue
      case 'insights':
        return const Color(0xFFEF476F); // Pink
      case 'general':
      default:
        return const Color(0xFF6C757D); // Gray
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
      default:
        return CupertinoIcons.star_fill;
    }
  }

  // MARK: - Validation Methods

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // MARK: - Date Methods

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
    } else {
      final months = (difference / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // MARK: - BLoC Integration Methods

  static void updateProfileWithBloc(
    BuildContext context,
    Map<String, dynamic> profileData,
  ) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(UpdateProfile(profileData: profileData));
    } catch (e) {
      showErrorSnackBar(context, 'Failed to update profile');
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
      showErrorSnackBar(context, 'Failed to update preferences');
    }
  }

  static void exportDataWithBloc(BuildContext context) {
    try {
      final profileBloc = context.read<ProfileBloc>();
      profileBloc.add(const ExportData());
      showInfoSnackBar(context, 'Data export started...');
    } catch (e) {
      showErrorSnackBar(context, 'Failed to export data');
    }
  }

  static void signOutWithBloc(BuildContext context) {
    try {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(const AuthLogout());
    } catch (e) {
      showErrorSnackBar(context, 'Failed to sign out');
    }
  }
}

// Additional Profile BLoC Events (add these to your profile_event.dart file)
class ProfileUpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  const ProfileUpdateProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class ProfileExportData extends ProfileEvent {
  const ProfileExportData();

  @override
  List<Object?> get props => [];
}

// Additional Auth BLoC Events (add these to your auth_event.dart file)
class AuthLogout extends AuthEvent {
  const AuthLogout();

  @override
  List<Object?> get props => [];
}
