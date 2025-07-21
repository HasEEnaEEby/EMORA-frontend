// lib/features/splash/presentation/view_model/cubit/splash_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../auth/data/data_source/local/auth_local_data_source.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences sharedPreferences;
  final AuthLocalDataSource authLocalDataSource;

  // Keys for persistent storage
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyLastUserSession = 'last_user_session';
  static const String _keySessionExpiredAt = 'session_expired_at';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  SplashCubit({
    required this.sharedPreferences,
    required this.authLocalDataSource,
  }) : super(const SplashInitial()) {
    _startInitialization();
  }

  void _startInitialization() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        initializeApp();
      }
    });
  }

  Future<void> initializeApp() async {
    try {
      Logger.info('🚀 Starting enhanced app initialization...');

      if (isClosed) return;
      emit(const SplashLoading());

      // Minimum splash time for UX
      await Future.delayed(AppConfig.splashDuration);
      if (isClosed) return;

      Logger.info('🔄 Enhanced authentication flow check...');

      // Step 1: Check authentication status with session validation
      final authStatus = await _validateAuthenticationStatus();

      if (isClosed) return;

      // Step 2: Handle navigation based on auth status
      await _handleNavigationFlow(authStatus);
    } catch (e, stackTrace) {
      Logger.error('. Initialization failed: $e', e, stackTrace);
      if (!isClosed) {
        _handleInitializationError();
      }
    }
  }

  /// Enhanced authentication status validation
  Future<AuthenticationStatus> _validateAuthenticationStatus() async {
    try {
      // Check if user has valid authentication token
      final authToken = await authLocalDataSource.getAuthToken();
      final isLoggedIn = authToken != null && authToken.isNotEmpty;

      Logger.info('🔐 Authentication check - isLoggedIn: $isLoggedIn');

      if (!isLoggedIn) {
        // Check if this is a returning user using multiple indicators
        final hadPreviousSession = sharedPreferences.getString(
          _keyLastUserSession,
        );
        final hasSeenOnboarding =
            sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;
        final hasCompletedOnboarding =
            sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;

        // User is returning if they have ANY of these indicators
        final isReturningUser =
            hadPreviousSession != null ||
            hasSeenOnboarding ||
            hasCompletedOnboarding;

        if (isReturningUser) {
          Logger.info('. Detected returning user with expired session');
          Logger.info(
            '. Session indicators - previous: ${hadPreviousSession != null}, seen: $hasSeenOnboarding, completed: $hasCompletedOnboarding',
          );
          await _markSessionExpired();
          return AuthenticationStatus.sessionExpired;
        } else {
          Logger.info(
            '👋 New user - no previous session or onboarding history',
          );
          return AuthenticationStatus.newUser;
        }
      }

      // User appears to be logged in, validate user data
      final user = await authLocalDataSource.getUserData();

      if (user == null) {
        Logger.warning('. Logged in but no user data - clearing auth');
        await _clearCorruptedAuth();
        return AuthenticationStatus.newUser;
      }

      // Check onboarding completion status
      final onboardingCompleted = _getOnboardingCompletionStatus(user);
      Logger.info('. User onboarding status: completed=$onboardingCompleted');

      // Update last session tracking
      final userId = user.username ?? user.id;
      await _updateLastSession(userId);

      if (onboardingCompleted) {
        return AuthenticationStatus.authenticatedComplete;
      } else {
        return AuthenticationStatus.authenticatedIncomplete;
      }
    } catch (e) {
      Logger.error('. Auth validation failed: $e', e);
      await _clearCorruptedAuth();
      return AuthenticationStatus.error;
    }
  }

  /// Get onboarding completion status with multiple fallbacks
  bool _getOnboardingCompletionStatus(dynamic user) {
    try {
      // Primary: Check user entity property
      // Note: Replace 'isOnboardingCompleted' with the actual property name in your UserEntity
      try {
        final hasCompleted = user.hasCompleted;
        if (hasCompleted != null) {
          return hasCompleted;
        }
      } catch (e) {
        // Property doesn't exist, continue to fallback
      }

      // Try alternative property names that might exist in your UserEntity
      try {
        final isOnboardingCompleted = user.isOnboardingCompleted;
        if (isOnboardingCompleted != null) {
          return isOnboardingCompleted;
        }
      } catch (e) {
        // Property doesn't exist, continue to fallback
      }

      // Fallback: Check SharedPreferences
      final storedStatus = sharedPreferences.getBool(_keyOnboardingCompleted);
      if (storedStatus != null) {
        Logger.info('. Using stored onboarding status: $storedStatus');
        return storedStatus;
      }

      // Default: Incomplete
      Logger.info('. No onboarding status found, defaulting to incomplete');
      return false;
    } catch (e) {
      Logger.warning('. Error checking onboarding status: $e');
      return false;
    }
  }

  /// Handle navigation flow based on authentication status
  Future<void> _handleNavigationFlow(AuthenticationStatus status) async {
    switch (status) {
      case AuthenticationStatus.authenticatedComplete:
        Logger.info('. Authenticated user with completed onboarding -> Home');
        emit(const SplashNavigateToHome());
        break;

      case AuthenticationStatus.authenticatedIncomplete:
        Logger.info(
          '. Authenticated user without completed onboarding -> Onboarding',
        );
        emit(const SplashNavigateToOnboarding(isFirstTime: false));
        break;

      case AuthenticationStatus.sessionExpired:
        Logger.info(
          '⏰ Session expired for returning user -> Auth with message',
        );
        emit(
          const SplashNavigateToAuthWithMessage(
            'Your session has expired. Please sign in again.',
            isReturningUser: true,
          ),
        );
        break;

      case AuthenticationStatus.newUser:
        // Double-check if user has seen onboarding before
        final hasSeenOnboarding =
            sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;
        final hasCompletedOnboarding =
            sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;

        // If user has ANY onboarding history, they're not truly new
        if (hasSeenOnboarding || hasCompletedOnboarding) {
          Logger.info(
            '🔄 User has onboarding history -> Auth Choice (not truly new)',
          );
          emit(const SplashNavigateToAuth());
        } else {
          Logger.info('🔄 Completely new user -> Onboarding');
          emit(const SplashNavigateToOnboarding(isFirstTime: true));
        }
        break;

      case AuthenticationStatus.error:
        // For errors, check if user has history to avoid unnecessary onboarding
        final hasSeenOnboarding =
            sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;
        final hasCompletedOnboarding =
            sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;
        final hadPreviousSession = sharedPreferences.getString(
          _keyLastUserSession,
        );
        final hasAnyHistory =
            hasSeenOnboarding ||
            hasCompletedOnboarding ||
            (hadPreviousSession != null);

        if (hasAnyHistory) {
          Logger.info('. Auth error for user with history -> Auth Choice');
          emit(const SplashNavigateToAuth());
        } else {
          Logger.info('. Auth error for new user -> Onboarding as fallback');
          emit(const SplashNavigateToOnboarding(isFirstTime: true));
        }
        break;
    }
  }

  /// Mark session as expired for proper user experience
  Future<void> _markSessionExpired() async {
    try {
      await sharedPreferences.setString(
        _keySessionExpiredAt,
        DateTime.now().toIso8601String(),
      );
      Logger.info('⏰ Session expiry marked');
    } catch (e) {
      Logger.warning('. Failed to mark session expiry: $e');
    }
  }

  /// Update last session tracking
  Future<void> _updateLastSession(String userId) async {
    try {
      await sharedPreferences.setString(_keyLastUserSession, userId);
      Logger.info('. Updated last session for user: $userId');
    } catch (e) {
      Logger.warning('. Failed to update session tracking: $e');
    }
  }

  /// Clear corrupted authentication data
  Future<void> _clearCorruptedAuth() async {
    try {
      await authLocalDataSource.clearAuthData();
      // Don't clear onboarding status - user may have seen onboarding before
      Logger.info('🧹 Cleared corrupted auth data');
    } catch (clearError) {
      Logger.warning('. Could not clear auth data: $clearError');
    }
  }

  /// Handle initialization errors with smart fallbacks
  void _handleInitializationError() {
    Logger.info('🔄 Error recovery with intelligent fallback');

    // Check if user has seen onboarding before
    final hasSeenOnboarding =
        sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;

    if (hasSeenOnboarding) {
      Logger.info('🔄 Error recovery -> Auth Choice (seen onboarding)');
      emit(const SplashNavigateToAuth());
    } else {
      Logger.info('🔄 Error recovery -> Onboarding (new user)');
      emit(const SplashNavigateToOnboarding());
    }
  }

  // Public methods for external use

  Future<void> retryInitialization() async {
    Logger.info('🔄 Retrying initialization...');
    await initializeApp();
  }

  /// Mark that user has successfully authenticated - call this after login/register
  Future<void> markUserAuthenticated(String userId) async {
    try {
      await sharedPreferences.setString(_keyLastUserSession, userId);
      Logger.info('. User authentication tracked: $userId');
    } catch (e) {
      Logger.warning('. Failed to track user authentication: $e');
    }
  }

  /// Mark onboarding as completed - call this when user completes onboarding
  Future<void> markOnboardingCompleted() async {
    try {
      await sharedPreferences.setBool(_keyHasSeenOnboarding, true);
      await sharedPreferences.setBool(_keyOnboardingCompleted, true);
      Logger.info('. Onboarding marked as completed');
    } catch (e) {
      Logger.warning('. Failed to mark onboarding completed: $e');
    }
  }

  /// Mark that user has seen onboarding (but may not have completed it)
  Future<void> markOnboardingSeen() async {
    try {
      await sharedPreferences.setBool(_keyHasSeenOnboarding, true);
      Logger.info('👁️ Onboarding marked as seen');
    } catch (e) {
      Logger.warning('. Failed to mark onboarding seen: $e');
    }
  }

  /// Clear all user session data - use for complete logout
  Future<void> clearAllUserData() async {
    try {
      await authLocalDataSource.clearAuthData();
      await sharedPreferences.remove(_keyLastUserSession);
      await sharedPreferences.remove(_keySessionExpiredAt);
      await sharedPreferences.remove(_keyOnboardingCompleted);
      // Keep _keyHasSeenOnboarding so user doesn't see onboarding again
      Logger.info('🧹 Cleared all user session data');
    } catch (e) {
      Logger.warning('. Failed to clear user data: $e');
    }
  }

  // Force navigation methods for testing
  void forceNavigateToOnboarding() {
    Logger.info('🔄 Force navigate to onboarding');
    emit(const SplashNavigateToOnboarding());
  }

  void forceNavigateToAuth() {
    Logger.info('🔄 Force navigate to auth');
    emit(const SplashNavigateToAuth());
  }

  void forceNavigateToHome() {
    Logger.info('🔄 Force navigate to home');
    emit(const SplashNavigateToHome());
  }
}

/// Enhanced authentication status enumeration
enum AuthenticationStatus {
  /// User is authenticated and has completed onboarding
  authenticatedComplete,

  /// User is authenticated but hasn't completed onboarding
  authenticatedIncomplete,

  /// User had a session before but it expired
  sessionExpired,

  /// Complete new user
  newUser,

  /// Authentication check failed
  error,
}
