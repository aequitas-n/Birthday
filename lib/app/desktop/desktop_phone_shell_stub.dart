import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Web (and any non-IO target): phone shell is the browser chrome itself.
bool get wantsDesktopPhoneShell => kIsWeb;

/// Logical phone canvas used inside the preview shell.
const Size kPhoneCanvasSize = Size(390, 844);

/// Outer shell footprint (bezel + title strip).
const Size kPhoneShellWindowSize = Size(430, 920);

Future<void> configureDesktopPhoneShell() async {}

Future<void> nudgeDesktopPhoneShellOnScreen() async {}
