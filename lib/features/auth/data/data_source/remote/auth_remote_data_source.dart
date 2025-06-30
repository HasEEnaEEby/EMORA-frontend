import 'package:dio/dio.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/auth_response_model.dart';
import '../../model/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> checkUsernameAvailability(String username);
  Future<AuthResponseModel> register({
    required String username,
    required String password,
    required String pronouns,
    required String ageGroup,
    required String selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
  });
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
    required this.networkInfo,
  });

  @override
  Future<bool> checkUsernameAvailability(String username) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      final response = await dioClient.get(
        '/api/onboarding/check-username/$username',
      );

      if (response.statusCode == 200) {
        return response.data['isAvailable'] ?? false;
      } else {
        throw ServerException(
          message: 'Failed to check username availability',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Error checking username availability', e);
      if (e.response?.statusCode == 400) {
        return false; // Username format invalid or reserved
      }
      throw ServerException(
        message: 'Network error: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected error checking username', e);
      throw ServerException(
        message: 'Failed to check username: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String username,
    required String password,
    required String pronouns,
    required String ageGroup,
    required String selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      // Use the EXACT values from onboarding - no conversion needed
      // Your backend expects the same values for both onboarding and registration
      final requestData = <String, dynamic>{
        'username': username,
        'password': password,
        'pronouns': pronouns, // Use as-is: "She / Her", "He / Him", etc.
        'ageGroup': ageGroup, // Use as-is: "20s", "30s", "40s", etc.
        'selectedAvatar': selectedAvatar, // Use as-is: "panda", "zebra", etc.
      };

      // Add location data if provided
      if (location != null && location.isNotEmpty) {
        requestData['location'] = location;
      }
      if (latitude != null) {
        requestData['latitude'] = latitude;
      }
      if (longitude != null) {
        requestData['longitude'] = longitude;
      }

      Logger.info(
        '🔄 Sending registration request with data: ${requestData.keys.toList()}',
      );
      Logger.info(
        '📤 Using exact onboarding values: pronouns="$pronouns", ageGroup="$ageGroup", avatar="$selectedAvatar"',
      );

      final response = await dioClient.post(
        '/api/onboarding/register',
        data: requestData,
      );

      if (response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Registration error', e);
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
      } else if (e.response?.statusCode == 409) {
        // Handle username suggestions from backend
        final responseData = e.response?.data;
        if (responseData != null && responseData['suggestions'] != null) {
          final suggestions = List<String>.from(responseData['suggestions']);
          throw ServerException(
            message: 'Username already exists. Try: ${suggestions.join(', ')}',
            statusCode: e.response?.statusCode,
          );
        }
        throw ServerException(
          message: 'Username already exists',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        message: 'Registration failed: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected registration error', e);
      throw ServerException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      final response = await dioClient.post(
        '/api/onboarding/login',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Login error', e);
      if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'Invalid username or password',
          statusCode: e.response?.statusCode,
        );
      } else if (e.response?.statusCode == 423) {
        throw ServerException(
          message: 'Account is temporarily locked',
          statusCode: e.response?.statusCode,
        );
      } else if (e.response?.statusCode == 400) {
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
          message: 'Invalid login credentials',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        message: 'Login failed: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected login error', e);
      throw ServerException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      final response = await dioClient.get('/api/onboarding/profile');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']['user']);
      } else {
        throw ServerException(
          message: 'Failed to get user profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Error getting current user', e);
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required',
          statusCode: e.response?.statusCode,
        );
      }
      throw ServerException(
        message: 'Failed to get user: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected error getting user', e);
      throw ServerException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      final response = await dioClient.post('/api/onboarding/logout');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Logout failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('Logout error', e);
      // Handle different logout scenarios
      if (e.response?.statusCode == 401) {
        // Token already invalid - this is fine for logout
        return;
      }
      throw ServerException(
        message: 'Logout failed: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('Unexpected logout error', e);
      throw ServerException(message: 'Logout failed: ${e.toString()}');
    }
  }
}
