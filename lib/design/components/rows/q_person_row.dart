import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/media/q_avatar.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The most important component in the app.
///
/// Coming-up rows stay chrome-free on every product theme: typography + avatar
/// on the canvas (same hierarchy as decorative birthday strips). No paper
/// capsules — Default matches Vintage / Neon.
///
/// Hierarchy: name → date/place → countdown.
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

  /// Paper capsules are retired — Coming up is bare type on every theme.
  bool _usesPaperStrip(BuildContext context) =>
      personRowUsesPaperStrip(context);

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paperStrip = _usesPaperStrip(context);
    final restacked = context.restacksRows;
    final paper = q.on(QuietSurfaceKind.paper);

    final nameStyle = (_isToday ? q.text.voiceSmEmphasis : q.text.personName);
    final name = Text(
      displayName,
      maxLines: restacked ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textScaler: context.nameTextScaler,
      style: paperStrip
          ? paper.inked(nameStyle)
          : nameStyle.tinted(q.color.textPrimary),
    );

    final dateLine = _dateLine.isEmpty
        ? null
        : Text(
            _dateLine,
            maxLines: restacked ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textScaler: context.structuralTextScaler,
            style: paperStrip
                ? paper.inked(
                    q.text.uiMetadata,
                    tone: QuietInkTone.secondary,
                  )
                : q.text.uiMetadata.tinted(q.color.textSecondary),
          );

    final countdown = _CountdownBadge(
      label: _countdown,
      emphasized: _isToday,
      alignStart: restacked,
      onPaper: paperStrip,
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        name,
        if (dateLine != null) ...[
          SizedBox(height: paperStrip ? q.space.xs : q.space.hair),
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
        SizedBox(width: paperStrip ? q.space.base : q.space.md),
        Expanded(child: text),
        if (!restacked) ...[SizedBox(width: q.space.sm), countdown],
      ],
    );

    final padded = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: paperStrip ? q.space.base : q.space.xs,
        vertical: paperStrip ? q.space.md : q.space.sm,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: restacked
              ? q.layout.personRowHeightStacked
              : paperStrip
                  ? q.layout.personRowHeight + q.space.sm
                  : q.layout.personRowHeight,
        ),
        child: body,
      ),
    );

    final child = paperStrip
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: q.journal.paper,
              borderRadius: BorderRadius.circular(q.radius.md),
              border: Border.all(
                color: q.journal.edge,
                width: context.hairlineWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: q.journal.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: padded,
          )
        : padded;

    return QPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      radius: q.radius.md,
      semanticLabel: _semanticLabel(),
      child: child,
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
    required this.onPaper,
  });

  final String label;
  final bool emphasized;
  final bool alignStart;
  final bool onPaper;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = emphasized
        ? q.color.accent
        : (onPaper ? q.journal.inkMuted : q.color.textSecondary);

    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        label,
        maxLines: 1,
        textScaler: context.structuralTextScaler,
        style: q.text.numeralSm.tinted(ink),
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

/// Whether person rows should use gap separation instead of hairlines.
///
/// Always false — Coming up is bare type on Default, Vintage, and Neon.
bool personRowUsesPaperStrip(BuildContext context) => false;
