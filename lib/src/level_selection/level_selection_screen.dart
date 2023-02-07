import 'package:flutter/material.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../audio/sounds.dart';
import '../style/responsive_screen.dart';
import 'levels.dart';

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ref.watch(paletteProvider).backgroundLevelSelection,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Select level',
                  style: TextStyle(fontFamily: 'Permanent Marker', fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ListView(
                children: [
                  for (final level in gameLevels)
                    ListTile(
                      enabled: ref.watch(playerProgressProvider) >= level.number - 1,
                      onTap: () {
                        ref.read(audioControllerProvider).playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}');
                      },
                      leading: Text(level.number.toString()),
                      title: Text('Level #${level.number}'),
                    )
                ],
              ),
            ),
          ],
        ),
        rectangularMenuArea: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).pop();
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
