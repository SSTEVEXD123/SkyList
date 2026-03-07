import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:skylist/models/song_item.dart';

class SongCard extends StatelessWidget {
  const SongCard({super.key, required this.song, required this.onTap});

  final SongItem song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: Container(color: Colors.white10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
