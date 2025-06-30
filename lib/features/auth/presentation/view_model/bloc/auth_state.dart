import 'package:equatable/equatable.dart';

import '../../../domain/entity/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? loadingMessage;

  const AuthLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final DateTime? lastLoginTime;
  final bool isFirstTimeLogin;

  const AuthAuthenticated(
    this.user, {
    this.lastLoginTime,
    this.isFirstTimeLogin = false,
  });

  @override
  List<Object?> get props => [user, lastLoginTime, isFirstTimeLogin];

  AuthAuthenticated copyWith({
    UserEntity? user,
    DateTime? lastLoginTime,
    bool? isFirstTimeLogin,
  }) {
    return AuthAuthenticated(
      user ?? this.user,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      isFirstTimeLogin: isFirstTimeLogin ?? this.isFirstTimeLogin,
    );
  }
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthSessionExpired extends AuthState {
  final String message;
  final DateTime expiredAt;

  AuthSessionExpired({
    this.message = 'Your session has expired. Please sign in again.',
    DateTime? expiredAt,
  }) : expiredAt = expiredAt ?? DateTime.now();

  @override
  List<Object?> get props => [message, expiredAt];
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final DateTime timestamp;
  final AuthErrorType errorType;

  AuthError(
    this.message, {
    this.errorCode,
    DateTime? timestamp,
    this.errorType = AuthErrorType.general,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [message, errorCode, timestamp, errorType];

  AuthError copyWith({
    String? message,
    String? errorCode,
    DateTime? timestamp,
    AuthErrorType? errorType,
  }) {
    return AuthError(
      message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      timestamp: timestamp ?? this.timestamp,
      errorType: errorType ?? this.errorType,
    );
  }
}

enum AuthErrorType {
  general,
  network,
  validation,
  unauthorized,
  server,
  timeout,
}

class AuthUsernameChecking extends AuthState {
  final String username;

  const AuthUsernameChecking(this.username);

  @override
  List<Object?> get props => [username];
}

class AuthUsernameCheckResult extends AuthState {
  final String username;
  final bool isAvailable;
  final String message;

  const AuthUsernameCheckResult({
    required this.username,
    required this.isAvailable,
    required this.message,
  });

  @override
  List<Object?> get props => [username, isAvailable, message];
}

class AuthRegistrationSuccess extends AuthState {
  final UserEntity user;
  final String message;

  const AuthRegistrationSuccess({
    required this.user,
    this.message = 'Registration successful!',
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthLoginSuccess extends AuthState {
  final UserEntity user;
  final String message;
  final bool isFirstTimeLogin;

  const AuthLoginSuccess({
    required this.user,
    this.message = 'Login successful!',
    this.isFirstTimeLogin = false,
  });

  @override
  List<Object?> get props => [user, message, isFirstTimeLogin];
}

class AuthTokenRefreshing extends AuthState {
  const AuthTokenRefreshing();
}

class AuthTokenRefreshed extends AuthState {
  final UserEntity user;
  final DateTime refreshedAt;

  AuthTokenRefreshed(this.user, {DateTime? refreshedAt})
    : refreshedAt = refreshedAt ?? DateTime.now();

  @override
  List<Object?> get props => [user, refreshedAt];
}

class AuthProfileUpdating extends AuthState {
  const AuthProfileUpdating();
}

class AuthProfileUpdated extends AuthState {
  final UserEntity user;
  final String message;

  const AuthProfileUpdated({
    required this.user,
    this.message = 'Profile updated successfully!',
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthPasswordChanging extends AuthState {
  const AuthPasswordChanging();
}

class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged({this.message = 'Password changed successfully!'});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetRequested extends AuthState {
  final String email;
  final String message;

  const AuthPasswordResetRequested({
    required this.email,
    this.message = 'Password reset link sent to your email.',
  });

  @override
  List<Object?> get props => [email, message];
}

class AuthSessionValidating extends AuthState {
  const AuthSessionValidating();
}

class AuthSessionValid extends AuthState {
  final UserEntity user;

  const AuthSessionValid(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSessionInvalid extends AuthState {
  final String reason;

  const AuthSessionInvalid({this.reason = 'Session is no longer valid'});

  @override
  List<Object?> get props => [reason];
}

// Extension to easily check state types and access common properties
extension AuthStateExtension on AuthState {
  bool get isLoading =>
      this is AuthLoading ||
      this is AuthTokenRefreshing ||
      this is AuthProfileUpdating ||
      this is AuthPasswordChanging ||
      this is AuthSessionValidating;

  bool get isAuthenticated =>
      this is AuthAuthenticated ||
      this is AuthTokenRefreshed ||
      this is AuthSessionValid;

  bool get isUnauthenticated =>
      this is AuthUnauthenticated ||
      this is AuthSessionExpired ||
      this is AuthSessionInvalid;

  bool get hasError => this is AuthError;

  bool get isUsernameChecking => this is AuthUsernameChecking;

  bool get isSuccess =>
      this is AuthRegistrationSuccess ||
      this is AuthLoginSuccess ||
      this is AuthProfileUpdated ||
      this is AuthPasswordChanged ||
      this is AuthPasswordResetRequested;

  UserEntity? get user {
    if (this is AuthAuthenticated) {
      return (this as AuthAuthenticated).user;
    }
    if (this is AuthRegistrationSuccess) {
      return (this as AuthRegistrationSuccess).user;
    }
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).user;
    }
    if (this is AuthTokenRefreshed) {
      return (this as AuthTokenRefreshed).user;
    }
    if (this is AuthProfileUpdated) {
      return (this as AuthProfileUpdated).user;
    }
    if (this is AuthSessionValid) {
      return (this as AuthSessionValid).user;
    }
    return null;
  }

  String? get errorMessage {
    if (this is AuthError) {
      return (this as AuthError).message;
    }
    if (this is AuthSessionExpired) {
      return (this as AuthSessionExpired).message;
    }
    if (this is AuthSessionInvalid) {
      return (this as AuthSessionInvalid).reason;
    }
    return null;
  }

  String? get successMessage {
    if (this is AuthRegistrationSuccess) {
      return (this as AuthRegistrationSuccess).message;
    }
    if (this is AuthLoginSuccess) {
      return (this as AuthLoginSuccess).message;
    }
    if (this is AuthProfileUpdated) {
      return (this as AuthProfileUpdated).message;
    }
    if (this is AuthPasswordChanged) {
      return (this as AuthPasswordChanged).message;
    }
    if (this is AuthPasswordResetRequested) {
      return (this as AuthPasswordResetRequested).message;
    }
    return null;
  }

  AuthErrorType? get errorType {
    if (this is AuthError) {
      return (this as AuthError).errorType;
    }
    return null;
  }

  bool get shouldNavigateToHome =>
      this is AuthAuthenticated ||
      this is AuthLoginSuccess ||
      this is AuthRegistrationSuccess;

  bool get shouldNavigateToAuth =>
      this is AuthUnauthenticated ||
      this is AuthSessionExpired ||
      this is AuthSessionInvalid;
}
