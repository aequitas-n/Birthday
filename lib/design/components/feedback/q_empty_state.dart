import 'package:flutter/widgets.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// An empty state is a first-class screen, not a grey illustration.
///
/// It is the state most users see first, so it gets the same design attention
/// as a full one. See docs/04-design-system.md §7.
class QEmptyState extends StatelessWidget {
  const QEmptyState({
    required this.headline,
    this.support,
    this.glyph,
    this.action,
    super.key,
  });

  final String headline;
  final String? support;
  final QuietGlyph? glyph;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    return Center(
      child: Padding(
        // True centre reads low, so the content is optically raised.
        padding: EdgeInsets.only(
          bottom: viewportHeight * q.layout.emptyStateOpticalLift,
          left: q.space.lg,
          right: q.space.lg,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: q.layout.emptyStateMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (glyph != null) ...[
                // Inside a soft disc rather than floating: a lone thin glyph on
                // a wide canvas reads as a missing image.
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: q.color.sunken,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(q.space.base),
                    child: QGlyphIcon(
                      glyph!,
                      color: q.color.textTertiary,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(height: q.space.xl),
              ],
              Text(
                headline,
                textAlign: TextAlign.center,
                textScaler: context.nameTextScaler,
                style: q.text.emptyStateTitle.tinted(q.color.textPrimary),
              ),
              if (support != null) ...[
                SizedBox(height: q.space.md),
                Text(
                  support!,
                  textAlign: TextAlign.center,
                  style: q.text.emptyStateBody.tinted(q.color.textSecondary),
                ),
              ],
              if (action != null) ...[
                SizedBox(height: q.space.chapter),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
