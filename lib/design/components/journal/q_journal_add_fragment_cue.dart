import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Quiet “+” that expands in place into a horizontal fragment chooser.
///
/// Collapsed: `+`
/// Expanded: Writing · List · Photograph · Audio on one line
///
/// Interaction reference: notebook “what comes next” chips — not a sheet.
class QJournalAddFragmentCue extends StatefulWidget {
  const QJournalAddFragmentCue({
    required this.choices,
    this.label = 'Add something to remember',
    super.key,
  });

  /// Short labels shown horizontally when expanded.
  final List<(String label, VoidCallback onTap)> choices;
  final String label;

  @override
  State<QJournalAddFragmentCue> createState() => _QJournalAddFragmentCueState();
}

class _QJournalAddFragmentCueState extends State<QJournalAddFragmentCue> {
  var _open = false;

  void _collapse() {
    if (!_open) return;
    setState(() => _open = false);
  }

  void _expand() {
    if (_open) return;
    setState(() => _open = true);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    if (!_open) {
      return Semantics(
        button: true,
        label: widget.label,
        child: Center(
          child: QPressable(
            onTap: _expand,
            radius: q.radius.full,
            semanticLabel: widget.label,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: q.space.lg,
                vertical: q.space.sm,
              ),
              child: Text(
                '+',
                style: q.inked(q.text.label),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.label,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, choice) in widget.choices.indexed) ...[
                if (index > 0) SizedBox(width: q.space.sm),
                _FragmentChip(
                  label: choice.$1,
                  onTap: () {
                    _collapse();
                    choice.$2();
                  },
                ),
              ],
              SizedBox(width: q.space.sm),
              QPressable(
                onTap: _collapse,
                radius: q.radius.full,
                semanticLabel: 'Close',
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: q.space.sm,
                    vertical: q.space.sm,
                  ),
                  child: Text(
                    '×',
                    style: q.inked(q.text.label, tone: QuietInkTone.secondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FragmentChip extends StatelessWidget {
  const _FragmentChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;

    return QPressable(
      onTap: onTap,
      radius: q.radius.full,
      semanticLabel: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(q.radius.full),
          border: Border.all(color: paper.border, width: context.hairlineWidth),
          color: paper.fill,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: q.space.md,
            vertical: q.space.sm,
          ),
          child: Text(
            label,
            textScaler: context.structuralTextScaler,
            style: q.inked(q.text.label, surface: QuietSurfaceKind.paper),
          ),
        ),
      ),
    );
  }
}
