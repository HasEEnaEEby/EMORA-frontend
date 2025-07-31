import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/check_auth_status.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/check_username_availability.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/get_current_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/login_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/logout_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/register_user.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_bloc.dart';
import 'package:emora_mobile_app/features/emotion/domain/repository/emotion_repository.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_emotion_feed.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_heatmap.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/get_global_emotion_stats.dart';
import 'package:emora_mobile_app/features/emotion/domain/use_case/log_emotion.dart';
import 'package:emora_mobile_app/features/emotion/presentation/view_model/bloc/emotion_bloc.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/get_user_stats.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/load_home_data.dart';
import 'package:emora_mobile_app/features/home/domain/use_case/navigate_to_main_flow.dart';
import 'package:emora_mobile_app/features/home/presentation/view_model/bloc/home_bloc.dart';
import 'package:emora_mobile_app/features/onboarding/domain/use_case/complete_onboarding.dart';
import 'package:emora_mobile_app/features/onboarding/domain/use_case/get_onboarding_steps.dart';
import 'package:emora_mobile_app/features/onboarding/domain/use_case/save_user_data.dart';
import 'package:emora_mobile_app/features/onboarding/presentation/view_model/bloc/onboarding_bloc.dart';
import 'package:emora_mobile_app/features/splash/presentation/view_model/cubit/splash_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlocManager {
  static HomeBloc? _homeBloc;
  static AuthBloc? _authBloc;
  static EmotionBloc? _emotionBloc;
  static OnboardingBloc? _onboardingBloc;
  static SplashCubit? _splashCubit;

  static final GetIt _sl = GetIt.instance;

  static int _homeBlocCreationCount = 0;
  static int _authBlocCreationCount = 0;
  static int _emotionBlocCreationCount = 0;
  static int _onboardingBlocCreationCount = 0;
  static int _splashCubitCreationCount = 0;

  static DateTime? _homeBlocCreatedAt;
  static DateTime? _authBlocCreatedAt;
  static DateTime? _emotionBlocCreatedAt;
  static DateTime? _onboardingBlocCreatedAt;
  static DateTime? _splashCubitCreatedAt;

  static HomeBloc getHomeBloc() {
    if (_homeBloc == null || _homeBloc!.isClosed) {
      Logger.info(
        '🎯 Creating new HomeBloc instance (#${_homeBlocCreationCount + 1})',
      );

      try {
        _homeBloc = HomeBloc(
          loadHomeData: _sl<LoadHomeData>(),
          getUserStats: _sl<GetUserStats>(),
          navigateToMainFlow: _sl<NavigateToMainFlow>(),
        );

        _homeBlocCreationCount++;
        _homeBlocCreatedAt = DateTime.now();

        Logger.info('. HomeBloc created successfully');
      } catch (e) {
        Logger.error('. Failed to create HomeBloc', e);
        rethrow;
      }
    } else {
      Logger.info(
        '📱 Reusing existing HomeBloc instance (created ${_getTimeAgo(_homeBlocCreatedAt)} ago)',
      );
    }
    return _homeBloc!;
  }

  static AuthBloc getAuthBloc() {
    if (_authBloc == null || _authBloc!.isClosed) {
      Logger.info(
        '🎯 Creating new AuthBloc instance (#${_authBlocCreationCount + 1})',
      );

      try {
        _authBloc = AuthBloc(
          checkUsernameAvailability: _sl<CheckUsernameAvailability>(),
          registerUser: _sl<RegisterUser>(),
          loginUser: _sl<LoginUser>(),
          getCurrentUser: _sl<GetCurrentUser>(),
          logoutUser: _sl<LogoutUser>(),
          checkAuthStatus:
_sl<CheckAuthStatus>(), 
        );

        _authBlocCreationCount++;
        _authBlocCreatedAt = DateTime.now();

        Logger.info('. AuthBloc created successfully');
      } catch (e) {
        Logger.error('. Failed to create AuthBloc:', e);
        rethrow;
      }
    } else {
      Logger.info(
        '📱 Reusing existing AuthBloc instance (created ${_getTimeAgo(_authBlocCreatedAt)} ago)',
      );
    }
    return _authBloc!;
  }

  static EmotionBloc getEmotionBloc() {
    if (_emotionBloc == null || _emotionBloc!.isClosed) {
      Logger.info(
        '🎯 Creating new EmotionBloc instance (#${_emotionBlocCreationCount + 1})',
      );

      try {
        _emotionBloc = EmotionBloc(
          logEmotion: _sl<LogEmotion>(),
          getEmotionFeed: _sl<GetEmotionFeed>(),
          getGlobalEmotionStats: _sl<GetGlobalEmotionStats>(),
          getGlobalHeatmap:
              _sl<
                GetGlobalEmotionHeatmap
>(), 
          emotionRepository:
              _sl<
                EmotionRepository
>(), 
        );

        _emotionBlocCreationCount++;
        _emotionBlocCreatedAt = DateTime.now();

        Logger.info('. EmotionBloc created successfully');
      } catch (e) {
        Logger.error('. Failed to create EmotionBloc', e);
        rethrow;
      }
    } else {
      Logger.info(
        '📱 Reusing existing EmotionBloc instance (created ${_getTimeAgo(_emotionBlocCreatedAt)} ago)',
      );
    }
    return _emotionBloc!;
  }

  static OnboardingBloc getOnboardingBloc() {
    if (_onboardingBloc == null || _onboardingBloc!.isClosed) {
      Logger.info(
        '🎯 Creating new OnboardingBloc instance (#${_onboardingBlocCreationCount + 1})',
      );

      try {
        _onboardingBloc = OnboardingBloc(
          getOnboardingSteps: _sl<GetOnboardingSteps>(),
          saveUserData: _sl<SaveUserData>(),
          completeOnboarding: _sl<CompleteOnboarding>(),
        );

        _onboardingBlocCreationCount++;
        _onboardingBlocCreatedAt = DateTime.now();

        Logger.info('. OnboardingBloc created successfully');
      } catch (e) {
        Logger.error('. Failed to create OnboardingBloc', e);
        rethrow;
      }
    } else {
      Logger.info(
        '📱 Reusing existing OnboardingBloc instance (created ${_getTimeAgo(_onboardingBlocCreatedAt)} ago)',
      );
    }
    return _onboardingBloc!;
  }

  static SplashCubit getSplashCubit() {
    if (_splashCubit == null || _splashCubit!.isClosed) {
      Logger.info(
        '🎯 Creating new SplashCubit instance (#${_splashCubitCreationCount + 1})',
      );

      try {
        _splashCubit = SplashCubit(
          sharedPreferences:
              _sl<
                SharedPreferences
>(), 
          authLocalDataSource:
              _sl<
                AuthLocalDataSource
>(), 
        );

        _splashCubitCreationCount++;
        _splashCubitCreatedAt = DateTime.now();

        Logger.info('. SplashCubit created successfully');
      } catch (e) {
        Logger.error('. Failed to create SplashCubit:', e);
        rethrow;
      }
    } else {
      Logger.info(
        '📱 Reusing existing SplashCubit instance (created ${_getTimeAgo(_splashCubitCreatedAt)} ago)',
      );
    }
    return _splashCubit!;
  }

  static void disposeHomeBloc() {
    if (_homeBloc != null && !_homeBloc!.isClosed) {
      Logger.info(
        '🗑️ Disposing HomeBloc (lived for ${_getTimeAgo(_homeBlocCreatedAt)})',
      );
      _homeBloc!.close();
    }
    _homeBloc = null;
    _homeBlocCreatedAt = null;
  }

  static void disposeAuthBloc() {
    if (_authBloc != null && !_authBloc!.isClosed) {
      Logger.info(
        '🗑️ Disposing AuthBloc (lived for ${_getTimeAgo(_authBlocCreatedAt)})',
      );
      _authBloc!.close();
    }
    _authBloc = null;
    _authBlocCreatedAt = null;
  }

  static void disposeEmotionBloc() {
    if (_emotionBloc != null && !_emotionBloc!.isClosed) {
      Logger.info(
        '🗑️ Disposing EmotionBloc (lived for ${_getTimeAgo(_emotionBlocCreatedAt)})',
      );
      _emotionBloc!.close();
    }
    _emotionBloc = null;
    _emotionBlocCreatedAt = null;
  }

  static void disposeOnboardingBloc() {
    if (_onboardingBloc != null && !_onboardingBloc!.isClosed) {
      Logger.info(
        '🗑️ Disposing OnboardingBloc (lived for ${_getTimeAgo(_onboardingBlocCreatedAt)})',
      );
      _onboardingBloc!.close();
    }
    _onboardingBloc = null;
    _onboardingBlocCreatedAt = null;
  }

  static void disposeSplashCubit() {
    if (_splashCubit != null && !_splashCubit!.isClosed) {
      Logger.info(
        '🗑️ Disposing SplashCubit (lived for ${_getTimeAgo(_splashCubitCreatedAt)})',
      );
      _splashCubit!.close();
    }
    _splashCubit = null;
    _splashCubitCreatedAt = null;
  }

  static void disposeAll() {
    Logger.info('🧹 Disposing all BLoCs and Cubits...');
    disposeHomeBloc();
    disposeAuthBloc();
    disposeEmotionBloc();
    disposeOnboardingBloc();
    disposeSplashCubit();
    Logger.info('. All BLoCs and Cubits disposed');
  }

  static bool isHomeBlocActive() {
    return _homeBloc != null && !_homeBloc!.isClosed;
  }

  static bool isAuthBlocActive() {
    return _authBloc != null && !_authBloc!.isClosed;
  }

  static bool isEmotionBlocActive() {
    return _emotionBloc != null && !_emotionBloc!.isClosed;
  }

  static bool isOnboardingBlocActive() {
    return _onboardingBloc != null && !_onboardingBloc!.isClosed;
  }

  static bool isSplashCubitActive() {
    return _splashCubit != null && !_splashCubit!.isClosed;
  }

  static Map<String, bool> getBlocStatus() {
    return {
      'homeBloc': isHomeBlocActive(),
      'authBloc': isAuthBlocActive(),
      'emotionBloc': isEmotionBlocActive(),
      'onboardingBloc': isOnboardingBlocActive(),
      'splashCubit': isSplashCubitActive(),
    };
  }

  static Map<String, dynamic> getBlocInfo() {
    return {
      'homeBloc': {
        'isActive': isHomeBlocActive(),
        'creationCount': _homeBlocCreationCount,
        'createdAt': _homeBlocCreatedAt?.toIso8601String(),
        'ageInMinutes': _homeBlocCreatedAt != null
            ? DateTime.now().difference(_homeBlocCreatedAt!).inMinutes
            : null,
      },
      'authBloc': {
        'isActive': isAuthBlocActive(),
        'creationCount': _authBlocCreationCount,
        'createdAt': _authBlocCreatedAt?.toIso8601String(),
        'ageInMinutes': _authBlocCreatedAt != null
            ? DateTime.now().difference(_authBlocCreatedAt!).inMinutes
            : null,
      },
      'emotionBloc': {
        'isActive': isEmotionBlocActive(),
        'creationCount': _emotionBlocCreationCount,
        'createdAt': _emotionBlocCreatedAt?.toIso8601String(),
        'ageInMinutes': _emotionBlocCreatedAt != null
            ? DateTime.now().difference(_emotionBlocCreatedAt!).inMinutes
            : null,
      },
      'onboardingBloc': {
        'isActive': isOnboardingBlocActive(),
        'creationCount': _onboardingBlocCreationCount,
        'createdAt': _onboardingBlocCreatedAt?.toIso8601String(),
        'ageInMinutes': _onboardingBlocCreatedAt != null
            ? DateTime.now().difference(_onboardingBlocCreatedAt!).inMinutes
            : null,
      },
      'splashCubit': {
        'isActive': isSplashCubitActive(),
        'creationCount': _splashCubitCreationCount,
        'createdAt': _splashCubitCreatedAt?.toIso8601String(),
        'ageInMinutes': _splashCubitCreatedAt != null
            ? DateTime.now().difference(_splashCubitCreatedAt!).inMinutes
            : null,
      },
    };
  }

  static int getActiveBlocCount() {
    final status = getBlocStatus();
    return status.values.where((isActive) => isActive).length;
  }

  static int getTotalCreationCount() {
    return _homeBlocCreationCount +
        _authBlocCreationCount +
        _emotionBlocCreationCount +
        _onboardingBlocCreationCount +
        _splashCubitCreationCount;
  }

  static Map<String, int> getCreationStats() {
    return {
      'homeBloc': _homeBlocCreationCount,
      'authBloc': _authBlocCreationCount,
      'emotionBloc': _emotionBlocCreationCount,
      'onboardingBloc': _onboardingBlocCreationCount,
      'splashCubit': _splashCubitCreationCount,
      'total': getTotalCreationCount(),
    };
  }

  static HomeBloc refreshHomeBloc() {
    Logger.info('🔄 Force refreshing HomeBloc');
    disposeHomeBloc();
    return getHomeBloc();
  }

  static AuthBloc refreshAuthBloc() {
    Logger.info('🔄 Force refreshing AuthBloc');
    disposeAuthBloc();
    return getAuthBloc();
  }

  static EmotionBloc refreshEmotionBloc() {
    Logger.info('🔄 Force refreshing EmotionBloc');
    disposeEmotionBloc();
    return getEmotionBloc();
  }

  static OnboardingBloc refreshOnboardingBloc() {
    Logger.info('🔄 Force refreshing OnboardingBloc');
    disposeOnboardingBloc();
    return getOnboardingBloc();
  }

  static SplashCubit refreshSplashCubit() {
    Logger.info('🔄 Force refreshing SplashCubit');
    disposeSplashCubit();
    return getSplashCubit();
  }

  static void cleanupInactiveBloCs() {
    Logger.info('🧹 Cleaning up inactive BLoCs...');

    int cleanedCount = 0;

    if (_homeBloc != null && _homeBloc!.isClosed) {
      _homeBloc = null;
      _homeBlocCreatedAt = null;
      cleanedCount++;
    }

    if (_authBloc != null && _authBloc!.isClosed) {
      _authBloc = null;
      _authBlocCreatedAt = null;
      cleanedCount++;
    }

    if (_emotionBloc != null && _emotionBloc!.isClosed) {
      _emotionBloc = null;
      _emotionBlocCreatedAt = null;
      cleanedCount++;
    }

    if (_onboardingBloc != null && _onboardingBloc!.isClosed) {
      _onboardingBloc = null;
      _onboardingBlocCreatedAt = null;
      cleanedCount++;
    }

    if (_splashCubit != null && _splashCubit!.isClosed) {
      _splashCubit = null;
      _splashCubitCreatedAt = null;
      cleanedCount++;
    }

    Logger.info('. Cleaned up $cleanedCount inactive BLoCs');
  }

  static bool validateBloCs() {
    try {
      Logger.info('. Validating BLoC configurations...');

      final testResults = <String, bool>{};

      try {
        final homeBloc = getHomeBloc();
        testResults['homeBloc'] = !homeBloc.isClosed;
      } catch (e) {
        Logger.error('. HomeBloc validation failed:', e);
        testResults['homeBloc'] = false;
      }

      try {
        final authBloc = getAuthBloc();
        testResults['authBloc'] = !authBloc.isClosed;
      } catch (e) {
        Logger.error('. AuthBloc validation failed', e);
        testResults['authBloc'] = false;
      }

      try {
        final emotionBloc = getEmotionBloc();
        testResults['emotionBloc'] = !emotionBloc.isClosed;
      } catch (e) {
        Logger.error('. EmotionBloc validation failed:', e);
        testResults['emotionBloc'] = false;
      }

      try {
        final onboardingBloc = getOnboardingBloc();
        testResults['onboardingBloc'] = !onboardingBloc.isClosed;
      } catch (e) {
        Logger.error('. OnboardingBloc validation failed:', e);
        testResults['onboardingBloc'] = false;
      }

      try {
        final splashCubit = getSplashCubit();
        testResults['splashCubit'] = !splashCubit.isClosed;
      } catch (e) {
        Logger.error('. SplashCubit validation failed', e);
        testResults['splashCubit'] = false;
      }

      final allValid = testResults.values.every((isValid) => isValid);

      if (allValid) {
        Logger.info('. All BLoCs validated successfully');
      } else {
        final failedBloCs = testResults.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .join(', ');
        Logger.error('. BLoC validation failed for:', failedBloCs);
      }

      return allValid;
    } catch (e) {
      Logger.error('. BLoC validation encountered an error', e);
      return false;
    }
  }

  static Map<String, dynamic> getHealthStatus() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'totalBloCs': 5,
      'activeBloCs': getActiveBlocCount(),
      'totalCreations': getTotalCreationCount(),
      'status': getBlocStatus(),
      'info': getBlocInfo(),
      'creationStats': getCreationStats(),
      'isHealthy': getActiveBlocCount() > 0,
    };
  }

  static void logBlocStatus() {
    final status = getBlocStatus();
    final activeCount = getActiveBlocCount();
    final totalCreations = getTotalCreationCount();

    Logger.info('. BLoC Manager Status:');
    Logger.info('   Active BLoCs: $activeCount/5');
    Logger.info('   Total Creations: $totalCreations');
    Logger.info('   HomeBloc: ${status['homeBloc'] == true ? '.' : '.'}');
    Logger.info('   AuthBloc: ${status['authBloc'] == true ? '.' : '.'}');
    Logger.info('   EmotionBloc: ${status['emotionBloc'] == true ? '.' : '.'}');
    Logger.info(
      '   OnboardingBloc: ${status['onboardingBloc'] == true ? '.' : '.'}',
    );
    Logger.info('   SplashCubit: ${status['splashCubit'] == true ? '.' : '.'}');
  }

  static void resetStatistics() {
    _homeBlocCreationCount = 0;
    _authBlocCreationCount = 0;
    _emotionBlocCreationCount = 0;
    _onboardingBlocCreationCount = 0;
    _splashCubitCreationCount = 0;
    Logger.info('🔄 BLoC statistics reset');
  }

  static String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '${difference.inSeconds}s';
    }
  }

  BlocManager._();
}
