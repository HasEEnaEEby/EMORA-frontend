import 'package:flutter/foundation.dart';

/// Route guard for handling authentication requirements
///
/// This class manages route access based on user authentication status
/// and provides a centralized way to check permissions.
class RouteGuard {
  static bool _isAuthenticated = false;
  static String? _currentUserId;
  static Map<String, dynamic>? _userPermissions;

  /// Check if user is currently authenticated
  static bool isAuthenticated() {
    return _isAuthenticated;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return _currentUserId;
  }

  /// Set authentication status
  static void setAuthenticated(
    bool authenticated, {
    String? userId,
    Map<String, dynamic>? permissions,
  }) {
    _isAuthenticated = authenticated;
    _currentUserId = userId;
    _userPermissions = permissions;

    debugPrint(
      '🔒 RouteGuard: Authentication status changed to $authenticated',
    );
    if (authenticated && userId != null) {
      debugPrint('🔒 RouteGuard: User $userId authenticated');
    }
  }

  /// Clear authentication data
  static void clearAuth() {
    _isAuthenticated = false;
    _currentUserId = null;
    _userPermissions = null;
    debugPrint('🔒 RouteGuard: Authentication cleared');
  }

  /// Check if user has specific permission
  static bool hasPermission(String permission) {
    if (!_isAuthenticated) return false;
    if (_userPermissions == null)
      return true; // Default allow if no permissions set

    return _userPermissions![permission] == true;
  }

  /// Check if user can access route
  static bool canAccessRoute(String routeName) {
    // Public routes that don't require authentication
    const publicRoutes = [
      '/',
      '/auth',
      '/auth-choice',
      '/login',
      '/register',
      '/onboarding',
    ];

    if (publicRoutes.contains(routeName)) {
      return true;
    }

    // All other routes require authentication
    return _isAuthenticated;
  }

  /// Get redirect route for unauthenticated users
  static String getRedirectRoute() {
    return '/auth-choice';
  }
}
