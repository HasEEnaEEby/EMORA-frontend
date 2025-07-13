// Add this to your auth_state.dart file

import 'package:equatable/equatable.dart';

// Base Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  String toString() => 'AuthInitial()';
}

// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  String toString() => 'AuthLoading()';
}

// Authenticated state
class AuthAuthenticated extends AuthState {
  final dynamic user; // Replace with your actual User entity type

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() =>
      'AuthAuthenticated(user: ${user?.username ?? 'unknown'})';
}

// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  String toString() => 'AuthUnauthenticated()';
}

// Username checking states
class AuthCheckingUsername extends AuthState {
  final String username;

  const AuthCheckingUsername(this.username);

  @override
  List<Object> get props => [username];

  @override
  String toString() => 'AuthCheckingUsername(username: $username)';
}

class AuthUsernameChecked extends AuthState {
  final String username;
  final bool isAvailable;
  final List<String> suggestions;
  final String message;

  const AuthUsernameChecked({
    required this.username,
    required this.isAvailable,
    this.suggestions = const [],
    required this.message,
  });

  @override
  List<Object> get props => [username, isAvailable, suggestions, message];

  @override
  String toString() =>
      'AuthUsernameChecked(username: $username, isAvailable: $isAvailable)';
}

// Registration states
class AuthRegistrationSuccess extends AuthState {
  final dynamic user; // Replace with your actual User entity type
  final String message;

  const AuthRegistrationSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];

  @override
  String toString() =>
      'AuthRegistrationSuccess(user: ${user?.username ?? 'unknown'})';
}

// Login states
class AuthLoginSuccess extends AuthState {
  final dynamic user; // Replace with your actual User entity type
  final String message;

  const AuthLoginSuccess({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];

  @override
  String toString() => 'AuthLoginSuccess(user: ${user?.username ?? 'unknown'})';
}

// Error states
enum AuthErrorType {
  validation,
  network,
  server,
  authentication,
  registration,
  login,
  logout,
  general,
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final AuthErrorType type;

  const AuthError(
    this.message, {
    this.errorCode,
    this.type = AuthErrorType.general,
  });

  // Named constructors for common error types
  const AuthError.emailExists()
    : message = 'This email address is already registered',
      errorCode = 'EMAIL_EXISTS',
      type = AuthErrorType.registration;

  const AuthError.usernameExists()
    : message = 'This username is already taken',
      errorCode = 'USERNAME_EXISTS',
      type = AuthErrorType.registration;

  const AuthError.invalidCredentials()
    : message = 'Invalid username or password',
      errorCode = 'INVALID_CREDENTIALS',
      type = AuthErrorType.authentication;

  const AuthError.networkError()
    : message =
          'Network connection failed. Please check your internet connection',
      errorCode = 'NETWORK_ERROR',
      type = AuthErrorType.network;

  const AuthError.serverError()
    : message = 'Server error. Please try again later',
      errorCode = 'SERVER_ERROR',
      type = AuthErrorType.server;

  const AuthError.tokenRefreshFailed()
    : message = 'Your session has expired. Please log in again.',
      errorCode = 'TOKEN_REFRESH_FAILED',
      type = AuthErrorType.authentication;

  @override
  List<Object?> get props => [message, errorCode, type];

  @override
  String toString() =>
      'AuthError(message: $message, code: $errorCode, type: $type)';
}

/// Special state for token refresh failures that requires user action
class AuthSessionExpired extends AuthState {
  final String message;

  const AuthSessionExpired({
    this.message = 'Your session has expired. Please log in again.',
  });

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthSessionExpired(message: $message)';
}
