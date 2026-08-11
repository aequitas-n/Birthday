import 'package:flutter/widgets.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_journal_paper.dart';
import 'package:kin/design/components/journal/q_journal_tape.dart';
import 'package:kin/design/theme/journal_mood_colors.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Visual variant for an archival memory fragment.
enum QJournalFragmentKind {
  typewritten,
  scrap,
  diary,
  photoPrint,
  document,
}

/// One memory as an archival artifact on a day page.
class QJournalFragment extends StatelessWidget {
  const QJournalFragment({
    required this.title,
    required this.onTap,
    this.bodyPreview,
    this.moodId,
    this.moodLabel,
    this.archiveIndex,
    this.kind = QJournalFragmentKind.typewritten,
    this.hasPhotos = false,
    this.photoThumb,
    this.rotation = 0,
    this.widthFactor = 1,
    this.showTape = false,
    this.showClip = false,
    this.seed = 0,
    super.key,
  });

  final String title;
  final String? bodyPreview;
  final String? moodId;
  final String? moodLabel;
  final String? archiveIndex;
  final QJournalFragmentKind kind;
  final bool hasPhotos;
  final Widget? photoThumb;
  final double rotation;
  final double widthFactor;
  final bool showTape;
  final bool showClip;
  final int seed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final torn =
        kind == QJournalFragmentKind.diary ||
        kind == QJournalFragmentKind.scrap;

    Color? tint;
    if (moodId != null) {
      final (fill, _) = JournalMoodColors.resolve(moodId!, dark: q.isDark);
      tint = Color.lerp(j.paper, fill, 0.18);
    }

    final titleStyle = switch (kind) {
      QJournalFragmentKind.typewritten ||
      QJournalFragmentKind.document => q.text.archiveTitle.tinted(j.ink),
      QJournalFragmentKind.photoPrint => q.text.voiceSm.tinted(j.ink),
      _ => q.text.voiceSm.tinted(j.ink),
    };

    final maxLines = switch (kind) {
      QJournalFragmentKind.document => 5,
      QJournalFragmentKind.scrap => 2,
      _ => 3,
    };

    final paper = QJournalPaper(
      torn: torn,
      tint: tint,
      seed: seed,
      elevated: kind == QJournalFragmentKind.photoPrint,
      padding: EdgeInsets.fromLTRB(
        q.space.md,
        q.space.md,
        q.space.md,
        q.space.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (archiveIndex != null) ...[
            Text(
              archiveIndex!,
              textScaler: context.structuralTextScaler,
              style: q.text.archiveLabel.tinted(j.inkMuted),
            ),
            SizedBox(height: q.space.xs),
          ],
          if (photoThumb != null) ...[
            AspectRatio(
              aspectRatio: 5 / 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: j.photoMat,
                  border: Border.all(
                    color: j.edge,
                    width: context.hairlineWidth * 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(q.space.xs),
                  child: photoThumb,
                ),
              ),
            ),
            SizedBox(height: q.space.sm),
          ],
          Text(
            title,
            textScaler: context.nameTextScaler,
            style: titleStyle,
          ),
          if (bodyPreview != null && bodyPreview!.isNotEmpty) ...[
            SizedBox(height: q.space.xs),
            Text(
              bodyPreview!,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: q.text.archiveBody.tinted(j.inkMuted),
            ),
          ],
          if (moodLabel != null || hasPhotos) ...[
            SizedBox(height: q.space.sm),
            Text(
              [
                if (moodLabel != null) moodLabel,
                if (hasPhotos) 'photograph',
              ].join(' · '),
              textScaler: context.structuralTextScaler,
              style: q.text.archiveCaption.tinted(j.inkMuted),
            ),
          ],
        ],
      ),
    );

    final labeled = Semantics(
      button: true,
      label: [
        title,
        if (moodLabel != null) moodLabel,
        if (hasPhotos) 'has photographs',
      ].join(', '),
      child: QPressable(
        onTap: onTap,
        radius: q.radius.sm,
        child: paper,
      ),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor.clamp(0.68, 1.0),
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              labeled,
              if (showTape)
                Positioned(
                  top: -5,
                  left: q.space.lg,
                  child: QJournalTape(angle: rotation > 0 ? -0.14 : 0.1),
                ),
              if (showClip)
                Positioned(
                  top: -8,
                  right: q.space.md,
                  child: QJournalClip(angle: rotation > 0 ? -0.08 : 0.16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
