// lib/core/utils/app_config.dart - Comprehensive App Configuration
class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Authentication Configuration
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingDataKey = 'onboarding_data';
  static const String hasEverBeenLoggedInKey = 'has_ever_been_logged_in';

  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your network and try again.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedErrorMessage = 'Your session has expired. Please log in again.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String logoutSuccessMessage = 'Logged out successfully';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully';

  // Validation Messages
  static const String usernameRequiredMessage = 'Username is required';
  static const String passwordRequiredMessage = 'Password is required';
  static const String emailInvalidMessage = 'Please enter a valid email address';
  static const String passwordTooShortMessage = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match';

  // Onboarding Messages
  static const String onboardingWelcomeMessage = 'Welcome to Emora!';
  static const String onboardingCompleteMessage = 'Setup complete! Welcome to Emora.';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
  static const bool enableBiometricAuth = false; // Future feature
  static const bool enableDarkModeOnly = true;

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration loadingTimeout = Duration(seconds: 10);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const bool enablePasswordStrengthCheck = true;
  static const bool enableSessionTimeout = true;
  static const Duration sessionTimeout = Duration(hours: 24);

  // Analytics Configuration
  static const bool enableCrashReporting = true;
  static const bool enableUsageAnalytics = true;
  static const bool enablePerformanceMonitoring = true;

  // Development Configuration
  static const bool enableDebugLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enableMockData = false;

  // Helper Methods
  static String getFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return networkErrorMessage;
    } else if (errorLower.contains('timeout')) {
      return timeoutErrorMessage;
    } else if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return unauthorizedErrorMessage;
    } else if (errorLower.contains('server') || errorLower.contains('500')) {
      return serverErrorMessage;
    } else {
      return unknownErrorMessage;
    }
  }

  static bool isTokenExpired(String token) {
    try {
      // Simple JWT expiration check (basic implementation)
      // In production, use a proper JWT library
      return false; // Placeholder - implement proper JWT parsing
    } catch (e) {
      return true;
    }
  }

  static bool isDevelopmentMode() {
    // Check if app is running in debug mode
    return true; // Placeholder - implement proper environment detection
  }

  static String getApiUrl(String endpoint) {
    return '$baseUrl$apiVersion$endpoint';
  }

  static Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Emora-Mobile-App/1.0.0',
    };
  }

  static Map<String, dynamic> getDefaultTimeout() {
    return {
      'connectTimeout': requestTimeout.inMilliseconds,
      'receiveTimeout': requestTimeout.inMilliseconds,
      'sendTimeout': requestTimeout.inMilliseconds,
    };
  }
} 