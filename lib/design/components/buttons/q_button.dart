import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_arc.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Three variants. There is no fourth, and no sizes beyond this.
///
/// See docs/08-components.md §1.
enum QButtonVariant {
  /// The single most important action on a screen. Exactly one per screen,
  /// or none.
  primary,

  /// Alternative actions.
  secondary,

  /// Dismiss, skip, low-stakes.
  tertiary,
}

class QButton extends StatefulWidget {
  const QButton({
    required this.label,
    required this.onPressed,
    this.variant = QButtonVariant.secondary,
    this.glyph,
    this.loading = false,
    this.destructive = false,
    super.key,
  });

  const QButton.primary({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.loading = false,
    super.key,
  }) : variant = QButtonVariant.primary,
       destructive = false;

  const QButton.tertiary({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.loading = false,
    super.key,
  }) : variant = QButtonVariant.tertiary,
       destructive = false;

  /// Destructive actions are a secondary button with danger text, never a
  /// filled red one. Red fills read as alarm, and this app does not alarm.
  const QButton.destructive({
    required this.label,
    required this.onPressed,
    this.glyph,
    this.loading = false,
    super.key,
  }) : variant = QButtonVariant.secondary,
       destructive = true;

  final String label;

  /// A null callback disables the button.
  final VoidCallback? onPressed;

  final QButtonVariant variant;
  final QuietGlyph? glyph;
  final bool loading;
  final bool destructive;

  static const double minHeight = 44;
  static const double maxWidth = 320;
  static const double glyphSize = 18;
  static const double disabledOpacity = 0.38;

  @override
  State<QButton> createState() => _QButtonState();
}

class _QButtonState extends State<QButton> {
  Timer? _spinnerDelay;
  bool _showSpinner = false;

  @override
  void didUpdateWidget(QButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loading == oldWidget.loading) return;
    _spinnerDelay?.cancel();
    if (widget.loading) {
      // A spinner that appears sooner than this flashes on fast operations,
      // which is worse than showing nothing at all.
      _spinnerDelay = Timer(
        context.quiet.motion.loadingIndicatorDelay,
        () => setState(() => _showSpinner = true),
      );
    } else {
      _showSpinner = false;
    }
  }

  @override
  void dispose() {
    _spinnerDelay?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final c = q.color;
    final enabled = widget.onPressed != null && !widget.loading;

    final foreground = switch (widget.variant) {
      _ when widget.destructive => c.danger,
      QButtonVariant.primary => c.textInverse,
      QButtonVariant.secondary => c.textPrimary,
      QButtonVariant.tertiary => c.textSecondary,
    };

    // The primary action is the only one set in the button token's full weight.
    // Secondary and tertiary labels stay at label weight, so a screen has one
    // typographic centre of gravity rather than three competing ones.
    final labelStyle = widget.variant == QButtonVariant.primary
        ? q.text.buttonLabel
        : q.text.label;

    final horizontalPadding = widget.glyph == null ? q.space.lg : q.space.base;

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The label keeps its box while loading, so the button never
          // resizes mid-action.
          Opacity(
            opacity: _showSpinner ? 0 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.glyph != null) ...[
                  QGlyphIcon(
                    widget.glyph!,
                    color: foreground,
                    size: QButton.glyphSize,
                  ),
                  SizedBox(width: q.space.sm),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textScaler: context.structuralTextScaler,
                    style: labelStyle.tinted(foreground),
                  ),
                ),
              ],
            ),
          ),
          if (_showSpinner) QArc(color: foreground),
        ],
      ),
    );

    // The primary fill is the accent, which QSurface cannot express because
    // its levels are neutrals only.
    final painted = switch (widget.variant) {
      QButtonVariant.primary => DecoratedBox(
        decoration: ShapeDecoration(
          color: c.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(q.radius.sm)),
          ),
        ),
        child: SizedBox(
          height: QButton.minHeight,
          child: Center(child: content),
        ),
      ),
      QButtonVariant.secondary => QSurface(
        radius: q.radius.sm,
        height: QButton.minHeight,
        elevation: QuietElevationLevel.hairline,
        borderColor: c.hairlineStrong,
        child: Center(child: content),
      ),
      QButtonVariant.tertiary => SizedBox(
        height: QButton.minHeight,
        child: Center(child: content),
      ),
    };

    return Opacity(
      opacity: enabled ? 1 : QButton.disabledOpacity,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: QButton.maxWidth),
        child: IntrinsicWidth(
          child: QPressable(
            enabled: enabled,
            radius: q.radius.sm,
            semanticLabel: widget.label,
            pressTint: widget.variant == QButtonVariant.primary
                ? c.accentPressed
                : c.sunken,
            onTap: enabled
                ? () {
                    unawaited(HapticFeedback.selectionClick());
                    widget.onPressed?.call();
                  }
                : null,
            child: painted,
          ),
        ),
      ),
    );
  }
}
