import 'dart:convert';

import 'package:flutter/material.dart';

class AppConfig {
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


  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String profileEndpoint = '/api/auth/profile';
  static const String currentUserEndpoint = '/api/auth/me';
  static const String refreshTokenEndpoint = '/api/auth/refresh';
  static const String updateProfileEndpoint = '/api/auth/profile/update';
  static const String deleteAccountEndpoint = '/api/auth/account/delete';

  static const String userPreferencesEndpoint = '/api/user/preferences';
  static const String updatePreferencesEndpoint =
      '/api/user/preferences/update';
  static const String exportUserDataEndpoint = '/api/user/export';
  static const String achievementsEndpoint = '/api/user/achievements';
  static const String achievementDetailEndpoint =
'/api/user/achievements'; 

  static const String checkUsernameEndpoint = '/api/auth/check-username';
  static const String onboardingStepsEndpoint = '/api/onboarding/steps';
  static const String userDataEndpoint = '/api/onboarding/user-data';
  static const String completeOnboardingEndpoint = '/api/onboarding/complete';
  static const String suggestUsernamesEndpoint = '/api/auth/suggest-usernames';

  static const String homeDataEndpoint = '/api/user/home-data';
  static const String userStatsEndpoint = '/api/user/stats';

  static const String logEmotionEndpoint = '/api/emotions/log';
  static const String emotionJourneyEndpoint = '/api/emotions/journey';
  static const String globalEmotionStatsEndpoint = '/api/emotions/global-stats';
  static const String globalEmotionHeatmapEndpoint =
      '/api/emotions/global-heatmap';
  static const String emotionFeedEndpoint = '/api/emotions/feed';
  static const String ventingSessionEndpoint = '/api/emotions/vent';
  static const String emotionInsightsEndpoint = '/api/emotions/insights';

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String hasEverBeenLoggedInKey = 'has_ever_been_logged_in';
  static const String lastEmotionLogKey = 'last_emotion_log';
  static const String userPreferencesKey = 'user_preferences';
  static const String splashShownKey = 'splash_shown';
  static const String firstAppLaunchKey = 'first_app_launch';
  static const String cacheValidityDurationKey = 'cache_validity_duration';
  static const String selectedThemeKey = 'selected_theme';
  static const String selectedLanguageKey = 'selected_language';
  static const String cachedAchievementsKey = 'cached_achievements';
  static const String profileCacheKey = 'profile_cache';


  static const Color softLavender = Color(
    0xFFF3E8FF,
); 
  static const Color midnightNavy = Color(
    0xFF374151,
); 
static const Color oceanMist = Color(0xFFB347D9); 
static const Color warmBlush = Color(0xFFFED7D7); 
static const Color cloudWhite = Color(0xFFFFFFFF); 

  static const Color vibrantPurple = Color(
    0xFFB347D9,
); 
  static const Color playfulPurple = Color(
    0xFFD8A5FF,
); 
static const Color deepPurple = Color(0xFF8B3FB8); 
static const Color charcoalPurple = Color(0xFF374151); 
  static const Color royalPurple = Color(
    0xFF5B21B6,
); 

static const Color sunnyYellow = Color(0xFFFEF3C7); 
static const Color skyBlue = Color(0xFFDBEAFE); 
static const Color mintGreen = Color(0xFFD1FAE5); 
static const Color peachPink = Color(0xFFFED7D7); 

static const Color softGray = Color(0xFFE5E7EB); 
  static const Color deepLavender = Color(
    0xFF8B3FB8,
); 
static const Color paleBlush = Color(0xFFFEF3C7); 
static const Color mistBlue = Color(0xFFDBEAFE); 

  static const Color primaryPurple = vibrantPurple;
  static const Color secondaryPurple = playfulPurple;
  static const Color accentPurple = peachPink;
  static const Color backgroundDark = softLavender;
  static const Color backgroundCard = cloudWhite;
static const Color backgroundSurface = Color(0xFFE9D8FD); 
  static const Color textPrimary = charcoalPurple;
  static const Color textSecondary = deepPurple;
static const Color textMuted = Color(0xFF9CA3AF); 


  static const Color dialogBackground = Color(0xFF1A1A2E);
  static const Color dialogSurface = cloudWhite;
  static const Color dialogOverlay = Color(0x66000000);
  static const Color dialogBorder = Color(0xFFE5E7EB);
  static const Color dialogShadow = Color(0x1A000000);

  static const Map<String, Color> themeColors = {
    'Cosmic Purple': Color(0xFF8B5CF6),
    'Ocean Blue': Color(0xFF3B82F6),
    'Forest Green': Color(0xFF10B981),
    'Sunset Orange': Color(0xFFF59E0B),
    'Cherry Blossom': Color(0xFFEC4899),
    'Fire Red': Color(0xFFEF4444),
    'Mystic Teal': Color(0xFF14B8A6),
    'Royal Indigo': Color(0xFF6366F1),
  };

  static const Map<String, Color> achievementColors = {
    'progress': Color(0xFF10B981),
    'milestone': Color(0xFF3B82F6),
    'special': Color(0xFF8B5CF6),
    'rare': Color(0xFFEF4444),
    'epic': Color(0xFFF59E0B),
    'legendary': Color(0xFFEC4899),
    'daily': Color(0xFF14B8A6),
    'weekly': Color(0xFF6366F1),
    'monthly': Color(0xFFD946EF),
    'general': Color(0xFF6B7280),
  };


static const Color emotionJoy = Color(0xFFFEF3C7); 
static const Color emotionCalm = Color(0xFFD1FAE5); 
static const Color emotionSad = Color(0xFFDBEAFE); 
static const Color emotionAnxious = Color(0xFFF3E8FF); 
static const Color emotionAngry = Color(0xFFFED7D7); 
static const Color emotionNeutral = Color(0xFFF9FAFB); 
static const Color emotionPeaceful = Color(0xFFECFDF5); 
  static const Color emotionExcited = Color(
    0xFFFEF3C7,
); 
static const Color emotionNumb = Color(0xFFF5F5F5); 


static const Color successGreen = Color(0xFFD1FAE5); 
static const Color errorRed = Color(0xFFFED7D7); 
static const Color warningYellow = Color(0xFFFEF3C7); 
static const Color infoBlue = Color(0xFFDBEAFE); 


  static const Color navHome = vibrantPurple;
  static const Color navMoodAtlas = mintGreen;
  static const Color navInsights = skyBlue;
  static const Color navFriends = peachPink;
  static const Color navVenting = sunnyYellow;


  static const double paddingTiny = 6.0;
  static const double paddingSmall = 10.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 28.0;
  static const double paddingXXLarge = 36.0;
  static const double paddingHuge = 44.0;
  static const double paddingMassive = 52.0;

  static const double radiusTiny = 6.0;
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 20.0;
  static const double radiusXLarge = 24.0;
  static const double radiusXXLarge = 28.0;
  static const double radiusHuge = 32.0;
  static const double radiusCircular = 100.0;

  static const double textTiny = 12.0;
  static const double textSmall = 14.0;
  static const double textMedium = 16.0;
  static const double textLarge = 18.0;
  static const double textXLarge = 20.0;
  static const double textXXLarge = 22.0;
  static const double textHeader = 26.0;
  static const double textTitle = 30.0;
  static const double textDisplay = 34.0;
  static const double textHero = 38.0;

  static const double iconTiny = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 28.0;
  static const double iconXLarge = 36.0;
  static const double iconXXLarge = 52.0;
  static const double iconHuge = 68.0;
  static const double iconMassive = 84.0;

  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightLarge = 60.0;
  static const double inputHeight = 52.0;
  static const double cardHeight = 180.0;
  static const double cardHeightLarge = 220.0;
  static const double avatarSize = 52.0;
  static const double avatarSizeLarge = 84.0;

  static const double dialogMaxWidth = 420.0;
  static const double dialogMaxHeight = 600.0;
  static const double dialogMinHeight = 300.0;
  static const double themeCardSize = 120.0;
  static const double achievementCardHeight = 100.0;

  static const double emotionTileSize = 88.0;
  static const double emotionDotSize = 16.0;
  static const double earthSectionHeight = 340.0;
  static const double sliderHeight = 52.0;
  static const double progressBarHeight = 10.0;

  static const double maxContentWidth = 420.0;
  static const double sectionSpacing = 36.0;
  static const double itemSpacing = 20.0;
  static const double gridSpacing = 16.0;

  static const double minTouchTarget = 48.0;
  static const double comfortableTouchTarget = 52.0;


  static const bool isDevelopmentMode = true;
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enableOfflineMode = true;
static const bool gracefullyHandleMissingEndpoints = false; 
static const bool enableProfileDialogMockData = false; 
  static const bool enableAchievementMockData =
true; 


  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  static const Duration cacheExpirationDuration = Duration(hours: 24);
static const Duration cacheValidityDuration = Duration(hours: 24); 
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetryAttempts = 3;
  static const int maxCacheSize = 100;

  static const int animationInstant = 150;
  static const int animationFast = 250;
  static const int animationMedium = 350;
  static const int animationSlow = 550;
  static const int animationXSlow = 850;
  static const int animationBreathing = 4000;


  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minBioLength = 0;
  static const int maxBioLength = 150;


  static const List<String> availablePronouns = [
    'She / Her',
    'He / Him',
    'They / Them',
    'Other',
  ];

  static const List<String> availableAgeGroups = [
    'Under 18',
'18-24', 
'25-34', 
'35-44', 
'45-54', 
'55-64', 
'65+',   
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

  static const List<Map<String, String>> availableLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
  ];

  static const List<Map<String, dynamic>> availableThemes = [
    {
      'name': 'Cosmic Purple',
      'primaryColor': Color(0xFF8B5CF6),
      'gradient': [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF6D28D9)],
      'description': 'Deep cosmic vibes with purple gradients',
    },
    {
      'name': 'Ocean Blue',
      'primaryColor': Color(0xFF3B82F6),
      'gradient': [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
      'description': 'Calm ocean depths and flowing waters',
    },
    {
      'name': 'Forest Green',
      'primaryColor': Color(0xFF10B981),
      'gradient': [Color(0xFF10B981), Color(0xFF059669), Color(0xFF065F46)],
      'description': 'Natural forest with fresh green energy',
    },
    {
      'name': 'Sunset Orange',
      'primaryColor': Color(0xFFF59E0B),
      'gradient': [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
      'description': 'Warm sunset with golden hour vibes',
    },
    {
      'name': 'Cherry Blossom',
      'primaryColor': Color(0xFFEC4899),
      'gradient': [Color(0xFFEC4899), Color(0xFFDB2777), Color(0xFF9D174D)],
      'description': 'Soft pink petals and romantic energy',
    },
    {
      'name': 'Fire Red',
      'primaryColor': Color(0xFFEF4444),
      'gradient': [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF991B1B)],
      'description': 'Passionate flames and bold energy',
    },
    {
      'name': 'Mystic Teal',
      'primaryColor': Color(0xFF14B8A6),
      'gradient': [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF134E4A)],
      'description': 'Mystical waters with ancient wisdom',
    },
    {
      'name': 'Royal Indigo',
      'primaryColor': Color(0xFF6366F1),
      'gradient': [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF3730A3)],
      'description': 'Royal elegance with deep indigo tones',
    },
  ];

  static const String defaultPronoun = 'They / Them';
static const String defaultAgeGroup = '18-24'; 
  static const String defaultAvatar = 'panda';
  static const String defaultLanguage = 'en';
  static const String defaultTheme = 'Cosmic Purple';

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
    'test',
    'demo',
    'guest',
    'anonymous',
  ];


  static const List<String> usernameAdjectives = [
    'happy',
    'calm',
    'bright',
    'gentle',
    'peaceful',
    'joyful',
    'serene',
    'vibrant',
    'cozy',
    'dreamy',
    'mindful',
    'wise',
    'brave',
    'kind',
    'creative',
    'hopeful',
    'caring',
    'warm',
    'sweet',
    'lovely',
  ];

  static const List<String> usernameNouns = [
    'moon',
    'star',
    'cloud',
    'river',
    'ocean',
    'garden',
    'butterfly',
    'rainbow',
    'sunrise',
    'petal',
    'breeze',
    'whisper',
    'sparkle',
    'crystal',
    'feather',
    'heart',
    'soul',
    'spirit',
    'dream',
    'wonder',
  ];

  static const List<String> fallbackUsernames = [
    'mindful_explorer',
    'emotion_friend',
    'calm_navigator',
    'peaceful_soul',
    'gentle_heart',
    'bright_spirit',
    'serene_mind',
    'joyful_journey',
    'wise_wanderer',
    'kind_companion',
    'dreamy_traveler',
    'warm_whisper',
  ];


  static const String networkErrorMessage =
      'Connection seems quiet. Check your network when ready 🌸';
  static const String serverErrorMessage =
      'Something didn\'t work. That\'s okay, let\'s try again ✨';
  static const String timeoutErrorMessage =
      'Taking a bit longer than usual. Please try again when ready 🕐';
  static const String unauthorizedErrorMessage =
      'Please sign in to continue your journey 🔑';
  static const String validationErrorMessage =
      'Let\'s check that information together 📝';
  static const String usernameExistsMessage =
      'This name is already taken. How about trying one of these? 💡';
  static const String usernameAvailableMessage =
      'Perfect! This name is available .';

  static const String profileUpdateSuccessMessage =
      'Profile updated successfully! ✨';
  static const String profileUpdateErrorMessage =
      'Could not update profile. Please try again 🔄';
  static const String themeChangeSuccessMessage =
      'Theme changed successfully! 🎨';
  static const String languageChangeSuccessMessage =
      'Language changed successfully! 🌍';
  static const String dataExportSuccessMessage =
      'Data exported successfully! 📁';
  static const String dataExportErrorMessage =
      'Could not export data. Please try again .';
  static const String avatarChangeSuccessMessage =
      'Avatar updated! Looking good! 🐾';

  static const String loginSuccessMessage = 'Welcome back! 🌸';
  static const String registrationSuccessMessage = 'Your space is ready! ✨';
  static const String logoutSuccessMessage = 'Take care, see you soon 👋';
  static const String onboardingCompleteMessage =
      'Your emotional journey begins 🪷';
  static const String usernameCheckingMessage =
      'Checking if this name is available... .';

  static const String onboardingWelcomeMessage =
      'Welcome to your emotional sanctuary 🌺';
  static const String onboardingSkipMessage =
      'You can always complete this later in settings';
  static const String onboardingProgressMessage =
      'Creating your personalized space...';

  static const String developmentModeMessage =
      'Running in development mode - crafting with care 🛠️';
  static const String endpointNotAvailableMessage =
      'This feature is being crafted with love .';


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

  static bool isValidBio(String bio) {
    return bio.length >= minBioLength && bio.length <= maxBioLength;
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

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateBio(String? bio) {
    if (bio == null) return null;
    if (!isValidBio(bio)) {
      if (bio.length > maxBioLength) {
        return 'Bio must be less than $maxBioLength characters';
      }
    }
    return null;
  }


  static String getAvatarEmoji(String avatarName) {
    switch (avatarName.toLowerCase()) {
      case 'panda':
        return '🐼';
      case 'elephant':
        return '🐘';
      case 'horse':
        return '🐴';
      case 'rabbit':
        return '🐰';
      case 'fox':
        return '🦊';
      case 'zebra':
        return '🦓';
      case 'bear':
        return '🐻';
      case 'pig':
        return '🐷';
      case 'raccoon':
        return '🦝';
      default:
        return '🐼';
    }
  }

  static Map<String, dynamic>? getThemeByName(String themeName) {
    try {
      return availableThemes.firstWhere((theme) => theme['name'] == themeName);
    } catch (e) {
return availableThemes.first; 
    }
  }

  static Map<String, String>? getLanguageByCode(String languageCode) {
    try {
      return availableLanguages.firstWhere(
        (lang) => lang['code'] == languageCode,
      );
    } catch (e) {
return availableLanguages.first; 
    }
  }

  static Color getAchievementColorByCategory(String category) {
    return achievementColors[category.toLowerCase()] ??
        achievementColors['general']!;
  }

  static Color getThemeColorByName(String themeName) {
    return themeColors[themeName] ?? themeColors['Cosmic Purple']!;
  }


  static List<String> generateUsernamesSuggestions({int count = 5}) {
    final suggestions = <String>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < count - 1; i++) {
      final adjIndex = (random + i) % usernameAdjectives.length;
      final nounIndex = (random + i * 2) % usernameNouns.length;
      final number = (random + i * 3) % 999 + 1;

      final suggestion =
          '${usernameAdjectives[adjIndex]}_${usernameNouns[nounIndex]}$number';
      suggestions.add(suggestion);
    }

    final fallbackIndex = random % fallbackUsernames.length;
    final fallbackNumber = random % 9999 + 1;
    suggestions.add('${fallbackUsernames[fallbackIndex]}$fallbackNumber');

    return suggestions;
  }


  static bool shouldHandleErrorGracefully(
    int? statusCode,
    String? errorMessage,
  ) {
    if (!isDevelopmentMode) return false;
    if (statusCode == 404) return true;
    
    
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
          ? 'Feature not available in development mode .'
          : 'Service temporarily unavailable .';
    }
    if (originalError.contains('401') ||
        originalError.contains('unauthorized')) {
      return unauthorizedErrorMessage;
    }
    if (originalError.contains('network') ||
        originalError.contains('connection')) {
      return networkErrorMessage;
    }
    if (originalError.contains('timeout')) {
      return timeoutErrorMessage;
    }
    return isDevelopmentMode
        ? 'Development mode: $originalError 🛠️'
        : serverErrorMessage;
  }


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
    return [baseColor, baseColor.withOpacity(0.3), Colors.transparent];
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


  static bool shouldShowSplash() {
    return true;
  }

  static bool shouldShowOnboarding() {
return true; 
  }


  static bool isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return true;
      }

      final payload = parts[1];
      final normalizedPayload = payload.padRight(
        (payload.length + 3) ~/ 4 * 4,
        '=',
      );

      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(payloadBytes);
      final payloadMap = jsonDecode(payloadString) as Map<String, dynamic>;

      final exp = payloadMap['exp'];
      if (exp == null) {
        return true;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(
(exp as int) * 1000, 
      );

      final now = DateTime.now().add(const Duration(seconds: 30));

      final isExpired = now.isAfter(expirationTime);
      
      if (isDevelopmentMode && isExpired) {
        print('🔑 Token expired: exp=$expirationTime, now=$now');
      }

      return isExpired;
    } catch (e) {
      if (isDevelopmentMode) {
        print('. Error parsing JWT token: $e');
      }
      return true;
    }
  }

  static Duration getTokenExpirationTime() {
return const Duration(days: 7); 
  }


  static Map<String, dynamic> getDefaultOnboardingData() {
    return {
      'username': null,
      'email': null,
      'pronouns': defaultPronoun,
      'ageGroup': defaultAgeGroup,
      'selectedAvatar': defaultAvatar,
      'isCompleted': false,
      'completedAt': null,
      'skipped': false,
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

  static Map<String, dynamic> getMockAuthResponse({
    required String username,
    required String email,
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
  }) {
    return {
      'success': true,
      'message': 'Authentication successful',
      'data': {
        'user': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'username': username,
          'email': email,
          'pronouns': pronouns ?? defaultPronoun,
          'ageGroup': ageGroup ?? defaultAgeGroup,
          'selectedAvatar': selectedAvatar ?? defaultAvatar,
          'isOnboardingCompleted': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'refreshToken':
            'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
        'expiresAt': DateTime.now()
            .add(getTokenExpirationTime())
            .toIso8601String(),
      },
    };
  }

  static Map<String, dynamic> getMockUsernameCheckResponse({
    required String username,
    required bool isAvailable,
    List<String>? suggestions,
  }) {
    return {
      'success': true,
      'data': {
        'username': username,
        'isAvailable': isAvailable,
        'suggestions':
            suggestions ?? (isAvailable ? [] : generateUsernamesSuggestions()),
        'message': isAvailable
            ? usernameAvailableMessage
            : usernameExistsMessage,
      },
    };
  }

  static List<Map<String, dynamic>> getMockOnboardingSteps() {
    return [
      {
        'id': 1,
        'title': 'Welcome to Emora! 🌸',
        'description': 'Let\'s create your personal emotional sanctuary',
        'type': 'welcome',
        'isRequired': false,
      },
      {
        'id': 2,
        'title': 'Choose Your Identity',
        'description': 'How would you like to be addressed?',
        'type': 'pronouns',
        'isRequired': false,
        'options': availablePronouns,
      },
      {
        'id': 3,
        'title': 'Select Your Age Group',
        'description': 'This helps us customize your experience',
        'type': 'age_group',
        'isRequired': false,
        'options': availableAgeGroups,
      },
      {
        'id': 4,
        'title': 'Pick Your Avatar Friend',
        'description': 'Choose a companion for your emotional journey',
        'type': 'avatar',
        'isRequired': false,
        'options': availableAvatars,
      },
    ];
  }

  static bool isOnboardingDataComplete(Map<String, dynamic> data) {
    return data['pronouns'] != null &&
        data['ageGroup'] != null &&
        data['selectedAvatar'] != null;
  }


  static Map<String, dynamic> getInitialAppState() {
    return {
      'isFirstLaunch': true,
      'splashShown': false,
      'onboardingCompleted': false,
      'hasEverBeenLoggedIn': false,
      'isLoggedIn': false,
      'currentUser': null,
      'authToken': null,
      'refreshToken': null,
    };
  }

  static Map<String, dynamic> getLoggedInAppState({
    required Map<String, dynamic> user,
    required String token,
    String? refreshToken,
  }) {
    return {
      'isFirstLaunch': false,
      'splashShown': true,
      'onboardingCompleted': true,
      'hasEverBeenLoggedIn': true,
      'isLoggedIn': true,
      'currentUser': user,
      'authToken': token,
      'refreshToken': refreshToken,
    };
  }


  static void logConfigInfo() {
    if (enableLogging && isDevelopmentMode) {
      print('. AppConfig Info:');
      print('  - App Name: $appName');
      print('  - Version: $appVersion');
      print('  - API Base URL: $effectiveApiBaseUrl');
      print('  - Development Mode: $isDevelopmentMode');
      print('  - Debug Mode: $isDebugMode');
      print('  - Graceful Error Handling: $gracefullyHandleMissingEndpoints');
      print('  - Profile Dialog Mock Data: $enableProfileDialogMockData');
      print('  - Achievement Mock Data: $enableAchievementMockData');
    }
  }

  static Map<String, dynamic> getDebugInfo() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'apiBaseUrl': effectiveApiBaseUrl,
      'isDevelopmentMode': isDevelopmentMode,
      'isDebugMode': isDebugMode,
      'enableLogging': enableLogging,
      'enableNetworkLogging': enableNetworkLogging,
      'enableOfflineMode': enableOfflineMode,
      'gracefulErrorHandling': gracefullyHandleMissingEndpoints,
      'enableProfileDialogMockData': enableProfileDialogMockData,
      'enableAchievementMockData': enableAchievementMockData,
      'splashDuration': splashDuration.inMilliseconds,
      'cacheExpirationDuration': cacheExpirationDuration.inHours,
      'maxRetryAttempts': maxRetryAttempts,
      'availableThemes': availableThemes.length,
      'availableLanguages': availableLanguages.length,
      'availableAvatars': availableAvatars.length,
    };
  }


  static bool shouldUseMockData(String feature) {
    if (!isDevelopmentMode) return false;

    switch (feature.toLowerCase()) {
      case 'profile':
      case 'edit_profile':
      case 'avatar':
      case 'theme':
      case 'language':
        return enableProfileDialogMockData;
      case 'achievements':
        return enableAchievementMockData;
      default:
        return gracefullyHandleMissingEndpoints;
    }
  }

  static String getSafeEndpointUrl(String endpoint) {
    return '$effectiveApiBaseUrl$endpoint';
  }

  static bool shouldMockEndpoint(String endpoint) {
    if (!isDevelopmentMode) return false;

    if (endpoint.contains('/profile') ||
        endpoint.contains('/preferences') ||
        endpoint.contains('/user/')) {
      return enableProfileDialogMockData;
    }

    if (endpoint.contains('/achievements')) {
      return enableAchievementMockData;
    }

    return gracefullyHandleMissingEndpoints;
  }
}
