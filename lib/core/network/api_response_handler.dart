import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../utils/logger.dart';

class ApiResponseHandler {
  static Map<String, dynamic> handleResponse(Response response) {
    try {
      Logger.info(
        '. API Response: ${response.statusCode} ${response.requestOptions.path}',
      );

      final rawData = response.data;
      Map<String, dynamic> data;

      if (rawData == null) {
        throw ServerException(
          message: 'Empty response from server',
          statusCode: response.statusCode,
        );
      }

      if (rawData is Map<String, dynamic>) {
        data = rawData;
      } else if (rawData is Map) {
        data = Map<String, dynamic>.from(rawData);
        Logger.info(
          '. Converted Map<dynamic, dynamic> to Map<String, dynamic>',
        );
      } else {
        Logger.error('. Invalid response type: ${rawData.runtimeType}');
        throw ServerException(
          message: 'Invalid response format: ${rawData.runtimeType}',
          statusCode: response.statusCode,
        );
      }

      final status = data['status'] as String?;
      final success = data['success'] as bool?;
      final message = data['message'] as String? ?? '';


      final isHttpSuccess =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      final isDataSuccess = status == 'success' || success == true;
      final isDataError = status == 'error';

      Logger.debug('📥 Response Details', {
        'status': status,
        'success': success,
        'message': message,
        'isHttpSuccess': isHttpSuccess,
        'isDataSuccess': isDataSuccess,
        'isDataError': isDataError,
        'dataType': data.runtimeType.toString(),
      });

      if (isHttpSuccess && (isDataSuccess || !isDataError)) {
        Logger.info('. Successful API response: $message');

        final responseData = data['data'];
        if (responseData != null) {
          if (responseData is Map<String, dynamic>) {
            return responseData;
          } else if (responseData is Map) {
            return Map<String, dynamic>.from(responseData);
          } else {
            return data;
          }
        } else {
          return data;
        }
      }

      if (isDataError || !isHttpSuccess) {
        Logger.error('. API Error Response: $message');

        if (data['errors'] != null) {
          final errors = data['errors'] as List<dynamic>?;
          if (errors != null && errors.isNotEmpty) {
            Logger.error('. Validation Errors:');
            for (final error in errors) {
              if (error is Map<String, dynamic>) {
                final field = error['field']?.toString() ?? 'unknown';
                final errorMessage =
                    error['message']?.toString() ?? 'unknown error';
                final value = error['value']?.toString() ?? 'unknown';
                Logger.error('   - $field: $errorMessage (received: $value)');
              }
            }

            throw ValidationException(
              message: message.isNotEmpty ? message : 'Validation failed',
              code: data['errorCode']?.toString(),
            );
          }
        }

        final statusCode = response.statusCode ?? 500;
        if (statusCode == 401) {
          throw UnauthorizedException(
            message: message.isNotEmpty ? message : 'Authentication required',
            code: data['errorCode']?.toString(),
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            message: message.isNotEmpty ? message : 'Resource not found',
            code: data['errorCode']?.toString(),
          );
        } else if (statusCode >= 400 && statusCode < 500) {
          throw ValidationException(
            message: message.isNotEmpty ? message : 'Client error occurred',
            code: data['errorCode']?.toString(),
          );
        } else {
          throw ServerException(
            message: message.isNotEmpty ? message : 'Server error occurred',
            statusCode: statusCode,
            code: data['errorCode']?.toString(),
          );
        }
      }

      Logger.warning(
        '. Ambiguous API response, treating as success: $message',
      );

      final responseData = data['data'];
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is Map) {
          return Map<String, dynamic>.from(responseData);
        }
      }
      return data;
    } catch (e) {
      if (e is ServerException ||
          e is ValidationException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }

      Logger.error('. Failed to handle API response: $e');
      throw ServerException(
        message: 'Failed to process server response: $e',
        statusCode: response.statusCode,
      );
    }
  }

  static Exception handleDioException(DioException error) {
    Logger.error('. DioException: ${error.type}', error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        Map<String, dynamic>? processedData;
        if (responseData is Map<String, dynamic>) {
          processedData = responseData;
        } else if (responseData is Map) {
          processedData = Map<String, dynamic>.from(responseData);
        }

        if (statusCode == 400 && processedData != null) {
          final message =
              processedData['message']?.toString() ?? 'Validation failed';

          if (processedData['errors'] != null) {
            Logger.error('. Validation Errors from server:');
            final errors = processedData['errors'] as List<dynamic>?;
            if (errors != null) {
              for (final error in errors) {
                if (error is Map<String, dynamic>) {
                  final field = error['field']?.toString() ?? 'unknown';
                  final errorMessage =
                      error['message']?.toString() ?? 'unknown error';
                  final value = error['value']?.toString() ?? 'unknown';
                  Logger.error('   - $field: $errorMessage (received: $value)');
                }
              }
            }
          }

          return ValidationException(
            message: message,
            code: processedData['errorCode']?.toString() ?? 'VALIDATION_ERROR',
          );
        } else if (statusCode == 401) {
          return UnauthorizedException(
            message:
                processedData?['message']?.toString() ??
                'Authentication required',
            code: processedData?['errorCode']?.toString() ?? 'UNAUTHORIZED',
          );
        } else if (statusCode == 404) {
          return NotFoundException(
            message:
                processedData?['message']?.toString() ?? 'Resource not found',
            code: processedData?['errorCode']?.toString() ?? 'NOT_FOUND',
          );
        }

        return ServerException(
          message:
              processedData?['message']?.toString() ?? 'Server error occurred',
          statusCode: statusCode,
          code: processedData?['errorCode']?.toString() ?? 'SERVER_ERROR',
        );

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'No internet connection available',
          code: 'NO_CONNECTION',
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate verification failed',
          code: 'SSL_ERROR',
        );

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          message: 'An unexpected error occurred: ${error.message}',
          code: 'UNKNOWN_ERROR',
        );
    }
  }
}
