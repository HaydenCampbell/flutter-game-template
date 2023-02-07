import 'package:flutter/foundation.dart';
import 'package:game_template/src/settings/settings_state.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'persistence/settings_persistence.dart';

/// An class that holds settings like [playerName] or [musicOn],
/// and saves them to an injected persistence store.
class SettingsController extends StateNotifier<SettingsState> {
  final SettingsPersistence _persistence;

  /// Creates a new instance of [SettingsController] backed by [persistence].
  SettingsController({required SettingsPersistence persistence})
      : _persistence = persistence,
        super(SettingsState());

  /// Asynchronously loads values from the injected persistence store.
  Future<void> loadStateFromPersistence() async {
    await Future.wait([
      _persistence.getPlayerName().then((value) => state = state.copyWith(playerName: value)),
      _persistence.getMusicOn().then((value) => state = state.copyWith(musicOn: value)),
      _persistence.getSoundsOn().then((value) => state = state.copyWith(soundsOn: value)),
      _persistence
          // On the web, sound can only start after user interaction, so
          // we start muted there.
          // On any other platform, we start unmuted.
          .getMuted(defaultValue: kIsWeb)
          .then((value) => state = state.copyWith(muted: value)),
    ]);
  }

  void setPlayerName(String name) {
    state = state.copyWith(playerName: name);
    _persistence.savePlayerName(state.playerName);
  }

  void toggleMusicOn() {
    state = state.copyWith(musicOn: !state.musicOn);
    _persistence.saveMusicOn(state.musicOn);
  }

  void toggleSoundsOn() {
    state = state.copyWith(soundsOn: !state.soundsOn);
    _persistence.saveSoundsOn(state.soundsOn);
  }

  void toggleMuted() {
    state = state.copyWith(muted: !state.muted);
    _persistence.saveMuted(state.muted);
  }
}
