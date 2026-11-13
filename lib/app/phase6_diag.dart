import 'dart:io' show ProcessInfo;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Temporary Phase 6 forensic diagnostics for bootstrap stalls and residual
/// first-screen frames.
///
/// Enable with `--dart-define=KIN_PHASE6_DIAG=true`.
/// Does not log every frame — only summaries, phase transitions, and frames
/// that exceed thresholds (or the first N frames after KinApp mounts).
abstract final class Phase6Diag {
  Phase6Diag._();

  static const enabled = bool.fromEnvironment(
    'KIN_PHASE6_DIAG',
    defaultValue: false,
  );

  static final Stopwatch _boot = Stopwatch();
  static var _bootStarted = false;
  static var _timingsAttached = false;
  static var _todayUsableMarked = false;

  /// White-canvas window: after first Flutter frame, before KinApp setState.
  static var _whiteWindow = false;
  static var _whiteFrameCount = 0;
  static var _whiteBuildUs = 0;
  static var _whiteRasterUs = 0;
  static var _whiteWorstTotalMs = 0;

  /// Post-KinApp: capture first few frames in detail + expensive ones.
  static var _postMountWindow = false;
  static var _postMountFrameIndex = 0;
  static const _postMountDetailLimit = 8;
  static var _expensivePostMount = 0;
  static var _worstPostMountMs = 0;

  static void ensureBoot() {
    if (!enabled || _bootStarted) return;
    _bootStarted = true;
    _boot.start();
    markRss('boot');
  }

  /// Call after [WidgetsFlutterBinding.ensureInitialized].
  static void attachAfterBinding() {
    if (!enabled) return;
    ensureBoot();
    _attachTimings();
  }

  static void mark(String label) {
    if (!enabled) return;
    ensureBoot();
    // ignore: avoid_print — Phase 6 diagnostic
    print('PHASE6 $label ms=${_boot.elapsedMilliseconds}');
  }

  static void markRss(String label) {
    if (!enabled) return;
    ensureBoot();
    // ignore: avoid_print — Phase 6 diagnostic
    print(
      'PHASE6 rss_$label bytes=${ProcessInfo.currentRss} '
      'ms=${_boot.elapsedMilliseconds}',
    );
  }

  static void markImageCache(String label) {
    if (!enabled) return;
    ensureBoot();
    final cache = PaintingBinding.instance.imageCache;
    // ignore: avoid_print — Phase 6 diagnostic
    print(
      'PHASE6 imageCache_$label '
      'currentSize=${cache.currentSize} '
      'currentSizeBytes=${cache.currentSizeBytes} '
      'ms=${_boot.elapsedMilliseconds}',
    );
  }

  static T timedValue<T>(String label, T Function() body) {
    if (!enabled) return body();
    ensureBoot();
    final sw = Stopwatch()..start();
    final value = body();
    sw.stop();
    // ignore: avoid_print — Phase 6 diagnostic
    print(
      'PHASE6 $label sync_ms=${sw.elapsedMilliseconds} '
      'at=${_boot.elapsedMilliseconds}',
    );
    return value;
  }

  /// Call from the first Flutter frame callback (white canvas).
  static void onFirstFlutterFrame() {
    if (!enabled) return;
    ensureBoot();
    mark('firstFlutterFrame');
    _whiteWindow = true;
    _whiteFrameCount = 0;
    _whiteBuildUs = 0;
    _whiteRasterUs = 0;
    _whiteWorstTotalMs = 0;
    mark('whiteWindow_begin');
  }

  /// Call when settings/DB await completes.
  static void onSettingsDone() {
    if (!enabled) return;
    _emitWhiteSummary('at_settingsOpen_done');
    markRss('settingsOpen_done');
  }

  /// Call just before KinApp setState (end of white canvas work).
  static void onBeforeKinApp() {
    if (!enabled) return;
    _emitWhiteSummary('at_beforeKinApp');
    _whiteWindow = false;
    mark('whiteWindow_end');
    markRss('beforeKinApp');
    markImageCache('beforeKinApp');
    _postMountWindow = true;
    _postMountFrameIndex = 0;
    _expensivePostMount = 0;
    _worstPostMountMs = 0;
    mark('postMountWindow_begin');
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!_postMountWindow) return;
      _postMountWindow = false;
      // ignore: avoid_print — Phase 6 diagnostic
      print(
        'PHASE6 postMountWindow_end '
        'expensiveFrames=$_expensivePostMount '
        'worstFrameMs=$_worstPostMountMs '
        'framesLogged=$_postMountFrameIndex '
        'at=${_boot.elapsedMilliseconds}',
      );
      markRss('postMountWindow_end');
      markImageCache('postMountWindow_end');
    });
  }

  static void onTab(String name) {
    if (!enabled) return;
    mark('tab_$name');
    markRss('tab_$name');
    markImageCache('tab_$name');
    // Briefly capture expensive frames around the tab switch.
    _postMountWindow = true;
    _postMountFrameIndex = 0;
    Future<void>.delayed(const Duration(seconds: 2), () {
      // ignore: avoid_print — Phase 6 diagnostic
      print(
        'PHASE6 tabWindow_end_$name '
        'expensiveFrames=$_expensivePostMount '
        'worstFrameMs=$_worstPostMountMs '
        'at=${_boot.elapsedMilliseconds}',
      );
    });
  }

  static void onTodayUsable() {
    if (!enabled || _todayUsableMarked) return;
    _todayUsableMarked = true;
    mark('todayUsable_peopleReady');
    markRss('todayUsable');
    markImageCache('todayUsable');
  }

  static void _emitWhiteSummary(String when) {
    // ignore: avoid_print — Phase 6 diagnostic
    print(
      'PHASE6 whiteFrames_$when '
      'count=$_whiteFrameCount '
      'buildMs=${(_whiteBuildUs / 1000).round()} '
      'rasterMs=${(_whiteRasterUs / 1000).round()} '
      'worstTotalMs=$_whiteWorstTotalMs '
      'at=${_boot.elapsedMilliseconds}',
    );
  }

  static void _attachTimings() {
    if (_timingsAttached) return;
    _timingsAttached = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  static void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final buildUs = t.buildDuration.inMicroseconds;
      final rasterUs = t.rasterDuration.inMicroseconds;
      final totalMs = (buildUs + rasterUs) / 1000.0;
      final vsyncMs = t.vsyncOverhead.inMilliseconds;

      if (_whiteWindow) {
        _whiteFrameCount++;
        _whiteBuildUs += buildUs;
        _whiteRasterUs += rasterUs;
        final rounded = totalMs.round();
        if (rounded > _whiteWorstTotalMs) _whiteWorstTotalMs = rounded;
        // Only log individual white frames if surprisingly expensive.
        if (totalMs >= 8) {
          // ignore: avoid_print — Phase 6 diagnostic
          print(
            'PHASE6 whiteFrame '
            'buildMs=${t.buildDuration.inMilliseconds} '
            'rasterMs=${t.rasterDuration.inMilliseconds} '
            'vsyncMs=$vsyncMs '
            'totalMs=$rounded '
            'at=${_boot.elapsedMilliseconds}',
          );
        }
        continue;
      }

      if (!_postMountWindow) continue;

      _postMountFrameIndex++;
      final rounded = totalMs.round();
      final detail = _postMountFrameIndex <= _postMountDetailLimit;
      final expensive = totalMs >= 18;
      if (expensive) {
        _expensivePostMount++;
        if (rounded > _worstPostMountMs) _worstPostMountMs = rounded;
      }
      if (detail || expensive) {
        // ignore: avoid_print — Phase 6 diagnostic
        print(
          'PHASE6 frame '
          'i=$_postMountFrameIndex '
          'buildMs=${t.buildDuration.inMilliseconds} '
          'rasterMs=${t.rasterDuration.inMilliseconds} '
          'vsyncMs=$vsyncMs '
          'spanMs=${t.totalSpan.inMilliseconds} '
          'totalMs=$rounded '
          '${expensive ? 'EXPENSIVE ' : ''}'
          'at=${_boot.elapsedMilliseconds}',
        );
      }
    }
  }
}
