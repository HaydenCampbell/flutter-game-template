import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.gen.freezed.dart';

@freezed
class SettingsState with _$SettingsState {
  factory SettingsState(
      {@Default("Player") String playerName,
      @Default(false) bool muted,
      @Default(true) bool soundsOn,
      @Default(true) bool musicOn}) = _Settings;
}
