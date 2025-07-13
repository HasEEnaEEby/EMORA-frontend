// lib/features/auth/presentation/view_model/bloc/auth_state.dart
import 'package:emora_mobile_app/features/auth/domain/entity/user_entity.dart';
import 'package:equatable/equatable.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when AuthBloc is first created
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

/// State when authentication operations are in progress
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthLoading(message: $message)';
}

/// State when user is successfully authenticated
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String? token;
  final DateTime? expiresAt;

  const AuthAuthenticated(
    this.user, {
    this.token,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [user, token, expiresAt];

  @override
  String toString() => 'AuthAuthenticated(user: ${user.username})';
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthUnauthenticated(message: $message)';
}

/// State when registration is successful but user might need email verification
class AuthRegistrationSuccess extends AuthState {
  final UserEntity user;
  final String message;
  final bool requiresEmailVerification;

  const AuthRegistrationSuccess({
    required this.user,
    required this.message,
    this.requiresEmailVerification = false,
  });

  @override
  List<Object?> get props => [user, message, requiresEmailVerification];

  @override
  String toString() => 'AuthRegistrationSuccess(user: ${user.username}, verificationRequired: $requiresEmailVerification)';
}

/// State when login is successful
class AuthLoginSuccess extends AuthState {
  final UserEntity user;
  final String message;
  final String? token;

  const AuthLoginSuccess({
    required this.user,
    required this.message,
    this.token,
  });

  @override
  List<Object?> get props => [user, message, token];

  @override
  String toString() => 'AuthLoginSuccess(user: ${user.username})';
}

/// State when checking username availability
class AuthCheckingUsername extends AuthState {
  final String username;

  const AuthCheckingUsername(this.username);

  @override
  List<Object> get props => [username];

  @override
  String toString() => 'AuthCheckingUsername(username: $username)';
}

/// State when username availability check is complete
class AuthUsernameChecked extends AuthState {
  final String username;
  final bool isAvailable;
  final List<String> suggestions;
  final String message;

  const AuthUsernameChecked({
    required this.username,
    required this.isAvailable,
    required this.suggestions,
    required this.message,
  });

  @override
  List<Object> get props => [username, isAvailable, suggestions, message];

  @override
  String toString() => 'AuthUsernameChecked(username: $username, available: $isAvailable)';
}

/// State when user session has expired
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({
    this.message = 'Your session has expired. Please log in again.',
  });

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthSessionExpired(message: $message)';
}

/// State when password reset email has been sent
class AuthPasswordResetSent extends AuthState {
  final String email;
  final String message;

  const AuthPasswordResetSent({
    required this.email,
    this.message = 'Password reset instructions have been sent to your email.',
  });

  @override
  List<Object> get props => [email, message];

  @override
  String toString() => 'AuthPasswordResetSent(email: $email)';
}

/// State when password has been successfully reset
class AuthPasswordResetSuccess extends AuthState {
  final String message;

  const AuthPasswordResetSuccess({
    this.message = 'Password has been reset successfully. Please log in with your new password.',
  });

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthPasswordResetSuccess(message: $message)';
}

/// State when password has been successfully changed
class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged({
    this.message = 'Password changed successfully.',
  });

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthPasswordChanged(message: $message)';
}

/// State when email verification is sent
class AuthEmailVerificationSent extends AuthState {
  final String email;
  final String message;

  const AuthEmailVerificationSent({
    required this.email,
    this.message = 'Verification email has been sent. Please check your inbox.',
  });

  @override
  List<Object> get props => [email, message];

  @override
  String toString() => 'AuthEmailVerificationSent(email: $email)';
}

/// State when email has been successfully verified
class AuthEmailVerified extends AuthState {
  final UserEntity user;
  final String message;

  const AuthEmailVerified({
    required this.user,
    this.message = 'Email verified successfully.',
  });

  @override
  List<Object> get props => [user, message];

  @override
  String toString() => 'AuthEmailVerified(user: ${user.username})';
}

/// State when two-factor authentication is required
class AuthTwoFactorRequired extends AuthState {
  final String sessionToken;
  final String message;

  const AuthTwoFactorRequired({
    required this.sessionToken,
    this.message = 'Please enter your two-factor authentication code.',
  });

  @override
  List<Object> get props => [sessionToken, message];

  @override
  String toString() => 'AuthTwoFactorRequired()';
}

/// State when two-factor authentication is successfully verified
class AuthTwoFactorVerified extends AuthState {
  final UserEntity user;
  final String message;

  const AuthTwoFactorVerified({
    required this.user,
    this.message = 'Two-factor authentication verified successfully.',
  });

  @override
  List<Object> get props => [user, message];

  @override
  String toString() => 'AuthTwoFactorVerified(user: ${user.username})';
}

/// State when two-factor authentication has been enabled/disabled
class AuthTwoFactorToggled extends AuthState {
  final bool enabled;
  final String message;
  final List<String>? backupCodes;

  const AuthTwoFactorToggled({
    required this.enabled,
    required this.message,
    this.backupCodes,
  });

  @override
  List<Object?> get props => [enabled, message, backupCodes];

  @override
  String toString() => 'AuthTwoFactorToggled(enabled: $enabled)';
}

/// State when account deletion is in progress
class AuthAccountDeleting extends AuthState {
  final String message;

  const AuthAccountDeleting({
    this.message = 'Deleting your account...',
  });

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthAccountDeleting(message: $message)';
}

/// State when account has been successfully deleted
class AuthAccountDeleted extends AuthState {
  final String message;

  const AuthAccountDeleted({
    this.message = 'Your account has been successfully deleted.',
  });

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'AuthAccountDeleted(message: $message)';
}

/// State when authentication token is being refreshed
class AuthTokenRefreshing extends AuthState {
  const AuthTokenRefreshing();

  @override
  String toString() => 'AuthTokenRefreshing()';
}

/// State when authentication token has been successfully refreshed
class AuthTokenRefreshed extends AuthState {
  final String token;
  final DateTime expiresAt;

  const AuthTokenRefreshed({
    required this.token,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [token, expiresAt];

  @override
  String toString() => 'AuthTokenRefreshed(expiresAt: $expiresAt)';
}

/// State when there's an authentication error
class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final AuthErrorType type;
  final Map<String, dynamic>? details;

  const AuthError(
    this.message, {
    this.errorCode,
    this.type = AuthErrorType.general,
    this.details,
  });

  @override
  List<Object?> get props => [message, errorCode, type, details];

  @override
  String toString() => 'AuthError(message: $message, type: $type, code: $errorCode)';

  /// Named constructors for common error types
  const AuthError.invalidCredentials({
    this.message = 'Invalid username or password. Please try again.',
    this.errorCode = 'INVALID_CREDENTIALS',
    this.details,
  }) : type = AuthErrorType.invalidCredentials;

  const AuthError.emailExists({
    this.message = 'An account with this email already exists. Please use a different email or try logging in.',
    this.errorCode = 'EMAIL_EXISTS',
    this.details,
  }) : type = AuthErrorType.emailExists;

  const AuthError.usernameExists({
    this.message = 'This username is already taken. Please choose a different username.',
    this.errorCode = 'USERNAME_EXISTS',
    this.details,
  }) : type = AuthErrorType.usernameExists;

  const AuthError.networkError({
    this.message = 'Network error. Please check your internet connection and try again.',
    this.errorCode = 'NETWORK_ERROR',
    this.details,
  }) : type = AuthErrorType.network;

  const AuthError.serverError({
    this.message = 'Server error. Please try again later.',
    this.errorCode = 'SERVER_ERROR',
    this.details,
  }) : type = AuthErrorType.server;

  const AuthError.validationError({
    required this.message,
    this.errorCode = 'VALIDATION_ERROR',
    this.details,
  }) : type = AuthErrorType.validation;

  const AuthError.tokenExpired({
    this.message = 'Your session has expired. Please log in again.',
    this.errorCode = 'TOKEN_EXPIRED',
    this.details,
  }) : type = AuthErrorType.tokenExpired;

  const AuthError.accountLocked({
    this.message = 'Your account has been temporarily locked due to multiple failed login attempts.',
    this.errorCode = 'ACCOUNT_LOCKED',
    this.details,
  }) : type = AuthErrorType.accountLocked;

  const AuthError.emailNotVerified({
    this.message = 'Please verify your email address before logging in.',
    this.errorCode = 'EMAIL_NOT_VERIFIED',
    this.details,
  }) : type = AuthErrorType.emailNotVerified;

  const AuthError.twoFactorRequired({
    this.message = 'Two-factor authentication code is required.',
    this.errorCode = 'TWO_FACTOR_REQUIRED',
    this.details,
  }) : type = AuthErrorType.twoFactorRequired;

  const AuthError.twoFactorInvalid({
    this.message = 'Invalid two-factor authentication code.',
    this.errorCode = 'TWO_FACTOR_INVALID',
    this.details,
  }) : type = AuthErrorType.twoFactorInvalid;
}

/// Enum for different types of authentication errors
enum AuthErrorType {
  general,
  invalidCredentials,
  emailExists,
  usernameExists,
  network,
  server,
  validation,
  tokenExpired,
  accountLocked,
  emailNotVerified,
  twoFactorRequired,
  twoFactorInvalid,
  registration,
  login,
  passwordReset,
  emailVerification,
}