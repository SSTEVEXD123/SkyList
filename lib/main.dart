import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:skylist/player_engine/player_controller.dart';
import 'package:skylist/services/library_controller.dart';
import 'package:skylist/storage_manager/app_settings_controller.dart';
import 'package:skylist/storage_manager/playlist_controller.dart';
import 'package:skylist/ui/screens/home_screen.dart';
import 'package:skylist/ui/screens/settings_screen.dart';
import 'package:skylist/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.skylist.app.playback',
      androidNotificationChannelName: 'SkyList Playback',
      androidNotificationOngoing: true,
    );
  }

  final settingsController = AppSettingsController();
  await settingsController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsController),
        ChangeNotifierProvider(create: (_) => LibraryController()..initialize()),
        ChangeNotifierProvider(create: (_) => PlaylistController()..load()),
        ChangeNotifierProvider(create: (_) => PlayerController()..initialize()),
      ],
      child: const SkyListApp(),
    ),
  );
}

class SkyListApp extends StatelessWidget {
  const SkyListApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyList',
      themeMode: settings.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routes: {
        '/': (_) => const HomeScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }
}
