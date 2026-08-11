import 'package:flutter/widgets.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Presents a `QSheet` with the T2 transition.
///
/// The sheet rises over `slow` on the emphasized curve and leaves over `quick`
/// on the exit curve, because leaving should always feel faster than arriving.
///
/// The page-recede effect described in docs/07-motion.md T2 is driven by the
/// underlying route's `secondaryAnimation`, so screens opt into it when they
/// are built in Phase 4; the sheet itself does not reach behind to apply it.
Future<T?> showQSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return Navigator.of(
    context,
    rootNavigator: true,
  ).push<T>(QSheetRoute<T>(builder: builder, dismissible: dismissible));
}

class QSheetRoute<T> extends PopupRoute<T> {
  QSheetRoute({required this.builder, this.dismissible = true});

  final WidgetBuilder builder;
  final bool dismissible;

  /// Below this fraction of the sheet's height, a release settles back.
  static const _dismissThreshold = 0.35;

  /// A flick faster than this dismisses regardless of distance.
  static const _dismissVelocity = 700.0;

  @override
  Color? get barrierColor => _barrierColor;
  Color? _barrierColor;

  @override
  bool get barrierDismissible => dismissible;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 360);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 160);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Resolved here rather than in the field initialiser so it follows the
    // active theme.
    _barrierColor ??= context.quiet.color.scrim;

    return Align(
      alignment: Alignment.bottomCenter,
      child: _DraggableSheet(
        route: this,
        dismissible: dismissible,
        child: Builder(builder: builder),
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final motion = QuietMotion.of(context);

    if (motion.reduced) {
      return FadeTransition(opacity: animation, child: child);
    }

    final curved = CurvedAnimation(
      parent: animation,
      curve: motion.emphasized,
      reverseCurve: motion.exit,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}

/// Lets the sheet follow the finger and hands velocity to the settle.
class _DraggableSheet extends StatefulWidget {
  const _DraggableSheet({
    required this.route,
    required this.child,
    required this.dismissible,
  });

  final QSheetRoute<dynamic> route;
  final Widget child;
  final bool dismissible;

  @override
  State<_DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<_DraggableSheet> {
  double _dragOffset = 0;
  double _height = 0;

  bool get _enabled => widget.dismissible && !context.prefersReducedMotion;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_enabled) return;
    setState(() {
      // Downward only. Upward drag meets resistance rather than stretching.
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_enabled) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    final passedDistance =
        _height > 0 && _dragOffset / _height > QSheetRoute._dismissThreshold;
    final flicked = velocity > QSheetRoute._dismissVelocity;

    if (passedDistance || flicked) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: AnimatedSlide(
        offset: Offset(0, _height == 0 ? 0 : _dragOffset / _height),
        duration: _dragOffset == 0 ? q.motion.quick : Duration.zero,
        curve: q.motion.standard,
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final box = context.findRenderObject() as RenderBox?;
              final measured = box?.size.height ?? 0;
              if (measured > 0 && measured != _height) {
                setState(() => _height = measured);
              }
            });
            return widget.child;
          },
        ),
      ),
    );
  }
}
