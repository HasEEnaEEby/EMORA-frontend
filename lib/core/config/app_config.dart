// lib/core/config/app_config.dart
import 'package:flutter/material.dart';

/// Master configuration file - Single source of truth for all app constants
/// Updated with vibrant, child-friendly purple color palette
class AppConfig {
  // ===========================
  // APP IDENTITY & VERSION
  // ===========================
  static const String appName = 'Emora';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your mindful emotion companion';

  // ===========================
  // API CONFIGURATION
  // ===========================
  static const String apiBaseUrl = 'http://localhost:8000';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ===========================
  // API ENDPOINTS
  // ===========================

  // Authentication & User Management
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String profileEndpoint = '/api/auth/profile';
  static const String currentUserEndpoint = '/api/auth/me';

  // Onboarding
  static const String checkUsernameEndpoint = '/api/onboarding/check-username';
  static const String onboardingStepsEndpoint = '/api/onboarding/steps';
  static const String userDataEndpoint = '/api/onboarding/user-data';
  static const String completeOnboardingEndpoint = '/api/onboarding/complete';

  // Home & Dashboard
  static const String homeDataEndpoint = '/api/onboarding/user-data';
  static const String userStatsEndpoint = '/api/user/stats';

  // Emotions
  static const String logEmotionEndpoint = '/api/emotions/log';
  static const String emotionJourneyEndpoint = '/api/emotions/journey';
  static const String globalEmotionStatsEndpoint = '/api/emotions/global-stats';
  static const String globalEmotionHeatmapEndpoint =
      '/api/emotions/global-heatmap';
  static const String emotionFeedEndpoint = '/api/emotions/feed';
  static const String ventingSessionEndpoint = '/api/emotions/vent';
  static const String emotionInsightsEndpoint = '/api/emotions/insights';

  // ===========================
  // STORAGE KEYS
  // ===========================
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastEmotionLogKey = 'last_emotion_log';
  static const String userPreferencesKey = 'user_preferences';

  // ===========================
  // CHILD-FRIENDLY PURPLE COLOR PALETTE 🌈
  // ===========================

  // Original Colors (for backward compatibility)
  static const Color softLavender = Color(
    0xFFF3E8FF,
  ); // Very light purple background
  static const Color midnightNavy = Color(
    0xFF374151,
  ); // Charcoal purple for text
  static const Color oceanMist = Color(0xFFB347D9); // Vibrant purple for CTAs
  static const Color warmBlush = Color(0xFFFED7D7); // Gentle pink warmth
  static const Color cloudWhite = Color(0xFFFFFFFF); // Pure white surfaces

  // Child-Friendly Purple Shades
  static const Color vibrantPurple = Color(
    0xFFB347D9,
  ); // Main purple for buttons
  static const Color playfulPurple = Color(
    0xFFD8A5FF,
  ); // Medium purple for accents
  static const Color deepPurple = Color(0xFF8B3FB8); // Dark purple for text
  static const Color charcoalPurple = Color(0xFF374151); // Primary text color
  static const Color royalPurple = Color(
    0xFF5B21B6,
  ); // Darkest purple for contrast

  // Child-Friendly Complementary Colors
  static const Color sunnyYellow = Color(0xFFFEF3C7); // Warm yellow highlights
  static const Color skyBlue = Color(0xFFDBEAFE); // Soft blue accents
  static const Color mintGreen = Color(0xFFD1FAE5); // Fresh green success
  static const Color peachPink = Color(0xFFFED7D7); // Gentle pink warmth

  // Supporting Colors - Child-Friendly
  static const Color softGray = Color(0xFFE5E7EB); // Light borders
  static const Color deepLavender = Color(
    0xFF8B3FB8,
  ); // Dark purple for secondary text
  static const Color paleBlush = Color(0xFFFEF3C7); // Warm yellow backgrounds
  static const Color mistBlue = Color(0xFFDBEAFE); // Soft blue accents

  // Legacy mappings for backward compatibility
  static const Color primaryPurple = vibrantPurple;
  static const Color secondaryPurple = playfulPurple;
  static const Color accentPurple = peachPink;
  static const Color backgroundDark = softLavender;
  static const Color backgroundCard = cloudWhite;
  static const Color backgroundSurface = Color(0xFFE9D8FD); // Soft lavender
  static const Color textPrimary = charcoalPurple;
  static const Color textSecondary = deepPurple;
  static const Color textMuted = Color(0xFF9CA3AF); // Purple gray

  // ===========================
  // CHILD-FRIENDLY EMOTION COLORS 🎨
  // ===========================

  static const Color emotionJoy = Color(0xFFFEF3C7); // Bright sunny yellow
  static const Color emotionCalm = Color(0xFFD1FAE5); // Soft mint green
  static const Color emotionSad = Color(0xFFDBEAFE); // Gentle sky blue
  static const Color emotionAnxious = Color(0xFFF3E8FF); // Light purple
  static const Color emotionAngry = Color(0xFFFED7D7); // Soft coral pink
  static const Color emotionNeutral = Color(0xFFF9FAFB); // Cool gray
  static const Color emotionPeaceful = Color(0xFFECFDF5); // Fresh mint
  static const Color emotionExcited = Color(
    0xFFFEF3C7,
  ); // Vibrant yellow-orange
  static const Color emotionNumb = Color(0xFFF5F5F5); // Neutral light gray

  // ===========================
  // STATUS COLORS - CHILD-FRIENDLY
  // ===========================

  static const Color successGreen = Color(0xFFD1FAE5); // Happy green
  static const Color errorRed = Color(0xFFFED7D7); // Gentle red
  static const Color warningYellow = Color(0xFFFEF3C7); // Cheerful yellow
  static const Color infoBlue = Color(0xFFDBEAFE); // Friendly blue

  // ===========================
  // NAVIGATION COLORS - PLAYFUL
  // ===========================

  static const Color navHome = vibrantPurple;
  static const Color navMoodAtlas = mintGreen;
  static const Color navInsights = skyBlue;
  static const Color navFriends = peachPink;
  static const Color navVenting = sunnyYellow;

  // ===========================
  // CHILD-FRIENDLY DIMENSIONS
  // ===========================

  // Spacing - More generous for little fingers
  static const double paddingTiny = 6.0; // Increased from 4.0
  static const double paddingSmall = 10.0; // Increased from 8.0
  static const double paddingMedium = 16.0; // Increased from 12.0
  static const double paddingLarge = 20.0; // Increased from 16.0
  static const double paddingXLarge = 28.0; // Increased from 24.0
  static const double paddingXXLarge = 36.0; // Increased from 32.0
  static const double paddingHuge = 44.0; // Increased from 40.0
  static const double paddingMassive = 52.0; // Increased from 48.0

  // Border Radius - More rounded for friendly feel
  static const double radiusTiny = 6.0; // Increased from 4.0
  static const double radiusSmall = 12.0; // Increased from 8.0
  static const double radiusMedium = 16.0; // Increased from 12.0
  static const double radiusLarge = 20.0; // Increased from 16.0
  static const double radiusXLarge = 24.0; // Increased from 20.0
  static const double radiusXXLarge = 28.0; // Increased from 24.0
  static const double radiusHuge = 32.0; // Increased from 28.0
  static const double radiusCircular = 100.0; // Fully circular

  // Text Sizes - Larger for better readability
  static const double textTiny = 12.0; // Increased from 10.0
  static const double textSmall = 14.0; // Increased from 12.0
  static const double textMedium = 16.0; // Increased from 14.0
  static const double textLarge = 18.0; // Increased from 16.0
  static const double textXLarge = 20.0; // Increased from 18.0
  static const double textXXLarge = 22.0; // Increased from 20.0
  static const double textHeader = 26.0; // Increased from 24.0
  static const double textTitle = 30.0; // Increased from 28.0
  static const double textDisplay = 34.0; // Increased from 32.0
  static const double textHero = 38.0; // Increased from 36.0

  // Icon Sizes - Larger for better interaction
  static const double iconTiny = 16.0; // Increased from 12.0
  static const double iconSmall = 20.0; // Increased from 16.0
  static const double iconMedium = 24.0; // Increased from 20.0
  static const double iconLarge = 28.0; // Increased from 24.0
  static const double iconXLarge = 36.0; // Increased from 32.0
  static const double iconXXLarge = 52.0; // Increased from 48.0
  static const double iconHuge = 68.0; // Increased from 64.0
  static const double iconMassive = 84.0; // Increased from 80.0

  // Component Sizes - Child-friendly touch targets
  static const double buttonHeight = 52.0; // Increased from 48.0
  static const double buttonHeightSmall = 40.0; // Increased from 36.0
  static const double buttonHeightLarge = 60.0; // Increased from 56.0
  static const double inputHeight = 52.0; // Increased from 48.0
  static const double cardHeight = 180.0; // Increased from 160.0
  static const double cardHeightLarge = 220.0; // Increased from 200.0
  static const double avatarSize = 52.0; // Increased from 48.0
  static const double avatarSizeLarge = 84.0; // Increased from 80.0

  // Emotion-specific Dimensions
  static const double emotionTileSize = 88.0; // Increased from 80.0
  static const double emotionDotSize = 16.0; // Increased from 12.0
  static const double earthSectionHeight = 340.0; // Increased from 320.0
  static const double sliderHeight = 52.0; // Increased from 48.0
  static const double progressBarHeight = 10.0; // Increased from 8.0

  // Layout Constraints
  static const double maxContentWidth = 420.0; // Increased from 400.0
  static const double sectionSpacing = 36.0; // Increased from 32.0
  static const double itemSpacing = 20.0; // Increased from 16.0
  static const double gridSpacing = 16.0; // Increased from 12.0

  // Touch Targets (Child-friendly)
  static const double minTouchTarget = 48.0; // Increased from 44.0
  static const double comfortableTouchTarget = 52.0; // Increased from 48.0

  // ===========================
  // ENVIRONMENT & FEATURE FLAGS
  // ===========================

  static const bool isDevelopmentMode = true;
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enableOfflineMode = true;
  static const bool gracefullyHandleMissingEndpoints = true;

  // ===========================
  // TIMING CONFIGURATION
  // ===========================

  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration cacheExpirationDuration = Duration(hours: 24);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetryAttempts = 3;
  static const int maxCacheSize = 100;

  // Animation Durations (milliseconds) - Slightly longer for children
  static const int animationInstant = 150; // Increased from 100
  static const int animationFast = 250; // Increased from 200
  static const int animationMedium = 350; // Increased from 300
  static const int animationSlow = 550; // Increased from 500
  static const int animationXSlow = 850; // Increased from 800
  static const int animationBreathing = 4000;

  // ===========================
  // VALIDATION CONSTANTS
  // ===========================

  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  // ===========================
  // BUSINESS LOGIC DATA
  // ===========================

  static const List<String> availablePronouns = [
    'She / Her',
    'He / Him',
    'They / Them',
    'Other',
  ];

  static const List<String> availableAgeGroups = [
    'Under 18',
    '18-25',
    '26-35',
    '36-45',
    '46-60',
    'Over 60',
  ];

  static const List<String> availableAvatars = [
    'panda',
    'elephant',
    'horse',
    'rabbit',
    'fox',
    'zebra',
    'bear',
    'pig',
    'raccoon',
  ];

  static const String defaultPronoun = 'They / Them';
  static const String defaultAgeGroup = '20s';
  static const String defaultAvatar = 'panda';

  static const List<String> reservedUsernames = [
    'admin',
    'administrator',
    'root',
    'moderator',
    'support',
    'help',
    'api',
    'www',
    'mail',
    'email',
    'system',
    'service',
    'emora',
    'official',
    'staff',
    'team',
    'bot',
    'null',
    'undefined',
  ];

  // ===========================
  // GENTLE MESSAGING STRINGS
  // ===========================

  // Error Messages - Gentle and understanding
  static const String networkErrorMessage =
      'Connection seems quiet. Check your network when ready';
  static const String serverErrorMessage =
      'Something didn\'t work. That\'s okay, let\'s try again';
  static const String timeoutErrorMessage =
      'Taking a bit longer than usual. Please try again when ready';
  static const String unauthorizedErrorMessage =
      'Please sign in to continue your journey';
  static const String validationErrorMessage =
      'Let\'s check that information together';

  // Success Messages - Encouraging and warm
  static const String loginSuccessMessage = 'Welcome back! 🌸';
  static const String registrationSuccessMessage = 'Your space is ready! ✨';
  static const String logoutSuccessMessage = 'Take care, see you soon';
  static const String onboardingCompleteMessage =
      'Your emotional journey begins 🪷';

  // Development Messages
  static const String developmentModeMessage =
      'Running in development mode - crafting with care';
  static const String endpointNotAvailableMessage =
      'This feature is being crafted with love';

  // ===========================
  // ENVIRONMENT HELPERS
  // ===========================

  static bool get isDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static bool get isProductionMode => !isDebugMode;

  static String get effectiveApiBaseUrl {
    if (isDevelopmentMode) {
      return 'http://localhost:8000';
    } else {
      return 'https://api.emora.app';
    }
  }

  // ===========================
  // VALIDATION LOGIC
  // ===========================

  static bool isValidUsername(String username) {
    if (username.length < minUsernameLength ||
        username.length > maxUsernameLength) {
      return false;
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return false;
    }
    if (username.startsWith('_') || username.endsWith('_')) {
      return false;
    }
    if (RegExp(r'^\d+$').hasMatch(username)) {
      return false;
    }
    if (reservedUsernames.contains(username.toLowerCase())) {
      return false;
    }
    return true;
  }

  static bool isValidPassword(String password) {
    if (password.length < minPasswordLength ||
        password.length > maxPasswordLength) {
      return false;
    }
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (!isValidUsername(username)) {
      if (username.length < minUsernameLength) {
        return 'Username must be at least $minUsernameLength characters';
      }
      if (username.length > maxUsernameLength) {
        return 'Username must be less than $maxUsernameLength characters';
      }
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
        return 'Username can only contain letters, numbers, and underscores';
      }
      if (username.startsWith('_') || username.endsWith('_')) {
        return 'Username cannot start or end with underscore';
      }
      if (RegExp(r'^\d+$').hasMatch(username)) {
        return 'Username cannot be only numbers';
      }
      if (reservedUsernames.contains(username.toLowerCase())) {
        return 'Username is reserved and cannot be used';
      }
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      if (password.length < minPasswordLength) {
        return 'Password must be at least $minPasswordLength characters';
      }
      if (password.length > maxPasswordLength) {
        return 'Password must be less than $maxPasswordLength characters';
      }
      return 'Password must contain uppercase, lowercase, number, and special character';
    }
    return null;
  }

  // ===========================
  // ERROR HANDLING
  // ===========================

  static bool shouldHandleErrorGracefully(
    int? statusCode,
    String? errorMessage,
  ) {
    if (!isDevelopmentMode) return false;
    if (statusCode == 404) return true;
    if (statusCode == 401 && gracefullyHandleMissingEndpoints) return true;
    if (errorMessage != null) {
      if (errorMessage.contains('user/home-data') ||
          errorMessage.contains('not found') ||
          (errorMessage.contains('Route') &&
              errorMessage.contains('not found'))) {
        return true;
      }
    }
    return false;
  }

  static String getFriendlyErrorMessage(String originalError) {
    if (originalError.contains('404') || originalError.contains('not found')) {
      return isDevelopmentMode
          ? 'Feature not available in development mode'
          : 'Service temporarily unavailable';
    }
    if (originalError.contains('401') ||
        originalError.contains('unauthorized')) {
      return 'Authentication required';
    }
    if (originalError.contains('network') ||
        originalError.contains('connection')) {
      return networkErrorMessage;
    }
    if (originalError.contains('timeout')) {
      return timeoutErrorMessage;
    }
    return isDevelopmentMode
        ? 'Development mode: $originalError'
        : serverErrorMessage;
  }

  // ===========================
  // EMOTIONAL DESIGN HELPERS
  // ===========================

  static Color getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happy':
        return emotionJoy;
      case 'calm':
      case 'peaceful':
        return emotionCalm;
      case 'sad':
      case 'sadness':
        return emotionSad;
      case 'anxious':
      case 'anxiety':
      case 'overwhelmed':
        return emotionAnxious;
      case 'angry':
      case 'anger':
        return emotionAngry;
      case 'excited':
        return emotionExcited;
      case 'numb':
        return emotionNumb;
      case 'neutral':
      default:
        return emotionNeutral;
    }
  }

  static String getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
      case 'happy':
        return '😊';
      case 'calm':
      case 'peaceful':
        return '😌';
      case 'sad':
      case 'sadness':
        return '😔';
      case 'anxious':
      case 'anxiety':
        return '😰';
      case 'angry':
      case 'anger':
        return '😤';
      case 'excited':
        return '🤩';
      case 'overwhelmed':
        return '🤯';
      case 'numb':
        return '😶';
      case 'neutral':
      default:
        return '😐';
    }
  }

  static List<Color> getEmotionGradient(String emotion) {
    final baseColor = getEmotionColor(emotion);
    return [baseColor, baseColor.withValues(alpha: 0.3), Colors.transparent];
  }

  static Color getNavColor(int index) {
    switch (index) {
      case 0:
        return navHome;
      case 1:
        return navMoodAtlas;
      case 2:
        return navInsights;
      case 3:
        return navFriends;
      case 4:
        return navVenting;
      default:
        return vibrantPurple;
    }
  }

  static bool isColorDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  static Color getContrastTextColor(Color backgroundColor) {
    return isColorDark(backgroundColor) ? cloudWhite : charcoalPurple;
  }

  // ===========================
  // MOCK DATA FOR DEVELOPMENT
  // ===========================

  static Map<String, dynamic> getDefaultOnboardingData() {
    return {
      'username': null,
      'pronouns': defaultPronoun,
      'ageGroup': defaultAgeGroup,
      'selectedAvatar': defaultAvatar,
      'isCompleted': true,
      'completedAt': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> getMockHomeData({
    String? username,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
  }) {
    return {
      'username': username ?? 'User',
      'pronouns': pronouns ?? defaultPronoun,
      'ageGroup': ageGroup ?? defaultAgeGroup,
      'selectedAvatar': selectedAvatar ?? defaultAvatar,
      'currentMood': 'joy',
      'moodEmoji': '😊',
      'todayMoodLogged': false,
      'isFirstTimeLogin': false,
      'streak': 7,
      'totalSessions': 25,
      'lastActivity': DateTime.now().toIso8601String(),
      'joinedAt': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
      'weekMoods': ['😊', '😌', '😊', '😰', '😊', '😑', '😊'],
      'recentEmotions': [
        {
          'emotion': 'joy',
          'intensity': 0.8,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        },
        {
          'emotion': 'calm',
          'intensity': 0.6,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
        },
      ],
      'globalEmotions': {
        'totalUsers': 2300000,
        'todayEntries': 450000,
        'topEmotion': 'joy',
        'averageIntensity': 0.65,
        'locations': [
          {'city': 'New York', 'emotion': 'joy', 'percentage': 42},
          {'city': 'Tokyo', 'emotion': 'calm', 'percentage': 38},
          {'city': 'London', 'emotion': 'anxious', 'percentage': 28},
          {'city': 'Sydney', 'emotion': 'joy', 'percentage': 52},
          {'city': 'Kathmandu', 'emotion': 'joy', 'percentage': 45},
        ],
      },
    };
  }

  static Map<String, dynamic> getMockUserStats() {
    return {
      'moodCheckins': 25,
      'streakDays': 7,
      'totalSessions': 25,
      'averageMood': 'joy',
      'weeklyTrend': 'improving',
      'lastActivityDate': DateTime.now().toIso8601String(),
      'joinDate': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
      'monthlyCheckins': 89,
      'longestStreak': 14,
      'favoriteEmotion': 'joy',
      'totalEmotionsLogged': 156,
      'averageIntensity': 0.65,
      'moodDistribution': {
        'joy': 0.35,
        'calm': 0.25,
        'neutral': 0.20,
        'anxious': 0.12,
        'sad': 0.08,
      },
    };
  }

  static bool isOnboardingDataComplete(Map<String, dynamic> data) {
    return data['pronouns'] != null &&
        data['ageGroup'] != null &&
        data['selectedAvatar'] != null;
  }
}
