// ============================================================================
// lib/core/services/connectivity_service.dart
// Complete connectivity service with banner management and network monitoring
// ============================================================================
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../navigation/navigation_service.dart';
import '../network/network_info.dart';
import '../utils/logger.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  ConnectivityService._internal();

  // Banner management
  static bool _isOfflineBannerShowing = false;
  static bool _isSyncBannerShowing = false;
  static OverlayEntry? _offlineBannerEntry;
  static OverlayEntry? _syncBannerEntry;

  // Network monitoring
  StreamSubscription<InternetConnectionStatus>? _networkSubscription;
  NetworkInfo? _networkInfo;
  bool _isInitialized = false;
  bool _isCurrentlyOnline = true;

  // Callbacks
  final List<VoidCallback> _onConnectedCallbacks = [];
  final List<VoidCallback> _onDisconnectedCallbacks = [];

  /// Initialize the connectivity service with network monitoring
  Future<void> initialize(NetworkInfo networkInfo) async {
    if (_isInitialized) return;

    _networkInfo = networkInfo;
    _isInitialized = true;

    Logger.info('🔗 Initializing connectivity service...');

    try {
      // Check initial connection status
      _isCurrentlyOnline = await networkInfo.isConnected;
      Logger.info(
        '📶 Initial connection status: ${_isCurrentlyOnline ? "Online" : "Offline"}',
      );

      // Start listening to network changes
      _networkSubscription = networkInfo.connectionStream.listen(
        _onNetworkStatusChanged,
        onError: (error) {
          Logger.error('Network monitoring error', error);
        },
      );

      // Show initial offline banner if needed
      if (!_isCurrentlyOnline) {
        showOfflineBanner();
      }

      Logger.info('✅ Connectivity service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize connectivity service', e);
    }
  }

  /// Handle network status changes
  void _onNetworkStatusChanged(InternetConnectionStatus status) {
    final wasOnline = _isCurrentlyOnline;
    _isCurrentlyOnline = status == InternetConnectionStatus.connected;

    Logger.info('📶 Network status changed: ${status.name}');

    if (!wasOnline && _isCurrentlyOnline) {
      // Just connected
      _onConnected();
    } else if (wasOnline && !_isCurrentlyOnline) {
      // Just disconnected
      _onDisconnected();
    }
  }

  /// Handle connection established
  void _onConnected() {
    Logger.info('🌐 Connected to internet');

    hideOfflineBanner();

    // Notify callbacks
    for (final callback in _onConnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        Logger.error('Error in connected callback', e);
      }
    }
  }

  /// Handle connection lost
  void _onDisconnected() {
    Logger.info('📴 Disconnected from internet');

    hideSyncBanner();
    showOfflineBanner();

    // Notify callbacks
    for (final callback in _onDisconnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        Logger.error('Error in disconnected callback', e);
      }
    }
  }

  /// Register callback for when connection is established
  void onConnected(VoidCallback callback) {
    _onConnectedCallbacks.add(callback);
  }

  /// Register callback for when connection is lost
  void onDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.add(callback);
  }

  /// Remove connection callback
  void removeOnConnected(VoidCallback callback) {
    _onConnectedCallbacks.remove(callback);
  }

  /// Remove disconnection callback
  void removeOnDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.remove(callback);
  }

  /// Get current connection status
  bool get isOnline => _isCurrentlyOnline;

  /// Check connection status asynchronously
  Future<bool> checkConnection() async {
    if (_networkInfo == null) {
      Logger.warning('Network info not initialized');
      return false;
    }

    try {
      final isConnected = await _networkInfo!.isConnected;
      _isCurrentlyOnline = isConnected;
      return isConnected;
    } catch (e) {
      Logger.error('Error checking connection', e);
      return false;
    }
  }

  /// Show offline banner at the top of the screen
  static void showOfflineBanner({
    String? customMessage,
    Duration? autoDismiss,
  }) {
    if (_isOfflineBannerShowing) return;

    final context = NavigationService.currentContext;
    if (context == null) {
      Logger.warning('No context available for offline banner');
      return;
    }

    _isOfflineBannerShowing = true;
    Logger.info('📴 Showing offline banner');

    _offlineBannerEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customMessage ??
                          'You\'re offline. Data will sync when connected.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: hideOfflineBanner,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      Overlay.of(context).insert(_offlineBannerEntry!);

      // Auto dismiss if specified
      if (autoDismiss != null) {
        Future.delayed(autoDismiss, () {
          hideOfflineBanner();
        });
      }
    } catch (e) {
      Logger.error('Failed to show offline banner', e);
      _isOfflineBannerShowing = false;
      _offlineBannerEntry = null;
    }
  }

  /// Show sync success banner
  static void showSyncSuccessBanner({
    int syncedCount = 1,
    String? customMessage,
    Duration autoDismiss = const Duration(seconds: 3),
  }) {
    final context = NavigationService.currentContext;
    if (context == null) {
      Logger.warning('No context available for sync success banner');
      return;
    }

    // Don't show if already showing
    if (_isSyncBannerShowing) return;

    _isSyncBannerShowing = true;
    Logger.info('✅ Showing sync success banner');

    _syncBannerEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.cloud_done, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customMessage ??
                          'Synced $syncedCount operation${syncedCount != 1 ? 's' : ''} successfully',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      Overlay.of(context).insert(_syncBannerEntry!);

      // Auto dismiss
      Future.delayed(autoDismiss, () {
        hideSyncBanner();
      });
    } catch (e) {
      Logger.error('Failed to show sync success banner', e);
      _isSyncBannerShowing = false;
      _syncBannerEntry = null;
    }
  }

  /// Show sync in progress banner
  static void showSyncInProgressBanner({
    int pendingCount = 1,
    String? customMessage,
    VoidCallback? onRetryPressed,
  }) {
    final context = NavigationService.currentContext;
    if (context == null) {
      Logger.warning('No context available for sync progress banner');
      return;
    }

    // Don't show if already showing
    if (_isSyncBannerShowing) return;

    _isSyncBannerShowing = true;
    Logger.info('🔄 Showing sync in progress banner');

    _syncBannerEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customMessage ??
                          'Syncing $pendingCount operation${pendingCount != 1 ? 's' : ''}...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onRetryPressed != null)
                    TextButton(
                      onPressed: () {
                        onRetryPressed();
                        hideSyncBanner();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      Overlay.of(context).insert(_syncBannerEntry!);
    } catch (e) {
      Logger.error('Failed to show sync progress banner', e);
      _isSyncBannerShowing = false;
      _syncBannerEntry = null;
    }
  }

  /// Show sync error banner
  static void showSyncErrorBanner({
    String? customMessage,
    VoidCallback? onRetryPressed,
    Duration autoDismiss = const Duration(seconds: 5),
  }) {
    final context = NavigationService.currentContext;
    if (context == null) {
      Logger.warning('No context available for sync error banner');
      return;
    }

    // Don't show if already showing
    if (_isSyncBannerShowing) return;

    _isSyncBannerShowing = true;
    Logger.info('❌ Showing sync error banner');

    _syncBannerEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(Icons.sync_problem, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customMessage ?? 'Sync failed. Will retry automatically.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onRetryPressed != null)
                    TextButton(
                      onPressed: () {
                        onRetryPressed();
                        hideSyncBanner();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Retry Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      Overlay.of(context).insert(_syncBannerEntry!);

      // Auto dismiss
      Future.delayed(autoDismiss, () {
        hideSyncBanner();
      });
    } catch (e) {
      Logger.error('Failed to show sync error banner', e);
      _isSyncBannerShowing = false;
      _syncBannerEntry = null;
    }
  }

  /// Hide offline banner
  static void hideOfflineBanner() {
    if (_isOfflineBannerShowing && _offlineBannerEntry != null) {
      Logger.info('🌐 Hiding offline banner');
      try {
        _offlineBannerEntry!.remove();
      } catch (e) {
        Logger.error('Error removing offline banner', e);
      }
      _offlineBannerEntry = null;
      _isOfflineBannerShowing = false;
    }
  }

  /// Hide sync banner
  static void hideSyncBanner() {
    if (_isSyncBannerShowing && _syncBannerEntry != null) {
      Logger.info('📱 Hiding sync banner');
      try {
        _syncBannerEntry!.remove();
      } catch (e) {
        Logger.error('Error removing sync banner', e);
      }
      _syncBannerEntry = null;
      _isSyncBannerShowing = false;
    }
  }

  /// Hide all banners
  static void hideAllBanners() {
    hideOfflineBanner();
    hideSyncBanner();
  }

  /// Check if any banner is currently showing
  static bool get isBannerShowing =>
      _isOfflineBannerShowing || _isSyncBannerShowing;

  /// Check if offline banner is showing
  static bool get isOfflineBannerShowing => _isOfflineBannerShowing;

  /// Check if sync banner is showing
  static bool get isSyncBannerShowing => _isSyncBannerShowing;

  /// Show a custom snackbar for connectivity messages
  static void showConnectivitySnackBar({
    required String message,
    required ConnectivityMessageType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? action,
    String? actionLabel,
  }) {
    final context = NavigationService.currentContext;
    if (context == null) return;

    Color backgroundColor;
    IconData icon;

    switch (type) {
      case ConnectivityMessageType.offline:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.wifi_off;
        break;
      case ConnectivityMessageType.online:
        backgroundColor = Colors.green.shade600;
        icon = Icons.wifi;
        break;
      case ConnectivityMessageType.syncing:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.sync;
        break;
      case ConnectivityMessageType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: action != null && actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: action,
              )
            : null,
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    Logger.info('🗑️ Disposing connectivity service...');

    _networkSubscription?.cancel();
    _networkSubscription = null;

    hideAllBanners();

    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();

    _isInitialized = false;
    _networkInfo = null;

    Logger.info('✅ Connectivity service disposed');
  }

  /// Reset the singleton instance (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}

// ============================================================================
// Supporting Enums and Classes
// ============================================================================

enum ConnectivityMessageType { offline, online, syncing, error }

class ConnectivityStatus {
  final bool isOnline;
  final DateTime lastChecked;
  final String? lastError;

  ConnectivityStatus({
    required this.isOnline,
    required this.lastChecked,
    this.lastError,
  });

  @override
  String toString() {
    return 'ConnectivityStatus(isOnline: $isOnline, lastChecked: $lastChecked, lastError: $lastError)';
  }
}

// ============================================================================
// Connectivity Widget Helper
// ============================================================================

class ConnectivityBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;
  final Widget? offlineChild;
  final Widget? onlineChild;

  const ConnectivityBuilder({
    super.key,
    required this.builder,
    this.offlineChild,
    this.onlineChild,
  });

  @override
  State<ConnectivityBuilder> createState() => _ConnectivityBuilderState();
}

class _ConnectivityBuilderState extends State<ConnectivityBuilder> {
  bool _isOnline = true;
  late ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService.instance;
    _isOnline = _connectivityService.isOnline;

    _connectivityService.onConnected(_onConnected);
    _connectivityService.onDisconnected(_onDisconnected);
  }

  @override
  void dispose() {
    _connectivityService.removeOnConnected(_onConnected);
    _connectivityService.removeOnDisconnected(_onDisconnected);
    super.dispose();
  }

  void _onConnected() {
    if (mounted) {
      setState(() => _isOnline = true);
    }
  }

  void _onDisconnected() {
    if (mounted) {
      setState(() => _isOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onlineChild != null && widget.offlineChild != null) {
      return _isOnline ? widget.onlineChild! : widget.offlineChild!;
    }

    return widget.builder(context, _isOnline);
  }
}
