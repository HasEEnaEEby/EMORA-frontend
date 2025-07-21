// lib/features/auth/data/data_source/remote/account_deletion_data_source.dart
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';

/// Professional account deletion data source that handles API calls
/// for account deletion with proper error handling and validation
class AccountDeletionDataSource {
  final ApiService apiService;
  final NetworkInfo networkInfo;

  const AccountDeletionDataSource({
    required this.apiService,
    required this.networkInfo,
  });

  /// Deletes user account with comprehensive data cleanup
  /// 
  /// [password] - User's password for verification
  /// [confirmation] - Must be "DELETE" to confirm
  /// 
  /// Throws:
  /// - [NetworkException] if no internet connection
  /// - [ServerException] if server error occurs
  /// - [AuthException] if authentication fails
  Future<Map<String, dynamic>> deleteAccount({
    required String password,
    required String confirmation,
  }) async {
    try {
      Logger.info('🗑️ Starting account deletion process...');

      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      // Validate confirmation
      if (confirmation != 'DELETE') {
        throw ValidationException(message: 'Please type DELETE to confirm account deletion');
      }

      // Validate password
      if (password.isEmpty) {
        throw ValidationException(message: 'Password is required for account deletion');
      }

      // Prepare request data
      final requestData = {
        'password': password,
        'confirmation': confirmation,
      };

      Logger.info('📤 Sending account deletion request...');

      // Make API call to delete account
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

  /// Validates account deletion request parameters
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

  /// Checks if account deletion is allowed (e.g., no pending transactions)
  Future<bool> isDeletionAllowed() async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        return false;
      }

      // TODO: Implement checks for pending transactions, subscriptions, etc.
      // For now, always allow deletion
      return true;

    } catch (e) {
      Logger.error('. Error checking deletion allowance: $e');
      return false;
    }
  }

  /// Gets account deletion requirements and warnings
  Future<Map<String, dynamic>> getDeletionRequirements() async {
    try {
      // Check network connectivity
      if (!await networkInfo.isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      // TODO: Implement API call to get deletion requirements
      // For now, return default requirements
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