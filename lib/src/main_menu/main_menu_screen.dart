import 'package:flutter/material.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/games_services/games_services.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio/sounds.dart';
import '../style/responsive_screen.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GamesServicesController? gamesServicesController =
        gamesServicesControllerProvider != null ? ref.watch(gamesServicesControllerProvider!) : null;

    return Scaffold(
      backgroundColor: ref.watch(paletteProvider).backgroundMain,
      body: ResponsiveScreen(
        mainAreaProminence: 0.45,
        squarishMainArea: Center(
          child: Transform.rotate(
            angle: -0.1,
            child: const Text(
              'Flutter Game Template!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 55,
                height: 1,
              ),
            ),
          ),
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                ref.read(audioControllerProvider).playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/play');
              },
              child: const Text('Play'),
            ),
            _gap,
            if (gamesServicesController != null) ...[
              _hideUntilReady(
                ready: gamesServicesController.signedIn,
                child: ElevatedButton(
                  onPressed: () => gamesServicesController.showAchievements(),
                  child: const Text('Achievements'),
                ),
              ),
              _gap,
              _hideUntilReady(
                ready: gamesServicesController.signedIn,
                child: ElevatedButton(
                  onPressed: () => gamesServicesController.showLeaderboard(),
                  child: const Text('Leaderboard'),
                ),
              ),
              _gap,
            ],
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/settings'),
              child: const Text('Settings'),
            ),
            _gap,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Consumer(
                builder: (context, ref, child) {
                  ref.watch(settingsControllerProvider);
                  return IconButton(
                    onPressed: () => ref.read(settingsControllerProvider.notifier).toggleMuted(),
                    icon: Icon(ref.watch(settingsControllerProvider).muted ? Icons.volume_off : Icons.volume_up),
                  );
                },
              ),
            ),
            _gap,
            const Text('Music by Mr Smith'),
            _gap,
          ],
        ),
      ),
    );
  }

  /// Prevents the game from showing game-services-related menu items
  /// until we're sure the player is signed in.
  ///
  /// This normally happens immediately after game start, so players will not
  /// see any flash. The exception is folks who decline to use Game Center
  /// or Google Play Game Services, or who haven't yet set it up.
  Widget _hideUntilReady({required Widget child, required Future<bool> ready}) {
    return FutureBuilder<bool>(
      future: ready,
      builder: (context, snapshot) {
        // Use Visibility here so that we have the space for the buttons
        // ready.
        return Visibility(
          visible: snapshot.data ?? false,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          child: child,
        );
      },
    );
  }

  static const _gap = SizedBox(height: 10);
}
