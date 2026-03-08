import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylist/models/playlist_item.dart';
import 'package:uuid/uuid.dart';

class PlaylistController extends ChangeNotifier {
  static const _playlistKey = 'user_playlists';
  final List<PlaylistItem> _playlists = [];
  final _uuid = const Uuid();

  List<PlaylistItem> get playlists => List.unmodifiable(_playlists);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playlistKey);
    if (raw == null) return;

    final data = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    _playlists
      ..clear()
      ..addAll(data.map(PlaylistItem.fromMap));
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistKey, jsonEncode(_playlists.map((p) => p.toMap()).toList()));
  }

  Future<void> createPlaylist(String name) async {
    _playlists.add(
      PlaylistItem(
        id: _uuid.v4(),
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final old = _playlists[index];
    _playlists[index] = PlaylistItem(
      id: old.id,
      name: newName,
      songIds: old.songIds,
      createdAt: old.createdAt,
    );
    await _save();
    notifyListeners();
  }

  Future<void> addSong(String id, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final old = _playlists[index];
    if (old.songIds.contains(songId)) return;
    _playlists[index] = PlaylistItem(
      id: old.id,
      name: old.name,
      songIds: [...old.songIds, songId],
      createdAt: old.createdAt,
    );
    await _save();
    notifyListeners();
  }

  Future<void> removeSong(String id, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final old = _playlists[index];
    _playlists[index] = PlaylistItem(
      id: old.id,
      name: old.name,
      songIds: old.songIds.where((s) => s != songId).toList(),
      createdAt: old.createdAt,
    );
    await _save();
    notifyListeners();
  }
}
