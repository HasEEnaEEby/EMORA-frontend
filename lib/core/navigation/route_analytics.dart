import 'package:flutter/foundation.dart';

/// Route analytics for tracking navigation patterns
///
/// This class provides analytics tracking for navigation events
/// to help understand user behavior and app performance.
class RouteAnalytics {
  static final List<NavigationEvent> _navigationHistory = [];
  static final Map<String, int> _routeVisitCounts = {};
  static final Map<String, Duration> _routeDurations = {};
  static DateTime? _lastNavigationTime;

  /// Track navigation to a route
  static void trackNavigation(String routeName, Object? arguments) {
    final now = DateTime.now();

    // Calculate time spent on previous route
    if (_lastNavigationTime != null) {
      final timeSpent = now.difference(_lastNavigationTime!);
      _updateRouteDuration(_getLastRoute(), timeSpent);
    }

    // Record navigation event
    final event = NavigationEvent(
      routeName: routeName,
      timestamp: now,
      arguments: arguments,
    );

    _navigationHistory.add(event);
    _routeVisitCounts[routeName] = (_routeVisitCounts[routeName] ?? 0) + 1;
    _lastNavigationTime = now;

    // Log in debug mode
    if (kDebugMode) {
      debugPrint('. RouteAnalytics: Navigated to $routeName');
      debugPrint('. Visit count: ${_routeVisitCounts[routeName]}');
    }

    // Keep history manageable (last 100 events)
    if (_navigationHistory.length > 100) {
      _navigationHistory.removeAt(0);
    }
  }

  /// Track route error
  static void trackRouteError(String routeName, String error) {
    final event = NavigationEvent(
      routeName: routeName,
      timestamp: DateTime.now(),
      isError: true,
      errorMessage: error,
    );

    _navigationHistory.add(event);

    if (kDebugMode) {
      debugPrint('. RouteAnalytics: Error on $routeName - $error');
    }
  }

  /// Get navigation statistics
  static NavigationStats getStats() {
    return NavigationStats(
      totalNavigations: _navigationHistory.length,
      routeVisitCounts: Map.from(_routeVisitCounts),
      routeDurations: Map.from(_routeDurations),
      navigationHistory: List.from(_navigationHistory),
    );
  }

  /// Get most visited routes
  static List<String> getMostVisitedRoutes({int limit = 5}) {
    final sorted = _routeVisitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// Get average time spent on route
  static Duration? getAverageTimeOnRoute(String routeName) {
    return _routeDurations[routeName];
  }

  /// Clear analytics data
  static void clearData() {
    _navigationHistory.clear();
    _routeVisitCounts.clear();
    _routeDurations.clear();
    _lastNavigationTime = null;

    if (kDebugMode) {
      debugPrint('. RouteAnalytics: Data cleared');
    }
  }

  /// Export analytics data for external analysis
  static Map<String, dynamic> exportData() {
    return {
      'totalNavigations': _navigationHistory.length,
      'routeVisitCounts': _routeVisitCounts,
      'routeDurations': _routeDurations.map(
        (key, value) => MapEntry(key, value.inMilliseconds),
      ),
      'navigationHistory': _navigationHistory.map((e) => e.toJson()).toList(),
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }

  // Helper methods
  static void _updateRouteDuration(String? routeName, Duration duration) {
    if (routeName == null) return;

    final currentDuration = _routeDurations[routeName];
    if (currentDuration == null) {
      _routeDurations[routeName] = duration;
    } else {
      // Calculate moving average
      final visitCount = _routeVisitCounts[routeName] ?? 1;
      final totalMs =
          (currentDuration.inMilliseconds * (visitCount - 1)) +
          duration.inMilliseconds;
      _routeDurations[routeName] = Duration(
        milliseconds: totalMs ~/ visitCount,
      );
    }
  }

  static String? _getLastRoute() {
    if (_navigationHistory.isEmpty) return null;
    return _navigationHistory.last.routeName;
  }
}

/// Navigation event data class
class NavigationEvent {
  final String routeName;
  final DateTime timestamp;
  final Object? arguments;
  final bool isError;
  final String? errorMessage;

  const NavigationEvent({
    required this.routeName,
    required this.timestamp,
    this.arguments,
    this.isError = false,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'routeName': routeName,
      'timestamp': timestamp.toIso8601String(),
      'arguments': arguments?.toString(),
      'isError': isError,
      'errorMessage': errorMessage,
    };
  }
}

/// Navigation statistics data class
class NavigationStats {
  final int totalNavigations;
  final Map<String, int> routeVisitCounts;
  final Map<String, Duration> routeDurations;
  final List<NavigationEvent> navigationHistory;

  const NavigationStats({
    required this.totalNavigations,
    required this.routeVisitCounts,
    required this.routeDurations,
    required this.navigationHistory,
  });

  @override
  String toString() {
    return 'NavigationStats('
        'totalNavigations: $totalNavigations, '
        'uniqueRoutes: ${routeVisitCounts.length}, '
        'mostVisited: ${_getMostVisited()}'
        ')';
  }

  String _getMostVisited() {
    if (routeVisitCounts.isEmpty) return 'none';

    final sorted = routeVisitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '${sorted.first.key} (${sorted.first.value} visits)';
  }
}
