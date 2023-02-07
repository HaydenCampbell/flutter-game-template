import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].

class LevelState extends StateNotifier<int> {
  final VoidCallback onWin;

  final int goal;

  LevelState({required this.onWin, this.goal = 100}) : super(0);

  int _progress = 0;

  void setProgress(int value) {
    _progress = value;
    state = _progress;
  }

  void evaluate() {
    if (_progress >= goal) {
      onWin();
    }
  }
}
