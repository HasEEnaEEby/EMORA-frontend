import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../auth/data/data_source/local/auth_local_data_source.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SharedPreferences sharedPreferences;
  final AuthLocalDataSource authLocalDataSource;

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

      await Future.delayed(AppConfig.splashDuration);
      if (isClosed) return;

      Logger.info('🔄 Enhanced authentication flow check...');

      final authStatus = await _validateAuthenticationStatus();

      if (isClosed) return;

      await _handleNavigationFlow(authStatus);
    } catch (e, stackTrace) {
      Logger.error('. Initialization failed: $e', e, stackTrace);
      if (!isClosed) {
        _handleInitializationError();
      }
    }
  }

  Future<AuthenticationStatus> _validateAuthenticationStatus() async {
    try {
      final authToken = await authLocalDataSource.getAuthToken();
      final isLoggedIn = authToken != null && authToken.isNotEmpty;

      Logger.info('🔐 Authentication check - isLoggedIn: $isLoggedIn');

      if (!isLoggedIn) {
        final hadPreviousSession = sharedPreferences.getString(
          _keyLastUserSession,
        );
        final hasSeenOnboarding =
            sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;
        final hasCompletedOnboarding =
            sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;

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

      final user = await authLocalDataSource.getUserData();

      if (user == null) {
        Logger.warning('. Logged in but no user data - clearing auth');
        await _clearCorruptedAuth();
        return AuthenticationStatus.newUser;
      }

      final onboardingCompleted = _getOnboardingCompletionStatus(user);
      Logger.info('. User onboarding status: completed=$onboardingCompleted');

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

  bool _getOnboardingCompletionStatus(dynamic user) {
    try {
      try {
        final hasCompleted = user.hasCompleted;
        if (hasCompleted != null) {
          return hasCompleted;
        }
      } catch (e) {
      }

      try {
        final isOnboardingCompleted = user.isOnboardingCompleted;
        if (isOnboardingCompleted != null) {
          return isOnboardingCompleted;
        }
      } catch (e) {
      }

      final storedStatus = sharedPreferences.getBool(_keyOnboardingCompleted);
      if (storedStatus != null) {
        Logger.info('. Using stored onboarding status: $storedStatus');
        return storedStatus;
      }

      Logger.info('. No onboarding status found, defaulting to incomplete');
      return false;
    } catch (e) {
      Logger.warning('. Error checking onboarding status: $e');
      return false;
    }
  }

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
        final hasSeenOnboarding =
            sharedPreferences.getBool(_keyHasSeenOnboarding) ?? false;
        final hasCompletedOnboarding =
            sharedPreferences.getBool(_keyOnboardingCompleted) ?? false;

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

  Future<void> _updateLastSession(String userId) async {
    try {
      await sharedPreferences.setString(_keyLastUserSession, userId);
      Logger.info('. Updated last session for user: $userId');
    } catch (e) {
      Logger.warning('. Failed to update session tracking: $e');
    }
  }

  Future<void> _clearCorruptedAuth() async {
    try {
      await authLocalDataSource.clearAuthData();
      Logger.info('🧹 Cleared corrupted auth data');
    } catch (clearError) {
      Logger.warning('. Could not clear auth data: $clearError');
    }
  }

  void _handleInitializationError() {
    Logger.info('🔄 Error recovery with intelligent fallback');

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


  Future<void> retryInitialization() async {
    Logger.info('🔄 Retrying initialization...');
    await initializeApp();
  }

  Future<void> markUserAuthenticated(String userId) async {
    try {
      await sharedPreferences.setString(_keyLastUserSession, userId);
      Logger.info('. User authentication tracked: $userId');
    } catch (e) {
      Logger.warning('. Failed to track user authentication: $e');
    }
  }

  Future<void> markOnboardingCompleted() async {
    try {
      await sharedPreferences.setBool(_keyHasSeenOnboarding, true);
      await sharedPreferences.setBool(_keyOnboardingCompleted, true);
      Logger.info('. Onboarding marked as completed');
    } catch (e) {
      Logger.warning('. Failed to mark onboarding completed: $e');
    }
  }

  Future<void> markOnboardingSeen() async {
    try {
      await sharedPreferences.setBool(_keyHasSeenOnboarding, true);
      Logger.info('👁️ Onboarding marked as seen');
    } catch (e) {
      Logger.warning('. Failed to mark onboarding seen: $e');
    }
  }

  Future<void> clearAllUserData() async {
    try {
      await authLocalDataSource.clearAuthData();
      await sharedPreferences.remove(_keyLastUserSession);
      await sharedPreferences.remove(_keySessionExpiredAt);
      await sharedPreferences.remove(_keyOnboardingCompleted);
      Logger.info('🧹 Cleared all user session data');
    } catch (e) {
      Logger.warning('. Failed to clear user data: $e');
    }
  }

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

enum AuthenticationStatus {
  authenticatedComplete,

  authenticatedIncomplete,

  sessionExpired,

  newUser,

  error,
}
