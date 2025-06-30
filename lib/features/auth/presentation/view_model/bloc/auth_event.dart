import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class CheckUsernameAvailabilityEvent extends AuthEvent {
  final String username;

  const CheckUsernameAvailabilityEvent(this.username);

  @override
  List<Object?> get props => [username];
}

class RegisterUserEvent extends AuthEvent {
  final String username;
  final String password;
  final String pronouns;
  final String ageGroup;
  final String selectedAvatar;
  final String? location;
  final double? latitude;
  final double? longitude;

  const RegisterUserEvent(
    this.username,
    this.password,
    this.pronouns,
    this.ageGroup,
    this.selectedAvatar, [
    this.location,
    this.latitude,
    this.longitude,
  ]);

  @override
  List<Object?> get props => [
    username,
    password,
    pronouns,
    ageGroup,
    selectedAvatar,
    location,
    latitude,
    longitude,
  ];
}

class LoginUserEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginUserEvent(this.username, this.password);

  @override
  List<Object?> get props => [username, password];
}

class LogoutUserEvent extends AuthEvent {
  const LogoutUserEvent();
}

class ClearAuthError extends AuthEvent {
  const ClearAuthError();
}

class RefreshAuthToken extends AuthEvent {
  const RefreshAuthToken();
}

class UpdateUserProfile extends AuthEvent {
  final Map<String, dynamic> updates;

  const UpdateUserProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}

class HandleSessionExpired extends AuthEvent {
  final String message;

  const HandleSessionExpired([
    this.message = 'Your session has expired. Please sign in again.',
  ]);

  @override
  List<Object?> get props => [message];
}

class ValidateSession extends AuthEvent {
  const ValidateSession();
}

class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword(this.email);

  @override
  List<Object?> get props => [email];
}

class ChangePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword(this.currentPassword, this.newPassword);

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
