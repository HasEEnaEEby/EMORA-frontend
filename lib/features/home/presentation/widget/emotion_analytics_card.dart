import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:emora_mobile_app/features/recommendations/service/recommendation_service.dart';

class EmotionAnalyticsCard extends StatelessWidget {
  final List<Map<String, dynamic>>? weeklyMoodData;
  final Map<String, dynamic>? analyticsData;
  final bool isNewUser;
  final String dominantMood; // Pass this from analytics

  const EmotionAnalyticsCard({
    super.key,
    this.weeklyMoodData,
    this.analyticsData,
    this.isNewUser = false,
    required this.dominantMood,
  });

  List<Map<String, dynamic>> get _effectiveWeeklyMoodData {
    if (weeklyMoodData != null && weeklyMoodData!.isNotEmpty) {
      return weeklyMoodData!;
    }
    return [];
  }

  Future<Map<String, dynamic>?> _fetchSpotifyPlaylist(String mood) async {
    try {
      final apiService = GetIt.instance<ApiService>();
      final response = await apiService.get(
        '/api/spotify/playlist',
        queryParameters: {'mood': mood},
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Spotify playlist fetched for mood: $mood');
        return response.data['data']['playlist'];
      } else {
        Logger.warning('⚠️ Spotify playlist request failed: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('❌ Error fetching Spotify playlist: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchSpotifyPlaylist(dominantMood),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildEmptyState();
        }
        final playlist = snapshot.data!;
        final tracks = (playlist['tracks'] as List<dynamic>? ?? [])
            .map<Map<String, dynamic>>((track) => {
                  'title': track['name'] ?? '',
                  'artist': track['artists'] ?? '',
                  'spotifyUrl': track['spotifyUrl'] ?? '',
                  'album': track['album'] ?? '',
                  'duration': track['duration'] ?? '',
                })
            .toList();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF2A2A3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        image: playlist['imageUrl'] != null
                            ? DecorationImage(
                                image: NetworkImage(playlist['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: playlist['imageUrl'] == null
                          ? const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist['name'] ?? 'Playlist',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            playlist['description'] ?? '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (tracks.isNotEmpty)
                  SizedBox(
                    height: 300, // Adjust as needed
                    child: HybridTrackList(spotifyTracks: tracks),
                  )
                else
                  Text(
                    'No tracks available for this playlist.',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Text(
          'Your Emotional Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Empty Chart Placeholder
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.1),
                const Color(0xFF6366F1).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: const Color(0xFF8B5CF6),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start logging emotions to see your patterns!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Empty Insights Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              width: 1,
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.2),
                const Color(0xFFD8A5FF).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized insights coming soon',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track emotions for a week to unlock patterns and insights',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.schedule_rounded,
                color: Colors.grey[500],
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMusicRecommendationSection(BuildContext context) {
    final musicRecommendation = _getMusicRecommendationForEmotion(dominantMood);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DB954), Color(0xFF1ED760)], // Spotify green
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.queue_music,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your mood playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      musicRecommendation['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      musicRecommendation['subtitle']!,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            musicRecommendation['description']!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSpotifyPlaylistRecommendations(context, dominantMood),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1DB954),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text(
                    'Find Playlists',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showComprehensiveRecommendations(context),
                icon: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: 'Get comprehensive recommendations',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _getMusicRecommendationForEmotion(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return {
          'title': 'Happy Vibes Playlist',
          'subtitle': 'Dance, laugh, and feel the joy!',
          'description': 'Perfect for lifting your spirits and getting everyone in a good mood.',
        };
      case 'sad':
        return {
          'title': 'Calm Down Playlist',
          'subtitle': 'Soothing tunes for a peaceful mind.',
          'description': 'Gentle melodies and calming beats to help you unwind and relax.',
        };
      case 'angry':
        return {
          'title': 'Energize Me Playlist',
          'subtitle': 'Get pumped up and ready to tackle the day!',
          'description': 'High-energy tracks to help you channel your energy and stay focused.',
        };
      case 'stressed':
        return {
          'title': 'Relax and Unwind Playlist',
          'subtitle': 'Take a deep breath and let go.',
          'description': 'Slow, soothing music to help you unwind and reduce stress.',
        };
      case 'excited':
        return {
          'title': 'Party Time Playlist',
          'subtitle': 'Let\'s celebrate and have fun!',
          'description': 'Upbeat tracks and energetic beats for a lively atmosphere.',
        };
      case 'calm':
        return {
          'title': 'Zen Mind Playlist',
          'subtitle': 'Find inner peace and tranquility.',
          'description': 'Soft, soothing music to help you meditate and find your center.',
        };
      case 'grateful':
      case 'gratitude':
        return {
          'title': 'Grateful Heart Playlist',
          'subtitle': 'Celebrate life\'s blessings.',
          'description': 'Inspirational music to help you appreciate the good things in life.',
        };
      case 'anxious':
        return {
          'title': 'Anxiety Relief Playlist',
          'subtitle': 'Calm your mind and find peace.',
          'description': 'Gentle, calming music to help reduce anxiety and promote relaxation.',
        };
      default:
        return {
          'title': 'Your Mood Playlist',
          'subtitle': 'Discover music that matches your current mood.',
          'description': 'Explore a variety of genres to find the perfect soundtrack for your emotions.',
        };
    }
  }

  void _showSpotifyPlaylistRecommendations(BuildContext context, String mood) async {
    try {
      final playlist = await _fetchSpotifyPlaylist(mood);
      
      if (playlist != null) {
        _showPlaylistDialog(context, playlist);
      } else {
        _showFallbackRecommendations(context, mood);
      }
    } catch (e) {
      Logger.error('❌ Error showing playlist recommendations: $e');
      _showFallbackRecommendations(context, mood);
    }
  }

  void _showPlaylistDialog(BuildContext context, Map<String, dynamic> playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(playlist['name'] ?? 'Playlist'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (playlist['description'] != null && playlist['description'].isNotEmpty)
              Text(playlist['description']),
            const SizedBox(height: 8),
            Text('${playlist['trackCount'] ?? 0} tracks'),
            const SizedBox(height: 16),
            if (playlist['tracks'] != null) ...[
              const Text('Sample tracks:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(playlist['tracks'] as List).take(3).map((track) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• ${track['name']} - ${track['artists']}'),
                )
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (playlist['spotifyUrl'] != null)
            ElevatedButton(
              onPressed: () {
                // Open Spotify URL
                Navigator.pop(context);
                // You can add URL launcher here
              },
              child: const Text('Open in Spotify'),
            ),
        ],
      ),
    );
  }

  void _showFallbackRecommendations(BuildContext context, String mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Music for $mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Here are some music suggestions for your $mood mood:'),
            const SizedBox(height: 16),
            Text(_getMusicRecommendationForEmotion(mood)['description']!),
            const SizedBox(height: 16),
            const Text('Try searching for:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._getSpotifySearchTerms(mood).map((term) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $term'),
              )
            ).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<String> _getSpotifySearchTerms(String mood) {
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
    
    return termMap[mood.toLowerCase()] ?? 
           ['mood music', 'emotional songs', '${mood} playlist'];
  }

  void _showComprehensiveRecommendations(BuildContext context) async {
    try {
      final apiService = GetIt.instance<ApiService>();
      final response = await apiService.get(
        '/api/recommendations/comprehensive',
        queryParameters: {
          'emotion': dominantMood,
          'intensity': '5',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _showComprehensiveDialog(context, data);
      } else {
        _showComprehensiveFallback(context);
      }
    } catch (e) {
      Logger.error('❌ Error fetching comprehensive recommendations: $e');
      _showComprehensiveFallback(context);
    }
  }

  void _showComprehensiveDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recommendations for ${data['emotion']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['music'] != null) ...[
                const Text('🎵 Music', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['music']['moodDescription'] ?? ''),
                const SizedBox(height: 8),
              ],
              if (data['activities'] != null && data['activities']['primary'] != null) ...[
                const Text('🏃 Activities', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(data['activities']['primary'] as List).map((activity) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• ${activity['title']} (${activity['duration']})'),
                  )
                ),
                const SizedBox(height: 8),
              ],
              if (data['wellness'] != null && data['wellness']['breathing'] != null) ...[
                const Text('🧘 Wellness', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(data['wellness']['breathing'] as List).take(2).map((exercise) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• ${exercise['name']} - ${exercise['description']}'),
                  )
                ),
                const SizedBox(height: 8),
              ],
              if (data['personalizedTips'] != null) ...[
                const Text('💡 Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(data['personalizedTips'] as List).take(3).map((tip) => 
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('• $tip'),
                  )
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComprehensiveFallback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recommendations for $dominantMood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎵 Music', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_getMusicRecommendationForEmotion(dominantMood)['description']!),
            const SizedBox(height: 16),
            const Text('🏃 Activities', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Take a walk'),
            const Text('• Practice deep breathing'),
            const Text('• Listen to calming music'),
            const SizedBox(height: 16),
            const Text('💡 Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• Take care of yourself'),
            const Text('• This feeling will pass'),
            const Text('• Reach out for support if needed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}