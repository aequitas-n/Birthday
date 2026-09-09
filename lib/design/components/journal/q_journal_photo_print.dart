import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// A photograph treated as a physical print in an archive.
class QJournalPhotoPrint extends StatelessWidget {
  const QJournalPhotoPrint({
    required this.child,
    this.caption,
    this.indexLabel,
    this.onTap,
    this.onRemove,
    this.rotation = 0,
    this.width,
    this.aspectRatio = 4 / 5,
    super.key,
  });

  final Widget child;
  final String? caption;
  final String? indexLabel;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final double rotation;
  final double? width;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;

    final print = DecoratedBox(
      decoration: BoxDecoration(
        color: j.photoMat,
        border: Border.all(color: j.edge, width: context.hairlineWidth * 2),
        boxShadow: [
          BoxShadow(
            color: j.shadow,
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          q.space.sm,
          q.space.sm,
          q.space.sm,
          q.space.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: ColoredBox(
                color: j.paperSunken,
                child: child,
              ),
            ),
            if (indexLabel != null || caption != null) ...[
              SizedBox(height: q.space.sm),
              Text(
                [
                  if (indexLabel != null) indexLabel,
                  if (caption != null && caption!.isNotEmpty) caption,
                ].whereType<String>().join(' — '),
                textScaler: context.structuralTextScaler,
                style: q.inked(
                  q.text.archiveCaption,
                  surface: QuietSurfaceKind.paper,
                  tone: QuietInkTone.secondary,
                ),
              ),
            ],
            if (onRemove != null) ...[
              SizedBox(height: q.space.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: QPressable(
                  onTap: onRemove,
                  semanticLabel: 'Remove photograph',
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: q.space.xs),
                    child: Text(
                      'Remove',
                      style: q.text.archiveCaption.tinted(q.color.danger),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final rotated = Transform.rotate(
      angle: rotation,
      child: SizedBox(width: width ?? 168, child: print),
    );

    if (onTap == null) return rotated;
    return QPressable(
      onTap: onTap,
      semanticLabel: caption ?? 'Photograph',
      child: rotated,
    );
  }
}
