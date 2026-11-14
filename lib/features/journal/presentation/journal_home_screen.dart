import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_ambient_scene.dart';
import 'package:kin/design/components/navigation/q_diary_top_bar.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_month_calendar.dart';

/// Journal root — month view answering "how did my month feel?"
class JournalHomeScreen extends ConsumerStatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  ConsumerState<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends ConsumerState<JournalHomeScreen> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final today = ref.read(journalTodayProvider);
    _year = today.year;
    _month = today.month;
  }

  void _goToMonth(int year, int month) {
    setState(() {
      _year = year;
      _month = month;
    });
  }

  void _goToToday() {
    final today = ref.read(journalTodayProvider);
    setState(() {
      _year = today.year;
      _month = today.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final today = ref.watch(journalTodayProvider);
    final markersAsync = ref.watch(
      journalMonthMarkersProvider((_year, _month)),
    );
    final markers = markersAsync.asData?.value ?? const [];
    final isCurrentMonth = _year == today.year && _month == today.month;

    final writtenDays = markers.where((m) => m.hasEntries).length;
    final moodDays = markers.where((m) => m.dayMood != null).length;
    final daysInMonth = DateTime(_year, _month + 1, 0).day;

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QDiaryTopBar(
              title: 'Journal',
              actions: [
                QIconButton(
                  glyph: QuietGlyph.bell,
                  onPressed: () => context.push(AppRoute.reminders.path),
                  semanticLabel: 'Reminders',
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  q.space.lg,
                  context.gutter,
                  q.space.xl,
                ),
                children: [
                  Row(
                    children: [
                      QIconButton(
                        glyph: QuietGlyph.chevronLeft,
                        onPressed: () {
                          if (_month == 1) {
                            _goToMonth(_year - 1, 12);
                          } else {
                            _goToMonth(_year, _month - 1);
                          }
                        },
                        semanticLabel: 'Previous month',
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _monthTitle(_year, _month),
                              textAlign: TextAlign.center,
                              textScaler: context.nameTextScaler,
                              style: q.text.sectionTitle.tinted(
                                q.color.textPrimary,
                              ),
                            ),
                            SizedBox(height: q.space.xs),
                            Text(
                              _archiveLine(
                                daysInMonth: daysInMonth,
                                written: writtenDays,
                                moods: moodDays,
                              ),
                              textAlign: TextAlign.center,
                              style: q.inked(
                                q.text.uiMetadata,
                                tone: QuietInkTone.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      QIconButton(
                        glyph: QuietGlyph.chevronRight,
                        onPressed: () {
                          if (_month == 12) {
                            _goToMonth(_year + 1, 1);
                          } else {
                            _goToMonth(_year, _month + 1);
                          }
                        },
                        semanticLabel: 'Next month',
                      ),
                    ],
                  ),
                  if (!isCurrentMonth) ...[
                    SizedBox(height: q.space.sm),
                    Center(
                      child: QPressable(
                        onTap: _goToToday,
                        semanticLabel: 'Return to today',
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: q.space.md,
                            vertical: q.space.xs,
                          ),
                          child: Text(
                            'Today',
                            style: q.inked(
                              q.text.uiLabel,
                              tone: QuietInkTone.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: q.space.lg),
                  AnimatedSwitcher(
                    duration: QuietMotion.of(context).fade,
                    switchInCurve: QuietMotion.of(context).enter,
                    switchOutCurve: QuietMotion.of(context).exit,
                    child: JournalMonthCalendar(
                      key: ValueKey('$_year-$_month'),
                      year: _year,
                      month: _month,
                      today: today,
                      markers: markers,
                      onDaySelected: (date) {
                        context.pushNamed(
                          AppRoute.journalDay.name,
                          pathParameters: {'date': date.storageKey},
                        );
                      },
                    ),
                  ),
                  if (context.appTheme.art != null) ...[
                    SizedBox(height: q.space.lg),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: QAmbientScene(width: 174),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthTitle(int year, int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[month - 1].toUpperCase()} $year';
  }

  String _archiveLine({
    required int daysInMonth,
    required int written,
    required int moods,
  }) {
    final parts = <String>[
      '$daysInMonth days',
      if (written == 1)
        '1 day written'
      else if (written > 1)
        '$written days written',
      if (moods == 1) '1 mood' else if (moods > 1) '$moods moods',
    ];
    return parts.join(' · ');
  }
}
