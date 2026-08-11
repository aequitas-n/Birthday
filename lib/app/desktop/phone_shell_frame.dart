import 'package:flutter/widgets.dart';
import 'package:kin/app/desktop/desktop_phone_shell.dart';
import 'package:kin/app/desktop/shell_window_controls.dart';

/// A laptop/browser window that looks and behaves like a phone in a shell.
///
/// The real app sits in a fixed 390×844 canvas so design review matches mobile.
class DesktopPhoneShell extends StatelessWidget {
  const DesktopPhoneShell({required this.child, super.key});

  final Widget child;

  static const _bezel = Color(0xFF141414);
  static const _bezelEdge = Color(0xFF2A2A2A);
  static const _desk = Color(0xFF0B0B0B);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _desk,
      child: Center(
        child: FittedBox(
          child: SizedBox(
            width: kPhoneShellWindowSize.width,
            height: kPhoneShellWindowSize.height,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                children: [
                  const _ShellTitleBar(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _bezel,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: _bezelEdge, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                        child: Column(
                          children: [
                            const _Notch(),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    size: kPhoneCanvasSize,
                                    padding: const EdgeInsets.only(top: 8),
                                    viewPadding: const EdgeInsets.only(top: 8),
                                    viewInsets: EdgeInsets.zero,
                                    devicePixelRatio: 2,
                                    textScaler: TextScaler.noScaling,
                                  ),
                                  child: SizedBox(
                                    width: kPhoneCanvasSize.width,
                                    height: kPhoneCanvasSize.height,
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const _HomeIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTitleBar extends StatelessWidget {
  const _ShellTitleBar();

  @override
  Widget build(BuildContext context) {
    return const ShellMoveArea(
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            SizedBox(width: 8),
            Text(
              'Kin',
              style: TextStyle(
                color: Color(0xFFB8B8B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'phone preview',
              style: TextStyle(color: Color(0xFF6E6E6E), fontSize: 11),
            ),
            Spacer(),
            ShellCloseButton(),
            SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 18,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF0A0A0A),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: SizedBox(width: 96, height: 10),
        ),
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 14,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF3A3A3A),
            borderRadius: BorderRadius.all(Radius.circular(99)),
          ),
          child: SizedBox(width: 108, height: 4),
        ),
      ),
    );
  }
}
