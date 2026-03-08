class SongItem {
  const SongItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.uri,
    this.artwork,
    required this.dateAdded,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String uri;
  final String? artwork;
  final DateTime dateAdded;

  SongItem copyWith({
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? uri,
    String? artwork,
  }) {
    return SongItem(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      uri: uri ?? this.uri,
      artwork: artwork ?? this.artwork,
      dateAdded: dateAdded,
    );
  }
}
