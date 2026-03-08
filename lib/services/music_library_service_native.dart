import 'package:on_audio_query/on_audio_query.dart';
import 'package:skylist/models/song_item.dart';

class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    return _audioQuery.permissionsStatus() || await _audioQuery.permissionsRequest();
  }

  Future<List<SongItem>> querySongs() async {
    final rawSongs = await _audioQuery.querySongs(
      sortType: SongSortType.DATE_ADDED,
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return rawSongs
        .where((s) => (s.uri ?? '').isNotEmpty)
        .map(
          (song) => SongItem(
            id: song.id,
            title: song.title,
            artist: song.artist ?? 'Unknown Artist',
            album: song.album ?? 'Unknown Album',
            durationMs: song.duration ?? 0,
            uri: song.uri ?? '',
            artwork: null,
            dateAdded: DateTime.fromMillisecondsSinceEpoch(
              ((song.dateAdded ?? DateTime.now().millisecondsSinceEpoch ~/ 1000) * 1000),
            ),
          ),
        )
        .toList();
  }
}
