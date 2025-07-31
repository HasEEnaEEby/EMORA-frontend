
class SpotifyPlaylist {
  final String id;
  final String name;
  final String description;
  final String mood;
  final int trackCount;
  final List<SpotifyTrack> tracks;
  final String duration;
  final String created;
  final String? coverImage;
  final String? spotifyUrl;
  final List<String> genres;
  final double energy;
  final double valence;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.mood,
    required this.trackCount,
    required this.tracks,
    required this.duration,
    required this.created,
    this.coverImage,
    this.spotifyUrl,
    required this.genres,
    required this.energy,
    required this.valence,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Playlist',
      description: json['description'] ?? '',
      mood: json['mood'] ?? '',
      trackCount: json['trackCount'] ?? 0,
      tracks: (json['tracks'] as List? ?? [])
          .map((track) => SpotifyTrack.fromJson(track))
          .toList(),
      duration: json['duration'] ?? '0m',
      created: json['created'] ?? DateTime.now().toIso8601String(),
      coverImage: json['coverImage'],
      spotifyUrl: json['spotifyUrl'],
      genres: List<String>.from(json['genres'] ?? []),
      energy: (json['energy'] ?? 0.5).toDouble(),
      valence: (json['valence'] ?? 0.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mood': mood,
      'trackCount': trackCount,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'duration': duration,
      'created': created,
      'coverImage': coverImage,
      'spotifyUrl': spotifyUrl,
      'genres': genres,
      'energy': energy,
      'valence': valence,
    };
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final String artists;
  final String album;
  final int duration;
  final String durationFormatted;
  final String? preview;
  final String spotifyUrl;
  final String uri;
  final String? image;
  final int popularity;
  final bool explicit;
  final String? releaseDate;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.duration,
    required this.durationFormatted,
    this.preview,
    required this.spotifyUrl,
    required this.uri,
    this.image,
    required this.popularity,
    required this.explicit,
    this.releaseDate,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Track',
      artists: json['artists'] ?? 'Unknown Artist',
      album: json['album'] ?? 'Unknown Album',
      duration: json['duration'] ?? 0,
      durationFormatted: json['durationFormatted'] ?? '0:00',
      preview: json['preview'],
      spotifyUrl: json['spotifyUrl'] ?? '',
      uri: json['uri'] ?? '',
      image: json['image'],
      popularity: json['popularity'] ?? 0,
      explicit: json['explicit'] ?? false,
      releaseDate: json['releaseDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': artists,
      'album': album,
      'duration': duration,
      'durationFormatted': durationFormatted,
      'preview': preview,
      'spotifyUrl': spotifyUrl,
      'uri': uri,
      'image': image,
      'popularity': popularity,
      'explicit': explicit,
      'releaseDate': releaseDate,
    };
  }

  bool get hasPreview => preview != null && preview!.isNotEmpty;
}
