import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Top chrome over the dark diary canvas — title/actions only.
///
/// No parchment strip asset here; `bottom-navbar.png` is reserved for
/// bottom navigation alone. Ink is cream canvas chrome (desk), not brown paper.
class QDiaryTopBar extends StatelessWidget {
  const QDiaryTopBar({
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    super.key,
  });

  /// Editorial page title (`q.text.pageTitle`), e.g. Today / Kin / Journal.
  final String? title;

  /// Courier supporting line under the title (e.g. Birthdays).
  final String? subtitle;

  /// Optional leading control (back).
  final Widget? leading;

  /// Trailing icon buttons (+, settings, bell).
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final ink = q.canvas;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    // Desk surface so [QIconButton] chrome ink is cream, not parchment brown.
    return QuietControlSurfaceScope(
      surface: QuietControlSurface.desk,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.gutter - q.space.sm,
          q.space.base,
          context.gutter - q.space.sm,
          q.space.sm,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: q.layout.minTouchTarget,
          ),
          child: Row(
            children: [
              if (leading != null) leading!,
              if (title != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textScaler: context.nameTextScaler,
                        style: ink.inked(q.text.pageTitle),
                      ),
                      if (hasSubtitle) ...[
                        SizedBox(height: q.space.hair),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: context.structuralTextScaler,
                          style: ink.inked(
                            q.text.uiMetadata,
                            tone: QuietInkTone.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Spacer(),
              for (final action in actions) action,
            ],
          ),
        ),
      ),
    );
  }
}
