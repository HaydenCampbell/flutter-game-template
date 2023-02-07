import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

CustomTransitionPage<T> buildMyTransition<T>({
  required Widget child,
  required Color color,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _MyReveal(
        animation: animation,
        color: color,
        child: child,
      );
    },
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    transitionDuration: const Duration(milliseconds: 700),
  );
}

class _MyReveal extends HookWidget {
  static final _log = Logger('_InkRevealState');

  final Color color;
  final Animation<double> animation;
  final Widget child;

  const _MyReveal({
    required this.color,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tween = Tween(begin: const Offset(0, -1), end: Offset.zero);

    final finished = useState(false);

    void _statusListener(AnimationStatus status) {
      _log.fine(() => 'status: $status');
      switch (animation.status) {
        case AnimationStatus.completed:
          finished.value = true;
          break;
        case AnimationStatus.forward:
        case AnimationStatus.dismissed:
        case AnimationStatus.reverse:
          finished.value = false;
          break;
      }
    }

    useEffect(() {
      animation.addStatusListener(_statusListener);
      return () => animation.removeStatusListener(_statusListener);
    }, const []);

    return Stack(
      fit: StackFit.expand,
      children: [
        SlideTransition(
          position: tween.animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeOutCubic,
            ),
          ),
          child: Container(
            color: color,
          ),
        ),
        AnimatedOpacity(
          opacity: finished.value ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        ),
      ],
    );
  }
}
