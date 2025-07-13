// lib/core/widgets/error_boundary.dart
import 'package:flutter/material.dart';
import '../navigation/navigation_service.dart';
import '../utils/logger.dart';

/// A comprehensive error boundary widget that provides consistent error handling
/// and recovery options across the app
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? context;
  final String? fallbackRoute;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final String? customErrorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.context,
    this.fallbackRoute,
    this.onRetry,
    this.showRetryButton = true,
    this.customErrorMessage,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorWidget();
    }

    return widget.child;
  }

  Widget _buildErrorWidget() {
    return Scaffold(
      backgroundColor: const Color(0xFF090110),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 24),

                // Error Title
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error Message
                Text(
                  widget.customErrorMessage ?? 
                  'We encountered an unexpected error. Please try again or restart the app.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                if (widget.context != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Context: ${widget.context}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  children: [
                    // Retry Button
                    if (widget.showRetryButton)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    if (widget.showRetryButton) const SizedBox(height: 16),

                    // Navigate to Fallback Button
                    if (widget.fallbackRoute != null)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _handleFallbackNavigation,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Go to ${_getFallbackRouteName()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    // Restart App Button (last resort)
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _handleRestart,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[500],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Restart App',
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRetry() {
    Logger.info('🔄 ErrorBoundary: Retrying operation in ${widget.context}');
    
    setState(() {
      _hasError = false;
      _error = null;
      _stackTrace = null;
    });

    if (widget.onRetry != null) {
      try {
        widget.onRetry!();
      } catch (e, stack) {
        Logger.error('❌ ErrorBoundary: Retry failed in ${widget.context}', e, stack);
        setState(() {
          _hasError = true;
          _error = e;
          _stackTrace = stack;
        });
      }
    }
  }

  void _handleFallbackNavigation() {
    Logger.info('🔄 ErrorBoundary: Navigating to fallback route ${widget.fallbackRoute}');
    
    if (widget.fallbackRoute != null) {
      NavigationService.safeNavigate(
        widget.fallbackRoute!,
        clearStack: true,
      );
    }
  }

  void _handleRestart() {
    Logger.info('🔄 ErrorBoundary: Restarting app due to unrecoverable error');
    NavigationService.safeNavigate('/', clearStack: true);
  }

  String _getFallbackRouteName() {
    switch (widget.fallbackRoute) {
      case '/':
        return 'Home';
      case '/auth-choice':
        return 'Login';
      case '/onboarding':
        return 'Setup';
      default:
        return 'Main Menu';
    }
  }

  /// Call this method when an error occurs to trigger the error boundary
  void captureError(Object error, StackTrace stackTrace) {
    Logger.error(
      '❌ ErrorBoundary: Captured error in ${widget.context ?? 'unknown context'}',
      error,
      stackTrace,
    );

    if (mounted) {
      setState(() {
        _hasError = true;
        _error = error;
        _stackTrace = stackTrace;
      });
    }
  }
}

/// A mixin that provides error boundary functionality to widgets
mixin ErrorBoundaryMixin<T extends StatefulWidget> on State<T> {
  void handleError(Object error, StackTrace stackTrace, [String? context]) {
    Logger.error(
      '❌ ErrorBoundaryMixin: Error in ${context ?? T.toString()}',
      error,
      stackTrace,
    );

    // Show user-friendly error message
    if (mounted) {
      NavigationService.showErrorSnackBar(
        'Something went wrong. Please try again.',
      );
    }
  }

  void handleNetworkError([String? operation]) {
    if (mounted) {
      NavigationService.showWarningSnackBar(
        'Connection issue. Please check your internet and try again.',
      );
    }
  }

  void handleValidationError(String message) {
    if (mounted) {
      NavigationService.showErrorSnackBar(message);
    }
  }

  void handleSuccessAction(String message) {
    if (mounted) {
      NavigationService.showSuccessSnackBar(message);
    }
  }
}

/// Global error handling utilities
class GlobalErrorHandler {
  static void handleUncaughtError(Object error, StackTrace stackTrace) {
    Logger.error('❌ GlobalErrorHandler: Uncaught error', error, stackTrace);
    
    // Show user notification if possible
    if (NavigationService.currentContext != null) {
      NavigationService.showErrorSnackBar(
        'An unexpected error occurred. Please restart the app if issues persist.',
      );
    }
  }

  static void handleFlutterError(FlutterErrorDetails details) {
    Logger.error(
      '❌ GlobalErrorHandler: Flutter error',
      details.exception,
      details.stack,
    );

    // In debug mode, we might want to show the red screen
    // In release mode, show user-friendly error
    if (!details.silent) {
      NavigationService.showErrorSnackBar(
        'App error detected. Please restart if issues persist.',
      );
    }
  }
} 