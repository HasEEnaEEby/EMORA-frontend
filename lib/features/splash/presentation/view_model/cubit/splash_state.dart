import 'package:equatable/equatable.dart';

// ===== SPLASH STATES =====

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  final String? message;

  const SplashLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class SplashNavigateToAuth extends SplashState {
  const SplashNavigateToAuth();
}

class SplashNavigateToAuthWithMessage extends SplashState {
  final String message;
  final bool isReturningUser;

  const SplashNavigateToAuthWithMessage(
    this.message, {
    this.isReturningUser = false,
  });

  @override
  List<Object?> get props => [message, isReturningUser];
}

class SplashNavigateToOnboarding extends SplashState {
  final bool isFirstTime;

  const SplashNavigateToOnboarding({this.isFirstTime = true});

  @override
  List<Object?> get props => [isFirstTime];
}

class SplashNavigateToHome extends SplashState {
  final Map<String, dynamic>? userData;

  const SplashNavigateToHome({this.userData});

  @override
  List<Object?> get props => [userData];
}

class SplashError extends SplashState {
  final String message;
  final String? errorCode;
  final bool canRetry;

  const SplashError(this.message, {this.errorCode, this.canRetry = true});

  @override
  List<Object?> get props => [message, errorCode, canRetry];

  @override
  String toString() => 'SplashError { message: $message, canRetry: $canRetry }';
}
