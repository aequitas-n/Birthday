import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_people_search_strip.dart';
import 'package:kin/design/components/navigation/q_diary_top_bar.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
// ignore: always_use_package_imports -- ARCH-03 requires relative imports within a feature
import 'birthday_timeline_page.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'relationship_gallery_page.dart';

/// Two ways of looking at the same people.
enum HomeScreenMode {
  birthdays,
  people,
}

/// Two ways of looking at the same people.
enum _HomeMode {
  birthdays('Birthdays'),
  people('People');

  const _HomeMode(this.label);

  final String label;

  static _HomeMode from(HomeScreenMode mode) => switch (mode) {
    HomeScreenMode.birthdays => _HomeMode.birthdays,
    HomeScreenMode.people => _HomeMode.people,
  };
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({this.initialMode = HomeScreenMode.birthdays, super.key});

  final HomeScreenMode initialMode;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final PageController _pageController;
  late _HomeMode _mode;
  final _peopleSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mode = _HomeMode.from(widget.initialMode);
    _pageController = PageController(initialPage: widget.initialMode.index);
  }

  @override
  void dispose() {
    _peopleSearchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(_HomeMode mode) {
    if (mode == _mode) return;
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
            _Masthead(
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
            SizedBox(height: q.space.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              child: _ModeSwitch(current: _mode, onSelected: _goTo),
            ),
            if (_mode == _HomeMode.people) ...[
              SizedBox(height: q.space.xs),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.gutter),
                child: QPeopleSearchStrip(
                  controller: _peopleSearchController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(height: q.space.md),
            ],
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) =>
                    setState(() => _mode = _HomeMode.values[page]),
                children: [
                  const _HomePane(child: BirthdayTimelinePage()),
                  _HomePane(
                    compact: true,
                    child: RelationshipGalleryPage(
                      query: _peopleSearchController.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One pane of the home pager.
///
/// Birthdays owns its own [ListView]. People is a fixed viewport (carousel).
class _HomePane extends StatelessWidget {
  const _HomePane({required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.gutter,
        q.space.sm,
        context.gutter,
        compact ? 0 : q.space.sm,
      ),
      child: child,
    );
  }
}

/// Compact Kin chrome — title always Kin; subtitle is a tab-contextual quote.
class _Masthead extends StatelessWidget {
  const _Masthead({
    required this.mode,
    required this.onSettings,
    required this.onAdd,
  });

  final _HomeMode mode;
  final VoidCallback onSettings;
  final VoidCallback onAdd;

  static const _birthdaysQuote = 'The days worth remembering.';
  static const _peopleQuote = 'The people worth remembering.';

  @override
  Widget build(BuildContext context) {
    return QDiaryTopBar(
      title: 'Kin',
      subtitle: mode == _HomeMode.people ? _peopleQuote : _birthdaysQuote,
      actions: [
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
                          ? q.inked(q.text.buttonLabel)
                          : q.inked(q.text.label, tone: QuietInkTone.secondary),
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
