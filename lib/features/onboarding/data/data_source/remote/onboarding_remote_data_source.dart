// lib/features/onboarding/data/data_source/remote/onboarding_remote_data_source.dart
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_response_handler.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/onboarding_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<OnboardingStepModel>> getOnboardingSteps();
  Future<bool> saveUserData(UserOnboardingModel userData);
  Future<bool> completeOnboarding(UserOnboardingModel userData);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiService apiService;

  OnboardingRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<OnboardingStepModel>> getOnboardingSteps() async {
    try {
      Logger.info('🌐 Fetching onboarding steps from server...');

      final response = await apiService.get('/onboarding/steps');

      // Use the new response handler
      final data = ApiResponseHandler.handleResponse(response);

      Logger.debug('📥 Onboarding steps data received', data);

      // Handle both formats: direct steps array or nested in 'steps' key
      List<dynamic> stepsData;
      if (data['steps'] != null) {
        stepsData = data['steps'] as List<dynamic>;
      } else if (data is List) {
        stepsData = data as List;
      } else {
        stepsData = [];
      }

      final steps = stepsData
          .map(
            (stepData) =>
                OnboardingStepModel.fromJson(stepData as Map<String, dynamic>),
          )
          .toList();

      Logger.info('✅ Retrieved ${steps.length} onboarding steps from server');
      return steps;
    } on ValidationException catch (e) {
      Logger.error('❌ Validation error fetching onboarding steps', e);
      rethrow;
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Authentication error fetching onboarding steps', e);
      rethrow;
    } on NotFoundException catch (e) {
      Logger.error('❌ Onboarding steps endpoint not found', e);
      rethrow;
    } on ServerException catch (e) {
      Logger.error('❌ Server error fetching onboarding steps', e);
      rethrow;
    } on NetworkException catch (e) {
      Logger.error('❌ Network error fetching onboarding steps', e);
      // Convert to ServerException for consistency
      throw ServerException(
        message: 'Network error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      Logger.error('❌ Unexpected error fetching onboarding steps', e);
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<bool> saveUserData(UserOnboardingModel userData) async {
    try {
      Logger.info('🌐 Saving user onboarding data to server...');
      Logger.debug('📤 User data being sent', userData.toJson());

      final response = await apiService.post(
        '/onboarding/user-data',
        data: userData.toJson(),
      );

      // Use the new response handler
      final data = ApiResponseHandler.handleResponse(response);

      Logger.info('✅ User onboarding data saved to server');
      Logger.debug('📥 Server response', data);

      return true;
    } on ValidationException catch (e) {
      Logger.error('❌ Validation error saving user data', e);

      // Check for specific age group validation error
      if (e.message.contains('ageGroup')) {
        Logger.error(
          '🔧 Age group validation failed - check frontend age options',
        );
        Logger.error('📋 Current user data: ${userData.ageGroup}');
      }

      // Return false for validation errors but don't throw
      // This allows the app to continue working offline
      return false;
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Authentication error saving user data', e);
      rethrow;
    } on NotFoundException catch (e) {
      Logger.error('❌ User data endpoint not found', e);
      rethrow;
    } on ServerException catch (e) {
      Logger.error('❌ Server error saving user data', e);
      // Return false for server errors but don't throw
      return false;
    } on NetworkException catch (e) {
      Logger.error('❌ Network error saving user data', e);
      // Return false for network errors but don't throw
      return false;
    } catch (e) {
      Logger.error('❌ Unexpected error saving user data', e);
      return false;
    }
  }

  @override
  Future<bool> completeOnboarding(UserOnboardingModel userData) async {
    try {
      Logger.info('🌐 Completing onboarding on server...');
      Logger.debug('📤 Completion data being sent', userData.toJson());

      final response = await apiService.post(
        '/onboarding/complete',
        data: userData.toJson(),
      );

      // Use the new response handler
      final data = ApiResponseHandler.handleResponse(response);

      Logger.info('✅ Onboarding completed on server');
      Logger.debug('📥 Server response', data);

      return true;
    } on ValidationException catch (e) {
      Logger.error('❌ Validation error completing onboarding', e);

      // Check for specific age group validation error
      if (e.message.contains('ageGroup')) {
        Logger.error('🔧 Age group validation failed during completion');
        Logger.error('📋 Current user data: ${userData.ageGroup}');
      }

      // Return false for validation errors but don't throw
      return false;
    } on UnauthorizedException catch (e) {
      Logger.error('❌ Authentication error completing onboarding', e);
      rethrow;
    } on NotFoundException catch (e) {
      Logger.error('❌ Onboarding completion endpoint not found', e);
      rethrow;
    } on ServerException catch (e) {
      Logger.error('❌ Server error completing onboarding', e);
      // Return false for server errors but don't throw
      return false;
    } on NetworkException catch (e) {
      Logger.error('❌ Network error completing onboarding', e);
      // Return false for network errors but don't throw
      return false;
    } catch (e) {
      Logger.error('❌ Unexpected error completing onboarding', e);
      return false;
    }
  }
}
