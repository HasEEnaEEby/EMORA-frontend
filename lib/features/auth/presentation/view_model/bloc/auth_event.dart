import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status
class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();

  @override
  String toString() => 'AuthCheckStatus()';
}

/// Event to get current user
class AuthGetCurrentUser extends AuthEvent {
  const AuthGetCurrentUser();

  @override
  String toString() => 'AuthGetCurrentUser()';
}

/// Event to check username availability
class AuthCheckUsername extends AuthEvent {
  final String username;

  const AuthCheckUsername(this.username);

  @override
  List<Object> get props => [username];

  @override
  String toString() => 'AuthCheckUsername(username: $username)';
}

/// Event to login user
class AuthLogin extends AuthEvent {
  final String username; // Note: Your AuthBloc uses username, not email
  final String password;

  const AuthLogin({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];

  @override
  String toString() => 'AuthLogin(username: $username)';
}

class LogoutEvent extends AuthEvent {}

/// Event to register user - Complete version with all required fields
class AuthRegister extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword; // ✅ Added confirmPassword field
  final String? pronouns;
  final String? ageGroup;
  final String? selectedAvatar;
  final String? location;
  final double? latitude;
  final double? longitude;
  final bool? termsAccepted;
  final bool? privacyAccepted;

  const AuthRegister({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword, // ✅ Added to constructor
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar,
    this.location,
    this.latitude,
    this.longitude,
    this.termsAccepted,
    this.privacyAccepted,
  });

  @override
  List<Object?> get props => [
    username,
    email,
    password,
    confirmPassword, // ✅ Added to props
    pronouns,
    ageGroup,
    selectedAvatar,
    location,
    latitude,
    longitude,
    termsAccepted,
    privacyAccepted,
  ];

  @override
  String toString() => 'AuthRegister(username: $username, email: $email)';
}

/// CRITICAL: Event to logout user - This MUST be present
class AuthLogout extends AuthEvent {
  const AuthLogout();

  @override
  String toString() => 'AuthLogout()';
}

/// Event to refresh token
class AuthRefreshToken extends AuthEvent {
  const AuthRefreshToken();

  @override
  String toString() => 'AuthRefreshToken()';
}

/// Event for token refresh failure - forces logout and shows user message
class AuthTokenRefreshFailed extends AuthEvent {
  final String message;
  
  const AuthTokenRefreshFailed({
    this.message = 'Your session has expired. Please log in again.',
  });

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'AuthTokenRefreshFailed(message: $message)';
}

/// Event to clear auth errors
class AuthClearError extends AuthEvent {
  const AuthClearError();

  @override
  String toString() => 'AuthClearError()';
}
