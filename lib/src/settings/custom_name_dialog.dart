import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:game_template/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void showCustomNameDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => CustomNameDialog(animation: animation));
}

class CustomNameDialog extends HookConsumerWidget {
  final Animation<double> animation;

  const CustomNameDialog({super.key, required this.animation});

  @override
  Widget build(BuildContext context, ref) {
    final controller = useTextEditingController();

    useEffect(() {
      controller.text = ref.read(settingsControllerProvider).playerName;
      return null;
    });

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: const Text('Change name'),
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 12,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              ref.read(settingsControllerProvider.notifier).setPlayerName(value);
            },
            onSubmitted: (value) {
              // Player tapped 'Submit'/'Done' on their keyboard.
              Navigator.pop(context);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
