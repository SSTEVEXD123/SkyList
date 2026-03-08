import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skylist/models/song_item.dart';

enum RepeatMode { off, one, all }

class PlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<SongItem> queue = [];
  int currentIndex = 0;
  bool shuffleEnabled = false;
  RepeatMode repeatMode = RepeatMode.off;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  AudioPlayer get raw => _player;

  SongItem? get currentSong => queue.isEmpty ? null : queue[currentIndex];

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _positionSub = _player.positionStream.listen((value) {
      position = value;
      notifyListeners();
    });
    _stateSub = _player.playerStateStream.listen((_) => notifyListeners());
    _player.durationStream.listen((d) {
      duration = d ?? Duration.zero;
      notifyListeners();
    });
    _player.currentIndexStream.listen((i) {
      if (i == null) return;
      currentIndex = i;
      notifyListeners();
    });
  }

  Future<void> playSongs(List<SongItem> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    queue = songs;
    currentIndex = startIndex;

    await _player.setAudioSources(
      songs
          .map(
            (s) => AudioSource.uri(
              Uri.parse(s.uri),
              tag: MediaItem(
                id: s.uri,
                title: s.title,
                artist: s.artist,
                album: s.album,
                duration: Duration(milliseconds: s.durationMs),
              ),
            ),
          )
          .toList(),
      initialIndex: startIndex,
      preload: true,
    );
    await _player.play();
    notifyListeners();
  }

  Future<void> playOrPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
    currentIndex = _player.currentIndex ?? currentIndex;
    notifyListeners();
  }

  Future<void> previous() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
    currentIndex = _player.currentIndex ?? currentIndex;
    notifyListeners();
  }

  Future<void> seek(Duration value) async {
    await _player.seek(value);
  }

  Future<void> toggleShuffle() async {
    shuffleEnabled = !shuffleEnabled;
    await _player.setShuffleModeEnabled(shuffleEnabled);
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    if (repeatMode == RepeatMode.off) {
      repeatMode = RepeatMode.all;
      await _player.setLoopMode(LoopMode.all);
    } else if (repeatMode == RepeatMode.all) {
      repeatMode = RepeatMode.one;
      await _player.setLoopMode(LoopMode.one);
    } else {
      repeatMode = RepeatMode.off;
      await _player.setLoopMode(LoopMode.off);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
