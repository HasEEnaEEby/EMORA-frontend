
class ServerException implements Exception {
  final String message;
  final String? code;
final int? statusCode; 

  ServerException({
    required this.message,
    this.code,
this.statusCode, 
  });

  @override
  String toString() =>
      'ServerException(message: $message, code: $code, statusCode: $statusCode)';
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException({required this.message, this.code});

  @override
  String toString() => 'NetworkException(message: $message, code: $code)';
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({required this.message, this.code});

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}

class UnauthorizedException implements Exception {
  final String message;
  final String? code;

  UnauthorizedException({required this.message, this.code});

  @override
  String toString() => 'UnauthorizedException(message: $message, code: $code)';
}

class NotFoundException implements Exception {
  final String message;
  final String? code;

  NotFoundException({required this.message, this.code});

  @override
  String toString() => 'NotFoundException(message: $message, code: $code)';
}

class ValidationException implements Exception {
  final String message;
  final String? code;

  ValidationException({required this.message, this.code});

  @override
  String toString() => 'ValidationException(message: $message, code: $code)';
}

class TimeoutException implements Exception {
  final String message;
  final String? code;

  TimeoutException({required this.message, this.code});

  @override
  String toString() => 'TimeoutException(message: $message, code: $code)';
}

class PermissionException implements Exception {
  final String message;
  final String? code;

  PermissionException({required this.message, this.code});

  @override
  String toString() => 'PermissionException(message: $message, code: $code)';
}

class RateLimitException implements Exception {
  final String message;
final int retryAfter; 

  RateLimitException({
    required this.message,
this.retryAfter = 300, 
  });

  @override
  String toString() => 'RateLimitException(message: $message, retryAfter: $retryAfter)';
}

class FriendRequestException implements Exception {
  final String message;
  final String? code;

  FriendRequestException({required this.message, this.code});

  @override
  String toString() => 'FriendRequestException(message: $message, code: $code)';
}

class DuplicateFriendRequestException implements Exception {
  final String message;
  final String? code;

  DuplicateFriendRequestException({required this.message, this.code});

  @override
  String toString() => 'DuplicateFriendRequestException(message: $message, code: $code)';
}
