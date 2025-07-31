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

  static bool _isOfflineBannerShowing = false;
  static bool _isSyncBannerShowing = false;
  static OverlayEntry? _offlineBannerEntry;
  static OverlayEntry? _syncBannerEntry;

  StreamSubscription<InternetConnectionStatus>? _networkSubscription;
  NetworkInfo? _networkInfo;
  bool _isInitialized = false;
  bool _isCurrentlyOnline = true;

  final List<VoidCallback> _onConnectedCallbacks = [];
  final List<VoidCallback> _onDisconnectedCallbacks = [];

  Future<void> initialize(NetworkInfo networkInfo) async {
    if (_isInitialized) return;

    _networkInfo = networkInfo;
    _isInitialized = true;

    Logger.info('🔗 Initializing connectivity service...');

    try {
      _isCurrentlyOnline = await networkInfo.isConnected;
      Logger.info(
        '📶 Initial connection status: ${_isCurrentlyOnline ? "Online" : "Offline"}',
      );

      _networkSubscription = networkInfo.connectionStream.listen(
        _onNetworkStatusChanged,
        onError: (error) {
          Logger.error('Network monitoring error', error);
        },
      );

      if (!_isCurrentlyOnline) {
        showOfflineBanner();
      }

      Logger.info('. Connectivity service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize connectivity service', e);
    }
  }

  void _onNetworkStatusChanged(InternetConnectionStatus status) {
    final wasOnline = _isCurrentlyOnline;
    _isCurrentlyOnline = status == InternetConnectionStatus.connected;

    Logger.info('📶 Network status changed: ${status.name}');

    if (!wasOnline && _isCurrentlyOnline) {
      _onConnected();
    } else if (wasOnline && !_isCurrentlyOnline) {
      _onDisconnected();
    }
  }

  void _onConnected() {
    Logger.info('🌐 Connected to internet');

    hideOfflineBanner();

    for (final callback in _onConnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        Logger.error('Error in connected callback', e);
      }
    }
  }

  void _onDisconnected() {
    Logger.info('📴 Disconnected from internet');

    hideSyncBanner();
    showOfflineBanner();

    for (final callback in _onDisconnectedCallbacks) {
      try {
        callback();
      } catch (e) {
        Logger.error('Error in disconnected callback', e);
      }
    }
  }

  void onConnected(VoidCallback callback) {
    _onConnectedCallbacks.add(callback);
  }

  void onDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.add(callback);
  }

  void removeOnConnected(VoidCallback callback) {
    _onConnectedCallbacks.remove(callback);
  }

  void removeOnDisconnected(VoidCallback callback) {
    _onDisconnectedCallbacks.remove(callback);
  }

  bool get isOnline => _isCurrentlyOnline;

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

    if (_isSyncBannerShowing) return;

    _isSyncBannerShowing = true;
    Logger.info('. Showing sync success banner');

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

      Future.delayed(autoDismiss, () {
        hideSyncBanner();
      });
    } catch (e) {
      Logger.error('Failed to show sync success banner', e);
      _isSyncBannerShowing = false;
      _syncBannerEntry = null;
    }
  }

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

    if (_isSyncBannerShowing) return;

    _isSyncBannerShowing = true;
    Logger.info('. Showing sync error banner');

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

      Future.delayed(autoDismiss, () {
        hideSyncBanner();
      });
    } catch (e) {
      Logger.error('Failed to show sync error banner', e);
      _isSyncBannerShowing = false;
      _syncBannerEntry = null;
    }
  }

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

  static void hideAllBanners() {
    hideOfflineBanner();
    hideSyncBanner();
  }

  static bool get isBannerShowing =>
      _isOfflineBannerShowing || _isSyncBannerShowing;

  static bool get isOfflineBannerShowing => _isOfflineBannerShowing;

  static bool get isSyncBannerShowing => _isSyncBannerShowing;

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

  void dispose() {
    Logger.info('🗑️ Disposing connectivity service...');

    _networkSubscription?.cancel();
    _networkSubscription = null;

    hideAllBanners();

    _onConnectedCallbacks.clear();
    _onDisconnectedCallbacks.clear();

    _isInitialized = false;
    _networkInfo = null;

    Logger.info('. Connectivity service disposed');
  }

  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
}


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
