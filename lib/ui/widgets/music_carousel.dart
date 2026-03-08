import 'package:flutter/material.dart';
import 'package:skylist/models/song_item.dart';
import 'package:skylist/ui/widgets/song_card.dart';

class MusicCarousel extends StatelessWidget {
  const MusicCarousel({
    super.key,
    required this.songs,
    required this.onTapSong,
  });

  final List<SongItem> songs;
  final void Function(SongItem) onTapSong;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: songs.length,
        itemBuilder: (_, index) {
          final song = songs[index];
          return SongCard(song: song, onTap: () => onTapSong(song));
        },
      ),
    );
  }
}
