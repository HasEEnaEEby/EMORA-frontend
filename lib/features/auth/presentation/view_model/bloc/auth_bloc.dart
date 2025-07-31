import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/errors/failures.dart';
import 'package:emora_mobile_app/core/use_case/use_case.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/check_auth_status.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/check_username_availability.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/get_current_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/login_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/logout_user.dart';
import 'package:emora_mobile_app/features/auth/domain/use_case/register_user.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_event.dart';
import 'package:emora_mobile_app/features/auth/presentation/view_model/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckUsernameAvailability checkUsernameAvailability;
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final GetCurrentUser getCurrentUser;
  final CheckAuthStatus checkAuthStatus;

  AuthBloc({
    required this.checkUsernameAvailability,
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.getCurrentUser,
    required this.checkAuthStatus,
  }) : super(const AuthInitial()) {
    Logger.info('. Initializing AuthBloc event handlers...');

    try {
      on<AuthCheckStatus>(_onCheckStatus);
      Logger.info('. AuthCheckStatus handler registered');

      on<AuthCheckUsername>(_onCheckUsername);
      Logger.info('. AuthCheckUsername handler registered');

      on<AuthRegister>(_onRegister);
      Logger.info('. AuthRegister handler registered');

      on<AuthLogin>(_onLogin);
      Logger.info('. AuthLogin handler registered');

      on<AuthLogout>(_onLogout);
      Logger.info('. AuthLogout handler registered');

      on<AuthGetCurrentUser>(_onGetCurrentUser);
      Logger.info('. AuthGetCurrentUser handler registered');

      on<AuthClearError>(_onClearError);
      Logger.info('. AuthClearError handler registered');

      on<AuthTokenRefreshFailed>(_onTokenRefreshFailed);
      Logger.info('. AuthTokenRefreshFailed handler registered');

      Logger.info('🎯 AuthBloc initialization completed successfully');
    } catch (e) {
      Logger.error('. Failed to register AuthBloc event handlers: $e');
      rethrow;
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    try {
      Logger.info('🚪 Processing logout request');
      emit(const AuthLoading());

      final result = await logoutUser(NoParams());

      result.fold(
        (failure) {
          Logger.error('. Logout failed on server: ${failure.message}');
          emit(const AuthUnauthenticated());
        },
        (_) {
          Logger.info('. Logout successful');
          emit(const AuthUnauthenticated());
        },
      );
    } catch (e) {
      Logger.error('. Logout error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onClearError(
    AuthClearError event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('🧹 Clearing auth error state');
    emit(const AuthUnauthenticated());
  }

  Future<void> _onTokenRefreshFailed(
    AuthTokenRefreshFailed event,
    Emitter<AuthState> emit,
  ) async {
    Logger.warning('🔄 Token refresh failed, forcing logout: ${event.message}');
    
    try {
      await logoutUser(NoParams());
    } catch (e) {
      Logger.error('. Error during forced logout after token refresh failure', e);
    }
    
    emit(AuthSessionExpired(message: event.message));
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('. Checking authentication status');
    emit(const AuthLoading());

    final result = await checkAuthStatus(NoParams());
    result.fold(
      (failure) {
        Logger.error('. Auth status check failed: ${failure.message}');
        
        if (failure is AuthFailure && failure.statusCode == 401) {
          emit(AuthSessionExpired(message: failure.message));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
      (isAuthenticated) {
        if (isAuthenticated) {
          Logger.info('. User is authenticated');
          add(const AuthGetCurrentUser());
        } else {
          Logger.info('. User is not authenticated');
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckUsername(
    AuthCheckUsername event,
    Emitter<AuthState> emit,
  ) async {
    if (event.username.isEmpty) return;

    Logger.info('. Checking username availability: ${event.username}');
    emit(AuthCheckingUsername(event.username));

    final validationError = AppConfig.validateUsername(event.username);
    if (validationError != null) {
      emit(
        AuthUsernameChecked(
          username: event.username,
          isAvailable: false,
          suggestions: AppConfig.generateUsernamesSuggestions(),
          message: validationError,
        ),
      );
      return;
    }

    final result = await checkUsernameAvailability(
      CheckUsernameParams(username: event.username),
    );

    result.fold(
      (failure) {
        Logger.error('. Username check failed: ${failure.message}');
        emit(
          AuthUsernameChecked(
            username: event.username,
            isAvailable: false,
            suggestions: AppConfig.generateUsernamesSuggestions(),
            message: AppConfig.getFriendlyErrorMessage(failure.toString()),
          ),
        );
      },
      (response) {
        final isAvailable = response['isAvailable'] as bool? ?? false;
        final suggestions = List<String>.from(response['suggestions'] ?? []);
        final message =
            response['message'] as String? ??
            (isAvailable
                ? AppConfig.usernameAvailableMessage
                : AppConfig.usernameExistsMessage);

        Logger.info('. Username check result: $isAvailable');
        emit(
          AuthUsernameChecked(
            username: event.username,
            isAvailable: isAvailable,
            suggestions: suggestions,
            message: message,
          ),
        );
      },
    );
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    Logger.info('📝 Starting user registration: ${event.username}');
    emit(const AuthLoading());

    if (event.password != event.confirmPassword) {
      emit(
        AuthError(
          'Passwords do not match. Please make sure both passwords are identical.',
          errorCode: 'PASSWORD_MISMATCH',
          type: AuthErrorType.validation,
        ),
      );
      return;
    }

    final usernameError = AppConfig.validateUsername(event.username);
    if (usernameError != null) {
      emit(
        AuthError(
          usernameError,
          errorCode: 'VALIDATION_ERROR',
          type: AuthErrorType.validation,
        ),
      );
      return;
    }

    final emailError = AppConfig.validateEmail(event.email);
    if (emailError != null) {
      emit(
        AuthError(
          emailError,
          errorCode: 'VALIDATION_ERROR',
          type: AuthErrorType.validation,
        ),
      );
      return;
    }

    final passwordError = AppConfig.validatePassword(event.password);
    if (passwordError != null) {
      emit(
        AuthError(
          passwordError,
          errorCode: 'VALIDATION_ERROR',
          type: AuthErrorType.validation,
        ),
      );
      return;
    }

    final result = await registerUser(
      RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
confirmPassword: event.confirmPassword, 
        pronouns: event.pronouns,
        ageGroup: event.ageGroup,
        selectedAvatar: event.selectedAvatar,
        location: event.location,
        latitude: event.latitude,
        longitude: event.longitude,
        termsAccepted: event.termsAccepted ?? true,
        privacyAccepted: event.privacyAccepted ?? true,
      ),
    );

    result.fold(
      (failure) {
        Logger.error('. Registration failed: ${failure.message}');

        final failureMessage = failure.toString().toLowerCase();

        if (failureMessage.contains('email') &&
            failureMessage.contains('exist')) {
          emit(const AuthError.emailExists());
        } else if (failureMessage.contains('username') &&
            failureMessage.contains('exist')) {
          emit(const AuthError.usernameExists());
        } else if (failureMessage.contains('network') ||
            failureMessage.contains('connection')) {
          emit(const AuthError.networkError());
        } else if (failureMessage.contains('server') ||
            failureMessage.contains('500')) {
          emit(const AuthError.serverError());
        } else {
          emit(
            AuthError(
              AppConfig.getFriendlyErrorMessage(failure.toString()),
              errorCode: 'REGISTRATION_ERROR',
              type: AuthErrorType.registration,
            ),
          );
        }
      },
      (authResponse) {
        Logger.info('. Registration successful: ${authResponse.user.username}');
        emit(
          AuthRegistrationSuccess(
            user: authResponse.user,
            message: AppConfig.registrationSuccessMessage,
          ),
        );
      },
    );
  }

  Future<void> _onLogin(AuthLogin event, Emitter<AuthState> emit) async {
    Logger.info('🔑 Starting user login: ${event.username}');
    emit(const AuthLoading());

    final result = await loginUser(
      LoginParams(username: event.username, password: event.password),
    );

    result.fold(
      (failure) {
        Logger.error('. Login failed: ${failure.message}');

        final failureMessage = failure.toString().toLowerCase();

        if (failureMessage.contains('invalid') ||
            failureMessage.contains('credentials')) {
          emit(const AuthError.invalidCredentials());
        } else if (failureMessage.contains('network') ||
            failureMessage.contains('connection')) {
          emit(const AuthError.networkError());
        } else {
          emit(
            AuthError(
              AppConfig.getFriendlyErrorMessage(failure.toString()),
              errorCode: 'LOGIN_ERROR',
              type: AuthErrorType.login,
            ),
          );
        }
      },
      (authResponse) {
        Logger.info('. Login successful: ${authResponse.user.username}');
        emit(
          AuthLoginSuccess(
            user: authResponse.user,
            message: AppConfig.loginSuccessMessage,
          ),
        );
      },
    );
  }

  Future<void> _onGetCurrentUser(
    AuthGetCurrentUser event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('. Getting current user');

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) {
        Logger.error('. Get current user failed: ${failure.message}');
        emit(const AuthUnauthenticated());
      },
      (user) {
        Logger.info('. Current user retrieved: ${user.username}');
        emit(AuthAuthenticated(user));
      },
    );
  }
}
