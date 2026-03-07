# SkyList

SkyList is a modern Android-first music player app built with Flutter.

## Features

- Dark-first Material 3 interface with rounded cards and smooth transitions
- Home sections: Recently Played, Favorites, Albums, Artists, Playlists
- Local storage scan and metadata extraction via `on_audio_query`
- Full player: play/pause, next/prev, shuffle, repeat, progress slider
- Smart sections: recently played, most played, favorites
- Playlist management: create, rename, add/remove songs
- Settings: theme toggle, cache/history clean, version, update check placeholder
- Visual effects: blurred animated artwork background and crossfade transitions

## Project layout

- `lib/ui`
- `lib/models`
- `lib/services`
- `lib/player_engine`
- `lib/storage_manager`
- `lib/utils`

## Open in Android Studio

1. Install Flutter SDK and Android SDK.
2. Run:
   ```bash
   flutter pub get
   flutter build apk
   ```
3. Open the repo root in Android Studio and run on an Android device/emulator.

## Notes

- Local playback and media scanning rely on Android permissions.
- Lock-screen / notification transport controls are scaffolded through `just_audio`; integrating `audio_service` background handler can be extended further for production-grade media sessions.
