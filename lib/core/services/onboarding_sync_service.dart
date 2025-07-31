import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/data/data_source/remote/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/model/onboarding_model.dart';
import '../network/network_info.dart';
import '../utils/logger.dart';

class OnboardingSyncService {
  final OnboardingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  static const String _pendingUserDataKey = 'pending_user_data_sync';
  static const String _pendingCompletionKey = 'pending_completion_sync';
  static const String _lastSyncAttemptKey = 'last_sync_attempt';

  Timer? _syncTimer;
  StreamSubscription? _networkSubscription;

  OnboardingSyncService({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  void initialize() {
    Logger.info('🔄 Initializing onboarding sync service...');

    _networkSubscription = networkInfo.connectionStream.listen((status) {
      if (status.name == 'connected') {
        Logger.info('🌐 Network connected - starting onboarding sync...');
        _performSync();
      }
    });

    networkInfo.isConnected.then((isConnected) {
      if (isConnected) {
        _performSync();
      }
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _performSync();
    });
  }

  Future<void> queueUserDataSync(UserOnboardingModel userData) async {
    try {
      final userDataJson = json.encode(userData.toJson());
      await sharedPreferences.setString(_pendingUserDataKey, userDataJson);
      Logger.info('📝 Queued user data for sync');

      if (await networkInfo.isConnected) {
        _performSync();
      }
    } catch (e) {
      Logger.error('Failed to queue user data sync', e);
    }
  }

  Future<void> queueCompletionSync(UserOnboardingModel userData) async {
    try {
      final userDataJson = json.encode(userData.toJson());
      await sharedPreferences.setString(_pendingCompletionKey, userDataJson);
      Logger.info('📝 Queued onboarding completion for sync');

      if (await networkInfo.isConnected) {
        _performSync();
      }
    } catch (e) {
      Logger.error('Failed to queue completion sync', e);
    }
  }

  Future<void> _performSync() async {
    try {
      if (!await networkInfo.isConnected) {
        Logger.info('📴 No internet connection - skipping sync');
        return;
      }

      await sharedPreferences.setInt(
        _lastSyncAttemptKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      bool hasPendingOperations = false;
      int successfulSyncs = 0;

      final pendingUserData = sharedPreferences.getString(_pendingUserDataKey);
      if (pendingUserData != null) {
        hasPendingOperations = true;
        if (await _syncUserData(pendingUserData)) {
          await sharedPreferences.remove(_pendingUserDataKey);
          successfulSyncs++;
          Logger.info('. User data synced and removed from queue');
        }
      }

      final pendingCompletion = sharedPreferences.getString(
        _pendingCompletionKey,
      );
      if (pendingCompletion != null) {
        hasPendingOperations = true;
        if (await _syncCompletion(pendingCompletion)) {
          await sharedPreferences.remove(_pendingCompletionKey);
          successfulSyncs++;
          Logger.info('. Onboarding completion synced and removed from queue');
        }
      }

      if (!hasPendingOperations) {
        Logger.info('. No pending onboarding operations');
      } else if (successfulSyncs > 0) {
        Logger.info(
          '🎉 Successfully synced $successfulSyncs onboarding operations',
        );
      }
    } catch (e) {
      Logger.error('Onboarding sync operation failed', e);
    }
  }

  Future<bool> _syncUserData(String userDataJson) async {
    try {
      final userData = UserOnboardingModel.fromJson(json.decode(userDataJson));
      final success = await remoteDataSource.saveUserData(userData);

      if (success) {
        Logger.info('. User data synced successfully');
      } else {
        Logger.warning('. User data sync returned false');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to sync user data', e);
      return false;
    }
  }

  Future<bool> _syncCompletion(String userDataJson) async {
    try {
      final userData = UserOnboardingModel.fromJson(json.decode(userDataJson));
      final success = await remoteDataSource.completeOnboarding(userData);

      if (success) {
        Logger.info('. Onboarding completion synced successfully');
      } else {
        Logger.warning('. Onboarding completion sync returned false');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to sync onboarding completion', e);
      return false;
    }
  }

  Future<OnboardingSyncStatus> getSyncStatus() async {
    final hasPendingUserData =
        sharedPreferences.getString(_pendingUserDataKey) != null;
    final hasPendingCompletion =
        sharedPreferences.getString(_pendingCompletionKey) != null;
    final lastSyncAttempt = sharedPreferences.getInt(_lastSyncAttemptKey);
    final isConnected = await networkInfo.isConnected;

    return OnboardingSyncStatus(
      hasPendingOperations: hasPendingUserData || hasPendingCompletion,
      hasPendingUserData: hasPendingUserData,
      hasPendingCompletion: hasPendingCompletion,
      lastSyncAttempt: lastSyncAttempt != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncAttempt)
          : null,
      isConnected: isConnected,
    );
  }

  Future<void> forceSyncNow() async {
    Logger.info('🔄 Force sync requested...');
    await _performSync();
  }

  Future<void> clearPendingOperations() async {
    await Future.wait([
      sharedPreferences.remove(_pendingUserDataKey),
      sharedPreferences.remove(_pendingCompletionKey),
    ]);
    Logger.info('🗑️ Cleared all pending onboarding sync operations');
  }

  void dispose() {
    _syncTimer?.cancel();
    _networkSubscription?.cancel();
    Logger.info('🔄 Onboarding sync service disposed');
  }
}

class OnboardingSyncStatus {
  final bool hasPendingOperations;
  final bool hasPendingUserData;
  final bool hasPendingCompletion;
  final DateTime? lastSyncAttempt;
  final bool isConnected;

  OnboardingSyncStatus({
    required this.hasPendingOperations,
    required this.hasPendingUserData,
    required this.hasPendingCompletion,
    required this.lastSyncAttempt,
    required this.isConnected,
  });

  bool get isFullySynced => !hasPendingOperations && isConnected;
  bool get hasFailedOperations =>
      hasPendingOperations && lastSyncAttempt != null;

  String get statusMessage {
    if (isFullySynced) {
      return 'All onboarding data synced';
    } else if (!isConnected) {
      final pendingCount =
          (hasPendingUserData ? 1 : 0) + (hasPendingCompletion ? 1 : 0);
      return 'Offline - $pendingCount operation${pendingCount != 1 ? 's' : ''} pending';
    } else if (hasFailedOperations) {
      final pendingCount =
          (hasPendingUserData ? 1 : 0) + (hasPendingCompletion ? 1 : 0);
      return '$pendingCount operation${pendingCount != 1 ? 's' : ''} failed to sync';
    } else {
      return 'Syncing onboarding data...';
    }
  }
}
