// lib/app/constants/app_colors.dart
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';

/// Clean wrapper for all app colors - imports from app_config.dart
/// This provides organized access to the emotional serenity color palette
class AppColors {
  /// Main background color - soft lavender for calmness
  static const Color softLavender = AppConfig.softLavender;

  /// Primary text color - gentle dark navy
  static const Color midnightNavy = AppConfig.midnightNavy;

  /// Accent and CTA color - trustworthy blue
  static const Color oceanMist = AppConfig.oceanMist;

  /// Emotion highlights - comforting warm blush
  static const Color warmBlush = AppConfig.warmBlush;

  /// Cards and surfaces - clean white
  static const Color cloudWhite = AppConfig.cloudWhite;

  // ===========================
  // CHILD-FRIENDLY PURPLE COLORS
  // ===========================

  /// Vibrant purple for main elements
  static const Color vibrantPurple = AppConfig.vibrantPurple;

  /// Playful purple for accents
  static const Color playfulPurple = AppConfig.playfulPurple;

  /// Deep purple for text
  static const Color deepPurple = AppConfig.deepPurple;

  /// Charcoal purple for primary text
  static const Color charcoalPurple = AppConfig.charcoalPurple;

  /// Royal purple for contrast
  static const Color royalPurple = AppConfig.royalPurple;

  // ===========================
  // CHILD-FRIENDLY COMPLEMENTARY COLORS
  // ===========================

  /// Sunny yellow for highlights
  static const Color sunnyYellow = AppConfig.sunnyYellow;

  /// Sky blue for accents
  static const Color skyBlue = AppConfig.skyBlue;

  /// Mint green for success
  static const Color mintGreen = AppConfig.mintGreen;

  /// Peach pink for warmth
  static const Color peachPink = AppConfig.peachPink;

  // ===========================
  // SUPPORTING COLORS
  // ===========================

  /// Subtle dividers and borders
  static const Color softGray = AppConfig.softGray;

  /// Secondary text color
  static const Color deepLavender = AppConfig.deepLavender;

  /// Light background variants
  static const Color paleBlush = AppConfig.paleBlush;

  /// Accent background variants
  static const Color mistBlue = AppConfig.mistBlue;

  // ===========================
  // EMOTION COLORS - SOFT GLOWS
  // ===========================

  /// Joy emotion - warm yellow glow
  static const Color emotionJoy = AppConfig.emotionJoy;

  /// Calm emotion - soft green glow
  static const Color emotionCalm = AppConfig.emotionCalm;

  /// Sad emotion - light blue glow
  static const Color emotionSad = AppConfig.emotionSad;

  /// Anxious emotion - light purple glow
  static const Color emotionAnxious = AppConfig.emotionAnxious;

  /// Angry emotion - soft red glow
  static const Color emotionAngry = AppConfig.emotionAngry;

  /// Neutral emotion - gray glow
  static const Color emotionNeutral = AppConfig.emotionNeutral;

  /// Peaceful emotion - mint green glow
  static const Color emotionPeaceful = AppConfig.emotionPeaceful;

  /// Excited emotion - warm orange glow
  static const Color emotionExcited = AppConfig.emotionExcited;

  /// Numb emotion - neutral glow
  static const Color emotionNumb = AppConfig.emotionNumb;

  // ===========================
  // STATUS COLORS - MUTED FOR CALMNESS
  // ===========================

  /// Success state - soft green
  static const Color success = AppConfig.successGreen;

  /// Error state - soft red
  static const Color error = AppConfig.errorRed;

  /// Warning state - soft yellow
  static const Color warning = AppConfig.warningYellow;

  /// Info state - soft blue
  static const Color info = AppConfig.infoBlue;

  // ===========================
  // NAVIGATION COLORS
  // ===========================

  /// Home navigation color
  static const Color navHome = AppConfig.navHome;

  /// Mood Atlas navigation color
  static const Color navMoodAtlas = AppConfig.navMoodAtlas;

  /// Insights navigation color
  static const Color navInsights = AppConfig.navInsights;

  /// Friends navigation color
  static const Color navFriends = AppConfig.navFriends;

  /// Venting navigation color
  static const Color navVenting = AppConfig.navVenting;

  // ===========================
  // LEGACY SUPPORT (Backward Compatibility)
  // ===========================

  /// Primary color (maps to vibrantPurple)
  static const Color primary = AppConfig.vibrantPurple;

  /// Secondary color (maps to deepLavender)
  static const Color secondary = AppConfig.deepLavender;

  /// Accent color (maps to warmBlush)
  static const Color accent = AppConfig.warmBlush;

  /// Background color (maps to softLavender)
  static const Color background = AppConfig.softLavender;

  /// Surface color (maps to cloudWhite)
  static const Color surface = AppConfig.cloudWhite;

  /// Surface variant (maps to paleBlush)
  static const Color surfaceVariant = AppConfig.paleBlush;

  /// Primary text (maps to charcoalPurple)
  static const Color textPrimary = AppConfig.charcoalPurple;

  /// Secondary text (maps to deepLavender)
  static const Color textSecondary = AppConfig.deepLavender;

  /// Muted text (maps to softGray)
  static const Color textMuted = AppConfig.softGray;

  /// Tertiary text (lighter than muted) - ADDED
  static const Color textTertiary = Color(0xFFB8B8CC);

  // ===========================
  // UTILITY COLORS
  // ===========================

  /// Pure white
  static const Color white = AppConfig.cloudWhite;

  /// Pure black (mapped to charcoalPurple for consistency)
  static const Color black = AppConfig.charcoalPurple;

  /// Transparent
  static const Color transparent = Color(0x00000000);

  // ===========================
  // BORDER COLORS
  // ===========================

  /// Light borders
  static Color border = AppConfig.softGray;

  /// Medium borders
  static Color borderMedium = AppConfig.deepLavender;

  /// Dark borders
  static final Color borderDark = AppConfig.charcoalPurple;

  // ===========================
  // HELPER METHODS
  // ===========================

  /// Get emotion color by name
  static Color getEmotionColor(String emotion) =>
      AppConfig.getEmotionColor(emotion);

  /// Get emotion gradient by name
  static List<Color> getEmotionGradient(String emotion) =>
      AppConfig.getEmotionGradient(emotion);

  /// Get navigation color by index
  static Color getNavColor(int index) => AppConfig.getNavColor(index);

  /// Check if color is dark (for contrast)
  static bool isColorDark(Color color) => AppConfig.isColorDark(color);

  /// Get contrast text color for background
  static Color getContrastTextColor(Color backgroundColor) =>
      AppConfig.getContrastTextColor(backgroundColor);

  /// Get emotion color with custom opacity
  static Color getEmotionWithOpacity(String emotion, double opacity) {
    final baseColor = getEmotionColor(emotion);
    return baseColor.withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  /// Get emotion color with intensity (for emotion tracking)
  static Color getEmotionWithIntensity(String emotion, double intensity) {
    final baseColor = getEmotionColor(emotion);
    final alpha = (intensity / 10 * 0.7 + 0.3).clamp(0.3, 1.0);
    return baseColor.withValues(alpha: alpha);
  }

  /// Get complementary background color for emotion
  static Color getComplementaryBackground(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happy':
      case 'excited':
        return emotionJoy;
      case 'calm':
      case 'peaceful':
      case 'grateful':
        return emotionCalm;
      case 'sad':
      case 'sadness':
      case 'lonely':
        return emotionSad;
      case 'angry':
      case 'anger':
      case 'frustrated':
        return emotionAngry;
      case 'anxious':
      case 'overwhelmed':
        return emotionAnxious;
      case 'numb':
        return emotionNumb;
      default:
        return emotionPeaceful;
    }
  }

  // ===========================
  // COLOR COLLECTIONS
  // ===========================

  /// All emotion colors as a map
  static const Map<String, Color> emotionColors = {
    'joy': emotionJoy,
    'calm': emotionCalm,
    'sad': emotionSad,
    'anxious': emotionAnxious,
    'angry': emotionAngry,
    'neutral': emotionNeutral,
    'peaceful': emotionPeaceful,
    'excited': emotionExcited,
    'numb': emotionNumb,
  };

  /// All navigation colors as a list
  static const List<Color> navigationColors = [
    navHome,
    navMoodAtlas,
    navInsights,
    navFriends,
    navVenting,
  ];

  /// All status colors as a map
  static const Map<String, Color> statusColors = {
    'success': success,
    'error': error,
    'warning': warning,
    'info': info,
  };
}
