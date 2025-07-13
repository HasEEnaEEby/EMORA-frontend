// lib/features/auth/data/data_source/remote/auth_remote_data_source.dart - CLEAN VERSION
import 'package:emora_mobile_app/core/config/app_config.dart';
import 'package:emora_mobile_app/core/errors/exceptions.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/network/network_info.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/auth_response_entity.dart';
import 'package:emora_mobile_app/features/auth/domain/entity/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> checkUsernameAvailability(String username);
  Future<AuthResponseEntity> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword, 
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
    bool? termsAccepted,
    bool? privacyAccepted,
  });


  Future<AuthResponseEntity> loginUser({
    required String username,
    required String password,
  });


  
  Future<UserEntity> getCurrentUser();
  Future<void> logout();
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;
  final NetworkInfo networkInfo;

  AuthRemoteDataSourceImpl({
    required this.apiService,
    required this.networkInfo,
  });

  @override
  Future<Map<String, dynamic>> checkUsernameAvailability(
    String username,
  ) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      Logger.info('🔍 Checking username availability: $username');

      final response = await apiService.get(
        '/onboarding/check-username/$username',
      );

      Logger.info('📥 Username check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle both nested and flat response structures
        final data = responseData['data'] ?? responseData;
        final isAvailable = data['isAvailable'] ?? false;
        final message =
            data['message'] ??
            (isAvailable
                ? 'Username is available'
                : 'Username is already taken');

        Logger.info('✅ Username $username availability: $isAvailable');

        return {
          'isAvailable': isAvailable,
          'suggestions': <String>[],
          'message': message,
        };
      } else {
        throw ServerException(
          message: 'Failed to check username availability',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('❌ Username check error', e);

      // Return mock data on error for development
      if (AppConfig.isDevelopmentMode) {
        final isAvailable = !AppConfig.reservedUsernames.contains(
          username.toLowerCase(),
        );
        return {
          'isAvailable': isAvailable,
          'suggestions': <String>[],
          'message': isAvailable
              ? 'Username is available'
              : 'Username is already taken',
        };
      }

      rethrow;
    }
  }

  @override
  Future<AuthResponseEntity> registerUser({
    required String username,
    required String email,
    required String password,
    required String confirmPassword, // ✅ Added confirmPassword parameter
    String? pronouns,
    String? ageGroup,
    String? selectedAvatar,
    String? location,
    double? latitude,
    double? longitude,
    bool? termsAccepted,
    bool? privacyAccepted,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final requestData = <String, dynamic>{
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword, // ✅ Added confirmPassword to request
        'termsAccepted': termsAccepted ?? true,
        'privacyAccepted': privacyAccepted ?? true,
      };

      // Add optional onboarding fields if provided
      if (pronouns != null && pronouns.isNotEmpty) {
        requestData['pronouns'] = pronouns;
      }
      if (ageGroup != null && ageGroup.isNotEmpty) {
        requestData['ageGroup'] = ageGroup;
      }
      if (selectedAvatar != null && selectedAvatar.isNotEmpty) {
        requestData['selectedAvatar'] = selectedAvatar;
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

      Logger.info('🔄 Registration request for username: $username');
      Logger.info('📤 Registration data: ${requestData.keys.toList()}');

      final response = await apiService.post(
        '/api/auth/register', // ✅ Clean auth endpoint
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        // ✅ CRITICAL FIX: Handle both 'success' and 'true' status formats
        final isSuccess = responseData?['success'] == true || 
                         responseData?['status'] == 'success';

        if (isSuccess) {
          final authData = responseData?['data'];
          final userData = authData?['user']; // ✅ Add null safety

          Logger.info('✅ Registration successful');

          // ✅ Create entities from response with proper null safety
          final userEntity = UserEntity(
            id: userData?['id']?.toString() ?? 
                DateTime.now().millisecondsSinceEpoch.toString(),
            username: userData?['username'] ?? username,
            email: userData?['email'] ?? email,
            pronouns: userData?['pronouns'],
            ageGroup: userData?['ageGroup'],
            selectedAvatar: userData?['selectedAvatar'],
            location: userData?['location']?['name'],
            latitude: userData?['location']?['coordinates']?['coordinates']?[1]?.toDouble(),
            longitude: userData?['location']?['coordinates']?['coordinates']?[0]?.toDouble(),
            isOnboardingCompleted: userData?['isOnboardingCompleted'] ?? true,
            createdAt: userData?['createdAt'] != null
                ? DateTime.tryParse(userData!['createdAt']) ?? DateTime.now()
                : DateTime.now(),
            updatedAt: userData?['updatedAt'] != null
                ? DateTime.tryParse(userData!['updatedAt']) ?? DateTime.now()
                : DateTime.now(),
          );

          return AuthResponseEntity(
            user: userEntity,
            token: authData?['token'] ?? '',
            refreshToken: authData?['refreshToken'],
            expiresAt: authData?['expiresIn'] != null
                ? DateTime.now().add(Duration(days: 7))
                : null,
          );
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Registration failed',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ServerException(
          message: 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('❌ Registration error', e);
      // ✅ Removed mock data fallback - always propagate real errors
      rethrow;
    }
  }

  @override
  Future<AuthResponseEntity> loginUser({
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final requestData = {'username': username, 'password': password};

      Logger.info('🔐 Login request for username: $username');
      
      // 🔍 ADD THIS DEBUG LINE:
      print('🔍 DEBUG: About to call apiService.post with: $requestData');

      final response = await apiService.post(
        '/api/auth/login', // ✅ Clean auth endpoint
        data: requestData,
      );

      // 🔍 ADD THIS DEBUG LINE:
      print('🔍 DEBUG: Got response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // ✅ CRITICAL FIX: Handle both 'success' and 'true' status formats
        final isSuccess = responseData?['success'] == true || 
                         responseData?['status'] == 'success';

        if (isSuccess) {
          final authData = responseData?['data'];
          final userData = authData?['user']; // ✅ Add null safety

          Logger.info('✅ Login successful');

          // ✅ Create entities from response with proper null safety
          final userEntity = UserEntity(
            id: userData?['id']?.toString() ?? 
                DateTime.now().millisecondsSinceEpoch.toString(),
            username: userData?['username'] ?? username,
            email: userData?['email'] ?? '',
            pronouns: userData?['pronouns'],
            ageGroup: userData?['ageGroup'],
            selectedAvatar: userData?['selectedAvatar'],
            location: userData?['location']?['name'],
            latitude: userData?['location']?['coordinates']?['coordinates']?[1]?.toDouble(),
            longitude: userData?['location']?['coordinates']?['coordinates']?[0]?.toDouble(),
            isOnboardingCompleted: userData?['isOnboardingCompleted'] ?? false,
            createdAt: userData?['createdAt'] != null
                ? DateTime.tryParse(userData!['createdAt']) ?? DateTime.now()
                : DateTime.now(),
            updatedAt: userData?['updatedAt'] != null
                ? DateTime.tryParse(userData!['updatedAt']) ?? DateTime.now()
                : DateTime.now(),
          );

          return AuthResponseEntity(
            user: userEntity,
            token: authData?['token'] ?? '',
            refreshToken: authData?['refreshToken'],
            expiresAt: authData?['expiresIn'] != null
                ? DateTime.now().add(Duration(days: 7))
                : null,
          );
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Login failed',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ServerException(
          message: 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // 🔍 ADD THIS DEBUG LINE:
      print('🔍 DEBUG: Login error caught: $e');
      Logger.error('❌ Login error', e);
      // ✅ Removed mock data fallback - always propagate real errors  
      rethrow;
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      Logger.info('👤 Getting current user...');

      final response = await apiService.get('/user/profile');

      if (response.statusCode == 200) {
        final responseData = response.data;
        final userData = responseData['data'] ?? responseData;

        Logger.info('✅ Current user retrieved successfully');

        return UserEntity(
          id:
              userData['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          pronouns: userData['pronouns'],
          ageGroup: userData['ageGroup'],
          selectedAvatar: userData['selectedAvatar'],
          location: userData['location']?['name'],
          latitude: userData['location']?['coordinates']?['coordinates']?[1]
              ?.toDouble(),
          longitude: userData['location']?['coordinates']?['coordinates']?[0]
              ?.toDouble(),
          isOnboardingCompleted: userData['isOnboardingCompleted'] ?? false,
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
          updatedAt: userData['updatedAt'] != null
              ? DateTime.parse(userData['updatedAt'])
              : DateTime.now(),
        );
      } else {
        throw ServerException(
          message: 'Failed to get current user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('❌ Get current user error', e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      Logger.info('🚪 Logging out...');

      if (await networkInfo.isConnected) {
        try {
          // Send empty JSON object to satisfy the backend's JSON validation
          await apiService.post('/api/auth/logout', data: {});
          Logger.info('✅ Server logout successful');
        } catch (e) {
          Logger.warning('⚠️ Server logout failed: $e');
          // Don't throw - we still want to clear local data
        }
      }

      Logger.info('🔑 Logout completed');
    } catch (e) {
      Logger.error('❌ Logout error', e);
      // Don't throw - logout should always succeed locally
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      Logger.info('🔄 Refreshing auth token');

      final response = await apiService.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final newToken =
            responseData['data']?['token'] ?? responseData['token'];

        if (newToken != null) {
          Logger.info('✅ Token refreshed successfully');
          return newToken;
        } else {
          throw ServerException(message: 'No token in refresh response');
        }
      } else {
        throw ServerException(
          message: 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      Logger.error('❌ Token refresh error', e);
      rethrow;
    }
  }
}
