import 'package:emora_mobile_app/core/network/dio_client.dart';

import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../model/home_data_model.dart';
import '../../model/user_stats_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData();
  Future<UserStatsModel> getUserStats();
  Future<List<GlobalEmotionModel>> getGlobalEmotions();
  Future<List<EmotionInsightModel>> getEmotionInsights();
  Future<bool> logEmotion(EmotionLogModel emotionLog);
  Future<void> markFirstTimeLoginComplete();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiService apiService;

  HomeRemoteDataSourceImpl({
    required this.apiService,
    required DioClient dioClient,
  });

  @override
  Future<HomeDataModel> getHomeData() async {
    try {
      Logger.info('🌐 Fetching home data from server...');

      final response = await apiService.get('/api/user/home-data');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        print('🔍 Raw API Response in Remote Source: $responseData');

        if (responseData['success'] == true && responseData['data'] != null) {
          final homeData = HomeDataModel.fromJson(responseData);
          Logger.info('. Home data retrieved successfully');
          return homeData;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get home data',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Home data endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error fetching home data', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<UserStatsModel> getUserStats() async {
    try {
      Logger.info('🌐 Fetching user stats from server...');

      final response = await apiService.get('/api/user/statistics');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final userStats = UserStatsModel.fromJson(responseData['data']);
          Logger.info('. User stats retrieved successfully');
          return userStats;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get user stats',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'User stats endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error fetching user stats', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<GlobalEmotionModel>> getGlobalEmotions() async {
    try {
      Logger.info('🌐 Fetching global emotions from server...');

      final response = await apiService.get('/api/emotions/global-stats');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final emotionsData = responseData['data'] as List;
          final emotions = emotionsData
              .map((emotionData) => GlobalEmotionModel.fromJson(emotionData))
              .toList();

          Logger.info('. Global emotions retrieved successfully');
          return emotions;
        } else {
          throw ServerException(
            message: responseData['message'] ?? 'Failed to get global emotions',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Global emotions endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error fetching global emotions', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<EmotionInsightModel>> getEmotionInsights() async {
    try {
      Logger.info('🌐 Fetching emotion insights from server...');

      final response = await apiService.get('/api/emotions/insights');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final insightsData = responseData['data'] as List;
          final insights = insightsData
              .map((insightData) => EmotionInsightModel.fromJson(insightData))
              .toList();

          Logger.info('. Emotion insights retrieved successfully');
          return insights;
        } else {
          throw ServerException(
            message:
                responseData['message'] ?? 'Failed to get emotion insights',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Emotion insights endpoint not found');
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error fetching emotion insights', e);
      if (e is ServerException || e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<bool> logEmotion(EmotionLogModel emotionLog) async {
    try {
      Logger.info('🌐 Logging emotion to server...');

      final response = await apiService.post(
        '/emotions/log',
        data: emotionLog.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          Logger.info('. Emotion logged successfully');
          return true;
        } else {
          Logger.warning(
            '. Server returned success=false: ${responseData['message']}',
          );
          return false;
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Emotion log endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message: 'Authentication required for logging emotion',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error logging emotion', e);
      if (e is ServerException ||
          e is NotFoundException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }

  @override
  Future<void> markFirstTimeLoginComplete() async {
    try {
      Logger.info('🌐 Marking first-time login complete on server...');

      final response = await apiService.patch(
        '/user/first-time-login-complete',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.data;

        if (responseData == null || responseData['success'] == true) {
          Logger.info('. First-time login marked complete on server');
          return;
        } else {
          throw ServerException(
            message:
                responseData['message'] ??
                'Failed to mark first-time login complete',
          );
        }
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'First-time login endpoint not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          message:
              'Authentication required for marking first-time login complete',
        );
      } else {
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('. Error marking first-time login complete', e);
      if (e is ServerException ||
          e is NotFoundException ||
          e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: ${e.toString()}');
    }
  }
}


class GlobalEmotionModel {
  final String city;
  final String emotion;
  final double percentage;

  GlobalEmotionModel({
    required this.city,
    required this.emotion,
    required this.percentage,
  });

  factory GlobalEmotionModel.fromJson(Map<String, dynamic> json) {
    return GlobalEmotionModel(
      city: json['city'] ?? '',
      emotion: json['emotion'] ?? 'neutral',
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'city': city, 'emotion': emotion, 'percentage': percentage};
  }
}

class EmotionInsightModel {
  final String title;
  final String description;
  final String type;
  final DateTime createdAt;

  EmotionInsightModel({
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory EmotionInsightModel.fromJson(Map<String, dynamic> json) {
    return EmotionInsightModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'general',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EmotionLogModel {
  final String emotion;
  final double intensity;
  final String? note;
  final DateTime timestamp;

  EmotionLogModel({
    required this.emotion,
    required this.intensity,
    this.note,
    required this.timestamp,
  });

  factory EmotionLogModel.fromJson(Map<String, dynamic> json) {
    return EmotionLogModel(
      emotion: json['emotion'] ?? 'neutral',
      intensity: (json['intensity'] ?? 0.5).toDouble(),
      note: json['note'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'intensity': intensity,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}