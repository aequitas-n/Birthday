import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop drag region for the frameless phone-preview window.
class ShellMoveArea extends StatelessWidget {
  const ShellMoveArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => DragToMoveArea(child: child);
}

class ShellCloseButton extends StatelessWidget {
  const ShellCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: windowManager.close,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE25555),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 12, height: 12),
          ),
        ),
      ),
    );
  }
}
