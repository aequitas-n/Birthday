import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late final PageController _controller;
  int _page = 0;

  /// Kicker, headline, support. The kicker numbers the thought without a
  /// visible "1 of 3" — the pager already carries that.
  static const _cards = <(String, String, String)>[
    (
      'Kin',
      'Remember the people who matter.',
      'Not just the date. The details.',
    ),
    (
      'Slowly',
      'Small details are worth keeping.',
      'A favourite flower. A film they quote. The coffee they always order.',
    ),
    (
      'Yours',
      'This stays on your phone.',
      'No account, no cloud, no one else reading it.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QScreen(
      child: QMeasure(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            q.space.base,
            context.gutter,
            q.space.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: QButton.tertiary(label: 'Skip', onPressed: _complete),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final (kicker, headline, support) = _cards[index];
                    return _WelcomePanel(
                      kicker: kicker,
                      headline: headline,
                      support: support,
                    );
                  },
                ),
              ),
              SizedBox(height: q.space.base),
              _WelcomePager(currentPage: _page, count: _cards.length),
              SizedBox(height: q.space.xl),
              Row(
                children: [
                  if (_page > 0)
                    QButton.tertiary(
                      label: 'Back',
                      onPressed: () => _controller.previousPage(
                        duration: q.motion.base,
                        curve: q.motion.emphasized,
                      ),
                    ),
                  const Spacer(),
                  if (_page < _cards.length - 1)
                    QButton.primary(
                      label: 'Next',
                      onPressed: () => _controller.nextPage(
                        duration: q.motion.base,
                        curve: q.motion.emphasized,
                      ),
                    )
                  else
                    QButton.primary(label: 'Begin', onPressed: _complete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete() async {
    final repository = ref.read(settingsRepositoryProvider);
    final settings = await repository.readSettings();
    await repository.saveSettings(
      settings.copyWith(onboardingCompletedAt: ref.read(clockProvider).now()),
    );
    if (!mounted) return;
    context.go('/');
  }
}

/// One thought, set on the canvas.
///
/// The copy is not put inside a bordered card. A card says "this is a
/// component"; the first screen of the app should say "this is a voice". The
/// type sits directly on the paper, centered in the frame so it can be read
/// without hunting for the bottom edge.
class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.kicker,
    required this.headline,
    required this.support,
  });

  final String kicker;
  final String headline;
  final String support;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Padding(
      padding: EdgeInsets.only(right: q.space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kicker,
            textScaler: context.structuralTextScaler,
            style: q.text.eyebrow.tinted(q.color.textTertiary),
          ),
          SizedBox(height: q.space.lg),
          QVoice(headline, style: q.text.voiceXl.tinted(q.color.textPrimary)),
          SizedBox(height: q.space.lg),
          Text(support, style: q.text.bodyLg.tinted(q.color.textSecondary)),
        ],
      ),
    );
  }
}

class _WelcomePager extends StatelessWidget {
  const _WelcomePager({required this.currentPage, required this.count});

  final int currentPage;
  final int count;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    // Short marks, left-aligned under the type, rather than three bars spanning
    // the screen: progress is a footnote here, not a headline.
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: q.motion.base,
            curve: q.motion.emphasized,
            height: 3,
            width: i == currentPage ? q.space.xl : q.space.md,
            decoration: ShapeDecoration(
              color: i == currentPage ? q.color.accent : q.color.hairlineStrong,
              shape: const StadiumBorder(),
            ),
          ),
          if (i < count - 1) SizedBox(width: q.space.xs),
        ],
      ],
    );
  }
}
