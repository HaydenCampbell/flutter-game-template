import 'package:flutter/material.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../style/responsive_screen.dart';
import 'custom_name_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _gap = SizedBox(height: 60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ref.watch(paletteProvider).backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            _gap,
            const Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 55,
                height: 1,
              ),
            ),
            _gap,
            const _NameChangeLine(
              'Name',
            ),
            Consumer(
              builder: (context, ref, child) => _SettingsLine(
                'Sound FX',
                Icon(ref.watch(settingsControllerProvider).soundsOn ? Icons.graphic_eq : Icons.volume_off),
                onSelected: () => ref.watch(settingsControllerProvider.notifier).toggleSoundsOn(),
              ),
            ),
            Consumer(
              builder: (context, ref, child) => _SettingsLine(
                'Music',
                Icon(ref.watch(settingsControllerProvider).musicOn ? Icons.music_note : Icons.music_off),
                onSelected: () => ref.watch(settingsControllerProvider.notifier).toggleMusicOn(),
              ),
            ),
            Consumer(builder: (context, ref, child) {
              if (inAppPurchaseControllerProvider == null) {
                // In-app purchases are not supported yet.
                // Go to lib/main.dart and uncomment the lines that create
                // the InAppPurchaseController.
                return const SizedBox.shrink();
              }

              Widget icon;
              VoidCallback? callback;

              //TODO: refactor to .when if ads enabled
              if (inAppPurchaseControllerProvider != null
                  ? ref.watch(inAppPurchaseControllerProvider!).maybeMap(
                        active: (value) => true,
                        orElse: () => false,
                      )
                  : false) {
                icon = const Icon(Icons.check);
              } else if (inAppPurchaseControllerProvider != null
                  ? ref.watch(inAppPurchaseControllerProvider!).maybeMap(
                        pending: (value) => true,
                        orElse: () => false,
                      )
                  : false) {
                icon = const CircularProgressIndicator();
              } else {
                icon = const Icon(Icons.ad_units);
                callback = () {
                  if (inAppPurchaseControllerProvider != null) {
                    ref.read(inAppPurchaseControllerProvider!.notifier).buy();
                  }
                };
              }
              return _SettingsLine(
                'Remove ads',
                icon,
                onSelected: callback,
              );
            }),
            _SettingsLine(
              'Reset progress',
              const Icon(Icons.delete),
              onSelected: () {
                ref.read(playerProgressProvider.notifier).reset();

                final messenger = ScaffoldMessenger.of(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Player progress has been reset.')),
                );
              },
            ),
            _gap,
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

class _NameChangeLine extends ConsumerWidget {
  final String title;

  const _NameChangeLine(this.title);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: () => showCustomNameDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                )),
            const Spacer(),
            Consumer(
              builder: (context, ref, child) => Text(
                '‘${ref.watch(settingsControllerProvider).playerName}’',
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget icon;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, this.icon, {this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      onTap: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: const TextStyle(
                  fontFamily: 'Permanent Marker',
                  fontSize: 30,
                )),
            const Spacer(),
            icon,
          ],
        ),
      ),
    );
  }
}
