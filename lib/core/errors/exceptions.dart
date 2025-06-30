abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() =>
      'AppException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});

  @override
  String toString() =>
      'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class CacheException extends AppException {
  const CacheException({required super.message});

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when user is not authorized (401 status code)
class UnauthorizedException extends AppException {
  final String? reason;

  const UnauthorizedException({
    required super.message,
    super.statusCode,
    this.reason,
  });

  @override
  String toString() =>
      'UnauthorizedException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown for bad requests (400 status code)
class BadRequestException extends AppException {
  const BadRequestException({required super.message, super.statusCode});

  @override
  String toString() =>
      'BadRequestException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when rate limit is exceeded (429 status code)
class RateLimitException extends AppException {
  const RateLimitException({required super.message, super.statusCode});

  @override
  String toString() =>
      'RateLimitException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when access is forbidden (403 status code)
class ForbiddenException extends AppException {
  const ForbiddenException({required super.message, super.statusCode});

  @override
  String toString() =>
      'ForbiddenException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when a resource is not found (404 status code)
class NotFoundException extends AppException {
  final String? resource;

  const NotFoundException({
    required super.message,
    super.statusCode,
    this.resource,
  });

  @override
  String toString() =>
      'NotFoundException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when a request times out
class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.statusCode});

  @override
  String toString() =>
      'TimeoutException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when input validation fails
class ValidationException extends AppException {
  final String? field;
  final Map<String, dynamic>? errors;

  const ValidationException({
    required super.message,
    this.field,
    this.errors,
    super.statusCode,
  });

  @override
  String toString() =>
      'ValidationException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
