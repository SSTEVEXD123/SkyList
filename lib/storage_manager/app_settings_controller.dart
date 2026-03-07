import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylist/storage_manager/history_storage.dart';

class AppSettingsController extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  ThemeMode themeMode = ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeKey);
    if (raw == 'light') themeMode = ThemeMode.light;
    if (raw == 'dark') themeMode = ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> clearCacheAndHistory() async {
    await HistoryStorage().clearAll();
  }
}
