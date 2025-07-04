import 'package:dio/dio.dart';

import '../../../../../core/constants/backend_mapping.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/onboarding_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingStepModel>> getOnboardingSteps();
  Future<bool> saveUserData(UserOnboardingModel userData);
  Future<bool> completeOnboarding(UserOnboardingModel userData);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  OnboardingRemoteDataSourceImpl({
    required this.dioClient,
    required this.networkInfo,
  });

  @override
  Future<List<OnboardingStepModel>> getOnboardingSteps() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      final response = await dioClient.get('/api/onboarding/steps');

      if (response.statusCode == 200) {
        final List<dynamic> stepsData = response.data['data'];
        return stepsData
            .map((step) => OnboardingStepModel.fromJson(step))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to get onboarding steps',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Error getting onboarding steps', e);
      if (e.response?.statusCode == 404) {
        // Handle gracefully in development mode
        Logger.info('Onboarding steps endpoint not available - using defaults');
        return [];
      }
      throw ServerException(
        message: 'Failed to get onboarding steps: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected error getting onboarding steps', e);
      throw ServerException(
        message: 'Failed to get onboarding steps: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> saveUserData(UserOnboardingModel userData) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      // FIXED: Send pronouns directly without transformation
      final requestData = <String, dynamic>{
        'username': userData.username,
        'pronouns': userData.pronouns, // Send directly without transformation
        'ageGroup': BackendValues.getBackendAgeGroup(userData.ageGroup),
        'selectedAvatar': BackendValues.getBackendAvatar(userData.selectedAvatar),
        'isCompleted': userData.isCompleted,
        'completedAt': userData.completedAt?.toIso8601String(),
        'additionalData': userData.additionalData,
      };

      Logger.info(
        '🌐 Syncing user onboarding data to server...',
      );
      Logger.info(
        '📤 Using backend-mapped values: pronouns="${requestData['pronouns']}", ageGroup="${requestData['ageGroup']}", avatar="${requestData['selectedAvatar']}"',
      );

      final response = await dioClient.post(
        '/api/onboarding/user-data',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ User data saved successfully to server');
        return true;
      } else {
        throw ServerException(
          message: 'Failed to save user data',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Network error syncing user data', e);
      if (e.response?.statusCode == 400) {
        // Parse validation errors from backend
        final responseData = e.response?.data;
        if (responseData != null && responseData['errors'] != null) {
          final errors = responseData['errors'] as List;
          final errorMessages = errors
              .map((error) => error['msg'] as String)
              .toList();
          throw ServerException(
            message: errorMessages.join(', '),
            statusCode: e.response?.statusCode,
          );
        }
        throw ServerException(
          message: 'Validation failed. Please check your input.',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        message: 'Failed to save user data: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected error saving user data', e);
      throw ServerException(
        message: 'Failed to save user data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> completeOnboarding(UserOnboardingModel userData) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      // FIXED: Send pronouns directly without transformation
      final requestData = <String, dynamic>{
        'username': userData.username,
        'pronouns': userData.pronouns, // Send directly without transformation
        'ageGroup': BackendValues.getBackendAgeGroup(userData.ageGroup),
        'selectedAvatar': BackendValues.getBackendAvatar(userData.selectedAvatar),
        'isCompleted': true,
        'completedAt': userData.completedAt?.toIso8601String(),
        'additionalData': userData.additionalData,
      };

      Logger.info(
        '🌐 Completing onboarding on server...',
      );
      Logger.info(
        '📤 Using backend-mapped values: pronouns="${requestData['pronouns']}", ageGroup="${requestData['ageGroup']}", avatar="${requestData['selectedAvatar']}"',
      );

      final response = await dioClient.post(
        '/api/onboarding/complete',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ Onboarding skip completed on server');
        return true;
      } else {
        throw ServerException(
          message: 'Failed to complete onboarding',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Network error completing onboarding', e);
      if (e.response?.statusCode == 400) {
        // Parse validation errors from backend
        final responseData = e.response?.data;
        if (responseData != null && responseData['errors'] != null) {
          final errors = responseData['errors'] as List;
          final errorMessages = errors
              .map((error) => error['msg'] as String)
              .toList();
          throw ServerException(
            message: errorMessages.join(', '),
            statusCode: e.response?.statusCode,
          );
        }
        throw ServerException(
          message: 'Validation failed. Please check your input.',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        message: 'Failed to complete onboarding: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected error completing onboarding', e);
      throw ServerException(
        message: 'Failed to complete onboarding: ${e.toString()}',
      );
    }
  }
}
