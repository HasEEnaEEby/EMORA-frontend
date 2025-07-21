import 'package:emora_mobile_app/core/services/spotify_service.dart';
import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/mood_selection_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/music_player_widget.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/spotify_playlist_card.dart';
import 'package:flutter/material.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String? initialMood;

  const MusicPlayerScreen({
    Key? key,
    this.initialMood,
  }) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late SpotifyService _spotifyService;
  String? _selectedMood;
  SpotifyPlaylist? _currentPlaylist;
  bool _showMusicPlayer = false;

  @override
  void initState() {
    super.initState();
    _spotifyService = SpotifyService();
    _selectedMood = widget.initialMood;
  }

  @override
  void dispose() {
    _spotifyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music for Your Mood'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFeaturedPlaylists,
            icon: const Icon(Icons.featured_play_list),
            tooltip: 'Featured Playlists',
          ),
          IconButton(
            onPressed: _showSpotifyAuth,
            icon: const Icon(Icons.login),
            tooltip: 'Connect Spotify',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Mood selection
                MoodSelectionWidget(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) {
                    setState(() {
                      _selectedMood = mood;
                    });
                  },
                ),
                
                // Playlist card
                if (_selectedMood != null)
                  SpotifyPlaylistCard(
                    mood: _selectedMood!,
                    spotifyService: _spotifyService,
                    onPlaylistLoaded: (playlist) {
                      setState(() {
                        _currentPlaylist = playlist;
                        _showMusicPlayer = true;
                      });
                    },
                  ),
                
                // Bottom padding for music player
                if (_showMusicPlayer) const SizedBox(height: 120),
              ],
            ),
          ),
          
          // Music player overlay
          if (_showMusicPlayer)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MusicPlayerWidget(
                spotifyService: _spotifyService,
                onClose: () {
                  setState(() {
                    _showMusicPlayer = false;
                  });
                  _spotifyService.stop();
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showFeaturedPlaylists() {
    // Implementation for featured playlists
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Featured playlists coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSpotifyAuth() {
    // Implementation for Spotify authentication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Spotify authentication coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}