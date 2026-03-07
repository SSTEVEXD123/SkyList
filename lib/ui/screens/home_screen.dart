import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skylist/models/song_item.dart';
import 'package:skylist/player_engine/player_controller.dart';
import 'package:skylist/services/library_controller.dart';
import 'package:skylist/storage_manager/playlist_controller.dart';
import 'package:skylist/ui/screens/player_screen.dart';
import 'package:skylist/ui/screens/settings_screen.dart';
import 'package:skylist/ui/widgets/music_carousel.dart';
import 'package:skylist/ui/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final playlists = context.watch<PlaylistController>();

    Future<void> onTapSong(SongItem song) async {
      final player = context.read<PlayerController>();
      final index = library.songs.indexWhere((s) => s.id == song.id);
      await player.playSongs(library.songs, startIndex: index < 0 ? 0 : index);
      await library.markPlayed(song);
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SkyList'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: library.refresh,
        child: library.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (!library.permissionGranted)
                    const ListTile(
                      title: Text('Storage permission is required to load local songs.'),
                    ),
                  SectionHeader(
                    title: 'Recently Played',
                    trailing: Text('${library.recentlyPlayed.length}'),
                  ),
                  MusicCarousel(songs: library.recentlyPlayed, onTapSong: onTapSong),
                  const SectionHeader(title: 'Favorites'),
                  MusicCarousel(songs: library.favoriteSongs, onTapSong: onTapSong),
                  const SectionHeader(title: 'Most Played'),
                  MusicCarousel(songs: library.mostPlayed, onTapSong: onTapSong),
                  SectionHeader(
                    title: 'Albums',
                    trailing: Text('${library.groupedByAlbum.length} albums'),
                  ),
                  _EntityScroller(items: library.groupedByAlbum.keys.toList()),
                  SectionHeader(
                    title: 'Artists',
                    trailing: Text('${library.groupedByArtist.length} artists'),
                  ),
                  _EntityScroller(items: library.groupedByArtist.keys.toList()),
                  SectionHeader(
                    title: 'Folders',
                    trailing: Text('${library.groupedByFolder.length} folders'),
                  ),
                  _EntityScroller(items: library.groupedByFolder.keys.toList()),
                  SectionHeader(
                    title: 'Playlists',
                    trailing: FilledButton.tonalIcon(
                      onPressed: () => _showCreatePlaylistDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('New'),
                    ),
                  ),
                  ...playlists.playlists.map(
                    (p) => ListTile(
                      onTap: () => _showPlaylistSongsDialog(context, p.id, p.name),
                      title: Text(p.name),
                      subtitle: Text('${p.songIds.length} songs'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _showPlaylistSongsDialog(context, p.id, p.name),
                            icon: const Icon(Icons.playlist_add),
                          ),
                          IconButton(
                            onPressed: () => _showRenameDialog(context, p.id, p.name),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 96),
                ],
              ),
      ),
      bottomNavigationBar: const _MiniPlayerBar(),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Playlist'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await context.read<PlaylistController>().createPlaylist(name);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, String id, String currentName) async {
    final controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await context.read<PlaylistController>().renamePlaylist(id, name);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPlaylistSongsDialog(BuildContext context, String playlistId, String playlistName) async {
    final library = context.read<LibraryController>();
    final playlists = context.read<PlaylistController>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final playlist = playlists.playlists.firstWhere((p) => p.id == playlistId);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Edit "$playlistName"', style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: library.songs.length,
                  itemBuilder: (_, i) {
                    final song = library.songs[i];
                    final exists = playlist.songIds.contains(song.id);
                    return CheckboxListTile(
                      title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      value: exists,
                      onChanged: (_) async {
                        if (exists) {
                          await playlists.removeSong(playlistId, song.id);
                        } else {
                          await playlists.addSong(playlistId, song.id);
                        }
                        setModalState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EntityScroller extends StatelessWidget {
  const _EntityScroller({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(right: 8),
          child: Chip(label: Text(items[i], overflow: TextOverflow.ellipsis)),
        ),
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  const _MiniPlayerBar();

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    return SafeArea(
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen())),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: player.playOrPause,
                icon: Icon(player.raw.playing ? Icons.pause_circle_filled : Icons.play_circle_fill),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
