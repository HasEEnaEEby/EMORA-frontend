import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'ServerFailure(message: $message, statusCode: $statusCode)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'NetworkFailure(message: $message, statusCode: $statusCode)';
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'CacheFailure(message: $message, statusCode: $statusCode)';
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'AuthFailure(message: $message, statusCode: $statusCode)';
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'ValidationFailure(message: $message, statusCode: $statusCode)';
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'NotFoundFailure(message: $message, statusCode: $statusCode)';
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'UnauthorizedFailure(message: $message, statusCode: $statusCode)';
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'TimeoutFailure(message: $message, statusCode: $statusCode)';
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.statusCode});

  @override
  String toString() =>
      'UnknownFailure(message: $message, statusCode: $statusCode)';
}
