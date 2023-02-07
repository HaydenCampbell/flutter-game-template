import 'package:flutter/foundation.dart';
import 'package:game_template/src/games_services/score.dart';
import 'package:game_template/src/level_selection/level_selection_screen.dart';
import 'package:game_template/src/level_selection/levels.dart';
import 'package:game_template/src/main_menu/main_menu_screen.dart';
import 'package:game_template/src/play_session/play_session_screen.dart';
import 'package:game_template/src/settings/settings_screen.dart';
import 'package:game_template/src/style/my_transition.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:game_template/src/win_game/win_game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,

    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainMenuScreen(key: Key('main menu')), routes: [
        GoRoute(
            path: 'play',
            pageBuilder: (context, state) => buildMyTransition(
                  child: const LevelSelectionScreen(key: Key('level selection')),
                  color: ref.read(paletteProvider).backgroundLevelSelection,
                ),
            routes: [
              GoRoute(
                path: 'session/:level',
                pageBuilder: (context, state) {
                  final levelNumber = int.parse(state.params['level']!);
                  final level = gameLevels.singleWhere((e) => e.number == levelNumber);
                  return buildMyTransition(
                    child: PlaySessionScreen(
                      level,
                      key: const Key('play session'),
                    ),
                    color: ref.read(paletteProvider).backgroundPlaySession,
                  );
                },
              ),
              GoRoute(
                path: 'won',
                pageBuilder: (context, state) {
                  final map = state.extra! as Map<String, dynamic>;
                  final score = map['score'] as Score;

                  return buildMyTransition(
                    child: WinGameScreen(
                      score: score,
                      key: const Key('win game'),
                    ),
                    color: ref.read(paletteProvider).backgroundPlaySession,
                  );
                },
              )
            ]),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(key: Key('settings')),
        ),
      ]),
    ], // All the routes can be found there
  );
});
