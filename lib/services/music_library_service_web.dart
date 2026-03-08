import 'package:skylist/models/song_item.dart';

class MusicLibraryService {
  Future<bool> requestPermission() async => false;

  Future<List<SongItem>> querySongs() async => const <SongItem>[];
}
