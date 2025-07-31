import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';

class AccountDeletionDataSource {
  final ApiService apiService;
  final NetworkInfo networkInfo;

  const AccountDeletionDataSource({
    required this.apiService,
    required this.networkInfo,
  });

  Future<Map<String, dynamic>> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    try {
      Logger.info('🗑️ Starting account deletion process...');

      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      if (confirmation != 'DELETE') {
        throw ValidationException(message: 'Please type DELETE to confirm account deletion');
      }

      if (password.isEmpty) {
        throw ValidationException(message: 'Password is required for account deletion');
      }

      final requestData = {
        'password': password,
        'confirmation': confirmation,
      };

      Logger.info('📤 Sending account deletion request...');

      final response = await apiService.postData(
        '/api/auth/delete-account',
        data: requestData,
      );

      Logger.info('. Account deletion API call successful');

      return response;

    } catch (e) {
      Logger.error('. Account deletion failed: $e');
      
      if (e is NetworkException || e is ServerException || e is ValidationException) {
        rethrow;
      }
      
      throw ServerException(
        message: 'Account deletion failed: ${e.toString()}',
      );
    }
  }

  static void validateDeletionRequest({
    required String password,
    required String confirmation,
  }) {
    if (password.isEmpty) {
      throw ValidationException(message: 'Password is required');
    }

    if (confirmation != 'DELETE') {
      throw ValidationException(message: 'Please type DELETE to confirm');
    }

    if (password.length < 6) {
      throw ValidationException(message: 'Password must be at least 6 characters');
    }
  }

  Future<bool> isDeletionAllowed() async {
    try {
      if (!await networkInfo.isConnected) {
        return false;
      }

      return true;

    } catch (e) {
      Logger.error('. Error checking deletion allowance: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getDeletionRequirements() async {
    try {
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      return {
        'requiresPassword': true,
        'requiresConfirmation': true,
        'confirmationText': 'DELETE',
        'warnings': [
          'All your data will be permanently deleted',
          'This action cannot be undone',
          'You will lose access to all your emotions and insights',
          'Your achievements and progress will be lost',
          'Social connections will be removed',
        ],
        'dataToBeDeleted': [
          'Profile information and settings',
          'All emotion logs and history',
          'Achievements and progress',
          'Social connections and shared content',
          'Analytics and insights data',
          'Account preferences and customizations',
        ],
      };

    } catch (e) {
      Logger.error('. Error getting deletion requirements: $e');
      throw ServerException(
        message: 'Failed to get deletion requirements: ${e.toString()}',
      );
    }
  }
} 