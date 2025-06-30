// lib/core/errors/failures.dart - Update your existing file with these classes
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class BadRequestFailure extends Failure {
  const BadRequestFailure({required super.message});
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure({required super.message, this.errors});

  @override
  List<Object> get props => [message, errors ?? {}];
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message});
}

// Add this missing UnexpectedFailure class
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
