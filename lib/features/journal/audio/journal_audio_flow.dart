import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/journal/audio/journal_audio_store.dart';
import 'package:record/record.dart';

/// Draft audio before it is persisted into a fragment.
class JournalAudioDraft {
  const JournalAudioDraft({
    required this.tempPath,
    required this.durationMs,
  });

  final String tempPath;
  final int durationMs;
}

/// Record a short memory as sound. Returns null if cancelled.
Future<JournalAudioDraft?> recordJournalAudioDraft(BuildContext context) {
  QuietHaptics.open();
  return showQSheet<JournalAudioDraft>(
    context: context,
    builder: (context) => const _RecordAudioSheet(),
  );
}

class _RecordAudioSheet extends StatefulWidget {
  const _RecordAudioSheet();

  @override
  State<_RecordAudioSheet> createState() => _RecordAudioSheetState();
}

class _RecordAudioSheetState extends State<_RecordAudioSheet> {
  final _recorder = AudioRecorder();
  final _elapsed = Stopwatch();
  String? _path;
  var _recording = false;
  var _kept = false;

  @override
  void dispose() {
    _recorder.dispose();
    final path = _path;
    if (!_kept && path != null) {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_recording) {
      final path = await _recorder.stop();
      _elapsed.stop();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _path = path;
      });
      return;
    }

    final allowed = await _recorder.hasPermission();
    if (!allowed || !mounted) return;

    // Discard a previous unfinished take.
    final previous = _path;
    if (previous != null) {
      final file = File(previous);
      if (file.existsSync()) file.deleteSync();
    }

    final path = await const LocalAudioStore().createTempRecordingPath();
    try {
      await _recorder.start(const RecordConfig(), path: path);
    } on Object {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _path = null;
      });
      return;
    }
    if (!mounted) return;
    _elapsed
      ..reset()
      ..start();
    setState(() {
      _recording = true;
      _path = path;
    });
  }

  void _keep() {
    final path = _path;
    if (path == null || _recording) return;
    final duration = _elapsed.elapsedMilliseconds.clamp(1, 60 * 60 * 1000);
    _kept = true;
    Navigator.of(context).pop(
      JournalAudioDraft(tempPath: path, durationMs: duration),
    );
  }

  Future<void> _discard() async {
    if (_recording) {
      await _recorder.stop();
      _elapsed.stop();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QSheet(
      title: 'Keep a moment in sound',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _recording
                ? 'Recording… tap Stop when you are done.'
                : _path == null
                ? 'Tap Record to begin.'
                : 'Ready to keep.',
            style: q.inked(q.text.uiBody, tone: QuietInkTone.secondary),
          ),
          SizedBox(height: q.space.xl),
          QButton.primary(
            label: _recording
                ? 'Stop'
                : _path == null
                ? 'Record'
                : 'Record again',
            onPressed: _toggle,
          ),
          if (_path != null && !_recording) ...[
            SizedBox(height: q.space.sm),
            QButton.primary(
              label: 'Keep audio',
              onPressed: _keep,
            ),
          ],
          SizedBox(height: q.space.sm),
          QButton.tertiary(
            label: 'Not now',
            onPressed: _discard,
          ),
        ],
      ),
    );
  }
}

Future<String> persistJournalAudioDraft({
  required JournalAudioDraft draft,
}) async {
  final written = await const LocalAudioStore().putFile(
    File(draft.tempPath),
  );
  return written.relativePath;
}

/// Archival voice-fragment playback — paper, not a media player.
class JournalAudioPlayback extends ConsumerStatefulWidget {
  const JournalAudioPlayback({
    required this.relativePath,
    this.durationMs,
    this.caption,
    super.key,
  });

  final String relativePath;
  final int? durationMs;
  final String? caption;

  @override
  ConsumerState<JournalAudioPlayback> createState() =>
      _JournalAudioPlaybackState();
}

class _JournalAudioPlaybackState extends ConsumerState<JournalAudioPlayback> {
  final _player = AudioPlayer();
  var _ready = false;
  var _missing = false;
  var _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    final seedMs = widget.durationMs;
    if (seedMs != null) {
      _duration = Duration(milliseconds: seedMs);
    }
    _load();
  }

  Future<void> _load() async {
    final candidate = File(widget.relativePath);
    final file = candidate.existsSync()
        ? candidate
        : await const LocalAudioStore().resolve(widget.relativePath);
    if (!file.existsSync()) {
      if (mounted) setState(() => _missing = true);
      return;
    }
    try {
      await _player.setFilePath(file.path);
    } on Object {
      if (mounted) setState(() => _missing = true);
      return;
    }
    if (!mounted) return;
    setState(() {
      _ready = true;
      _duration = _player.duration ?? _duration;
    });
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state.playing);
    });
    _player.positionStream.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _player.durationStream.listen((duration) {
      if (!mounted || duration == null) return;
      setState(() => _duration = duration);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (!_ready || _missing) return;
    if (_playing) {
      await _player.pause();
    } else {
      if (_position >= _duration && _duration > Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  String _format(Duration value) {
    final total = value.inSeconds.clamp(0, 3600);
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final caption = (widget.caption?.trim().isNotEmpty ?? false)
        ? widget.caption!.trim()
        : 'Voice note';
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Semantics(
      label: caption,
      button: true,
      child: QPressable(
        onTap: _missing ? null : _toggle,
        radius: q.radius.md,
        semanticLabel: caption,
        semanticHint: _missing
            ? 'Audio file missing'
            : (_playing ? 'Pause' : 'Play'),
        child: QSurface(
          elevation: QuietElevationLevel.hairline,
          radius: q.radius.md,
          padding: EdgeInsets.all(q.space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'VOICE NOTE',
                textScaler: context.structuralTextScaler,
                style: q.inked(q.text.uiMetadata, tone: QuietInkTone.secondary),
              ),
              SizedBox(height: q.space.sm),
              if (_missing)
                Text(
                  'This recording is no longer on this device.',
                  style: q.inked(q.text.uiBody, tone: QuietInkTone.secondary),
                )
              else ...[
                Row(
                  children: [
                    Text(
                      _playing ? '||' : '>',
                      style: q.inked(q.text.uiMetadata),
                    ),
                    SizedBox(width: q.space.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 2,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: q.color.hairline,
                                    borderRadius: BorderRadius.circular(
                                      q.radius.full,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: progress,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: q.canvas.primary,
                                        borderRadius: BorderRadius.circular(
                                          q.radius.full,
                                        ),
                                      ),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: q.space.xs),
                          Row(
                            children: [
                              Text(
                                _format(_position),
                                style: q.inked(
                                  q.text.uiCaption,
                                  tone: QuietInkTone.secondary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _format(_duration),
                                style: q.inked(
                                  q.text.uiCaption,
                                  tone: QuietInkTone.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: q.space.sm),
                Text(
                  caption,
                  style: q.inked(q.text.sectionTitle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
