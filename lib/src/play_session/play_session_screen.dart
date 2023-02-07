import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_template/main.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart' hide Level;

import '../ads/ads_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../games_services/score.dart';
import '../level_selection/levels.dart';
import '../style/confetti.dart';

class PlaySessionScreen extends ConsumerStatefulWidget {
  final GameLevel level;

  const PlaySessionScreen(this.level, {super.key});

  @override
  PlaySessionScreenState createState() => PlaySessionScreenState();
}

class PlaySessionScreenState extends ConsumerState<PlaySessionScreen> {
  static final _log = Logger('PlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);

  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;

  late DateTime _startOfPlay;

  @override
  Widget build(BuildContext context) {
    final levelStateProvider =
        StateNotifierProvider<LevelState, int>((ref) => LevelState(onWin: _playerWon, goal: widget.level.difficulty));

    return IgnorePointer(
      ignoring: _duringCelebration,
      child: Scaffold(
        backgroundColor: ref.watch(paletteProvider).backgroundPlaySession,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                // This is the entirety of the "game".
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkResponse(
                        onTap: () => GoRouter.of(context).push('/settings'),
                        child: Image.asset(
                          'assets/images/settings.png',
                          semanticLabel: 'Settings',
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text('Drag the slider to ${widget.level.difficulty}%'
                        ' or above!'),
                    Consumer(builder: (context, ref, child) {
                      return Slider(
                        label: 'Level Progress',
                        autofocus: true,
                        value: ref.watch(levelStateProvider) / 100,
                        onChanged: (value) => ref.read(levelStateProvider.notifier).setProgress((value * 100).round()),
                        onChangeEnd: (value) => ref.read(levelStateProvider.notifier).evaluate(),
                      );
                    }),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => GoRouter.of(context).pop(),
                          child: const Text('Back'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(
                      isStopped: !_duringCelebration,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startOfPlay = DateTime.now();

    // Preload ad for the win screen.
    final adsRemoved = inAppPurchaseControllerProvider != null
        ? ref.read(inAppPurchaseControllerProvider!).maybeMap(
              active: (value) => true,
              orElse: () => false,
            )
        : false;
    if (!adsRemoved && adsControllerProvider != null) {
      ref.read<AdsController?>(adsControllerProvider!)!.preloadAd();
    }
  }

  Future<void> _playerWon() async {
    _log.info('Level ${widget.level.number} won');

    final score = Score(
      widget.level.number,
      widget.level.difficulty,
      DateTime.now().difference(_startOfPlay),
    );

    ref.read(playerProgressProvider.notifier).setLevelReached(widget.level.number);

    // Let the player see the game just after winning for a bit.
    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    ref.read(audioControllerProvider).playSfx(SfxType.congrats);

    if (gamesServicesControllerProvider != null) {
      // Award achievement.
      if (widget.level.awardsAchievement) {
        await ref.read(gamesServicesControllerProvider!).awardAchievement(
              android: widget.level.achievementIdAndroid!,
              iOS: widget.level.achievementIdIOS!,
            );
      }

      // Send score to leaderboard.
      await ref.read(gamesServicesControllerProvider!).submitLeaderboardScore(score);
    }

    /// Give the player some time to see the celebration animation.
    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).go('/play/won', extra: {'score': score});
  }
}
