import 'package:flutter/widgets.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/theme/illustrated_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// Each collection composes its own little scene. Drawings have reserved space,
/// so live writing and actions stay clear even at large accessibility sizes.
class QIllustratedJournalInvite extends StatelessWidget {
  const QIllustratedJournalInvite({
    required this.dateLabel,
    required this.onAdd,
    super.key,
  });
  final String dateLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final art = context.appTheme.art!;
    final q = context.quiet;
    final title = Text(
      art.invitation,
      style: q.text.invitationTitle.copyWith(color: art.ink),
    );
    final date = Text(
      dateLabel,
      style: q.text.uiMetadata.copyWith(color: art.muted),
    );
    final eyebrow = Text(
      art.eyebrow,
      style: q.text.uiMetadata.copyWith(
        color: art.accent,
        fontSize: 10,
        letterSpacing: 1.3,
      ),
    );
    final prompt = Text(
      art.style == IllustrationStyle.comic
          ? 'The big plot twist. Or the tiny good thing.'
          : 'A thought, a photo, a tiny good thing.',
      style: q.text.journalPrompt.copyWith(color: art.muted),
    );
    final action = QButton.primary(label: 'Add memory', onPressed: onAdd);
    Widget sprite(double size) =>
        QAnimatedIllustration(asset: art.atlas, size: size);
    Widget paper(
      Widget content, {
      EdgeInsets padding = const EdgeInsets.fromLTRB(25, 24, 25, 26),
    }) => QIllustratedSurface(padding: padding, child: content);
    Widget words() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 12), date],
    );

    return QuietControlSurfaceScope(
      surface: QuietControlSurface.parchment,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomy =
              constraints.maxWidth >= 300 &&
              MediaQuery.textScalerOf(context).scale(16) <= 23;
          // One readable stack is the intentional composition at very large type.
          if (!roomy) {
            return paper(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: sprite(100)),
                  words(),
                  const SizedBox(height: 18),
                  prompt,
                  const SizedBox(height: 20),
                  action,
                ],
              ),
            );
          }
          return switch (art.style) {
            IllustrationStyle.storybook => Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 78),
                  child: paper(
                    Column(
                      children: [
                        const SizedBox(height: 22),
                        eyebrow,
                        const SizedBox(height: 16),
                        DefaultTextStyle.merge(
                          textAlign: TextAlign.center,
                          child: title,
                        ),
                        const SizedBox(height: 12),
                        date,
                        const SizedBox(height: 18),
                        DefaultTextStyle.merge(
                          textAlign: TextAlign.center,
                          child: prompt,
                        ),
                        const SizedBox(height: 22),
                        action,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  left: (constraints.maxWidth - 132) / 2,
                  child: sprite(132),
                ),
              ],
            ),
            IllustrationStyle.seaside => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 10),
                  child: Row(
                    children: [
                      sprite(120),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            eyebrow,
                            const SizedBox(height: 14),
                            words(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                paper(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [prompt, const SizedBox(height: 20), action],
                  ),
                ),
              ],
            ),
            IllustrationStyle.botanical => Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 22),
                  child: paper(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 94),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              eyebrow,
                              const SizedBox(height: 12),
                              words(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        prompt,
                        const SizedBox(height: 20),
                        action,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -8,
                  left: -15,
                  child: Transform.rotate(angle: -0.045, child: sprite(128)),
                ),
              ],
            ),
            IllustrationStyle.comic => Stack(
              clipBehavior: Clip.none,
              children: [
                paper(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      eyebrow,
                      const SizedBox(height: 18),
                      title,
                      const SizedBox(height: 14),
                      date,
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(right: 70),
                        child: prompt,
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.only(right: 68),
                        child: action,
                      ),
                    ],
                  ),
                ),
                Positioned(bottom: -20, right: -15, child: sprite(132)),
              ],
            ),
            IllustrationStyle.postcard => paper(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              eyebrow,
                              const SizedBox(height: 13),
                              date,
                            ],
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: 0.09,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: art.secondary.withValues(alpha: 0.35),
                            ),
                            color: art.secondary.withValues(alpha: 0.05),
                          ),
                          child: sprite(86),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  title,
                  const SizedBox(height: 16),
                  prompt,
                  const SizedBox(height: 22),
                  action,
                ],
              ),
            ),
            IllustrationStyle.arcade => paper(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow,
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: words()),
                      const SizedBox(width: 8),
                      sprite(110),
                    ],
                  ),
                  const SizedBox(height: 18),
                  prompt,
                  const SizedBox(height: 20),
                  action,
                ],
              ),
            ),
            IllustrationStyle.vintage => paper(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  eyebrow,
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: words()),
                      const SizedBox(width: 8),
                      sprite(106),
                    ],
                  ),
                  const SizedBox(height: 18),
                  prompt,
                  const SizedBox(height: 20),
                  action,
                ],
              ),
            ),
          };
        },
      ),
    );
  }
}
