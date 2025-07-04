// lib/core/navigation/navigation_service.dart - ENHANCED VERSION
import 'package:flutter/material.dart';

import '../utils/logger.dart';

/// Centralized navigation service with comprehensive error handling and debugging
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigation state tracking
  static bool _isNavigating = false;
  static String? _lastRoute;
  static DateTime? _lastNavigationTime;
  static const Duration _navigationDebounce = Duration(milliseconds: 500);
  static final List<String> _navigationHistory = [];

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get the current navigator state
  static NavigatorState? get currentState => navigatorKey.currentState;

  /// Convenience getter for context
  static BuildContext? get context => currentContext;

  /// Enhanced safe navigation with comprehensive error handling
  static Future<T?> safeNavigate<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replacement = false,
    bool clearStack = false,
    bool allowDuplicates = false,
  }) async {
    try {
      Logger.info('🚀 SafeNavigate: $routeName (replacement: $replacement, clearStack: $clearStack)');

      // Prevent rapid duplicate navigation
      if (!allowDuplicates && _isDuplicateNavigation(routeName)) {
        Logger.warning('🔄 Preventing duplicate navigation to: $routeName');
        return null;
      }

      if (currentState == null) {
        Logger.error('❌ NavigationService: Navigator state is null');
        return null;
      }

      // Handle navigation queue
      if (_isNavigating) {
        Logger.info('⏳ Navigation in progress, queuing: $routeName');
        await Future.delayed(const Duration(milliseconds: 100));
        return safeNavigate<T>(
          routeName,
          arguments: arguments,
          replacement: replacement,
          clearStack: clearStack,
          allowDuplicates: true, // Allow on retry
        );
      }

      _isNavigating = true;
      _updateNavigationHistory(routeName);

      try {
        T? result;
        
        if (clearStack) {
          Logger.info('🔄 Clearing navigation stack and navigating to: $routeName');
          result = await pushNamedAndClearStack<T>(routeName, arguments: arguments);
        } else if (replacement) {
          Logger.info('🔄 Replacing current route with: $routeName');
          result = await pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);
        } else {
          Logger.info('▶️ Pushing new route: $routeName');
          result = await pushNamed<T>(routeName, arguments: arguments);
        }

        Logger.info('✅ Navigation completed successfully to: $routeName');
        return result;
      } finally {
        // Reset navigation flag after a delay
        Future.delayed(_navigationDebounce, () {
          _isNavigating = false;
        });
      }
    } catch (e, stackTrace) {
      Logger.error('❌ NavigationService safeNavigate error for $routeName', e, stackTrace);
      _isNavigating = false;
      
      // Show user-friendly error
      showErrorSnackBar('Navigation failed: Please try again');
      return null;
    }
  }

  /// Check for duplicate navigation
  static bool _isDuplicateNavigation(String routeName) {
    final now = DateTime.now();

    if (_lastRoute == routeName &&
        _lastNavigationTime != null &&
        now.difference(_lastNavigationTime!) < _navigationDebounce) {
      return true;
    }

    return false;
  }

  /// Update navigation history
  static void _updateNavigationHistory(String routeName) {
    _lastRoute = routeName;
    _lastNavigationTime = DateTime.now();
    
    // Add to history (keep last 10 entries)
    _navigationHistory.add('${DateTime.now().toIso8601String()}: $routeName');
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }

  /// Push a named route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      if (currentState != null) {
        return await currentState!.pushNamed<T>(
          routeName,
          arguments: arguments,
        );
      } else {
        Logger.error('❌ NavigationService: Navigator state is null for pushNamed');
        return null;
      }
    } catch (e) {
      Logger.error('❌ NavigationService pushNamed error for $routeName', e);
      return null;
    }
  }

  /// Push a named route and remove all previous routes
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) async {
    try {
      if (currentState != null) {
        return await currentState!.pushNamedAndRemoveUntil<T>(
          routeName,
          predicate,
          arguments: arguments,
        );
      } else {
        Logger.error('❌ NavigationService: Navigator state is null for pushNamedAndRemoveUntil');
        return null;
      }
    } catch (e) {
      Logger.error('❌ NavigationService pushNamedAndRemoveUntil error for $routeName', e);
      return null;
    }
  }

  /// Push a named route and clear the entire stack (convenience method)
  static Future<T?> pushNamedAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    Logger.info('🗑️ Clearing entire navigation stack for: $routeName');
    return await pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false, // Remove all previous routes
      arguments: arguments,
    );
  }

  /// Replace the current route with a named route
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) async {
    try {
      if (currentState != null) {
        return await currentState!.pushReplacementNamed<T, TO>(
          routeName,
          arguments: arguments,
          result: result,
        );
      } else {
        Logger.error('❌ NavigationService: Navigator state is null for pushReplacementNamed');
        return null;
      }
    } catch (e) {
      Logger.error('❌ NavigationService pushReplacementNamed error for $routeName', e);
      return null;
    }
  }

  /// Pop the current route
  static void pop<T extends Object?>([T? result]) {
    try {
      if (currentState != null && currentState!.canPop()) {
        Logger.info('⬅️ Popping current route');
        currentState!.pop<T>(result);
      } else {
        Logger.warning('⚠️ NavigationService: Cannot pop - no routes available or navigator state null');
      }
    } catch (e) {
      Logger.error('❌ NavigationService pop error', e);
    }
  }

  /// Pop until a specific route
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    try {
      if (currentState != null) {
        Logger.info('⬅️ Popping until condition met');
        currentState!.popUntil(predicate);
      } else {
        Logger.error('❌ NavigationService: Navigator state is null for popUntil');
      }
    } catch (e) {
      Logger.error('❌ NavigationService popUntil error', e);
    }
  }

  /// Show a snackbar with enhanced styling
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    try {
      if (currentContext != null) {
        ScaffoldMessenger.of(currentContext!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: backgroundColor ?? const Color(0xFF374151),
            duration: duration,
            action: action,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        Logger.warning('⚠️ NavigationService: Context is null, cannot show snackbar: $message');
      }
    } catch (e) {
      Logger.error('❌ NavigationService showSnackBar error', e);
    }
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message, 
      backgroundColor: const Color(0xFF10B981),
      icon: Icons.check_circle,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(String message) {
    showSnackBar(
      message, 
      backgroundColor: const Color(0xFFEF4444),
      icon: Icons.error,
      duration: const Duration(seconds: 4),
    );
  }

  /// Show an info snackbar
  static void showInfoSnackBar(String message) {
    showSnackBar(
      message, 
      backgroundColor: const Color(0xFF3B82F6),
      icon: Icons.info,
    );
  }

  /// Show a warning snackbar
  static void showWarningSnackBar(String message) {
    showSnackBar(
      message, 
      backgroundColor: const Color(0xFFF59E0B),
      icon: Icons.warning,
    );
  }

  /// Show a custom dialog
  static Future<T?> showCustomDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    try {
      if (currentContext != null) {
        return await showDialog<T>(
          context: currentContext!,
          barrierDismissible: barrierDismissible,
          builder: (context) => dialog,
        );
      } else {
        Logger.error('❌ NavigationService: Context is null, cannot show dialog');
        return null;
      }
    } catch (e) {
      Logger.error('❌ NavigationService showCustomDialog error', e);
      return null;
    }
  }

  /// Show a confirmation dialog with enhanced styling
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) async {
    try {
      if (currentContext == null) {
        Logger.error('❌ NavigationService: Context is null, cannot show confirmation dialog');
        return null;
      }

      return await showDialog<bool>(
        context: currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  cancelText,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor ?? const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Logger.error('❌ NavigationService showConfirmationDialog error', e);
      return null;
    }
  }

  /// Show an error dialog with enhanced styling
  static Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    try {
      if (currentContext == null) {
        Logger.error('❌ NavigationService: Context is null, cannot show error dialog');
        return;
      }

      await showDialog(
        context: currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade400, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Logger.error('❌ NavigationService showErrorDialog error', e);
    }
  }

  /// Show a loading dialog
  static void showLoadingDialog({String message = 'Loading...'}) {
    try {
      if (currentContext != null) {
        showDialog(
          context: currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        Logger.error('❌ NavigationService: Context is null, cannot show loading dialog');
      }
    } catch (e) {
      Logger.error('❌ NavigationService showLoadingDialog error', e);
    }
  }

  /// Hide the current dialog
  static void hideDialog() {
    try {
      if (currentContext != null) {
        Navigator.of(currentContext!).pop();
      } else {
        Logger.warning('⚠️ NavigationService: Context is null, cannot hide dialog');
      }
    } catch (e) {
      Logger.error('❌ NavigationService hideDialog error', e);
    }
  }

  /// Get the current route name
  static String? getCurrentRouteName() {
    try {
      if (currentContext != null) {
        return ModalRoute.of(currentContext!)?.settings.name;
      }
      return null;
    } catch (e) {
      Logger.error('❌ NavigationService getCurrentRouteName error', e);
      return null;
    }
  }

  /// Check if we can pop the current route
  static bool canPop() {
    try {
      return currentState?.canPop() ?? false;
    } catch (e) {
      Logger.error('❌ NavigationService canPop error', e);
      return false;
    }
  }

  /// Navigate with fallback options
  static Future<void> navigateWithFallback({
    required String primaryRoute,
    String? fallbackRoute,
    Object? arguments,
    bool replacement = false,
  }) async {
    try {
      Logger.info('🎯 Attempting navigation with fallback: $primaryRoute -> $fallbackRoute');
      
      // Try primary route
      final result = await safeNavigate(
        primaryRoute,
        arguments: arguments,
        replacement: replacement,
      );

      if (result == null && fallbackRoute != null) {
        Logger.info('🔄 Primary navigation failed, trying fallback: $fallbackRoute');
        await safeNavigate(fallbackRoute, replacement: replacement);
      }
    } catch (e) {
      Logger.error('❌ NavigationService navigateWithFallback error', e);
      if (fallbackRoute != null) {
        await safeNavigate(fallbackRoute, replacement: replacement);
      }
    }
  }

  /// Reset navigation stack and go to route
  static Future<void> resetAndNavigateTo(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      Logger.info('🔄 Resetting navigation stack and navigating to: $routeName');
      await safeNavigate(routeName, arguments: arguments, clearStack: true);
    } catch (e) {
      Logger.error('❌ NavigationService resetAndNavigateTo error', e);
      showErrorSnackBar('Failed to reset navigation');
    }
  }

  /// Clear all snackbars
  static void clearSnackBars() {
    try {
      if (currentContext != null) {
        ScaffoldMessenger.of(currentContext!).clearSnackBars();
      }
    } catch (e) {
      Logger.error('❌ NavigationService clearSnackBars error', e);
    }
  }

  /// Show bottom sheet
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool enableDrag = true,
    bool isDismissible = true,
  }) async {
    try {
      if (currentContext == null) {
        Logger.error('❌ NavigationService: Context is null, cannot show bottom sheet');
        return null;
      }

      return await showModalBottomSheet<T>(
        context: currentContext!,
        isScrollControlled: isScrollControlled,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        backgroundColor: Colors.transparent,
        builder: (context) => child,
      );
    } catch (e) {
      Logger.error('❌ NavigationService showBottomSheet error', e);
      return null;
    }
  }

  /// Get navigation statistics for debugging
  static Map<String, dynamic> getNavigationStats() {
    return {
      'isNavigating': _isNavigating,
      'lastRoute': _lastRoute,
      'lastNavigationTime': _lastNavigationTime?.toIso8601String(),
      'canPop': canPop(),
      'currentRoute': getCurrentRouteName(),
      'navigationHistory': _navigationHistory,
      'hasContext': currentContext != null,
      'hasNavigatorState': currentState != null,
    };
  }

  /// Debug method to print navigation statistics
  static void debugPrintNavigationStats() {
    final stats = getNavigationStats();
    Logger.info('📊 Navigation Statistics:');
    stats.forEach((key, value) {
      Logger.info('   $key: $value');
    });
  }

  /// Clear navigation history (for testing/debugging)
  static void clearNavigationHistory() {
    _navigationHistory.clear();
    _lastRoute = null;
    _lastNavigationTime = null;
    Logger.info('🗑️ Navigation history cleared');
  }

  /// Check if navigation service is properly initialized
  static bool isInitialized() {
    return navigatorKey.currentContext != null;
  }

  /// Get a health check of the navigation service
  static Map<String, dynamic> healthCheck() {
    return {
      'initialized': isInitialized(),
      'hasContext': currentContext != null,
      'hasNavigatorState': currentState != null,
      'canPop': canPop(),
      'currentRoute': getCurrentRouteName(),
      'isNavigating': _isNavigating,
      'lastRoute': _lastRoute,
      'historyLength': _navigationHistory.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}