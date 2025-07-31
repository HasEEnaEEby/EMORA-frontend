import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:get_it/get_it.dart';
import 'package:emora_mobile_app/core/network/api_service.dart';
import 'package:emora_mobile_app/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

class SpotifyService {
  final ApiService _apiService = GetIt.instance<ApiService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<SpotifyTrack> _currentPlaylist = [];
  int _currentTrackIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;
  
  List<SpotifyTrack> get currentPlaylist => _currentPlaylist;
  int get currentTrackIndex => _currentTrackIndex;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  SpotifyTrack? get currentTrack => 
    _currentPlaylist.isNotEmpty ? _currentPlaylist[_currentTrackIndex] : null;

  Stream<PlayerState> get playerStateStream => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<Duration?> get durationStream => _audioPlayer.onDurationChanged;

  Future<SpotifyPlaylist?> getPlaylistForMood(String mood) async {
    try {
      Logger.info('🎵 Fetching playlist for mood: $mood');
      _isLoading = true;
      
      final response = await _apiService.get(
        '/api/spotify/playlist',
        queryParameters: {'mood': mood.toLowerCase()},
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final playlist = SpotifyPlaylist.fromJson(data['playlist']);
        
        Logger.info('✅ Playlist fetched: ${playlist.name} (${playlist.tracks.length} tracks)');
        
        _currentPlaylist = playlist.tracks;
        _currentTrackIndex = 0;
        
        return playlist;
      } else {
        Logger.warning('⚠️ Playlist request failed: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      Logger.error('❌ Error fetching playlist: $e');
    }
    return null;
  }

  Future<List<SpotifyTrack>> searchTracksByMood(String mood, {int limit = 20}) async {
    try {
      Logger.info('🔍 Searching tracks for mood: $mood');
      
      final response = await _apiService.get(
        '/api/spotify/tracks',
        queryParameters: {
          'mood': mood.toLowerCase(),
          'limit': limit.toString()
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final tracks = (data['tracks'] as List)
            .map((track) => SpotifyTrack.fromJson(track))
            .toList();
        
        Logger.info('✅ Found ${tracks.length} tracks for mood: $mood');
        return tracks;
      }
    } catch (e) {
      Logger.error('❌ Error searching tracks: $e');
    }
    return [];
  }

  Future<List<SpotifyPlaylist>> getFeaturedPlaylists() async {
    try {
      Logger.info('🎵 Fetching featured playlists');
      
      final response = await _apiService.get('/api/spotify/featured');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final playlists = (data['playlists'] as List)
            .map((playlist) => SpotifyPlaylist.fromJson(playlist))
            .toList();
        
        Logger.info('✅ Found ${playlists.length} featured playlists');
        return playlists;
      }
    } catch (e) {
      Logger.error('❌ Error fetching featured playlists: $e');
    }
    return [];
  }

  Future<void> playTrack(SpotifyTrack track) async {
    try {
      if (track.preview == null || track.preview!.isEmpty) {
        Logger.warning('⚠️ No preview available for track: ${track.name}');
        throw Exception('No preview available for this track');
      }

      Logger.info('▶️ Playing track: ${track.name} by ${track.artists}');
      
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(track.preview!));
      _isPlaying = true;
      
      final trackIndex = _currentPlaylist.indexWhere((t) => t.id == track.id);
      if (trackIndex != -1) {
        _currentTrackIndex = trackIndex;
      }
      
    } catch (e) {
      Logger.error('❌ Error playing track: $e');
      _isPlaying = false;
      rethrow;
    }
  }

  Future<void> playPlaylist({int startIndex = 0}) async {
    if (_currentPlaylist.isEmpty) {
      throw Exception('No playlist loaded');
    }

    _currentTrackIndex = startIndex.clamp(0, _currentPlaylist.length - 1);
    await playTrack(_currentPlaylist[_currentTrackIndex]);
  }

  Future<void> playNext() async {
    if (_currentPlaylist.isEmpty) return;
    
    _currentTrackIndex = (_currentTrackIndex + 1) % _currentPlaylist.length;
    await playTrack(_currentPlaylist[_currentTrackIndex]);
  }

  Future<void> playPrevious() async {
    if (_currentPlaylist.isEmpty) return;
    
    _currentTrackIndex = _currentTrackIndex > 0 
        ? _currentTrackIndex - 1 
        : _currentPlaylist.length - 1;
    await playTrack(_currentPlaylist[_currentTrackIndex]);
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    Logger.info('⏸️ Track paused');
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    Logger.info('▶️ Track resumed');
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    Logger.info('⏹️ Track stopped');
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> openInSpotify(String spotifyUrl) async {
    try {
      final uri = Uri.parse(spotifyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Logger.info('🎵 Opened in Spotify: $spotifyUrl');
      } else {
        throw Exception('Cannot open Spotify URL');
      }
    } catch (e) {
      Logger.error('❌ Error opening Spotify: $e');
      rethrow;
    }
  }

  Future<String?> getSpotifyAuthUrl() async {
    try {
      final response = await _apiService.get('/api/spotify/auth-url');
      
      if (response.statusCode == 200) {
        return response.data['data']['authUrl'];
      }
    } catch (e) {
      Logger.error('❌ Error getting auth URL: $e');
    }
    return null;
  }

  Future<bool> handleSpotifyAuth(String authCode) async {
    try {
      final response = await _apiService.post(
        '/api/spotify/callback',
        data: {'code': authCode},
      );

      if (response.statusCode == 200) {
        Logger.info('✅ Spotify authorization successful');
        return true;
      }
    } catch (e) {
      Logger.error('❌ Error handling Spotify auth: $e');
    }
    return false;
  }

  void shufflePlaylist() {
    if (_currentPlaylist.isEmpty) return;
    
    final currentTrack = _currentPlaylist[_currentTrackIndex];
    _currentPlaylist.shuffle();
    
    final newIndex = _currentPlaylist.indexWhere((t) => t.id == currentTrack.id);
    if (newIndex != -1 && newIndex != 0) {
      _currentPlaylist.removeAt(newIndex);
      _currentPlaylist.insert(0, currentTrack);
      _currentTrackIndex = 0;
    }
    
    Logger.info('🔀 Playlist shuffled');
  }

  void clearPlaylist() {
    _currentPlaylist.clear();
    _currentTrackIndex = 0;
    stop();
    Logger.info('🗑️ Playlist cleared');
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

