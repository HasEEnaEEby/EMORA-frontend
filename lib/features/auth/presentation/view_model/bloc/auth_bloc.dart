import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../core/use_case/use_case.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/repository/auth_repository_impl.dart';
import '../../../domain/entity/user_entity.dart';
import '../../../domain/use_case/check_username_availability.dart';
import '../../../domain/use_case/get_current_user.dart';
import '../../../domain/use_case/login_user.dart';
import '../../../domain/use_case/logout_user.dart';
import '../../../domain/use_case/register_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckUsernameAvailability checkUsernameAvailability;
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final GetCurrentUser getCurrentUser;
  final LogoutUser logoutUser;
  final AuthRepositoryImpl authRepository;

  AuthBloc({
    required this.checkUsernameAvailability,
    required this.registerUser,
    required this.loginUser,
    required this.getCurrentUser,
    required this.logoutUser,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<CheckUsernameAvailabilityEvent>(_onCheckUsernameAvailability);
    on<RegisterUserEvent>(_onRegisterUser);
    on<LoginUserEvent>(_onLoginUser);
    on<LogoutUserEvent>(_onLogoutUser);
    on<ClearAuthError>(_onClearAuthError);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('🔍 Checking authentication status...');
    emit(AuthLoading());

    try {
      final result = await getCurrentUser(NoParams());

      await result.fold(
        (failure) async {
          Logger.warning('⚠️ Auth check failed: ${failure.message}');

          // Check if user has ever been logged in to determine the appropriate state
          if (failure is UnauthorizedFailure) {
            final hasBeenLoggedInResult = await authRepository
                .hasEverBeenLoggedIn();

            hasBeenLoggedInResult.fold(
              (error) {
                Logger.error('❌ Error checking login history', error);
                // If we can't check, assume new user to be safe
                emit(AuthUnauthenticated());
              },
              (hasEverBeenLoggedIn) {
                if (hasEverBeenLoggedIn) {
                  Logger.info('📱 Returning user with expired session');
                  emit(AuthSessionExpired());
                } else {
                  Logger.info('👋 New user detected');
                  emit(AuthUnauthenticated());
                }
              },
            );
          } else {
            // For network errors or other failures, treat as unauthenticated
            Logger.info(
              '🌐 Network or other error, treating as unauthenticated',
            );
            emit(AuthUnauthenticated());
          }
        },
        (user) {
          if (user != null) {
            Logger.info('✅ User authenticated: ${user.username}');
            emit(AuthAuthenticated(user));
          } else {
            Logger.info('❌ No user found');
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('❌ Unexpected error in auth check', e, stackTrace);
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCheckUsernameAvailability(
    CheckUsernameAvailabilityEvent event,
    Emitter<AuthState> emit,
  ) async {
    final username = event.username.trim();

    // Skip check for empty usernames
    if (username.isEmpty) {
      return;
    }

    // Don't emit checking state if already checking the same username
    if (state is! AuthUsernameChecking ||
        (state as AuthUsernameChecking).username != username) {
      emit(AuthUsernameChecking(username));
    }

    try {
      final result = await checkUsernameAvailability(
        CheckUsernameParams(username: username),
      );

      result.fold(
        (failure) {
          Logger.error('❌ Username check failed', failure);
          emit(
            AuthUsernameCheckResult(
              username: username,
              isAvailable: false,
              message: failure.message,
            ),
          );
        },
        (isAvailable) {
          Logger.info('✅ Username "$username" availability: $isAvailable');
          emit(
            AuthUsernameCheckResult(
              username: username,
              isAvailable: isAvailable,
              message: isAvailable
                  ? 'Username is available'
                  : 'Username is already taken',
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      Logger.error('❌ Username check error', e, stackTrace);
      emit(
        AuthUsernameCheckResult(
          username: username,
          isAvailable: false,
          message: 'Failed to check username availability',
        ),
      );
    }
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('📝 Starting registration for: ${event.username}');
    emit(AuthLoading());

    try {
      // Validate input before making the request
      if (event.username.trim().isEmpty || event.password.isEmpty) {
        emit(AuthError('Username and password are required'));
        return;
      }

      final result = await registerUser(
        RegisterUserParams(
          username: event.username.trim(),
          password: event.password,
          pronouns: event.pronouns,
          ageGroup: event.ageGroup,
          selectedAvatar: event.selectedAvatar,
        ),
      );

      await result.fold(
        (failure) async {
          Logger.error('❌ Registration failed', failure);
          emit(AuthError(failure.message));
        },
        (authResponse) async {
          Logger.info(
            '✅ Registration successful for: ${authResponse.user.username}',
          );

          // Emit success state first
          emit(AuthAuthenticated(authResponse.user));

          // Navigate to home after successful registration
          await _navigateToHomeAfterAuth(
            user: authResponse.user,
            message: '🎉 Welcome to Emora! Registration successful.',
            isFirstTime: true,
          );
        },
      );
    } catch (e, stackTrace) {
      Logger.error('❌ Registration error', e, stackTrace);
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  Future<void> _onLoginUser(
    LoginUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('🔐 Starting login for: ${event.username}');
    emit(AuthLoading());

    try {
      // Validate input before making the request
      if (event.username.trim().isEmpty || event.password.isEmpty) {
        emit(AuthError('Username and password are required'));
        return;
      }

      final result = await loginUser(
        LoginUserParams(
          username: event.username.trim(),
          password: event.password,
        ),
      );

      await result.fold(
        (failure) async {
          Logger.error('❌ Login failed', failure);
          emit(AuthError(failure.message));
        },
        (authResponse) async {
          Logger.info('✅ Login successful for: ${authResponse.user.username}');

          // Emit success state first
          emit(AuthAuthenticated(authResponse.user));

          // Navigate to home after successful login
          await _navigateToHomeAfterAuth(
            user: authResponse.user,
            message: '👋 Welcome back!',
            isFirstTime: false,
          );
        },
      );
    } catch (e, stackTrace) {
      Logger.error('❌ Login error', e, stackTrace);
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutUser(
    LogoutUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    Logger.info('🚪 Starting logout process...');
    emit(AuthLoading());

    try {
      await logoutUser(NoParams());
      Logger.info('✅ Logout successful');
      emit(AuthUnauthenticated());

      // Navigate to auth choice after logout
      await _navigateToAuthChoice();
    } catch (e, stackTrace) {
      Logger.error('❌ Logout error', e, stackTrace);
      emit(AuthError('Logout failed: ${e.toString()}'));

      // Even if logout API fails, clear local session
      emit(AuthUnauthenticated());
      await _navigateToAuthChoice();
    }
  }

  void _onClearAuthError(ClearAuthError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  // Navigation Methods

  Future<void> _navigateToHomeAfterAuth({
    required UserEntity user,
    required String message,
    required bool isFirstTime,
  }) async {
    Logger.info('🏠 Navigating to home after authentication...');

    try {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 300));

      if (NavigationService.currentState != null) {
        await NavigationService.pushNamedAndClearStack(
          AppRouter.home,
          arguments: {
            'isAuthenticated': true,
            'isGuest': false,
            'isFirstTime': isFirstTime,
            'userData': _userToMap(user),
            'user': user, // Pass the actual user entity as well
          },
        );

        Logger.info('✅ Successfully navigated to home');

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          NavigationService.showSuccessSnackBar(message);
        });
      } else {
        Logger.error('❌ NavigationService not ready', 'AuthBloc');
        throw Exception('Navigation service not initialized');
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Navigation to home failed', e, stackTrace);
      NavigationService.showErrorSnackBar('Failed to navigate to home');
    }
  }

  Future<void> _navigateToAuthChoice() async {
    Logger.info('🔄 Navigating to auth choice...');

    try {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 200));

      if (NavigationService.currentState != null) {
        await NavigationService.pushNamedAndClearStack(AppRouter.authChoice);
        Logger.info('✅ Navigated to auth choice after logout');
      } else {
        Logger.error(
          '❌ NavigationService not ready for logout navigation',
          'AuthBloc',
        );
      }
    } catch (e, stackTrace) {
      Logger.error('❌ Navigation to auth choice failed', e, stackTrace);
    }
  }

  // Helper method to convert user entity to map for passing through navigation
  Map<String, dynamic> _userToMap(UserEntity user) {
    try {
      return {
        'id': user.id,
        'username': user.username,
        'pronouns': user.pronouns ?? '',
        'ageGroup': user.ageGroup ?? '',
        'selectedAvatar': user.selectedAvatar ?? '',
        'createdAt': user.createdAt.toIso8601String() ?? '',
        // Add any other user properties you need that actually exist in UserEntity
      };
    } catch (e, stackTrace) {
      Logger.error('❌ Error converting user to map', e, stackTrace);
      return {
        'id': user.id,
        'username': user.username,
        'pronouns': '',
        'ageGroup': '',
        'selectedAvatar': '',
        'createdAt': '',
      };
    }
  }

  // Helper method to validate authentication state
  bool get isAuthenticated => state is AuthAuthenticated;

  // Helper method to get current user
  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }
}
