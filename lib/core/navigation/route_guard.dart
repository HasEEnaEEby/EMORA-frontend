import 'package:flutter/foundation.dart';

class RouteGuard {
  static bool _isAuthenticated = false;
  static String? _currentUserId;
  static Map<String, dynamic>? _userPermissions;

  static bool isAuthenticated() {
    return _isAuthenticated;
  }

  static String? getCurrentUserId() {
    return _currentUserId;
  }

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

  static void clearAuth() {
    _isAuthenticated = false;
    _currentUserId = null;
    _userPermissions = null;
    debugPrint('🔒 RouteGuard: Authentication cleared');
  }

  static bool hasPermission(String permission) {
    if (!_isAuthenticated) return false;
    if (_userPermissions == null)
return true; 

    return _userPermissions![permission] == true;
  }

  static bool canAccessRoute(String routeName) {
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

    return _isAuthenticated;
  }

  static String getRedirectRoute() {
    return '/auth-choice';
  }
}
