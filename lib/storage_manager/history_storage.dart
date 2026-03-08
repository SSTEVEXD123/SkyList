import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryStorage {
  static const _favoritesKey = 'favorites';
  static const _playCountKey = 'play_count';
  static const _recentKey = 'recent';

  Set<int> favorites = <int>{};
  Map<int, int> playCount = {};
  List<int> recent = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    favorites = (prefs.getStringList(_favoritesKey) ?? const <String>[])
        .map((e) => int.tryParse(e) ?? -1)
        .where((e) => e >= 0)
        .toSet();

    final playJson = prefs.getString(_playCountKey);
    if (playJson != null) {
      final map = jsonDecode(playJson) as Map<String, dynamic>;
      playCount = map.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    recent = (prefs.getStringList(_recentKey) ?? const <String>[])
        .map((e) => int.tryParse(e) ?? -1)
        .where((e) => e >= 0)
        .toList();
  }

  Future<void> persist({
    required Map<int, int> playCount,
    required List<int> recent,
    required Set<int> favorites,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favoritesKey, favorites.map((e) => '$e').toList());
    await prefs.setString(_playCountKey, jsonEncode(playCount.map((k, v) => MapEntry('$k', v))));
    await prefs.setStringList(_recentKey, recent.map((e) => '$e').toList());
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    await prefs.remove(_playCountKey);
    await prefs.remove(_recentKey);
  }
}
