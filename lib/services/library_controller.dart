import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:skylist/models/song_item.dart';
import 'package:skylist/services/music_library_service.dart';
import 'package:skylist/storage_manager/history_storage.dart';

class LibraryController extends ChangeNotifier {
  final MusicLibraryService _service = MusicLibraryService();
  final HistoryStorage _historyStorage = HistoryStorage();

  bool permissionGranted = false;
  bool isLoading = false;
  List<SongItem> songs = [];
  Set<int> favorites = <int>{};
  Map<int, int> playCount = {};
  List<int> recentIds = [];

  Future<void> initialize() async {
    await _historyStorage.load();
    favorites = _historyStorage.favorites;
    playCount = _historyStorage.playCount;
    recentIds = _historyStorage.recent;
    await refresh();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();

    permissionGranted = await _service.requestPermission();
    if (permissionGranted) {
      songs = await _service.querySongs();
    }

    isLoading = false;
    notifyListeners();
  }

  List<SongItem> get recentlyPlayed => recentIds
      .map((id) => songs.firstWhereOrNull((song) => song.id == id))
      .whereType<SongItem>()
      .toList();

  List<SongItem> get mostPlayed {
    final entries = playCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries
        .map((entry) => songs.firstWhereOrNull((song) => song.id == entry.key))
        .whereType<SongItem>()
        .take(20)
        .toList();
  }

  List<SongItem> get favoriteSongs => songs.where((song) => favorites.contains(song.id)).toList();

  Map<String, List<SongItem>> get groupedByAlbum {
    final map = <String, List<SongItem>>{};
    for (final song in songs) {
      map.putIfAbsent(song.album, () => []).add(song);
    }
    return map;
  }

  Map<String, List<SongItem>> get groupedByArtist {
    final map = <String, List<SongItem>>{};
    for (final song in songs) {
      map.putIfAbsent(song.artist, () => []).add(song);
    }
    return map;
  }

  Map<String, List<SongItem>> get groupedByFolder {
    final map = <String, List<SongItem>>{};
    for (final song in songs) {
      final folder = song.uri.split('/').reversed.skip(1).firstOrNull ?? 'Unknown';
      map.putIfAbsent(folder, () => []).add(song);
    }
    return map;
  }

  Future<void> markPlayed(SongItem song) async {
    recentIds = [song.id, ...recentIds.where((id) => id != song.id)].take(30).toList();
    playCount[song.id] = (playCount[song.id] ?? 0) + 1;
    await _historyStorage.persist(playCount: playCount, recent: recentIds, favorites: favorites);
    notifyListeners();
  }

  Future<void> toggleFavorite(SongItem song) async {
    if (favorites.contains(song.id)) {
      favorites.remove(song.id);
    } else {
      favorites.add(song.id);
    }
    await _historyStorage.persist(playCount: playCount, recent: recentIds, favorites: favorites);
    notifyListeners();
  }
}
