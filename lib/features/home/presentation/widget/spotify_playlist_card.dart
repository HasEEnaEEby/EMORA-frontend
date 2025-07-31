import 'package:emora_mobile_app/core/services/spotify_service.dart';
import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/track_list_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

class SpotifyPlaylistCard extends StatefulWidget {
  final String mood;
  final SpotifyService spotifyService;
  final Function(SpotifyPlaylist)? onPlaylistLoaded;

  const SpotifyPlaylistCard({
    Key? key,
    required this.mood,
    required this.spotifyService,
    this.onPlaylistLoaded,
  }) : super(key: key);

  @override
  State<SpotifyPlaylistCard> createState() => _SpotifyPlaylistCardState();
}

class _SpotifyPlaylistCardState extends State<SpotifyPlaylistCard> {
  SpotifyPlaylist? _playlist;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final playlist = await widget.spotifyService.getPlaylistForMood(widget.mood);
      if (mounted) {
        setState(() {
          _playlist = playlist;
          _isLoading = false;
        });
        
        if (playlist != null && widget.onPlaylistLoaded != null) {
          widget.onPlaylistLoaded!(playlist);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      Logger.error('❌ Error loading playlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: _getMoodGradient(widget.mood),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_playlist == null) {
      return _buildEmptyState();
    }

    return _buildPlaylistContent();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Creating your ${widget.mood} playlist...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load playlist',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPlaylist,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_off, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(
            'No playlist available',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find music for this mood right now',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistContent() {
    final playlist = _playlist!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: playlist.coverImage != null
                    ? Image.network(
                        playlist.coverImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultCover(),
                      )
                    : _buildDefaultCover(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playlist.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.trackCount} tracks • ${playlist.duration}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _playAllPreviews(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text(
                    'Play All Previews',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showTrackList(),
                icon: const Icon(Icons.queue_music, color: Colors.white),
                tooltip: 'View tracks',
              ),
              IconButton(
                onPressed: () => _shufflePlaylist(),
                icon: const Icon(Icons.shuffle, color: Colors.white),
                tooltip: 'Shuffle',
              ),
              IconButton(
                onPressed: _loadPlaylist,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Generate new playlist',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: Wrap(
            spacing: 8,
            children: [
              _buildMoodChip('Energy: ${(playlist.energy * 100).round()}%'),
              _buildMoodChip('Positivity: ${(playlist.valence * 100).round()}%'),
              ...playlist.genres.take(3).map((genre) => _buildMoodChip(genre)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.library_music,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildMoodChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Color> _getMoodGradient(String mood) {
    final gradients = {
      'happy': [const Color(0xFFFFD700), const Color(0xFFFF6B6B)],
      'sad': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      'calm': [const Color(0xFF10B981), const Color(0xFF059669)],
      'energetic': [const Color(0xFFEF4444), const Color(0xFFF97316)],
      'romantic': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      'focus': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      'angry': [const Color(0xFFDC2626), const Color(0xFF991B1B)],
      'excited': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'nostalgic': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
      'confident': [const Color(0xFF059669), const Color(0xFF047857)],
      'anxious': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      'grateful': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
      'stressed': [const Color(0xFF64748B), const Color(0xFF475569)],
    };

    return gradients[mood.toLowerCase()] ?? 
           [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
  }

  Future<void> _playPlaylist() async {
    try {
      await widget.spotifyService.playPlaylist();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playing ${_playlist!.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing playlist: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _shufflePlaylist() {
    widget.spotifyService.shufflePlaylist();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist shuffled'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _playAllPreviews() {
    _showTrackList(playAll: true);
  }

  void _showTrackList({bool playAll = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TrackListBottomSheet(
        playlist: _playlist!,
        spotifyService: widget.spotifyService,
      ),
    );
  }
}