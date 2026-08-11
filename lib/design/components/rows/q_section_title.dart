import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// An editorial section title.
///
/// The replacement for `QSectionHeader` on every product surface. A section on
/// a person's page is a chapter in their story — "Their year", "Memories",
/// "This week" — so it is set in the Voice, in sentence case, at a size the eye
/// reads as a heading rather than as a field label.
///
/// `QSectionHeader` survives for the one job capitals are still right for:
/// labelling an input inside an editor, where the label is chrome and must
/// visibly not be content.
class QSectionTitle extends StatelessWidget {
  const QSectionTitle(
    this.title, {
    this.support,
    this.trailing,
    this.isFirst = false,
    super.key,
  });

  final String title;

  /// One line beneath the title. Sets the tone of the section rather than
  /// explaining it.
  final String? support;

  /// A count, or a single low-stakes action.
  final Widget? trailing;

  /// The first title on a screen sits closer to what precedes it than a title
  /// that opens a new chapter.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? q.space.xs : q.space.chapter,
        bottom: q.space.base,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textScaler: context.nameTextScaler,
                  style: q.text.sectionTitle.tinted(q.color.textPrimary),
                ),
                if (support != null && support!.isNotEmpty) ...[
                  SizedBox(height: q.space.xs),
                  Text(
                    support!,
                    style: q.text.metadata.tinted(q.color.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: q.space.md), trailing!],
        ],
      ),
    );
  }
}

/// A count set beside a section title.
class QSectionCount extends StatelessWidget {
  const QSectionCount(this.value, {super.key});

  final int value;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      // Optically aligned to the title's cap height rather than its box.
      padding: EdgeInsets.only(top: q.space.xs),
      child: Text(
        '$value',
        textScaler: context.structuralTextScaler,
        style: q.text.numeralSm.tinted(q.color.textTertiary),
      ),
    );
  }
}
