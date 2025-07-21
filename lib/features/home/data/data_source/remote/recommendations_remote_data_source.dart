// lib/features/home/data/data_source/remote/recommendations_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class RecommendationsRemoteDataSource {
  final ApiService _apiService = GetIt.instance<ApiService>();

  /// Get Spotify playlist recommendation based on mood
  Future<Map<String, dynamic>?> getSpotifyPlaylistForMood(String mood) async {
    try {
      Logger.info('🎵 Fetching Spotify playlist for mood: $mood');
      
      final response = await _apiService.get(
        '/api/spotify/playlist',
        queryParameters: {'mood': mood},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        Logger.info('✅ Spotify playlist fetched successfully');
        return data['data']['playlist'];
      } else {
        Logger.warning('⚠️ Spotify playlist request failed: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching Spotify playlist: $e');
    }
    return null;
  }

  /// Get comprehensive recommendations including music, activities, and wellness
  Future<Map<String, dynamic>?> getComprehensiveRecommendations({
    required String emotion,
    int intensity = 5,
    String? timeOfDay,
    String? weather,
  }) async {
    try {
      Logger.info('📝 Fetching comprehensive recommendations for: $emotion (intensity: $intensity)');
      
      final queryParams = {
        'emotion': emotion,
        'intensity': intensity.toString(),
      };
      
      if (timeOfDay != null) queryParams['timeOfDay'] = timeOfDay;
      if (weather != null) queryParams['weather'] = weather;

      final response = await _apiService.get(
        '/api/recommendations/comprehensive',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Comprehensive recommendations fetched successfully');
        return response.data['data'];
      } else {
        Logger.warning('⚠️ Comprehensive recommendations request failed: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching comprehensive recommendations: $e');
    }
    return null;
  }

  /// Get featured playlists from Spotify
  Future<List<Map<String, dynamic>>> getFeaturedPlaylists() async {
    try {
      Logger.info('🎵 Fetching featured playlists');
      
      final response = await _apiService.get('/api/spotify/featured');
      
      if (response.statusCode == 200) {
        final playlists = response.data['data']['playlists'] as List;
        Logger.info('✅ Featured playlists fetched: ${playlists.length} items');
        return playlists.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      Logger.error('❌ Error fetching featured playlists: $e');
    }
    return [];
  }

  /// Search tracks by mood
  Future<List<Map<String, dynamic>>> searchTracksByMood(String mood, {int limit = 20}) async {
    try {
      Logger.info('🔍 Searching tracks for mood: $mood');
      
      final response = await _apiService.get(
        '/api/spotify/tracks',
        queryParameters: {
          'mood': mood, 
          'limit': limit.toString()
        },
      );
      
      if (response.statusCode == 200) {
        final tracks = response.data['data']['tracks'] as List;
        Logger.info('✅ Tracks found: ${tracks.length} items');
        return tracks.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      Logger.error('❌ Error searching tracks: $e');
    }
    return [];
  }

  /// Get music recommendations only
  Future<Map<String, dynamic>?> getMusicRecommendations(String emotion) async {
    try {
      Logger.info('🎵 Fetching music recommendations for: $emotion');
      
      final response = await _apiService.get(
        '/api/recommendations/music',
        queryParameters: {'emotion': emotion},
      );
      
      if (response.statusCode == 200) {
        Logger.info('✅ Music recommendations fetched successfully');
        return response.data['data'];
      }
    } catch (e) {
      Logger.error('❌ Error fetching music recommendations: $e');
    }
    return null;
  }

  /// Get activity recommendations
  Future<Map<String, dynamic>?> getActivityRecommendations({
    required String emotion,
    String? timeOfDay,
    String? weather,
  }) async {
    try {
      Logger.info('🏃 Fetching activity recommendations for: $emotion');
      
      final queryParams = {'emotion': emotion};
      if (timeOfDay != null) queryParams['timeOfDay'] = timeOfDay;
      if (weather != null) queryParams['weather'] = weather;
      
      final response = await _apiService.get(
        '/api/recommendations/activities',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        Logger.info('✅ Activity recommendations fetched successfully');
        return response.data['data'];
      }
    } catch (e) {
      Logger.error('❌ Error fetching activity recommendations: $e');
    }
    return null;
  }

  /// Get wellness recommendations
  Future<Map<String, dynamic>?> getWellnessRecommendations({
    required String emotion,
    int intensity = 5,
  }) async {
    try {
      Logger.info('🧘 Fetching wellness recommendations for: $emotion');
      
      final response = await _apiService.get(
        '/api/recommendations/wellness',
        queryParameters: {
          'emotion': emotion,
          'intensity': intensity.toString(),
        },
      );
      
      if (response.statusCode == 200) {
        Logger.info('✅ Wellness recommendations fetched successfully');
        return response.data['data'];
      }
    } catch (e) {
      Logger.error('❌ Error fetching wellness recommendations: $e');
    }
    return null;
  }

  /// Get mood characteristics (energy, valence) for a given emotion
  Map<String, double> getMoodCharacteristics(String emotion, int intensity) {
    final intensityFloat = intensity / 10.0;
    
    final moodMap = {
      'happy': {'baseEnergy': 0.8, 'baseValence': 0.9},
      'joy': {'baseEnergy': 0.9, 'baseValence': 0.95},
      'excited': {'baseEnergy': 0.95, 'baseValence': 0.85},
      'calm': {'baseEnergy': 0.2, 'baseValence': 0.7},
      'peaceful': {'baseEnergy': 0.1, 'baseValence': 0.8},
      'sad': {'baseEnergy': 0.2, 'baseValence': 0.2},
      'angry': {'baseEnergy': 0.9, 'baseValence': 0.1},
      'frustrated': {'baseEnergy': 0.8, 'baseValence': 0.2},
      'anxious': {'baseEnergy': 0.7, 'baseValence': 0.3},
      'stressed': {'baseEnergy': 0.6, 'baseValence': 0.3},
      'love': {'baseEnergy': 0.6, 'baseValence': 0.9},
      'grateful': {'baseEnergy': 0.5, 'baseValence': 0.9},
      'gratitude': {'baseEnergy': 0.5, 'baseValence': 0.9},
    };

    final mood = moodMap[emotion.toLowerCase()] ?? {'baseEnergy': 0.5, 'baseValence': 0.5};
    
    return {
      'energy': (mood['baseEnergy']! + (intensityFloat - 0.5) * 0.3).clamp(0.0, 1.0),
      'valence': (mood['baseValence']! + (intensityFloat - 0.5) * 0.2).clamp(0.0, 1.0),
    };
  }

  /// Get Spotify search terms for a given emotion
  List<String> getSpotifySearchTerms(String emotion) {
    final termMap = {
      'happy': ['happy hits', 'feel good music', 'upbeat pop', 'positive vibes'],
      'joy': ['joyful music', 'celebration songs', 'happy dance', 'uplifting pop'],
      'excited': ['party music', 'dance hits', 'energetic songs', 'pump up'],
      'sad': ['sad songs', 'melancholy indie', 'emotional ballads', 'comfort music'],
      'calm': ['chill out', 'relaxing music', 'peaceful sounds', 'ambient chill'],
      'angry': ['rock anthems', 'metal hits', 'aggressive music', 'punk rock'],
      'love': ['love songs', 'romantic music', 'r&b classics', 'valentine songs'],
      'grateful': ['grateful songs', 'thankful music', 'inspirational', 'positive'],
      'gratitude': ['gratitude music', 'thankful songs', 'appreciation', 'blessed'],
      'anxious': ['calming music', 'anxiety relief', 'meditation sounds', 'peaceful'],
      'stressed': ['stress relief', 'relaxation music', 'calming sounds', 'zen']
    };
    
    return termMap[emotion.toLowerCase()] ?? 
           ['mood music', 'emotional songs', '${emotion} playlist'];
  }

  /// Get local fallback recommendations when API is unavailable
  Map<String, dynamic> getFallbackRecommendations(String emotion) {
    return {
      'music': _getFallbackMusicRecs(emotion),
      'activities': _getFallbackActivityRecs(emotion),
      'wellness': _getFallbackWellnessRecs(emotion),
      'tips': _getFallbackTips(emotion),
    };
  }

  Map<String, dynamic> _getFallbackMusicRecs(String emotion) {
    final recommendations = {
      'happy': {
        'title': 'Feel Good Hits',
        'description': 'Uplifting songs to match your joy',
        'genres': ['Pop', 'Dance', 'Indie'],
        'searchTerms': ['happy music', 'feel good', 'upbeat'],
      },
      'sad': {
        'title': 'Comfort & Healing',
        'description': 'Gentle melodies for emotional support',
        'genres': ['Indie', 'Acoustic', 'Folk'],
        'searchTerms': ['sad songs', 'comfort music', 'healing'],
      },
      'calm': {
        'title': 'Peaceful Vibes',
        'description': 'Serene sounds for tranquil moments',
        'genres': ['Ambient', 'Classical', 'Lo-Fi'],
        'searchTerms': ['chill music', 'peaceful', 'relaxing'],
      },
      'grateful': {
        'title': 'Gratitude & Grace',
        'description': 'Inspirational music for thankful hearts',
        'genres': ['Gospel', 'Inspirational', 'Folk'],
        'searchTerms': ['grateful music', 'thankful songs', 'blessed'],
      },
    };

    return recommendations[emotion.toLowerCase()] ?? recommendations['calm']!;
  }

  List<Map<String, dynamic>> _getFallbackActivityRecs(String emotion) {
    final activities = {
      'happy': [
        {'title': 'Dance to your favorite music', 'duration': '10-15 min', 'category': 'physical'},
        {'title': 'Call a friend to share good news', 'duration': '15-30 min', 'category': 'social'},
        {'title': 'Take photos of beautiful things', 'duration': '15-30 min', 'category': 'creative'},
      ],
      'sad': [
        {'title': 'Write in a journal', 'duration': '15-20 min', 'category': 'reflection'},
        {'title': 'Take a warm bath', 'duration': '20-30 min', 'category': 'self-care'},
        {'title': 'Listen to comforting music', 'duration': '30+ min', 'category': 'entertainment'},
      ],
      'calm': [
        {'title': 'Practice meditation', 'duration': '10-20 min', 'category': 'wellness'},
        {'title': 'Read a book', 'duration': '30+ min', 'category': 'entertainment'},
        {'title': 'Do gentle yoga', 'duration': '20-30 min', 'category': 'physical'},
      ],
      'anxious': [
        {'title': 'Practice deep breathing', 'duration': '5-10 min', 'category': 'wellness'},
        {'title': 'Go for a walk', 'duration': '15-20 min', 'category': 'physical'},
        {'title': 'Listen to calming music', 'duration': '20-30 min', 'category': 'entertainment'},
      ],
    };

    return activities[emotion.toLowerCase()] ?? activities['calm']!;
  }

  Map<String, dynamic> _getFallbackWellnessRecs(String emotion) {
    return {
      'breathing': [
        {
          'name': '4-7-8 Breathing',
          'description': 'Inhale for 4, hold for 7, exhale for 8',
          'duration': '5-10 minutes',
        }
      ],
      'mindfulness': [
        {
          'title': 'Body scan meditation',
          'duration': '10-20 min',
          'description': 'Progressive awareness of physical sensations',
        }
      ],
    };
  }

  List<String> _getFallbackTips(String emotion) {
    final tips = {
      'happy': [
        'Share your joy with others to amplify it',
        'Capture this moment in a photo or journal',
        'Use this positive energy for productive activities',
      ],
      'sad': [
        'Remember that sadness is temporary',
        'Reach out to supportive friends or family',
        'Be gentle with yourself during this time',
      ],
      'grateful': [
        'Express your gratitude to someone specific',
        'Write down three things you\'re grateful for',
        'Share what you\'re grateful for with others',
      ],
    };

    return tips[emotion.toLowerCase()] ?? [
      'Take care of yourself during this time',
      'This feeling will pass',
      'Consider what this emotion might be telling you',
    ];
  }

  /// Validate internet connection and API availability
  Future<bool> isServiceAvailable() async {
    try {
      final response = await _apiService.get('/api/health');
      return response.statusCode == 200;
    } catch (e) {
      Logger.warning('⚠️ Service availability check failed: $e');
      return false;
    }
  }

  /// Get cached recommendations if available
  Map<String, dynamic>? getCachedRecommendations(String emotion) {
    // Implement caching logic here if needed
    // For now, return null to always fetch fresh data
    return null;
  }

  /// Cache recommendations for offline use
  void cacheRecommendations(String emotion, Map<String, dynamic> recommendations) {
    // Implement caching logic here
    Logger.info('💾 Caching recommendations for $emotion');
  }
} 