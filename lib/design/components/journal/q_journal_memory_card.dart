import 'package:flutter/widgets.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Fixed-geometry diary memory card — theme journal-card paper when present.
///
/// Outer size is supplied by the parent deck. Content never changes card
/// dimensions; text truncates and the photo region stays fixed.
///
/// When [moodId] is set, a mirrored mood character hangs from the top-right
/// corner (~half outside the paper) without affecting card layout height.
class QJournalMemoryCard extends StatelessWidget {
  const QJournalMemoryCard({
    required this.archiveIndex,
    required this.title,
    this.bodyPreview,
    this.moodId,
    this.moodLabel,
    this.fragmentLabel,
    this.photo,
    this.onTap,
    this.showContent = true,
    super.key,
  });

  /// e.g. `No. 01`
  final String archiveIndex;
  final String title;
  final String? bodyPreview;

  /// Journal mood storage id — drives the overlapping illustration.
  final String? moodId;
  final String? moodLabel;
  final String? fragmentLabel;
  final Widget? photo;
  final VoidCallback? onTap;

  /// When false, only the paper silhouette renders (depth ≥ 2 deck layers).
  final bool showContent;

  /// Width / height — portrait diary card.
  static const aspectRatio = 0.72;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final layout = context.appTheme.assets.layout;
    final cardAspect = layout.journalCardAspectRatio ?? aspectRatio;

    final card = AspectRatio(
      aspectRatio: cardAspect,
      child: QMoodDecoratedPaper(
        moodId: showContent ? moodId : null,
        child: QJournalCardSurface(
          scaleContentToFit: false,
          padding: layout.journalCardContent != null
              ? null
              : EdgeInsets.fromLTRB(
                  q.space.lg,
                  q.space.md,
                  q.space.lg,
                  q.space.md,
                ),
          child: showContent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      archiveIndex,
                      textScaler: context.structuralTextScaler,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: q.inked(
                        q.text.decorativeLabel,
                        surface: QuietSurfaceKind.paper,
                        tone: QuietInkTone.secondary,
                      ),
                    ),
                    SizedBox(height: q.space.sm),
                    Expanded(
                      flex: photo != null ? 5 : 2,
                      child: photo != null
                          ? _PhotoFrame(child: photo!)
                          : const SizedBox.expand(),
                    ),
                    SizedBox(height: q.space.sm),
                    Text(
                      title,
                      textScaler: context.nameTextScaler,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: q.inked(
                        q.text.memoryTitle,
                        surface: QuietSurfaceKind.paper,
                      ),
                    ),
                    if (bodyPreview != null &&
                        bodyPreview!.trim().isNotEmpty) ...[
                      SizedBox(height: q.space.xs),
                      Text(
                        bodyPreview!.trim(),
                        maxLines: photo != null ? 3 : 5,
                        overflow: TextOverflow.ellipsis,
                        style: q.inked(
                          q.text.journalWriting,
                          surface: QuietSurfaceKind.paper,
                          tone: QuietInkTone.secondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (moodLabel != null || fragmentLabel != null)
                      Row(
                        children: [
                          if (fragmentLabel != null) ...[
                            QGlyphIcon(
                              QuietGlyph.journal,
                              color: paper.secondary,
                              size: 14,
                            ),
                            SizedBox(width: q.space.xs),
                          ],
                          Expanded(
                            child: Text(
                              [
                                if (moodLabel != null) moodLabel,
                                if (fragmentLabel != null) fragmentLabel,
                              ].join(' · '),
                              textScaler: context.structuralTextScaler,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: q.inked(
                                q.text.uiCaption,
                                surface: QuietSurfaceKind.paper,
                                tone: QuietInkTone.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : const SizedBox.expand(),
        ),
      ),
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final paper = q.paper;
    final j = q.journal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: j.photoMat,
        border: Border.all(
          color: paper.border,
          width: context.hairlineWidth * 2,
        ),
        boxShadow: [
          BoxShadow(
            color: j.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(q.space.xs),
        child: ClipRect(
          child: SizedBox.expand(child: child),
        ),
      ),
    );
  }
}
