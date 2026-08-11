import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

/// True when Kin should open as a phone-sized desktop/web preview shell.
bool get wantsDesktopPhoneShell {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/// Logical phone canvas used inside the desktop shell.
const Size kPhoneCanvasSize = Size(390, 844);

/// Outer window: phone canvas + bezel + title drag strip.
const Size kPhoneShellWindowSize = Size(430, 920);

Future<void> configureDesktopPhoneShell() async {
  if (kIsWeb) return;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: kPhoneShellWindowSize,
    minimumSize: kPhoneShellWindowSize,
    maximumSize: kPhoneShellWindowSize,
    center: true,
    backgroundColor: Color(0x00000000),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Kin — phone preview',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.show();
    await windowManager.focus();
  });
}
