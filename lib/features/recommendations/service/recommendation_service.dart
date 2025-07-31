import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class HybridTrackList extends StatefulWidget {
final List<Map<String, dynamic>> spotifyTracks; 

  const HybridTrackList({super.key, required this.spotifyTracks});

  @override
  State<HybridTrackList> createState() => _HybridTrackListState();
}

class _HybridTrackListState extends State<HybridTrackList> {
  final Map<int, String?> _jamendoUrls = {};
  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  bool _loading = false;
  
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _fetchJamendoUrls();
  }

  Future<void> _fetchJamendoUrls() async {
if (!mounted) return; 
    
    setState(() => _loading = true);
    for (int i = 0; i < widget.spotifyTracks.length; i++) {
if (!mounted) break; 
      
      final track = widget.spotifyTracks[i];
      final url = await findJamendoStreamUrl(track['title'], track['artist']);
      
if (!mounted) break; 
      
      _jamendoUrls[i] = url;
setState(() {}); 
    }
    
if (mounted) { 
      setState(() => _loading = false);
    }
  }

  Future<String?> findJamendoStreamUrl(String title, String artist) async {
    try {
      final clientId = '7e49a9e7';
      final url = Uri.parse(
        'https:////api.jamendo.com/v3/tracks/',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['audio'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching Jamendo URL: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _play(int index, String url) async {
    try {
      await _player.setUrl(url);
      _player.play();
      
if (!mounted) return; 
      setState(() => _playingIndex = index);
      
      _playerStateSubscription?.cancel();
      _playerStateSubscription = _player.playerStateStream.listen((state) {
if (!mounted) return; 
        
        if (state.processingState == ProcessingState.completed) {
          setState(() => _playingIndex = null);
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        setState(() => _playingIndex = null);
      }
    }
  }

  void _openSpotify(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error opening Spotify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
if (!mounted) return Container(); 
    
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.spotifyTracks.length,
      itemBuilder: (context, i) {
        final track = widget.spotifyTracks[i];
        final jamendoUrl = _jamendoUrls[i];
        return ListTile(
          leading: Icon(
            jamendoUrl != null ? Icons.play_circle : Icons.music_note, 
            color: Colors.green
          ),
          title: Text('${track['title']}'),
          subtitle: Text('${track['artist']}'),
          trailing: jamendoUrl != null
              ? IconButton(
                  icon: Icon(_playingIndex == i ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
if (!mounted) return; 
                    
                    if (_playingIndex == i) {
                      _player.pause();
                      setState(() => _playingIndex = null);
                    } else {
                      _play(i, jamendoUrl);
                    }
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => _openSpotify(track['spotifyUrl']),
                  tooltip: 'Play on Spotify',
                ),
        );
      },
    );
  }
}