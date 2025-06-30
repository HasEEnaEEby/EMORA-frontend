import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/onboarding_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingStepModel>> getOnboardingSteps();
  Future<bool> syncUserOnboardingData(UserOnboardingModel userData);
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
      Logger.info('🌐 Fetching onboarding steps from server...');

      final response = await dioClient.get('/api/onboarding/steps');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response formats
        List<dynamic> stepsData;
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          stepsData = data['data'] as List<dynamic>;
        } else if (data is List) {
          stepsData = data;
        } else {
          throw const ServerException(message: 'Invalid response format');
        }

        final steps = stepsData
            .map(
              (stepJson) => OnboardingStepModel.fromJson(
                stepJson as Map<String, dynamic>,
              ),
            )
            .toList();

        Logger.info('✅ Fetched ${steps.length} onboarding steps from server');
        return steps;
      } else {
        throw ServerException(
          message: 'Server returned status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Network error fetching onboarding steps', e);
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error fetching onboarding steps', e);
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> syncUserOnboardingData(UserOnboardingModel userData) async {
    if (!await networkInfo.isConnected) {
      Logger.warning('📴 No internet - user data sync will be queued');
      return false; // Indicates offline mode
    }

    try {
      Logger.info('🌐 Syncing user onboarding data to server...');

      final response = await dioClient.post(
        '/api/onboarding/user-data',
        data: userData.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ User onboarding data synced successfully');
        return true;
      } else {
        Logger.warning(
          '⚠️ Server returned unexpected status: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      // FIXED: Handle development mode gracefully
      if (e.response?.statusCode == 404) {
        developer.log(
          'User data endpoint not available in development mode',
          name: 'OnboardingRemoteDataSource',
        );
        return false; // Return false but don't throw - let offline-first handle it
      }

      Logger.error('Network error syncing user data', e);
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error syncing user data', e);
      throw ServerException(
        message: 'Failed to sync user data: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> completeOnboarding(UserOnboardingModel userData) async {
    if (!await networkInfo.isConnected) {
      Logger.warning(
        '📴 No internet - onboarding completion will be synced later',
      );
      return false; // Indicates offline mode
    }

    try {
      Logger.info('🌐 Completing onboarding on server...');

      final response = await dioClient.post(
        '/api/onboarding/complete',
        data: userData.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.info('✅ Onboarding completed successfully on server');
        return true;
      } else {
        Logger.warning(
          '⚠️ Server returned unexpected status: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      // FIXED: Handle development mode gracefully
      if (e.response?.statusCode == 404) {
        developer.log(
          'Onboarding completion endpoint not available in development mode',
          name: 'OnboardingRemoteDataSource',
        );
        return false; // Return false but don't throw
      }

      if (e.response?.statusCode == 401) {
        // Expected during onboarding - user hasn't registered yet
        developer.log(
          'Onboarding completion requires authentication - will sync after registration',
          name: 'OnboardingRemoteDataSource',
        );
        return false; // Return false but don't throw
      }

      Logger.error('Network error completing onboarding', e);
      throw _handleDioError(e);
    } catch (e) {
      Logger.error('Unexpected error completing onboarding', e);
      throw ServerException(
        message: 'Failed to complete onboarding: ${e.toString()}',
      );
    }
  }

  // Enhanced error handling
  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout - please try again',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection error - check your internet',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return ValidationException(
              message: 'Invalid data: $message',
              statusCode: statusCode,
            );
          case 401:
            return UnauthorizedException(
              message: 'Unauthorized access',
              statusCode: statusCode,
            );
          case 404:
            return NotFoundException(
              message: 'Resource not found',
              statusCode: statusCode,
            );
          case 500:
            return ServerException(
              message: 'Server error: $message',
              statusCode: statusCode,
            );
          default:
            return ServerException(
              message: 'HTTP $statusCode: $message',
              statusCode: statusCode,
            );
        }

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled');

      default:
        return NetworkException(
          message: 'Network error: ${e.message}',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
