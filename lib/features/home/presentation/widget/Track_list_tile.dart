




import 'package:emora_mobile_app/features/home/data/model/spotify_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TrackListTile extends StatelessWidget {
  final SpotifyTrack track;
  final int index;
  final bool isCurrentTrack;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback onOpenSpotify;
  final AudioPlayer? audioPlayer;
  final VoidCallback? onPlaybackComplete;

  const TrackListTile({
    Key? key,
    required this.track,
    required this.index,
    required this.isCurrentTrack,
    required this.isPlaying,
    this.onTap,
    required this.onOpenSpotify,
    this.audioPlayer,
    this.onPlaybackComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isCurrentTrack ? Colors.green.withOpacity(0.1) : Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: track.image != null
                  ? Image.network(
                      track.image!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultTrackImage(),
                    )
                  : _buildDefaultTrackImage(),
            ),
            if (isCurrentTrack)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        ),
        title: Text(
          track.name,
          style: TextStyle(
            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTrack ? Colors.green : Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.artists,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                if (track.explicit)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'E',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  track.durationFormatted,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (!track.hasPreview) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.block,
                    size: 12,
                    color: Colors.grey[400],
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: track.hasPreview ? onTap : null,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: track.hasPreview ? Colors.green : Colors.grey),
        ),
        onTap: track.hasPreview ? onTap : null,
      ),
    );
  }

  Widget _buildDefaultTrackImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.grey[400],
        size: 24,
      ),
    );
  }
}
