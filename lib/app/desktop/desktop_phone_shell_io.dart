import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

/// True when Kin should open as a phone-sized desktop/web preview shell.
bool get wantsDesktopPhoneShell {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

/// Logical phone canvas used inside the desktop shell.
const Size kPhoneCanvasSize = Size(390, 844);

/// Outer window design size: phone canvas + bezel + title drag strip.
///
/// Actual window size may be smaller so the shell fits the work area
/// (Windows laptops with display scaling often have < 920 logical height).
const Size kPhoneShellWindowSize = Size(430, 920);

Future<void> configureDesktopPhoneShell() async {
  if (kIsWeb) return;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  await windowManager.ensureInitialized();

  final placed = await _fittedShellBounds();

  final options = WindowOptions(
    size: placed.size,
    minimumSize: placed.size,
    maximumSize: placed.size,
    // Do not use center:true — on Windows + DPI it often lands at a
    // negative Y, which clips the title/drag strip off the top of the screen.
    center: false,
    backgroundColor: const Color(0x00000000),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Kin — phone preview',
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
    await windowManager.setBounds(placed);
    await windowManager.show();
    await windowManager.focus();
    // Size/DPR can settle after the first show; clamp again.
    await Future<void>.delayed(const Duration(milliseconds: 32));
    await nudgeDesktopPhoneShellOnScreen();
  });
}

/// Re-fit and clamp the shell fully into the visible work area.
///
/// Safe to call after the first frame — recovers windows stuck above the
/// monitor where the drag strip is unreachable.
Future<void> nudgeDesktopPhoneShellOnScreen() async {
  if (kIsWeb) return;
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  try {
    final placed = await _fittedShellBounds();
    await windowManager.setMinimumSize(placed.size);
    await windowManager.setMaximumSize(placed.size);
    await windowManager.setBounds(placed);
  } on Object {
    // Preview shell should never crash the app over window chrome.
  }
}

Future<Rect> _fittedShellBounds() async {
  const design = kPhoneShellWindowSize;
  const margin = 48.0;

  final display = await screenRetriever.getPrimaryDisplay();
  final visibleSize = display.visibleSize ?? display.size;
  final origin = display.visiblePosition ?? Offset.zero;

  final maxW = math.max(200, visibleSize.width - margin * 2);
  final maxH = math.max(320, visibleSize.height - margin * 2);
  final scale = math.min(
    1,
    math.min(maxW / design.width, maxH / design.height),
  );
  final width = (design.width * scale).roundToDouble();
  final height = (design.height * scale).roundToDouble();

  // Prefer true center; if the shell is still taller/wider than the work
  // area (pathological), pin to the top-left inset so the title bar stays
  // on-screen and draggable.
  final rawX = origin.dx + (visibleSize.width - width) / 2;
  final rawY = origin.dy + (visibleSize.height - height) / 2;
  final minX = origin.dx + margin;
  final minY = origin.dy + margin;
  final maxX = origin.dx + visibleSize.width - width - margin;
  final maxY = origin.dy + visibleSize.height - height - margin;

  final x = maxX >= minX ? rawX.clamp(minX, maxX) : minX;
  final y = maxY >= minY ? rawY.clamp(minY, maxY) : minY;

  return Rect.fromLTWH(x, y, width, height);
}
