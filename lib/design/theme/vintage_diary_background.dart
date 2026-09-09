import 'package:flutter/widgets.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/color_tokens.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

/// The Vintage Diary background — aged dark parchment texture.
///
/// [vintage-bg] is the visual foundation of the entire app. It scales to cover
/// the viewport, stays fixed behind scrollable content, and never repeats
/// with visible seams on phone aspect ratios.
class VintageDiaryBackground extends StatelessWidget {
  const VintageDiaryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: ColorTokens.vdDiaryCanvas,
        image: DecorationImage(
          image: AssetImage(VintageDiaryAssets.background),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Wraps content with the diary texture and a subtle vignette for readability.
class VintageDiaryCanvas extends StatelessWidget {
  const VintageDiaryCanvas({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Stack(
      fit: StackFit.expand,
      children: [
        const VintageDiaryBackground(),
        // Soft edge darkening so cream type stays legible over busy corners.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 1.15,
              colors: [
                q.color.transparent,
                ColorTokens.vdScrim.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Physical diary card surface using the supplied Journal-Card asset.
class VintageDiaryJournalCard extends StatelessWidget {
  const VintageDiaryJournalCard({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final resolvedPadding =
        padding ??
        EdgeInsets.fromLTRB(q.space.xl, q.space.lg, q.space.xl, q.space.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(q.radius.lg),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.vdInkPrimary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage(VintageDiaryAssets.journalCard),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(q.radius.lg),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}

/// Aged parchment page for the Journal month calendar (`Calendar.png`).
///
/// Cream / tan paper — use journal brown ink for text, not cream chrome.
class VintageDiaryCalendarSurface extends StatelessWidget {
  const VintageDiaryCalendarSurface({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final j = q.journal;
    final resolvedPadding =
        padding ??
        EdgeInsets.fromLTRB(q.space.sm, q.space.md, q.space.sm, q.space.md);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: j.paper,
        borderRadius: BorderRadius.circular(q.radius.md),
        border: Border.all(color: j.edge, width: context.hairlineWidth),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.vdInkPrimary.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage(VintageDiaryAssets.calendar),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(q.radius.md),
        child: QuietControlSurfaceScope(
          surface: QuietControlSurface.parchment,
          child: Padding(padding: resolvedPadding, child: child),
        ),
      ),
    );
  }
}
