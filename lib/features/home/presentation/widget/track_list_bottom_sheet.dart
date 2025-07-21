import 'package:emora_mobile_app/core/services/spotify_service.dart';
import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:emora_mobile_app/features/home/presentation/widget/Track_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TrackListBottomSheet extends StatefulWidget {
  final SpotifyPlaylist playlist;
  final SpotifyService spotifyService;

  const TrackListBottomSheet({
    Key? key,
    required this.playlist,
    required this.spotifyService,
  }) : super(key: key);

  @override
  State<TrackListBottomSheet> createState() => _TrackListBottomSheetState();
}

class _TrackListBottomSheetState extends State<TrackListBottomSheet> {
  late AudioPlayer _audioPlayer;
  int? _currentTrackIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _playNextTrack();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playTrack(SpotifyTrack track, int index) async {
    if (!track.hasPreview) return;
    setState(() {
      _currentTrackIndex = index;
      _isPlaying = true;
    });
    await _audioPlayer.setUrl(track.preview!);
    await _audioPlayer.play();
  }

  void _playNextTrack() async {
    if (_currentTrackIndex == null) return;
    final tracks = widget.playlist.tracks;
    int nextIndex = _currentTrackIndex! + 1;
    while (nextIndex < tracks.length && !tracks[nextIndex].hasPreview) {
      nextIndex++;
    }
    if (nextIndex < tracks.length) {
      _playTrack(tracks[nextIndex], nextIndex);
    } else {
      setState(() {
        _isPlaying = false;
        _currentTrackIndex = null;
      });
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else if (_currentTrackIndex != null) {
      await _audioPlayer.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playableTracks = widget.playlist.tracks.where((t) => t.hasPreview).toList();
    if (playableTracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No previews available for this playlist.'),
            ElevatedButton(
              onPressed: () => widget.spotifyService.openInSpotify(widget.playlist.spotifyUrl ?? ''),
              child: Text('Open in Spotify'),
            ),
          ],
        ),
      );
    }
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.playlist.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.playlist.trackCount} tracks • ${widget.playlist.duration}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Playlist controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _togglePlayPause,
                    ),
                    if (_currentTrackIndex != null)
                      Text('Playing: ${widget.playlist.tracks[_currentTrackIndex!].name}'),
                  ],
                ),
              ),
              const Divider(),
              // Track list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.playlist.tracks.length,
                  itemBuilder: (context, index) {
                    final track = widget.playlist.tracks[index];
                    final isCurrentTrack = _currentTrackIndex == index;
                    return TrackListTile(
                      track: track,
                      index: index,
                      isCurrentTrack: isCurrentTrack,
                      isPlaying: isCurrentTrack && _isPlaying,
                      onTap: track.hasPreview ? () => _playTrack(track, index) : null,
                      onOpenSpotify: () => widget.spotifyService.openInSpotify(track.spotifyUrl),
                      audioPlayer: _audioPlayer,
                      onPlaybackComplete: _playNextTrack,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
