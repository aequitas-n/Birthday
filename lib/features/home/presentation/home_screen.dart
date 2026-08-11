import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/text/q_voice.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'birthday_timeline_page.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'relationship_gallery_page.dart';

/// Two ways of looking at the same people.
enum _HomeMode {
  birthdays('Birthdays'),
  people('People')
  ;

  const _HomeMode(this.label);

  final String label;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  _HomeMode _mode = _HomeMode.birthdays;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(_HomeMode mode) {
    if (mode == _mode) return;
    // Title and tab chrome follow the tap immediately; the pager catches up.
    // Waiting for [onPageChanged] left the masthead a beat behind and felt sticky.
    setState(() => _mode = mode);
    _pageController.animateToPage(
      mode.index,
      duration: context.quiet.motion.base,
      curve: context.quiet.motion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter,
                q.space.base,
                context.gutter,
                0,
              ),
              child: _Masthead(
                mode: _mode,
                onSettings: () => context.push('/settings'),
                onAdd: () {
                  if (_mode == _HomeMode.people) {
                    showProfileCreationChooser(context: context, ref: ref);
                  } else {
                    showAddPersonFlow(context, ref);
                  }
                },
              ),
            ),
            SizedBox(height: q.space.md),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: _ModeSwitch(current: _mode, onSelected: _goTo),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) =>
                    setState(() => _mode = _HomeMode.values[page]),
                children: const [
                  _HomePane(child: BirthdayTimelinePage()),
                  _HomePane(child: RelationshipGalleryPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One scrolling pane of the home pager.
class _HomePane extends StatelessWidget {
  const _HomePane({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            q.space.sm,
            context.gutter,
            q.space.emptiness,
          ),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: child,
          ),
        ),
      ],
    );
  }
}

/// Compact Kin chrome: literary title, then the Birthdays / People place.
///
/// Matches Journal's voice hierarchy — one screen title, not a stacked brand
/// eyebrow competing with the mode name.
class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.mode,
    required this.onSettings,
    required this.onAdd,
  });

  final _HomeMode mode;
  final VoidCallback onSettings;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: QVoice(
                  'Kin',
                  style: q.text.voiceLg.tinted(q.color.textPrimary),
                ),
              ),
              SizedBox(height: q.space.xs),
              // No crossfade: AnimatedSwitcher stacked both labels and flashed
              // "Birthdays" through "People". A plain swap matches the tap.
              Text(
                mode.label,
                textScaler: context.structuralTextScaler,
                style: q.text.archiveMeta.tinted(q.color.textSecondary),
              ),
            ],
          ),
        ),
        QIconButton(
          glyph: QuietGlyph.plus,
          onPressed: onAdd,
          semanticLabel: 'Add someone',
        ),
        QIconButton(
          glyph: QuietGlyph.settings,
          onPressed: onSettings,
          semanticLabel: 'Settings',
        ),
      ],
    );
  }
}

/// Two labels and a rule that slides between them.
///
/// Not a segmented control: a segmented control is a setting, and this is a
/// place. The indicator is a hairline under the active word, which is the
/// lightest possible way to say "you are here".
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.current, required this.onSelected});

  final _HomeMode current;
  final ValueChanged<_HomeMode> onSelected;

  static const double _ruleHeight = 2;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Row(
      children: [
        for (final mode in _HomeMode.values) ...[
          QPressable(
            onTap: () => onSelected(mode),
            radius: q.radius.xs,
            semanticLabel: mode.label,
            selected: mode == current,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: q.space.xs),
                    child: Text(
                      mode.label,
                      textScaler: context.structuralTextScaler,
                      style: mode == current
                          ? q.text.buttonLabel.tinted(q.color.textPrimary)
                          : q.text.label.tinted(q.color.textTertiary),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: q.motion.base,
                    curve: q.motion.standard,
                    opacity: mode == current ? 1 : 0,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: q.color.accent,
                        shape: const StadiumBorder(),
                      ),
                      child: const SizedBox(height: _ruleHeight),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: q.space.xl),
        ],
      ],
    );
  }
}
