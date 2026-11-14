import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Temporary Phase 5 startup/mount diagnostics.
///
/// Enable with `--dart-define=KIN_PHASE5_DIAG=true` (profile/release safe).
/// Remove or leave disabled after the phase.
abstract final class Phase5Diag {
  Phase5Diag._();

  static const enabled = bool.fromEnvironment(
    'KIN_PHASE5_DIAG',
  );

  static final Stopwatch _boot = Stopwatch();
  static var _bootStarted = false;
  static var _frameListenerAttached = false;
  static var _expensiveFrames = 0;
  static var _worstFrameMs = 0;
  static var _frameWindowOpen = false;

  static void ensureBoot() {
    if (!enabled || _bootStarted) return;
    _bootStarted = true;
    _boot.start();
  }

  static void mark(String label) {
    if (!enabled) return;
    ensureBoot();
    // ignore: avoid_print — Phase 5 diagnostic
    print('PHASE5 $label ms=${_boot.elapsedMilliseconds}');
  }

  static void markImageCache(String label) {
    if (!enabled) return;
    ensureBoot();
    final cache = PaintingBinding.instance.imageCache;
    // ignore: avoid_print — Phase 5 diagnostic
    print(
      'PHASE5 imageCache_$label '
      'currentSize=${cache.currentSize} '
      'currentSizeBytes=${cache.currentSizeBytes} '
      'ms=${_boot.elapsedMilliseconds}',
    );
  }

  static void timed(String label, void Function() body) {
    if (!enabled) {
      body();
      return;
    }
    ensureBoot();
    final sw = Stopwatch()..start();
    body();
    sw.stop();
    // ignore: avoid_print — Phase 5 diagnostic
    print(
      'PHASE5 $label sync_ms=${sw.elapsedMilliseconds} '
      'at=${_boot.elapsedMilliseconds}',
    );
  }

  static T timedValue<T>(String label, T Function() body) {
    if (!enabled) return body();
    ensureBoot();
    final sw = Stopwatch()..start();
    final value = body();
    sw.stop();
    // ignore: avoid_print — Phase 5 diagnostic
    print(
      'PHASE5 $label sync_ms=${sw.elapsedMilliseconds} '
      'at=${_boot.elapsedMilliseconds}',
    );
    return value;
  }

  /// Watch the next [window] for frames whose build+raster exceeds 18ms.
  static void watchExpensiveFrames({
    Duration window = const Duration(seconds: 2),
  }) {
    if (!enabled) return;
    ensureBoot();
    _expensiveFrames = 0;
    _worstFrameMs = 0;
    _frameWindowOpen = true;
    mark('frameWatchStart');

    if (!_frameListenerAttached) {
      _frameListenerAttached = true;
      SchedulerBinding.instance.addTimingsCallback(_onTimings);
    }

    Future<void>.delayed(window, () {
      if (!_frameWindowOpen) return;
      _frameWindowOpen = false;
      // ignore: avoid_print — Phase 5 diagnostic
      print(
        'PHASE5 frameWatchEnd expensiveFrames=$_expensiveFrames '
        'worstFrameMs=$_worstFrameMs at=${_boot.elapsedMilliseconds}',
      );
    });
  }

  static void _onTimings(List<FrameTiming> timings) {
    if (!_frameWindowOpen) return;
    for (final t in timings) {
      final totalMs =
          (t.buildDuration + t.rasterDuration).inMicroseconds / 1000.0;
      if (totalMs < 18) continue;
      _expensiveFrames++;
      final rounded = totalMs.round();
      if (rounded > _worstFrameMs) _worstFrameMs = rounded;
      // ignore: avoid_print — Phase 5 diagnostic
      print(
        'PHASE5 expensiveFrame buildMs=${t.buildDuration.inMilliseconds} '
        'rasterMs=${t.rasterDuration.inMilliseconds} '
        'totalMs=$rounded '
        'at=${_boot.elapsedMilliseconds}',
      );
    }
  }
}
