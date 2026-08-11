import 'package:flutter/widgets.dart';

/// No-op window chrome helpers for web.
class ShellMoveArea extends StatelessWidget {
  const ShellMoveArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class ShellCloseButton extends StatelessWidget {
  const ShellCloseButton({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
