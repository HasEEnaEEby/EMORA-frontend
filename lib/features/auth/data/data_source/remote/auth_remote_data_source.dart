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
    String? email,
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
    Logger.info('🔍 Checking username availability: $username');
    
    final response = await dioClient.get(
      '/api/auth/check-username/$username',
    );

    Logger.info('📥 Username check response: ${response.statusCode}');
    Logger.info('📥 Username check data: ${response.data}');

    if (response.statusCode == 200) {
      // FIX: Look for 'isAvailable' field that server actually returns
      final isAvailable = response.data['data']?['isAvailable'] ?? 
                         response.data['isAvailable'] ?? 
                         false;
      
      Logger.info('✅ Username $username availability: $isAvailable');
      return isAvailable;
    } else {
      throw ServerException(
        message: 'Failed to check username availability',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    Logger.error('❌ Username check error', e);
    
    if (e.response?.statusCode == 400) {
      return false; // Username format invalid or reserved
    } else if (e.response?.statusCode == 404) {
      // Endpoint not found, return false for safety
      Logger.warning('⚠️ Username check endpoint not found');
      return false;
    } else if (e.response?.statusCode == 409) {
      // Username already taken
      return false;
    }
    
    throw ServerException(
      message: 'Network error: ${e.message}',
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    Logger.error('❌ Unexpected username check error', e);
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
    String? email,
  }) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      // Prepare registration data
      final requestData = <String, dynamic>{
        'username': username,
        'password': password,
        'pronouns': pronouns, // Send pronouns as-is
        'ageGroup': ageGroup, // Send age group as-is
        'selectedAvatar': selectedAvatar, // Send avatar as-is
      };

      // Add optional fields
      if (email != null && email.isNotEmpty) {
        requestData['email'] = email;
      }
      if (location != null && location.isNotEmpty) {
        requestData['location'] = location;
      }
      if (latitude != null) {
        requestData['latitude'] = latitude;
      }
      if (longitude != null) {
        requestData['longitude'] = longitude;
      }

      Logger.info('🔄 Registration request data: ${requestData.keys.toList()}');
      Logger.info('📤 Username: $username, Pronouns: $pronouns, AgeGroup: $ageGroup');

      // Try multiple possible registration endpoints
      Response? response;
      
      // First try the auth endpoint
      try {
        response = await dioClient.post('/api/auth/register', data: requestData);
        Logger.info('✅ Registration successful via /api/auth/register');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          Logger.info('🔄 /api/auth/register not found, trying /api/onboarding/register');
          // Try the onboarding endpoint as fallback
          response = await dioClient.post('/api/onboarding/register', data: requestData);
          Logger.info('✅ Registration successful via /api/onboarding/register');
        } else {
          rethrow;
        }
      }

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        Logger.info('📥 Registration response: ${response.data}');
        
        // Handle different response structures
        final responseData = response.data;
        final authData = responseData['data'] ?? responseData;
        
        Logger.info('🔍 Parsing auth data: $authData');
        
        final authResponse = AuthResponseModel.fromJson(authData);
        
        // Set the token in DioClient for future requests
        if (authResponse.token.isNotEmpty) {
          dioClient.setAuthToken(authResponse.token);
          Logger.info('🔑 Auth token set successfully');
        }
        
        return authResponse;
      } else {
        throw ServerException(
          message: 'Registration failed with status: [1m${response.statusCode}[0m',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('❌ Registration DioException', e);
      
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      Logger.info('📥 Error response data: $responseData');
      
      if (statusCode == 400) {
        // Handle validation errors
        if (responseData != null) {
          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as List;
            final errorMessages = errors.map((error) => error['msg'] as String).toList();
            throw ServerException(
              message: errorMessages.join(', '),
              statusCode: statusCode,
            );
          } else if (responseData['message'] != null) {
            throw ServerException(
              message: responseData['message'],
              statusCode: statusCode,
            );
          }
        }
        throw ServerException(
          message: 'Invalid registration data. Please check your input.',
          statusCode: statusCode,
        );
      } else if (statusCode == 409) {
        // Username already exists
        if (responseData != null && responseData['suggestions'] != null) {
          final suggestions = List<String>.from(responseData['suggestions']);
          throw ServerException(
            message: 'Username already exists. Try: ${suggestions.join(', ')}',
            statusCode: statusCode,
          );
        }
        throw ServerException(
          message: 'Username already exists',
          statusCode: statusCode,
        );
      }
      
      throw ServerException(
        message: 'Registration failed: ${e.message}',
        statusCode: statusCode,
      );
    } catch (e) {
      Logger.error('❌ Unexpected registration error', e);
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
      final requestData = {
        'username': username,
        'password': password,
      };

      Logger.info('🔐 Login request for username: $username');

      final response = await dioClient.post('/api/auth/login', data: requestData);

      Logger.info('📥 Login response status: ${response.statusCode}');
      Logger.info('📥 Login response data keys: ${response.data?.keys?.toList()}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final authData = responseData['data'] ?? responseData;
        
        Logger.info('🔍 Parsing login auth data: $authData');
        
        final authResponse = AuthResponseModel.fromJson(authData);
        
        // Set the token in DioClient for future requests
        if (authResponse.token.isNotEmpty) {
          dioClient.setAuthToken(authResponse.token);
          Logger.info('🔑 Login auth token set successfully');
        }
        
        return authResponse;
      } else {
        throw ServerException(
          message: 'Login failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('❌ Login DioException', e);
      
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      if (statusCode == 401) {
        throw ServerException(
          message: 'Invalid username or password',
          statusCode: statusCode,
        );
      } else if (statusCode == 423) {
        throw ServerException(
          message: 'Account is temporarily locked',
          statusCode: statusCode,
        );
      } else if (statusCode == 400) {
        if (responseData != null) {
          if (responseData['errors'] != null) {
            final errors = responseData['errors'] as List;
            final errorMessages = errors.map((error) => error['msg'] as String).toList();
            throw ServerException(
              message: errorMessages.join(', '),
              statusCode: statusCode,
            );
          } else if (responseData['message'] != null) {
            throw ServerException(
              message: responseData['message'],
              statusCode: statusCode,
            );
          }
        }
        throw ServerException(
          message: 'Invalid login credentials',
          statusCode: statusCode,
        );
      }
      
      throw ServerException(
        message: 'Login failed: ${e.message}',
        statusCode: statusCode,
      );
    } catch (e) {
      Logger.error('❌ Unexpected login error', e);
      throw ServerException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }

    try {
      Logger.info('👤 Getting current user...');
      
      final response = await dioClient.get('/api/auth/me');

      Logger.info('📥 Get user response status: ${response.statusCode}');
      Logger.info('📥 Get user response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle different response structures
        dynamic userData;
        if (responseData['data'] != null) {
          if (responseData['data']['user'] != null) {
            userData = responseData['data']['user'];
          } else {
            userData = responseData['data'];
          }
        } else {
          userData = responseData;
        }
        
        Logger.info('🔍 Parsing user data: $userData');
        
        return UserModel.fromJson(userData);
      } else {
        throw ServerException(
          message: 'Failed to get current user',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      Logger.error('❌ Get current user error', e);
      
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(message: 'Session expired');
      }
      
      throw ServerException(
        message: 'Failed to get current user: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      Logger.error('❌ Unexpected get current user error', e);
      throw ServerException(
        message: 'Failed to get current user: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      Logger.info('🚪 Logging out...');
      
      if (await networkInfo.isConnected) {
        try {
          await dioClient.post('/api/auth/logout');
          Logger.info('✅ Server logout successful');
        } catch (e) {
          Logger.warning('⚠️ Server logout failed: $e');
          // Don't throw - we still want to clear local token
        }
      }
    } finally {
      // Always clear the token from DioClient
      dioClient.clearAuthToken();
      Logger.info('🔑 Auth token cleared locally');
    }
  }
}
