// lib/widgets/music_player_widget.dart
import 'package:emora_mobile_app/core/services/spotify_service.dart';
import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';

// =======================================================================
// Main Music Player Widget (Bottom Player)
// =======================================================================

class MusicPlayerWidget extends StatefulWidget {
  final SpotifyService spotifyService;
  final VoidCallback? onClose;
  final VoidCallback? onExpand;
  final bool showCloseButton;

  const MusicPlayerWidget({
    Key? key,
    required this.spotifyService,
    this.onClose,
    this.onExpand,
    this.showCloseButton = true,
  }) : super(key: key);

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget>
    with TickerProviderStateMixin {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioListeners();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
  }

  void _setupAudioListeners() {
    widget.spotifyService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    widget.spotifyService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    widget.spotifyService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.paused; // Simplified state
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.spotifyService.currentTrack;
    
    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOut,
      )),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            _buildProgressBar(),
            
            // Main player content
            _buildPlayerContent(currentTrack),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      child: LinearProgressIndicator(
        value: _duration.inMilliseconds > 0 
            ? _position.inMilliseconds / _duration.inMilliseconds 
            : 0.0,
        backgroundColor: Colors.white.withOpacity(0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildPlayerContent(SpotifyTrack track) {
    return GestureDetector(
      onTap: widget.onExpand,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Album art with animation
            _buildAlbumArt(track),
            
            const SizedBox(width: 16),
            
            // Track info
            Expanded(child: _buildTrackInfo(track)),
            
            // Control buttons
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumArt(SpotifyTrack track) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPlaying ? 1.0 + (_pulseController.value * 0.05) : 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                track.image != null
                    ? Image.network(
                        track.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultAlbumArt(),
                      )
                    : _buildDefaultAlbumArt(),
                
                // Playing indicator overlay
                if (_isPlaying)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.graphic_eq,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAlbumArt() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildTrackInfo(SpotifyTrack track) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          track.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          track.artists,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.spotifyService.playPrevious,
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 24,
        ),
        
        _buildPlayPauseButton(),
        
        IconButton(
          onPressed: widget.spotifyService.playNext,
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 24,
        ),
        
        if (widget.showCloseButton)
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close, color: Colors.white),
            iconSize: 20,
          ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: _togglePlayPause,
        icon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
      ),
    );
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.spotifyService.pause();
    } else {
      widget.spotifyService.resume();
    }
  }
}

// =======================================================================
// Full Screen Music Player
// =======================================================================

class FullScreenMusicPlayer extends StatefulWidget {
  final SpotifyService spotifyService;

  const FullScreenMusicPlayer({
    Key? key,
    required this.spotifyService,
  }) : super(key: key);

  @override
  State<FullScreenMusicPlayer> createState() => _FullScreenMusicPlayerState();
}

class _FullScreenMusicPlayerState extends State<FullScreenMusicPlayer>
    with TickerProviderStateMixin {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  late AnimationController _rotationController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudioListeners();
  }

  void _setupAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController.forward();
  }

  void _setupAudioListeners() {
    widget.spotifyService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    widget.spotifyService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    widget.spotifyService.playerStateStream.listen((state) {
      if (mounted) {
        final playing = state == PlayerState.playing;
        setState(() {
          _isPlaying = playing;
        });
        
        if (playing) {
          _rotationController.repeat();
        } else {
          _rotationController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.spotifyService.currentTrack;
    
    if (currentTrack == null) {
      return Scaffold(
        body: Center(
          child: Text('No track selected'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOut,
            )),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildAlbumArtSection(currentTrack)),
                _buildTrackInfo(currentTrack),
                _buildProgressSection(),
                _buildControlsSection(),
                _buildBottomActions(currentTrack),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.keyboard_arrow_down, 
                color: Colors.white, size: 32),
          ),
          Column(
            children: [
              Text(
                'PLAYING FROM PLAYLIST',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                widget.spotifyService.currentPlaylist.isNotEmpty 
                    ? 'Mood Playlist'
                    : 'Single Track',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _showOptions,
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArtSection(SpotifyTrack track) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        margin: const EdgeInsets.all(40),
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: track.image != null
                      ? Image.network(
                          track.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultFullAlbumArt(),
                        )
                      : _buildDefaultFullAlbumArt(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultFullAlbumArt() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 100,
      ),
    );
  }

  Widget _buildTrackInfo(SpotifyTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            track.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            track.artists,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0 
                  ? _position.inMilliseconds / _duration.inMilliseconds 
                  : 0.0,
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                );
                widget.spotifyService.seek(newPosition);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _toggleShuffle,
            icon: Icon(
              Icons.shuffle,
              color: _isShuffled ? Colors.white : Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
          IconButton(
            onPressed: widget.spotifyService.playPrevious,
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _togglePlayPause,
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Theme.of(context).primaryColor,
                size: 36,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.spotifyService.playNext,
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
          ),
          IconButton(
            onPressed: _toggleRepeat,
            icon: Icon(
              _isRepeating ? Icons.repeat_one : Icons.repeat,
              color: _isRepeating ? Colors.white : Colors.white.withOpacity(0.5),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(SpotifyTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => widget.spotifyService.openInSpotify(track.spotifyUrl),
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            tooltip: 'Open in Spotify',
          ),
          IconButton(
            onPressed: _showQueue,
            icon: const Icon(Icons.queue_music, color: Colors.white),
            tooltip: 'Show queue',
          ),
          IconButton(
            onPressed: _shareTrack,
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share',
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      widget.spotifyService.pause();
    } else {
      widget.spotifyService.resume();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffled = !_isShuffled;
    });
    if (_isShuffled) {
      widget.spotifyService.shufflePlaylist();
    }
  }

  void _toggleRepeat() {
    setState(() {
      _isRepeating = !_isRepeating;
    });
    // Implement repeat logic in SpotifyService if needed
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to playlist'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Song info'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showQueue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QueueScreen(spotifyService: widget.spotifyService),
      ),
    );
  }

  void _shareTrack() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}

// =======================================================================
// Queue Screen
// =======================================================================

class QueueScreen extends StatelessWidget {
  final SpotifyService spotifyService;

  const QueueScreen({
    Key? key,
    required this.spotifyService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: spotifyService.currentPlaylist.length,
        itemBuilder: (context, index) {
          final track = spotifyService.currentPlaylist[index];
          final isCurrentTrack = spotifyService.currentTrackIndex == index;
          
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: track.image != null
                  ? Image.network(
                      track.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.music_note),
                    ),
            ),
            title: Text(
              track.name,
              style: TextStyle(
                fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                color: isCurrentTrack ? Theme.of(context).primaryColor : null,
              ),
            ),
            subtitle: Text(track.artists),
            trailing: isCurrentTrack
                ? Icon(
                    spotifyService.isPlaying ? Icons.volume_up : Icons.pause,
                    color: Theme.of(context).primaryColor,
                  )
                : null,
            onTap: () async {
              await spotifyService.playTrack(track);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

// =======================================================================
// Mini Player Widget (for other screens)
// =======================================================================

class MiniMusicPlayer extends StatefulWidget {
  final SpotifyService spotifyService;
  final VoidCallback? onTap;

  const MiniMusicPlayer({
    Key? key,
    required this.spotifyService,
    this.onTap,
  }) : super(key: key);

  @override
  State<MiniMusicPlayer> createState() => _MiniMusicPlayerState();
}

class _MiniMusicPlayerState extends State<MiniMusicPlayer> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.spotifyService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.spotifyService.currentTrack;
    
    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: currentTrack.image != null
                  ? Image.network(
                      currentTrack.image!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      color: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentTrack.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    currentTrack.artists,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                if (_isPlaying) {
                  widget.spotifyService.pause();
                } else {
                  widget.spotifyService.resume();
                }
              },
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}