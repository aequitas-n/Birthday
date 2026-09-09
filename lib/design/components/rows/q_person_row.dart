import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The most important component in the app.
///
/// The home timeline is typography, not a card deck. There is no chrome here on
/// purpose: the name is the anchor, the date supports it, and the countdown is
/// a quiet badge that never competes with either.
///
/// Hierarchy: name → date/place → countdown badge.
class QPersonRow extends StatelessWidget {
  const QPersonRow({
    required this.displayName,
    required this.seed,
    required this.daysUntil,
    this.nextBirthdayLine,
    this.countdownText,
    this.subtitle,
    this.photo,
    this.turningAge,
    this.onTap,
    this.onLongPress,
    this.heroTag,
    super.key,
  });

  final String displayName;

  /// Stable id, used for the monogram tint and the shared-element tag.
  final String seed;

  /// Zero means today.
  final int daysUntil;

  /// e.g. `7 July · Chennai`.
  final String? nextBirthdayLine;

  /// e.g. `344 days`. Falls back to derived text from [daysUntil].
  final String? countdownText;

  /// Deprecated alias for [nextBirthdayLine].
  final String? subtitle;

  final ImageProvider? photo;

  /// Null when the birth year is unknown, which is common and fine.
  final int? turningAge;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Object? heroTag;

  bool get _isToday => daysUntil == 0;

  String get _dateLine => nextBirthdayLine ?? subtitle ?? '';

  String get _countdown =>
      countdownText ??
      switch (daysUntil) {
        0 => 'Today',
        1 => 'Tomorrow',
        _ => '$daysUntil days',
      };

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;
    final restacked = context.restacksRows;

    final name = Text(
      displayName,
      maxLines: restacked ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textScaler: context.nameTextScaler,
      // A shade heavier on the day itself. The only weight change in the
      // timeline, and it is what makes the eye land on today's row first.
      style: (_isToday ? q.text.voiceSmEmphasis : q.text.personName).tinted(
        c.textPrimary,
      ),
    );

    final dateLine = _dateLine.isEmpty
        ? null
        : Text(
            _dateLine,
            maxLines: restacked ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textScaler: context.structuralTextScaler,
            style: q.text.uiMetadata.tinted(c.textSecondary),
          );

    final countdown = _CountdownBadge(
      label: _countdown,
      emphasized: _isToday,
      alignStart: restacked,
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        name,
        if (dateLine != null) ...[
          SizedBox(height: q.space.hair),
          dateLine,
        ],
        if (restacked) ...[
          SizedBox(height: q.space.sm),
          countdown,
        ],
      ],
    );

    final avatar = QAvatar(
      displayName: displayName,
      seed: seed,
      photo: photo,
      heroTag: heroTag,
    );

    final Widget body = Row(
      crossAxisAlignment: restacked
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        avatar,
        SizedBox(width: q.space.md),
        Expanded(child: text),
        if (!restacked) ...[SizedBox(width: q.space.sm), countdown],
      ],
    );

    return QPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      radius: q.radius.md,
      semanticLabel: _semanticLabel(),
      child: Padding(
        // Dense vertical rhythm: the timeline should hold five or six people
        // before the fold, and still leave each row feelable under a finger.
        padding: EdgeInsets.symmetric(
          horizontal: q.space.xs,
          vertical: q.space.sm,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: restacked
                ? q.layout.personRowHeightStacked
                : q.layout.personRowHeight,
          ),
          child: body,
        ),
      ),
    );
  }

  /// One coherent sentence, not three disconnected fragments.
  String _semanticLabel() {
    final parts = <String>[displayName];
    if (_dateLine.isNotEmpty) parts.add(_dateLine);
    parts.add(_countdown);
    return parts.join(', ');
  }
}

/// Countdown as a quiet capsule, tied to the row rather than floating free.
class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({
    required this.label,
    required this.emphasized,
    required this.alignStart,
  });

  final String label;
  final bool emphasized;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = emphasized ? q.color.accent : q.color.textSecondary;
    final fill = emphasized ? q.color.accentWash : q.color.sunken;

    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: fill,
          shape: const StadiumBorder(),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: q.space.sm,
            vertical: q.space.xs,
          ),
          child: Text(
            label,
            maxLines: 1,
            textScaler: context.structuralTextScaler,
            style: q.text.numeralSm.tinted(ink),
          ),
        ),
      ),
    );
  }
}

/// The inset a person-row hairline uses, so separators align with the name's
/// left edge rather than the screen edge.
double personRowHairlineIndent(BuildContext context) {
  final q = context.quiet;
  return q.space.xs + QAvatarSize.md.diameter + q.space.md;
}
