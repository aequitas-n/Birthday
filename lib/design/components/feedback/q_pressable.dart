import 'package:flutter/widgets.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Press feedback for every interactive surface in Kin.
///
/// The scale is anchored at the touch point rather than the widget centre.
/// It is a small thing and it is most of why the app feels expensive — the
/// surface appears to yield under the finger that is actually touching it.
///
/// Focus rings appear for keyboard and assistive input only, never on touch,
/// and are never suppressed. See docs/04-design-system.md §5.
class QPressable extends StatefulWidget {
  const QPressable({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.radius = 0,
    this.pressTint,
    this.enabled = true,
    this.selected,
    this.semanticLabel,
    this.semanticHint,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Radius of the press tint and the focus ring.
  final double radius;

  /// Tint painted beneath the child while pressed. Defaults to the sunken
  /// surface.
  final Color? pressTint;

  final bool enabled;

  /// Set on surfaces that are one of a set of choices, so assistive tech
  /// announces the current one instead of leaving the user to infer it from a
  /// visual ring they cannot see.
  final bool? selected;

  final String? semanticLabel;
  final String? semanticHint;

  @override
  State<QPressable> createState() => _QPressableState();
}

class _QPressableState extends State<QPressable> {
  static const _ringWidth = 2.0;
  static const _ringOffset = 3.0;

  bool _pressed = false;
  bool _focused = false;
  Alignment _anchor = Alignment.center;

  bool get _interactive =>
      widget.enabled && (widget.onTap != null || widget.onLongPress != null);

  void _onTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size;
    setState(() {
      _pressed = true;
      _anchor = (size == null || size.isEmpty)
          ? Alignment.center
          : Alignment(
              ((details.localPosition.dx / size.width) * 2 - 1).clamp(
                -1.0,
                1.0,
              ),
              ((details.localPosition.dy / size.height) * 2 - 1).clamp(
                -1.0,
                1.0,
              ),
            );
    });
  }

  void _release() {
    if (!_pressed) return;
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final motion = QuietMotion.of(context);
    final tint = widget.pressTint ?? q.color.sunken;
    final borderRadius = BorderRadius.all(Radius.circular(widget.radius));

    return Semantics(
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      button: _interactive,
      onTap: _interactive ? widget.onTap : null,
      onLongPress: _interactive ? widget.onLongPress : null,
      enabled: widget.enabled,
      selected: widget.selected,
      // A row announces name, relationship and time-to-birthday as one
      // coherent sentence. Without this, assistive tech reads the same
      // information three times as disconnected fragments.
      excludeSemantics: widget.semanticLabel != null,
      child: FocusableActionDetector(
        enabled: _interactive,
        onShowFocusHighlight: (value) {
          if (value != _focused) setState(() => _focused = value);
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _interactive ? _onTapDown : null,
          onTapUp: _interactive ? (_) => _release() : null,
          onTapCancel: _interactive ? _release : null,
          onTap: _interactive ? widget.onTap : null,
          onLongPress: _interactive ? widget.onLongPress : null,
          child: AnimatedScale(
            scale: _pressed ? motion.scale(q.motion.pressScale) : 1,
            alignment: _anchor,
            duration: _pressed
                ? motion.move(q.motion.instant)
                : motion.move(q.motion.quick),
            curve: _pressed ? motion.standard : motion.enter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The tint sits behind the child, so the child's own opacity
                // is never touched.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _pressed ? 1 : 0,
                      duration: q.motion.instant,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: borderRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                widget.child,
                if (_focused)
                  Positioned(
                    left: -_ringOffset,
                    top: -_ringOffset,
                    right: -_ringOffset,
                    bottom: -_ringOffset,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: q.color.accent,
                              width: _ringWidth,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.radius + _ringOffset),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
