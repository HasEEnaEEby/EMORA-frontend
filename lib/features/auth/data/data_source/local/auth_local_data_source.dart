import 'dart:convert';

import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> saveUserData(UserModel user);
  Future<UserModel?> getUserData();
Future<UserModel?> getCurrentUser(); 
  Future<void> clearAuthData();
  Future<bool> hasEverBeenLoggedIn();
  Future<void> markAsLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      final success = await sharedPreferences.setString(
        AppConfig.authTokenKey,
        token,
      );
      if (!success) {
        throw CacheException(message: 'Failed to save auth token');
      }
      Logger.info('. Auth token saved successfully');
    } catch (e) {
      Logger.error('. Failed to save auth token', e);
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      final token = sharedPreferences.getString(AppConfig.authTokenKey);
      Logger.info(
        '🔑 Retrieved auth token: ${token != null ? 'Found' : 'Not found'}',
      );
      return token;
    } catch (e) {
      Logger.error('. Failed to get auth token', e);
      return null;
    }
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final success = await sharedPreferences.setString(
        AppConfig.refreshTokenKey,
        refreshToken,
      );
      if (!success) {
        throw CacheException(message: 'Failed to save refresh token');
      }
      Logger.info('. Refresh token saved successfully');
    } catch (e) {
      Logger.error('. Failed to save refresh token', e);
      throw CacheException(message: 'Failed to save refresh token: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = sharedPreferences.getString(AppConfig.refreshTokenKey);
      Logger.info(
        '🔄 Retrieved refresh token: ${token != null ? 'Found' : 'Not found'}',
      );
      return token;
    } catch (e) {
      Logger.error('. Failed to get refresh token', e);
      return null;
    }
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      final success = await sharedPreferences.setString(
        AppConfig.userDataKey,
        userJson,
      );
      if (!success) {
        throw CacheException(message: 'Failed to save user data');
      }
      Logger.info('. User data saved successfully');
    } catch (e) {
      Logger.error('. Failed to save user data', e);
      throw CacheException(message: 'Failed to save user data: $e');
    }
  }

  @override
  Future<UserModel?> getUserData() async {
    try {
      final userJson = sharedPreferences.getString(AppConfig.userDataKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        Logger.info('. Retrieved user data: ${user.username}');
        return user;
      }
      Logger.info('. No user data found');
      return null;
    } catch (e) {
      Logger.error('. Failed to get user data', e);
      return null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConfig.userDataKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        Logger.info('. Retrieved current user: ${user.username}');
        return user;
      }
      Logger.info('. No current user found');
      return null;
    } catch (e) {
      Logger.error('. Failed to get current user', e);
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(AppConfig.authTokenKey),
        sharedPreferences.remove(AppConfig.refreshTokenKey),
        sharedPreferences.remove(AppConfig.userDataKey),
      ]);
      Logger.info('🗑️ Auth data cleared successfully');
    } catch (e) {
      Logger.error('. Failed to clear auth data', e);
      throw CacheException(message: 'Failed to clear auth data: $e');
    }
  }

  @override
  Future<bool> hasEverBeenLoggedIn() async {
    try {
      final hasBeenLoggedIn =
          sharedPreferences.getBool(AppConfig.hasEverBeenLoggedInKey) ?? false;
      Logger.info('. Has ever been logged in: $hasBeenLoggedIn');
      return hasBeenLoggedIn;
    } catch (e) {
      Logger.error('. Failed to check login history', e);
      return false;
    }
  }

  @override
  Future<void> markAsLoggedIn() async {
    try {
      await sharedPreferences.setBool(AppConfig.hasEverBeenLoggedInKey, true);
      Logger.info('. Marked as logged in');
    } catch (e) {
      Logger.error('. Failed to mark as logged in', e);
    }
  }
}
