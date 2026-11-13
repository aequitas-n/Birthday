import 'dart:developer' show Timeline;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Phase 7 investigation: emit widget-level BUILD/PAINT timeline events.
///
/// Enable with `--dart-define=KIN_PHASE7_DIAG=true` (profile builds only).
/// Leaves no behavior change when disabled.
abstract final class Phase7Diag {
  Phase7Diag._();

  static const enabled = bool.fromEnvironment(
    'KIN_PHASE7_DIAG',
    defaultValue: false,
  );

  static var _installed = false;

  static void install() {
    if (!enabled || _installed) return;
    _installed = true;
    // Profile-mode timeline events naming each user widget build/paint.
    debugProfileBuildsEnabled = true;
    debugProfilePaintsEnabled = true;
  }

  static void mark(String name) {
    if (!enabled) return;
    Timeline.startSync('PHASE7_$name');
    Timeline.finishSync();
    // ignore: avoid_print — Phase 7 diagnostic
    print('PHASE7 $name');
  }
}
