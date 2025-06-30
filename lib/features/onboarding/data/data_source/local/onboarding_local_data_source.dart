import 'dart:convert';

import 'package:emora_mobile_app/features/onboarding/domain/entity/onboarding_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/onboarding_model.dart';

abstract class OnboardingLocalDataSource {
  Future<List<OnboardingStepModel>> getOnboardingSteps();
  Future<List<OnboardingStepModel>> getCachedOnboardingSteps();
  Future<void> cacheOnboardingSteps(List<OnboardingStepModel> steps);
  Future<UserOnboardingModel> getUserOnboardingData();
  Future<bool> saveUserOnboardingData(UserOnboardingModel userData);
  Future<bool> completeOnboarding();
  Future<bool> isOnboardingCompleted();
  Future<void> clearOnboardingData();
  bool isCacheFresh({Duration maxAge = const Duration(hours: 24)});
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  static const String _onboardingStepsKey = 'onboarding_steps';
  static const String _userDataKey = 'user_onboarding_data';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _lastSyncKey = 'onboarding_last_sync';
  static const String _stepsVersionKey = 'onboarding_steps_version';

  @override
  Future<List<OnboardingStepModel>> getOnboardingSteps() async {
    return getCachedOnboardingSteps();
  }

  @override
  Future<List<OnboardingStepModel>> getCachedOnboardingSteps() async {
    try {
      final stepsJson = sharedPreferences.getString(_onboardingStepsKey);
      if (stepsJson != null) {
        final List<dynamic> stepsList = json.decode(stepsJson);
        final steps = stepsList
            .map((step) => OnboardingStepModel.fromJson(step))
            .toList();

        Logger.info('✅ Loaded ${steps.length} cached onboarding steps');
        return steps;
      }

      // Return default steps if none cached
      Logger.info('📋 No cached steps found, using defaults');
      return _getDefaultOnboardingSteps();
    } catch (e) {
      Logger.error('Failed to get cached onboarding steps', e);

      // Fallback to default steps on any error
      Logger.info('🔄 Falling back to default onboarding steps');
      return _getDefaultOnboardingSteps();
    }
  }

  @override
  Future<void> cacheOnboardingSteps(List<OnboardingStepModel> steps) async {
    try {
      final stepsJson = json.encode(
        steps.map((step) => step.toJson()).toList(),
      );

      await Future.wait([
        sharedPreferences.setString(_onboardingStepsKey, stepsJson),
        sharedPreferences.setInt(
          _lastSyncKey,
          DateTime.now().millisecondsSinceEpoch,
        ),
        sharedPreferences.setString(
          _stepsVersionKey,
          DateTime.now().toIso8601String(),
        ),
      ]);

      Logger.info('✅ Cached ${steps.length} onboarding steps successfully');
    } catch (e) {
      Logger.error('Failed to cache onboarding steps', e);
      throw CacheException(
        message: 'Failed to cache onboarding steps: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserOnboardingModel> getUserOnboardingData() async {
    try {
      final userDataJson = sharedPreferences.getString(_userDataKey);
      if (userDataJson != null) {
        final Map<String, dynamic> userData = json.decode(userDataJson);
        final model = UserOnboardingModel.fromJson(userData);
        Logger.info('✅ Retrieved user onboarding data');
        return model;
      }

      // Return empty user data if none exists
      Logger.info('ℹ️ No user onboarding data found, returning empty model');
      return const UserOnboardingModel();
    } catch (e) {
      Logger.error('Failed to get user onboarding data', e);
      throw CacheException(
        message: 'Failed to get user onboarding data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> saveUserOnboardingData(UserOnboardingModel userData) async {
    try {
      final userDataJson = json.encode(userData.toJson());
      final success = await sharedPreferences.setString(
        _userDataKey,
        userDataJson,
      );

      if (success) {
        Logger.info('✅ Saved user onboarding data locally');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to save user onboarding data', e);
      throw CacheException(
        message: 'Failed to save user onboarding data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> completeOnboarding() async {
    try {
      // Get current user data and mark as completed
      final currentUserData = await getUserOnboardingData();
      final completedUserData = UserOnboardingModel(
        username: currentUserData.username,
        pronouns: currentUserData.pronouns,
        ageGroup: currentUserData.ageGroup,
        selectedAvatar: currentUserData.selectedAvatar,
        isCompleted: true,
      );

      // Save both completion flag and updated user data
      final results = await Future.wait([
        sharedPreferences.setBool(_onboardingCompletedKey, true),
        saveUserOnboardingData(completedUserData),
      ]);

      final success = results.every((result) => result == true);

      if (success) {
        Logger.info('✅ Onboarding marked as completed locally');
      }

      return success;
    } catch (e) {
      Logger.error('Failed to complete onboarding', e);
      throw CacheException(
        message: 'Failed to complete onboarding: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      final isCompleted =
          sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
      Logger.info('ℹ️ Onboarding completion status: $isCompleted');
      return isCompleted;
    } catch (e) {
      Logger.error('Failed to check onboarding status', e);
      return false; // Default to false on error
    }
  }

  @override
  Future<void> clearOnboardingData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_userDataKey),
        sharedPreferences.remove(_onboardingCompletedKey),
        sharedPreferences.remove(_onboardingStepsKey),
        sharedPreferences.remove(_lastSyncKey),
        sharedPreferences.remove(_stepsVersionKey),
      ]);
      Logger.info('🗑️ Cleared all onboarding data');
    } catch (e) {
      Logger.error('Failed to clear onboarding data', e);
      throw CacheException(
        message: 'Failed to clear onboarding data: ${e.toString()}',
      );
    }
  }

  @override
  bool isCacheFresh({Duration maxAge = const Duration(hours: 24)}) {
    try {
      final lastSync = sharedPreferences.getInt(_lastSyncKey);
      if (lastSync == null) return false;

      final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
      final now = DateTime.now();

      final isFresh = now.difference(lastSyncTime) < maxAge;
      Logger.info(
        '🔍 Cache freshness check: $isFresh (age: ${now.difference(lastSyncTime).inHours}h)',
      );
      return isFresh;
    } catch (e) {
      Logger.error('Error checking cache freshness', e);
      return false;
    }
  }

  List<OnboardingStepModel> _getDefaultOnboardingSteps() {
    return [
      const OnboardingStepModel(
        stepNumber: 1,
        title: 'Welcome to',
        subtitle: 'Emora!',
        description: 'What do you want us to call you?',
        type: OnboardingStepType.welcome,
      ),
      const OnboardingStepModel(
        stepNumber: 2,
        title: 'Hello!',
        subtitle: 'How can we refer to you?',
        description:
            'We\'ve committed to creating a welcoming experience for members of all gender identities.',
        type: OnboardingStepType.pronouns,
        data: {
          'options': ['She / Her', 'He / Him', 'They / Them', 'Other'],
        },
      ),
      const OnboardingStepModel(
        stepNumber: 3,
        title: 'Thanks!',
        subtitle: 'How old are you?',
        description:
            'We want to tailor your experience — your age helps us do that better.',
        type: OnboardingStepType.age,
        data: {
          'options': ['less than 20s', '20s', '30s', '40s', '50s and above'],
        },
      ),
      const OnboardingStepModel(
        stepNumber: 4,
        title: 'Lastly, choose your',
        subtitle: 'avatar!',
        description:
            'We\'d like you to express yourself through your favorite animal — you can change it anytime.',
        type: OnboardingStepType.avatar,
        data: {
          'avatars': [
            'panda',
            'elephant',
            'horse',
            'rabbit',
            'fox',
            'zebra',
            'bear',
            'pig',
            'raccoon',
          ],
        },
      ),
      const OnboardingStepModel(
        stepNumber: 5,
        title: 'Congrats,',
        subtitle: 'User!',
        description: 'You\'re free to express yourself',
        type: OnboardingStepType.completion,
      ),
    ];
  }
}
