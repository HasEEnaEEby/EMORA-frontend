class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:5000';
  static const String apiVersion = '/api';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String onboardingDataKey = 'onboarding_data';
  static const String hasEverBeenLoggedInKey = 'has_ever_been_logged_in';

  static const String networkErrorMessage = 'No internet connection. Please check your network and try again.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unauthorizedErrorMessage = 'Your session has expired. Please log in again.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';

  static const String loginSuccessMessage = 'Welcome back!';
  static const String registrationSuccessMessage = 'Account created successfully!';
  static const String logoutSuccessMessage = 'Logged out successfully';
  static const String profileUpdateSuccessMessage = 'Profile updated successfully';

  static const String usernameRequiredMessage = 'Username is required';
  static const String passwordRequiredMessage = 'Password is required';
  static const String emailInvalidMessage = 'Please enter a valid email address';
  static const String passwordTooShortMessage = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match';

  static const String onboardingWelcomeMessage = 'Welcome to Emora!';
  static const String onboardingCompleteMessage = 'Setup complete! Welcome to Emora.';

  static const bool enableAnalytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationServices = true;
static const bool enableBiometricAuth = false; 
  static const bool enableDarkModeOnly = true;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration loadingTimeout = Duration(seconds: 10);

  static const Duration cacheExpiration = Duration(hours: 24);
static const int maxCacheSize = 50; 

  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const bool enablePasswordStrengthCheck = true;
  static const bool enableSessionTimeout = true;
  static const Duration sessionTimeout = Duration(hours: 24);

  static const bool enableCrashReporting = true;
  static const bool enableUsageAnalytics = true;
  static const bool enablePerformanceMonitoring = true;

  static const bool enableDebugLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enableMockData = false;

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
return false; 
    } catch (e) {
      return true;
    }
  }

  static bool isDevelopmentMode() {
return true; 
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