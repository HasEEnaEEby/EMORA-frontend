import 'package:equatable/equatable.dart';

import '../../domain/entity/home_data_entity.dart';
import 'user_stats_model.dart';

class HomeDataModel extends Equatable {
  final String username;
  final String? currentMood;
  final int streak;
  final bool isFirstTimeLogin;
  final UserStatsModel userStats;
  final String? selectedAvatar;
  final Map<String, dynamic> dashboardData;
  final DateTime lastUpdated;

  const HomeDataModel({
    required this.username,
    this.currentMood,
    required this.streak,
    required this.isFirstTimeLogin,
    required this.userStats,
    this.selectedAvatar,
    required this.dashboardData,
    required this.lastUpdated,
  });

  // ✅ ENHANCED: Computed properties for better state management
  bool get isNewUser {
    // Extract total emotions from the nested dashboard data structure
    final data = dashboardData['data'];
    if (data == null) return true;
    
    final dashboard = data['dashboard'];
    if (dashboard == null) return true;
    
    final totalEmotions = dashboard['totalEmotions'] ?? 0;
    
    // User is new if they have 0 total emotions
    final isNew = totalEmotions == 0;
    
    print('🔍 DEBUG: HomeDataModel.isNewUser computed: $isNew (totalEmotions: $totalEmotions)');
    
    return isNew;
  }

  int get totalEmotions {
    final data = dashboardData['data'];
    final dashboard = data?['dashboard'];
    return dashboard?['totalEmotions'] ?? 0;
  }

  int get todayEmotions {
    final data = dashboardData['data'];
    final dashboard = data?['dashboard'];
    return dashboard?['todayEmotions'] ?? 0;
  }

  int get averageMoodScore {
    final data = dashboardData['data'];
    final dashboard = data?['dashboard'];
    return dashboard?['averageMoodScore'] ?? 50;
  }

  List<Map<String, dynamic>> get recentEmotions {
    final data = dashboardData['data'];
    final dashboard = data?['dashboard'];
    final emotions = dashboard?['recentEmotions'];
    
    if (emotions is List) {
      return emotions.cast<Map<String, dynamic>>();
    }
    
    return [];
  }

  // ✅ FIXED: Enhanced factory constructor to parse the correct API structure
  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 HomeDataModel.fromJson input: ${json.toString().substring(0, 200)}...');
      
      // Extract the actual data from the API response structure
      // API returns: { "success": true, "data": { "user": { "username": "haseenakc" }, "dashboard": {...}, "insights": {...} } }
      final responseData = json['data'] ?? json;
      print('🔍 responseData found: ${responseData != null}');
      
      final userData = responseData['user'] ?? {};
      final dashboardData = responseData['dashboard'] ?? {};
      final insightsData = responseData['insights'] ?? {};
      
      print('🔍 userData keys: ${userData.keys.toList()}');
      print('🔍 dashboardData keys: ${dashboardData.keys.toList()}');
      
      // Extract username from the correct path: data.user.username
      final username = _safeString(userData['username']) ?? 'Unknown';
      print('🔍 Extracted username: "$username"');
      
      // Extract emotions count for debugging
      final totalEmotions = _safeInt(dashboardData['totalEmotions']);
      print('🔍 Total emotions from API: $totalEmotions');
      
      return HomeDataModel(
        username: username, // ✅ Now gets "haseenakc" instead of "User"
        currentMood: _safeString(userData['currentMood']),
        streak: _safeInt(userData['currentStreak']) ?? _safeInt(userData['streak']) ?? 0,
        isFirstTimeLogin: _safeBool(dashboardData['isFirstTimeLogin']) ?? (totalEmotions == 0),
        userStats: _parseUserStats({
          'moodCheckins': totalEmotions,
          'streakDays': _safeInt(userData['currentStreak']) ?? 0,
          'totalMoodEntries': totalEmotions,
          'longestStreak': _safeInt(userData['longestStreak']) ?? 0,
          'averageMoodScore': _safeInt(dashboardData['averageMoodScore']) ?? 50,
          'totalSessions': totalEmotions,
          'mostFrequentMood': _safeString(userData['currentMood']) ?? 'neutral',
          'lastMoodLog': DateTime.now(),
          'weeklyStats': {},
          'monthlyStats': {},
          'totalFriends': 0,
          'helpedFriends': 0,
          'badgesEarned': 0,
          'userLevel': 'New Explorer',
          'favoriteEmotion': _safeString(userData['currentMood']) ?? '',
          'daysSinceJoined': 0,
          'lastActivity': DateTime.now(),
          'comprehensiveStats': {},
          'achievements': {},
        }),
        selectedAvatar: _safeString(userData['selectedAvatar']),
        dashboardData: json, // Store the entire API response for computed properties
        lastUpdated: _parseDateTime(responseData['timestamp']) ?? DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing HomeDataModel: $e');
      print('❌ Stack trace: $stackTrace');
      
      // Return safe defaults if parsing fails
      return HomeDataModel(
        username: 'Unknown',
        currentMood: 'neutral',
        streak: 0,
        isFirstTimeLogin: true,
        userStats: UserStatsModel.empty(),
        selectedAvatar: 'default',
        dashboardData: json,
        lastUpdated: DateTime.now(),
      );
    }
  }

  // ✅ ENHANCED: Mock factory method for testing
  factory HomeDataModel.mock({
    String? username, 
    String? avatar,
    int? totalEmotions,
    bool? isNew,
  }) {
    final mockTotalEmotions = totalEmotions ?? (isNew == true ? 0 : 5);
    
    return HomeDataModel(
      username: username ?? 'testuser',
      currentMood: 'neutral',
      streak: 0,
      isFirstTimeLogin: isNew ?? false,
      userStats: UserStatsModel.empty(),
      selectedAvatar: avatar ?? 'elephant',
      dashboardData: {
        'success': true,
        'data': {
          'user': {
            'username': username ?? 'testuser',
            'selectedAvatar': avatar ?? 'elephant',
          },
          'dashboard': {
            'totalEmotions': mockTotalEmotions,
            'todayEmotions': 0,
            'averageMoodScore': 50,
            'recentEmotions': [],
          },
        },
      },
      lastUpdated: DateTime.now(),
    );
  }

  // Convert from Entity to Model (for clean architecture)
  factory HomeDataModel.fromEntity(HomeDataEntity entity) {
    return HomeDataModel(
      username: entity.username,
      currentMood: entity.currentMood,
      streak: entity.streak,
      isFirstTimeLogin: entity.isFirstTimeLogin,
      userStats: UserStatsModel.fromEntity(entity.userStats),
      selectedAvatar: entity.selectedAvatar,
      dashboardData: entity.dashboardData,
      lastUpdated: entity.lastUpdated,
    );
  }

  // ✅ ENHANCED: Safe type conversion methods with better error handling
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    return value.toString().trim().isEmpty ? null : value.toString().trim();
  }

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return 0;
      return int.tryParse(trimmed) ?? 0;
    }
    return 0;
  }

  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final trimmed = value.trim().toLowerCase();
      return trimmed == 'true' || trimmed == '1' || trimmed == 'yes';
    }
    if (value is int) {
      return value == 1;
    }
    if (value is double) {
      return value == 1.0;
    }
    return false;
  }

  static UserStatsModel _parseUserStats(dynamic statsData) {
    try {
      if (statsData == null) return UserStatsModel.empty();

      if (statsData is Map<String, dynamic>) {
        return UserStatsModel.fromJson(statsData);
      }

      if (statsData is UserStatsModel) return statsData;

      // Try to convert if it's a different type of Map
      if (statsData is Map) {
        return UserStatsModel.fromJson(Map<String, dynamic>.from(statsData));
      }

      return UserStatsModel.empty();
    } catch (e) {
      print('❌ Error parsing UserStats: $e');
      return UserStatsModel.empty();
    }
  }

  static Map<String, dynamic> _parseDashboardData(dynamic dashboardData) {
    try {
      if (dashboardData == null) return {};

      if (dashboardData is Map<String, dynamic>) {
        return dashboardData;
      }

      if (dashboardData is Map) {
        return Map<String, dynamic>.from(dashboardData);
      }

      return {};
    } catch (e) {
      print('❌ Error parsing dashboard data: $e');
      return {};
    }
  }

  static DateTime _parseDateTime(dynamic dateData) {
    try {
      if (dateData == null) return DateTime.now();

      if (dateData is DateTime) return dateData;

      if (dateData is String && dateData.isNotEmpty) {
        return DateTime.tryParse(dateData) ?? DateTime.now();
      }

      if (dateData is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateData);
      }

      return DateTime.now();
    } catch (e) {
      print('❌ Error parsing DateTime: $e');
      return DateTime.now();
    }
  }

  // ✅ ENHANCED: Better JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'currentMood': currentMood,
      'streak': streak,
      'isFirstTimeLogin': isFirstTimeLogin,
      'userStats': userStats.toJson(),
      'selectedAvatar': selectedAvatar,
      'dashboardData': dashboardData,
      'lastUpdated': lastUpdated.toIso8601String(),
      // Include computed properties for debugging
      'computedValues': {
        'isNewUser': isNewUser,
        'totalEmotions': totalEmotions,
        'todayEmotions': todayEmotions,
        'averageMoodScore': averageMoodScore,
      },
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  HomeDataEntity toEntity() {
    return HomeDataEntity(
      username: username,
      currentMood: currentMood,
      streak: streak,
      isFirstTimeLogin: isFirstTimeLogin,
      userStats: userStats.toEntity(),
      selectedAvatar: selectedAvatar,
      dashboardData: dashboardData,
      lastUpdated: lastUpdated,
    );
  }

  HomeDataModel copyWith({
    String? username,
    String? currentMood,
    int? streak,
    bool? isFirstTimeLogin,
    UserStatsModel? userStats,
    String? selectedAvatar,
    Map<String, dynamic>? dashboardData,
    DateTime? lastUpdated,
  }) {
    return HomeDataModel(
      username: username ?? this.username,
      currentMood: currentMood ?? this.currentMood,
      streak: streak ?? this.streak,
      isFirstTimeLogin: isFirstTimeLogin ?? this.isFirstTimeLogin,
      userStats: userStats ?? this.userStats,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      dashboardData: dashboardData ?? this.dashboardData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // ✅ ENHANCED: Debug method for troubleshooting
  void debugPrint() {
    print('🔍 ===== HomeDataModel Debug =====');
    print('🔍 Username: "$username"');
    print('🔍 Current Mood: "$currentMood"');
    print('🔍 Streak: $streak');
    print('🔍 Is First Time Login: $isFirstTimeLogin');
    print('🔍 Selected Avatar: "$selectedAvatar"');
    print('🔍 Last Updated: $lastUpdated');
    print('🔍 ----- Computed Properties -----');
    print('🔍 Is New User: $isNewUser');
    print('🔍 Total Emotions: $totalEmotions');
    print('🔍 Today Emotions: $todayEmotions');
    print('🔍 Average Mood Score: $averageMoodScore');
    print('🔍 Recent Emotions Count: ${recentEmotions.length}');
    print('🔍 ----- User Stats -----');
    print('🔍 Mood Checkins: ${userStats.moodCheckins}');
    print('🔍 Streak Days: ${userStats.streakDays}');
    print('🔍 Total Mood Entries: ${userStats.totalMoodEntries}');
    print('🔍 ===============================');
  }

  // ✅ ENHANCED: Validation method
  bool get isValid {
    return username.isNotEmpty && 
           username != 'Unknown' && 
           lastUpdated.isBefore(DateTime.now().add(const Duration(hours: 1)));
  }

  @override
  List<Object?> get props => [
    username,
    currentMood,
    streak,
    isFirstTimeLogin,
    userStats,
    selectedAvatar,
    dashboardData,
    lastUpdated,
  ];

  @override
  String toString() {
    return 'HomeDataModel(username: $username, isNewUser: $isNewUser, totalEmotions: $totalEmotions, streak: $streak)';
  }
}