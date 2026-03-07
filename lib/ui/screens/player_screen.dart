import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:skylist/player_engine/player_controller.dart';
import 'package:skylist/services/library_controller.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('No track selected')));
    }

    final max = (player.duration.inMilliseconds <= 0 ? 1 : player.duration.inMilliseconds).toDouble();
    final value = player.position.inMilliseconds.toDouble().clamp(0, max);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: QueryArtworkWidget(
              key: ValueKey(song.id),
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkFit: BoxFit.cover,
              nullArtworkWidget: Container(color: Colors.black),
            ),
          ),
          AnimatedBuilder(
            animation: _zoomController,
            builder: (_, child) => Transform.scale(
              scale: 1 + (_zoomController.value * 0.06),
              child: child,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(color: Colors.black.withOpacity(0.65)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.expand_more, size: 30)),
                const Spacer(),
                Hero(
                  tag: 'art_${song.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 280,
                      artworkHeight: 280,
                      size: 280,
                      nullArtworkWidget: Container(
                        height: 280,
                        width: 280,
                        color: Colors.white10,
                        child: const Icon(Icons.music_note, size: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(song.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                Text(song.artist, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Slider(
                    value: value,
                    max: max,
                    onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(player.position)),
                      Text(_fmt(player.duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: player.toggleShuffle,
                      icon: Icon(Icons.shuffle, color: player.shuffleEnabled ? Colors.white : Colors.white54),
                    ),
                    IconButton(onPressed: player.previous, icon: const Icon(Icons.skip_previous, size: 36)),
                    FilledButton.tonal(
                      onPressed: player.playOrPause,
                      style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(22)),
                      child: Icon(player.raw.playing ? Icons.pause : Icons.play_arrow, size: 34),
                    ),
                    IconButton(onPressed: player.next, icon: const Icon(Icons.skip_next, size: 36)),
                    IconButton(
                      onPressed: player.cycleRepeatMode,
                      icon: Icon(
                        player.repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
                        color: player.repeatMode == RepeatMode.off ? Colors.white54 : Colors.white,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.read<LibraryController>().toggleFavorite(song),
                  icon: Icon(
                    context.watch<LibraryController>().favorites.contains(song.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: const Text('Favorite'),
                ),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}
