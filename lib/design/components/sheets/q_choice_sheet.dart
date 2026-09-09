import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// One choice, or one action.
class QChoice {
  const QChoice(this.label, {this.support, this.destructive = false});

  final String label;

  /// One line beneath, for choices that need a qualifier.
  final String? support;

  /// Draws the label in the danger role. Never a red fill.
  final bool destructive;
}

/// Pick one of a short list, in a sheet.
///
/// Every picker and every action list in the product goes through here: months,
/// photo actions, birthday actions. They were previously hand-built per screen
/// out of full-width buttons stacked with hairlines between them, which reads as
/// a stack of buttons rather than as a list of choices — and each screen drifted
/// a little from the last.
///
/// Returns the index of the chosen row, or null if dismissed.
Future<int?> showQChoiceSheet({
  required BuildContext context,
  required String title,
  required List<QChoice> choices,
  int? selectedIndex,
}) {
  return showQSheet<int>(
    context: context,
    builder: (context) => QSheet(
      title: title,
      child: _ChoiceList(choices: choices, selectedIndex: selectedIndex),
    ),
  );
}

class _ChoiceList extends StatelessWidget {
  const _ChoiceList({required this.choices, required this.selectedIndex});

  final List<QChoice> choices;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    // Scrollable only when it needs to be, so a three-item action list sits at
    // its natural height instead of opening a full-height sheet.
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, choice) in choices.indexed) ...[
            if (index > 0) const QHairline(),
            _ChoiceRow(
              choice: choice,
              selected: index == selectedIndex,
              onTap: () => Navigator.of(context).pop(index),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final QChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final i = q.interactive;
    final ink = choice.destructive ? q.color.danger : context.controlInk;

    return QPressable(
      onTap: onTap,
      radius: q.radius.md,
      semanticLabel: choice.label,
      selected: selected,
      child: SizedBox(
        height: q.layout.settingRowHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    choice.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: selected
                        ? q.text.body.tinted(i.accent)
                        : q.text.body.tinted(ink),
                  ),
                  if (choice.support != null) ...[
                    SizedBox(height: q.space.hair),
                    Text(
                      choice.support!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: q.text.metadata.tinted(context.controlInkMuted),
                    ),
                  ],
                ],
              ),
            ),
            // A check, not a filled radio: the row is already the control, and
            // a radio would add a second thing to look at on every line.
            if (selected)
              QGlyphIcon(
                QuietGlyph.check,
                color: i.accent,
                size: context.structuralTextScaler.scale(18),
              ),
          ],
        ),
      ),
    );
  }
}
