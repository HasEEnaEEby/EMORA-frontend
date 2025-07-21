import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/onboarding_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingStepModel>> getCachedOnboardingSteps();
  Future<bool> cacheOnboardingSteps(List<OnboardingStepModel> steps);
  Future<UserOnboardingModel> getUserOnboardingData();
  Future<bool> saveUserOnboardingData(UserOnboardingModel userData);
  Future<bool> completeOnboarding();
  Future<bool> isOnboardingCompleted();
  Future<void> clearOnboardingData();
  bool isCacheFresh();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  // Cache keys
  static const String _cachedStepsKey = 'cached_onboarding_steps';
  static const String _cacheTimestampKey = 'onboarding_cache_timestamp';
  static const String _userDataKey = 'user_onboarding_data';
  static const String _completionKey = 'onboarding_completed';
  static const String _completionTimestampKey = 'onboarding_completed_at';

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OnboardingStepModel>> getCachedOnboardingSteps() async {
    try {
      final stepsJson = sharedPreferences.getString(_cachedStepsKey);

      if (stepsJson != null) {
        final stepsData = jsonDecode(stepsJson) as List;
        final steps = stepsData
            .map((stepData) => OnboardingStepModel.fromJson(stepData))
            .toList();

        Logger.info('📱 Retrieved ${steps.length} cached onboarding steps');
        return steps;
      }

      // Return default steps if no cache
      Logger.info('📱 No cached steps, returning default steps');
      return _getDefaultSteps();
    } catch (e) {
      Logger.error('Error getting cached onboarding steps', e);
      return _getDefaultSteps();
    }
  }

  @override
  Future<bool> cacheOnboardingSteps(List<OnboardingStepModel> steps) async {
    try {
      final stepsData = steps.map((step) => step.toJson()).toList();
      final stepsJson = jsonEncode(stepsData);

      await sharedPreferences.setString(_cachedStepsKey, stepsJson);
      await sharedPreferences.setInt(
        _cacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      Logger.info('. Cached ${steps.length} onboarding steps');
      return true;
    } catch (e) {
      Logger.error('Error caching onboarding steps', e);
      return false;
    }
  }

  @override
  Future<UserOnboardingModel> getUserOnboardingData() async {
    try {
      final userDataJson = sharedPreferences.getString(_userDataKey);

      if (userDataJson != null) {
        final userData = jsonDecode(userDataJson);
        final model = UserOnboardingModel.fromJson(userData);
        Logger.info('📱 Retrieved user onboarding data: ${model.toString()}');
        return model;
      }

      // Return empty user data if none exists
      Logger.info('📱 No cached user data, returning empty model');
      return UserOnboardingModel();
    } catch (e) {
      Logger.error('Error getting user onboarding data', e);
      throw CacheException(message: 'Failed to get user onboarding data: $e');
    }
  }

  @override
  Future<bool> saveUserOnboardingData(UserOnboardingModel userData) async {
    try {
      final userDataJson = jsonEncode(userData.toJson());
      await sharedPreferences.setString(_userDataKey, userDataJson);

      Logger.info('. Saved user onboarding data: ${userData.toString()}');
      return true;
    } catch (e) {
      Logger.error('Error saving user onboarding data', e);
      throw CacheException(message: 'Failed to save user onboarding data: $e');
    }
  }

  @override
  Future<bool> completeOnboarding() async {
    try {
      await sharedPreferences.setBool(_completionKey, true);
      await sharedPreferences.setString(
        _completionTimestampKey,
        DateTime.now().toIso8601String(),
      );

      Logger.info('. Marked onboarding as completed locally');
      return true;
    } catch (e) {
      Logger.error('Error completing onboarding', e);
      throw CacheException(message: 'Failed to complete onboarding: $e');
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final isCompleted = sharedPreferences.getBool(_completionKey) ?? false;
      Logger.info('. Onboarding completion status: $isCompleted');
      return isCompleted;
    } catch (e) {
      Logger.error('Error checking onboarding completion', e);
      return false;
    }
  }

  @override
  Future<void> clearOnboardingData() async {
    try {
      await sharedPreferences.remove(_userDataKey);
      await sharedPreferences.remove(_completionKey);
      await sharedPreferences.remove(_completionTimestampKey);
      // Keep cached steps for reuse

      Logger.info('🧹 Cleared onboarding data');
    } catch (e) {
      Logger.error('Error clearing onboarding data', e);
      throw CacheException(message: 'Failed to clear onboarding data: $e');
    }
  }

  @override
  bool isCacheFresh() {
    try {
      final cacheTimestamp = sharedPreferences.getInt(_cacheTimestampKey);

      if (cacheTimestamp == null) return false;

      final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTimestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheDate);

      final isFresh = difference < AppConfig.cacheValidityDuration;
      Logger.info('. Cache freshness: $isFresh (age: ${difference.inHours}h)');

      return isFresh;
    } catch (e) {
      Logger.error('Error checking cache freshness', e);
      return false;
    }
  }

  // Helper method to get default onboarding steps
  List<OnboardingStepModel> _getDefaultSteps() {
    return [
      OnboardingStepModel(
        stepNumber: 1,
        title: 'Welcome to',
        subtitle: 'Emora!',
        description: 'What do you want us to call you?',
        type: 'welcome',
      ),
      OnboardingStepModel(
        stepNumber: 2,
        title: 'Hey there! What pronouns do you',
        subtitle: 'go by?',
        description:
            'We want everyone to feel seen and respected. Pick the pronouns you\'re most comfortable with.',
        type: 'pronouns',
        data: {'options': AppConfig.availablePronouns},
      ),
      OnboardingStepModel(
        stepNumber: 3,
        title: 'Awesome! How',
        subtitle: 'old are you?',
        description:
            'What\'s your age group? This helps us show the most relevant content for you.',
        type: 'age',
        data: {'options': AppConfig.availableAgeGroups},
      ),
      OnboardingStepModel(
        stepNumber: 4,
        title: 'Lastly, pick',
        subtitle: 'your avatar!',
        description:
            'Choose an avatar that feels like you — it\'s all about personality.',
        type: 'avatar',
        data: {'avatars': AppConfig.availableAvatars},
      ),
      OnboardingStepModel(
        stepNumber: 5,
        title: 'Congrats,',
        subtitle: 'User!',
        description: 'You\'re free to express yourself',
        type: 'completion',
      ),
    ];
  }
}
