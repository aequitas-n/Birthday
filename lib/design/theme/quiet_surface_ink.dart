import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:kin/design/theme/quiet_colors.dart';
import 'package:kin/design/theme/quiet_journal.dart';

/// Where type sits in Vintage Diary (and future themes).
///
/// Screens pick a surface once; ink comes from the theme — never hardcode
/// cream vs brown at call sites.
enum QuietSurfaceKind {
  /// Dark diary background, sheets, chrome, open writing wells.
  canvas,

  /// Cream paper cards, calendar parchment, polaroid mats, fragment chips.
  paper,
}

/// Emphasis within a surface's ink scale.
enum QuietInkTone {
  /// Titles, body, primary actions.
  primary,

  /// Dates, supporting copy, placeholders.
  secondary,

  /// Eyebrows, de-emphasized meta.
  tertiary,
}

/// Theme-owned ink + border (+ optional fill) for one surface.
///
/// ```dart
/// style: q.on(QuietSurfaceKind.canvas).type(q.text.pageTitle)
/// style: q.on(QuietSurfaceKind.paper).type(q.text.journalWriting)
/// style: q.on(QuietSurfaceKind.canvas).type(
///   q.text.uiDate,
///   tone: QuietInkTone.secondary,
/// )
/// ```
@immutable
final class QuietSurfaceInk {
  const QuietSurfaceInk({
    required this.kind,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.border,
    this.fill,
  });

  /// Builds canvas (cream-on-dark) and paper (brown-on-cream) from theme parts.
  factory QuietSurfaceInk.fromTheme({
    required QuietSurfaceKind kind,
    required QuietColors color,
    required QuietJournal journal,
  }) {
    return switch (kind) {
      QuietSurfaceKind.canvas => QuietSurfaceInk(
        kind: kind,
        primary: color.textPrimary,
        secondary: color.textSecondary,
        tertiary: color.textTertiary,
        border: color.textSecondary,
      ),
      QuietSurfaceKind.paper => QuietSurfaceInk(
        kind: kind,
        primary: journal.ink,
        secondary: journal.inkMuted,
        tertiary: journal.clip,
        border: journal.edge,
        fill: journal.paper,
      ),
    };
  }

  final QuietSurfaceKind kind;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color border;

  /// Solid fill when the surface is paper; `null` for open canvas wells.
  final Color? fill;

  Color ink(QuietInkTone tone) => switch (tone) {
    QuietInkTone.primary => primary,
    QuietInkTone.secondary => secondary,
    QuietInkTone.tertiary => tertiary,
  };

  /// Applies surface ink to a colourless typography role.
  TextStyle inked(
    TextStyle role, {
    QuietInkTone tone = QuietInkTone.primary,
  }) => role.copyWith(color: ink(tone));
}
