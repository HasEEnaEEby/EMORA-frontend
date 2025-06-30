import 'package:flutter/material.dart';

/// Centralized navigation service to handle navigation throughout the app
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get the current navigator state
  static NavigatorState? get currentState => navigatorKey.currentState;

  /// Convenience getter for context (fixes the connectivity service error)
  static BuildContext? get context => currentContext;

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
        debugPrint('❌ NavigationService: Navigator state is null');
        return null;
      }
    } catch (e) {
      debugPrint('❌ NavigationService pushNamed error: $e');
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
        debugPrint('❌ NavigationService: Navigator state is null');
        return null;
      }
    } catch (e) {
      debugPrint('❌ NavigationService pushNamedAndRemoveUntil error: $e');
      return null;
    }
  }

  /// Push a named route and clear the entire stack (convenience method)
  static Future<T?> pushNamedAndClearStack<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
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
        debugPrint('❌ NavigationService: Navigator state is null');
        return null;
      }
    } catch (e) {
      debugPrint('❌ NavigationService pushReplacementNamed error: $e');
      return null;
    }
  }

  /// Pop the current route
  static void pop<T extends Object?>([T? result]) {
    try {
      if (currentState != null && currentState!.canPop()) {
        currentState!.pop<T>(result);
      } else {
        debugPrint(
          '❌ NavigationService: Cannot pop - navigator state is null or cannot pop',
        );
      }
    } catch (e) {
      debugPrint('❌ NavigationService pop error: $e');
    }
  }

  /// Pop until a specific route
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    try {
      if (currentState != null) {
        currentState!.popUntil(predicate);
      } else {
        debugPrint('❌ NavigationService: Navigator state is null');
      }
    } catch (e) {
      debugPrint('❌ NavigationService popUntil error: $e');
    }
  }

  /// Show a snackbar
  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    try {
      if (currentContext != null) {
        ScaffoldMessenger.of(currentContext!).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: duration,
            action: action,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        debugPrint(
          '❌ NavigationService: Context is null, cannot show snackbar',
        );
      }
    } catch (e) {
      debugPrint('❌ NavigationService showSnackBar error: $e');
    }
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFF4CAF50));
  }

  /// Show an error snackbar
  static void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFFf44336));
  }

  /// Show an info snackbar
  static void showInfoSnackBar(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFF2196F3));
  }

  /// Show a warning snackbar
  static void showWarningSnackBar(String message) {
    showSnackBar(message, backgroundColor: const Color(0xFFFF9800));
  }

  /// Show a dialog
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
        debugPrint('❌ NavigationService: Context is null, cannot show dialog');
        return null;
      }
    } catch (e) {
      debugPrint('❌ NavigationService showCustomDialog error: $e');
      return null;
    }
  }

  /// Show a confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    try {
      if (currentContext == null) {
        debugPrint(
          '❌ NavigationService: Context is null, cannot show confirmation dialog',
        );
        return null;
      }

      return await showDialog<bool>(
        context: currentContext!,
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
                  backgroundColor: confirmColor ?? const Color(0xFF8B5FBF),
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
      debugPrint('❌ NavigationService showConfirmationDialog error: $e');
      return null;
    }
  }

  /// Show an error dialog
  static Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    try {
      if (currentContext == null) {
        debugPrint(
          '❌ NavigationService: Context is null, cannot show error dialog',
        );
        return;
      }

      await showDialog(
        context: currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
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
      debugPrint('❌ NavigationService showErrorDialog error: $e');
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
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5FBF),
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
        debugPrint(
          '❌ NavigationService: Context is null, cannot show loading dialog',
        );
      }
    } catch (e) {
      debugPrint('❌ NavigationService showLoadingDialog error: $e');
    }
  }

  /// Hide the current dialog
  static void hideDialog() {
    try {
      if (currentContext != null) {
        Navigator.of(currentContext!).pop();
      } else {
        debugPrint('❌ NavigationService: Context is null, cannot hide dialog');
      }
    } catch (e) {
      debugPrint('❌ NavigationService hideDialog error: $e');
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
      debugPrint('❌ NavigationService getCurrentRouteName error: $e');
      return null;
    }
  }

  /// Check if we can pop the current route
  static bool canPop() {
    try {
      return currentState?.canPop() ?? false;
    } catch (e) {
      debugPrint('❌ NavigationService canPop error: $e');
      return false;
    }
  }

  /// Safe navigation with error handling
  static Future<T?> safeNavigate<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool replacement = false,
    bool clearStack = false,
  }) async {
    try {
      if (currentState == null) {
        debugPrint('❌ NavigationService: Navigator state is null');
        return null;
      }

      if (clearStack) {
        return await pushNamedAndClearStack<T>(routeName, arguments: arguments);
      } else if (replacement) {
        return await pushReplacementNamed<T, dynamic>(
          routeName,
          arguments: arguments,
        );
      } else {
        return await pushNamed<T>(routeName, arguments: arguments);
      }
    } catch (e) {
      debugPrint('❌ NavigationService safeNavigate error: $e');
      showErrorSnackBar('Navigation failed: ${e.toString()}');
      return null;
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
      // Try primary route
      final result = await safeNavigate(
        primaryRoute,
        arguments: arguments,
        replacement: replacement,
      );

      if (result == null && fallbackRoute != null) {
        debugPrint(
          '🔄 Primary navigation failed, trying fallback: $fallbackRoute',
        );
        await safeNavigate(fallbackRoute, replacement: replacement);
      }
    } catch (e) {
      debugPrint('❌ NavigationService navigateWithFallback error: $e');
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
      await pushNamedAndClearStack(routeName, arguments: arguments);
    } catch (e) {
      debugPrint('❌ NavigationService resetAndNavigateTo error: $e');
      showErrorSnackBar('Failed to reset navigation');
    }
  }

  /// Navigate back to a specific route by name
  static void popToRoute(String routeName) {
    try {
      if (currentState != null) {
        currentState!.popUntil((route) {
          return route.settings.name == routeName;
        });
      } else {
        debugPrint('❌ NavigationService: Navigator state is null');
      }
    } catch (e) {
      debugPrint('❌ NavigationService popToRoute error: $e');
    }
  }

  /// Check if a specific route is in the navigation stack
  static bool isRouteInStack(String routeName) {
    try {
      if (currentContext == null) return false;

      // This is a simplified check - you might need a more robust implementation
      return getCurrentRouteName() == routeName;
    } catch (e) {
      debugPrint('❌ NavigationService isRouteInStack error: $e');
      return false;
    }
  }

  /// Get navigation history depth (approximate)
  static int getNavigationDepth() {
    try {
      if (currentState == null) return 0;

      // This is an approximation - Flutter doesn't provide direct access to navigation stack depth
      return currentState!.canPop() ? 1 : 0;
    } catch (e) {
      debugPrint('❌ NavigationService getNavigationDepth error: $e');
      return 0;
    }
  }

  /// Clear all snackbars
  static void clearSnackBars() {
    try {
      if (currentContext != null) {
        ScaffoldMessenger.of(currentContext!).clearSnackBars();
      }
    } catch (e) {
      debugPrint('❌ NavigationService clearSnackBars error: $e');
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
        debugPrint(
          '❌ NavigationService: Context is null, cannot show bottom sheet',
        );
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
      debugPrint('❌ NavigationService showBottomSheet error: $e');
      return null;
    }
  }
}