import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../model/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuthData();
  Future<bool> isLoggedIn();
  // NEW: Check if user has ever been logged in
  Future<bool> hasEverBeenLoggedIn();
  Future<void> markAsLoggedInBefore();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Storage keys
  static const String _hasEverBeenLoggedInKey = 'has_ever_been_logged_in';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveToken(String token) async {
    try {
      final success = await sharedPreferences.setString(
        AppConfig.authTokenKey,
        token,
      );
      if (!success) {
        throw const CacheException(message: 'Failed to save auth token');
      }

      // Mark that user has been logged in before
      await markAsLoggedInBefore();
    } catch (e) {
      throw CacheException(message: 'Failed to save auth token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConfig.authTokenKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get auth token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      final success = await sharedPreferences.setString(
        AppConfig.userDataKey,
        userJson,
      );
      if (!success) {
        throw const CacheException(message: 'Failed to save user data');
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save user data: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = sharedPreferences.getString(AppConfig.userDataKey);
      if (userJson != null) {
        try {
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          return UserModel.fromJson(userMap);
        } catch (e) {
          throw const CacheException(message: 'Failed to parse user data');
        }
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get user data: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(AppConfig.authTokenKey),
        sharedPreferences.remove(AppConfig.userDataKey),
        sharedPreferences.remove(AppConfig.onboardingCompletedKey),
        // NOTE: Don't remove the "ever logged in" flag - we want to remember this
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth data: $e');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasEverBeenLoggedIn() async {
    try {
      return sharedPreferences.getBool(_hasEverBeenLoggedInKey) ?? false;
    } catch (e) {
      // If we can't read the preference, assume false (new user)
      return false;
    }
  }

  @override
  Future<void> markAsLoggedInBefore() async {
    try {
      await sharedPreferences.setBool(_hasEverBeenLoggedInKey, true);
    } catch (e) {
      // This is not critical, so we log but don't throw
      print('Warning: Failed to mark user as logged in before: $e');
    }
  }
}
