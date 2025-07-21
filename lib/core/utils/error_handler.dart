// lib/core/utils/error_handler.dart - Comprehensive Error Handling
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logger.dart';
import 'app_config.dart';

class ErrorHandler {
  static const String _tag = 'ErrorHandler';

  // Error types for better categorization
  static const String networkError = 'NETWORK_ERROR';
  static const String serverError = 'SERVER_ERROR';
  static const String authError = 'AUTH_ERROR';
  static const String validationError = 'VALIDATION_ERROR';
  static const String cacheError = 'CACHE_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  // Error severity levels
  static const String severityLow = 'LOW';
  static const String severityMedium = 'MEDIUM';
  static const String severityHigh = 'HIGH';
  static const String severityCritical = 'CRITICAL';

  /// Handles and logs errors with proper categorization
  static void handleError(
    dynamic error,
    String context, {
    String? userId,
    Map<String, dynamic>? additionalData,
    String severity = severityMedium,
  }) {
    final errorInfo = _extractErrorInfo(error);
    
    Logger.error(
      '. Error in $context: ${errorInfo.message}',
      {
        'context': context,
        'errorType': errorInfo.type,
        'severity': severity,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'originalError': error,
        ...?additionalData,
      },
    );

    // Report critical errors to analytics/crash reporting
    if (severity == severityCritical) {
      _reportCriticalError(errorInfo, context, userId);
    }
  }

  /// Extracts structured error information
  static ErrorInfo _extractErrorInfo(dynamic error) {
    if (error is String) {
      return ErrorInfo(
        message: error,
        type: _categorizeError(error),
        originalError: error,
      );
    }

    final errorString = error.toString().toLowerCase();
    return ErrorInfo(
      message: _extractErrorMessage(error),
      type: _categorizeError(errorString),
      originalError: error,
      statusCode: _extractStatusCode(error),
    );
  }

  /// Categorizes errors based on content
  static String _categorizeError(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('network') || 
        errorLower.contains('connection') ||
        errorLower.contains('timeout')) {
      return networkError;
    } else if (errorLower.contains('unauthorized') ||
               errorLower.contains('401') ||
               errorLower.contains('forbidden') ||
               errorLower.contains('403')) {
      return authError;
    } else if (errorLower.contains('validation') ||
               errorLower.contains('invalid') ||
               errorLower.contains('required')) {
      return validationError;
    } else if (errorLower.contains('server') ||
               errorLower.contains('500') ||
               errorLower.contains('internal')) {
      return serverError;
    } else if (errorLower.contains('cache') ||
               errorLower.contains('storage')) {
      return cacheError;
    } else {
      return unknownError;
    }
  }

  /// Extracts user-friendly error message
  static String _extractErrorMessage(dynamic error) {
    if (error is String) {
      return AppConfig.getFriendlyErrorMessage(error);
    }

    final errorString = error.toString();
    
    // Handle common error patterns
    if (errorString.contains('Exception:')) {
      return errorString.split('Exception:').last.trim();
    }
    
    if (errorString.contains('Error:')) {
      return errorString.split('Error:').last.trim();
    }

    return AppConfig.getFriendlyErrorMessage(errorString);
  }

  /// Extracts HTTP status code if available
  static int? _extractStatusCode(dynamic error) {
    try {
      final errorString = error.toString();
      final statusMatch = RegExp(r'(\d{3})').firstMatch(errorString);
      if (statusMatch != null) {
        return int.tryParse(statusMatch.group(1) ?? '');
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Reports critical errors to analytics/crash reporting
  static void _reportCriticalError(
    ErrorInfo errorInfo,
    String context,
    String? userId,
  ) {
    // TODO: Implement crash reporting integration
    Logger.critical(
      '🚨 Critical error reported: ${errorInfo.message}',
      {
        'context': context,
        'userId': userId,
        'errorType': errorInfo.type,
        'statusCode': errorInfo.statusCode,
        'originalError': errorInfo.originalError,
      },
    );
  }

  /// Shows user-friendly error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAction?.call();
              },
              child: Text(
                actionText ?? 'OK',
                style: const TextStyle(
                  color: Color(0xFF8B5FBF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Shows error snackbar with retry option
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String? actionText,
    VoidCallback? onAction,
    Duration duration = AppConfig.snackBarDuration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: duration,
        action: actionText != null && onAction != null
            ? SnackBarAction(
                label: actionText,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Handles authentication errors specifically
  static void handleAuthError(
    dynamic error,
    BuildContext context, {
    String? userId,
    VoidCallback? onLogout,
  }) {
    final errorInfo = _extractErrorInfo(error);
    
    Logger.warning(
      '🔐 Auth error: ${errorInfo.message}',
      {
        'userId': userId,
        'errorType': errorInfo.type,
        'statusCode': errorInfo.statusCode,
        'originalError': error,
      },
    );

    // Handle specific auth error types
    switch (errorInfo.type) {
      case authError:
        if (errorInfo.statusCode == 401) {
          // Token expired or invalid
          _handleTokenExpired(context, onLogout);
        } else {
          showErrorSnackBar(
            context,
            'Authentication failed. Please try again.',
            actionText: 'Retry',
            onAction: () {
              // Trigger re-authentication
              onLogout?.call();
            },
          );
        }
        break;
      
      case networkError:
        showErrorSnackBar(
          context,
          AppConfig.networkErrorMessage,
          actionText: 'Retry',
          onAction: () {
            // Trigger retry logic
          },
        );
        break;
      
      default:
        showErrorSnackBar(
          context,
          errorInfo.message,
          actionText: 'Retry',
          onAction: () {
            // Trigger retry logic
          },
        );
    }
  }

  /// Handles token expiration
  static void _handleTokenExpired(
    BuildContext context,
    VoidCallback? onLogout,
  ) {
    showErrorDialog(
      context,
      'Session Expired',
      'Your session has expired. Please log in again.',
      actionText: 'OK',
      onAction: onLogout,
    );
  }

  /// Clears error state from storage
  static Future<void> clearErrorState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_error');
      await prefs.remove('error_count');
      Logger.info('🧹 Error state cleared');
    } catch (e) {
      Logger.error('. Failed to clear error state', e);
    }
  }

  /// Records error for analytics
  static Future<void> recordError(
    String errorType,
    String context, {
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorCount = prefs.getInt('error_count') ?? 0;
      await prefs.setInt('error_count', errorCount + 1);
      
      Logger.info(
        '. Error recorded: $errorType in $context (count: ${errorCount + 1})',
        {
          'errorType': errorType,
          'context': context,
          'userId': userId,
          'totalErrors': errorCount + 1,
          ...?additionalData,
        },
      );
    } catch (e) {
      Logger.error('. Failed to record error', e);
    }
  }
}

/// Structured error information
class ErrorInfo {
  final String message;
  final String type;
  final dynamic originalError;
  final int? statusCode;

  const ErrorInfo({
    required this.message,
    required this.type,
    required this.originalError,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ErrorInfo(type: $type, message: $message, statusCode: $statusCode)';
  }
} 