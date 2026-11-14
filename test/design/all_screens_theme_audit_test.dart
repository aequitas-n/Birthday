import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/place_picker_sheet.dart';
import 'package:kin/app/profile_creation_launcher.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/journal/q_animated_illustration.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/app_theme_definition.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/local_clock_time.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/personal_reminder.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/models/reminder_day_part.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/domain/repositories/journal_repository.dart';
import 'package:kin/domain/repositories/profile_repository.dart';
import 'package:kin/features/gallery/presentation/gallery_screen.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/audio/journal_audio_flow.dart';
import 'package:kin/features/journal/presentation/journal_day_screen.dart';
import 'package:kin/features/journal/presentation/journal_entry_screen.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/journal/presentation/journal_memory_editor.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/person/presentation/person_screen.dart';
import 'package:kin/features/person/presentation/photo_memory_flow.dart';
import 'package:kin/features/person/presentation/profile_sheet.dart';
import 'package:kin/features/person_editor/presentation/add_person_sheet.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/reminders/presentation/reminder_composer_sheet.dart';
import 'package:kin/features/reminders/presentation/reminder_planner_screen.dart';
import 'package:kin/features/settings/presentation/notification_debug_screen.dart';
import 'package:kin/features/settings/presentation/settings_screen.dart';
import 'package:kin/features/today/presentation/today_screen.dart';
import 'package:kin/features/welcome/presentation/welcome_screen.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../support/quiet_test_app.dart';

const _export = bool.fromEnvironment('EXPORT_THEME_AUDIT');
const _date = LocalCalendarDate(year: 2026, month: 11, day: 14);
final _now = DateTime.utc(2026, 11, 14, 8);
final _person = Person(
  id: 'priya',
  displayName: 'Priya Raman',
  birthday: const PartialDate(month: 11, day: 16, year: 1997),
  sortKey: 'priya',
  createdAt: _now,
  updatedAt: _now,
);
final _profile = RelationshipProfile(
  id: 'profile',
  personId: 'priya',
  nickname: 'Priya',
  relationship: RelationshipKind.friend,
  createdAt: _now,
  updatedAt: _now,
);
final List<Note> _notes = [
  for (final (index, kind, value) in [
    (0, NoteKind.flower, 'Peonies'),
    (1, NoteKind.giftIdea, 'A handwritten letter'),
    (2, NoteKind.plan, 'A slow Sunday by the sea'),
    (3, NoteKind.photo, 'review-photo'),
  ])
    Note(
      id: 'note-$index',
      profileId: 'profile',
      kind: kind,
      value: value,
      label: kind == NoteKind.photo ? 'An afternoon to keep.' : null,
      position: index,
      createdAt: _now,
      updatedAt: _now,
    ),
];
final _entry = JournalEntry(
  id: 'entry',
  localDate: _date,
  title: 'The little things',
  body: 'Tea in the garden, a long conversation, and nowhere to hurry.',
  mood: JournalMood.joyful,
  position: 0,
  createdAt: _now,
  updatedAt: _now,
);
final _fragments = [
  JournalFragment(
    id: 'writing',
    entryId: 'entry',
    kind: JournalFragmentKind.writing,
    position: 0,
    textBody: _entry.body,
    createdAt: _now,
    updatedAt: _now,
  ),
  JournalFragment(
    id: 'list',
    entryId: 'entry',
    kind: JournalFragmentKind.list,
    position: 1,
    textBody: '["A cup of tea","A good conversation"]',
    createdAt: _now,
    updatedAt: _now,
  ),
];
final _reminder = PersonalReminder(
  id: 'reminder',
  localDate: _date,
  localTime: const LocalClockTime(hour: 18, minute: 30),
  dayPart: ReminderDayPart.evening,
  text: 'Write Priya a birthday letter',
  timezone: 'UTC',
  position: 0,
  createdAt: _now,
  updatedAt: _now,
);
const _status = NotificationRuntimeStatus(
  notificationsEnabled: false,
  notificationPermission: AndroidCapabilityState.granted,
  exactAlarmPermission: AndroidCapabilityState.granted,
  deviceTimeZone: 'UTC',
  pendingCount: 0,
  plannedCount: 0,
  lastReconciledAt: null,
);

class _Clock extends Clock {
  const _Clock();
  @override
  DateTime now() => _now;
}

class _Profiles implements ProfileRepository {
  @override
  Future<RelationshipProfile?> readForPerson(String personId) async => null;
  @override
  Stream<List<RelationshipProfile>> watchAll() => Stream.value([]);
  @override
  Stream<RelationshipProfile?> watchForPerson(String personId) =>
      Stream.value(null);
  @override
  Future<RelationshipProfile> save(RelationshipProfile profile) async =>
      profile;
  @override
  Future<void> softDelete(String id) async {}
}

/// Real feature widgets with deterministic populated data; no screenshots of
/// substitute layouts. The same fixtures are used for Vintage and every theme.
class _AuditHost extends StatelessWidget {
  const _AuditHost({
    required this.theme,
    required this.page,
    required this.boundary,
    this.scale = 1,
    this.empty = false,
    this.keyboard = 0,
    super.key,
  });
  final AppThemeDefinition theme;
  final Widget page;
  final GlobalKey boundary;
  final double scale;
  final bool empty;
  final double keyboard;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings(productThemeId: theme.id);
    return ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(const _Clock()),
        profileRepositoryProvider.overrideWithValue(_Profiles()),
        initialAppSettingsProvider.overrideWithValue(settings),
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        notificationStatusProvider.overrideWith((ref) async => _status),
        notificationDebugSnapshotProvider.overrideWith(
          (ref) async => const NotificationDebugSnapshot(
            status: _status,
            pending: [],
            scheduled: [],
            desiredPlans: [],
            people: [],
          ),
        ),
        peopleStreamProvider.overrideWith(
          (ref) => Stream.value(empty ? [] : [_person]),
        ),
        profilesStreamProvider.overrideWith(
          (ref) => Stream.value(empty ? [] : [_profile]),
        ),
        galleryMemorySummariesProvider.overrideWith((ref) => Stream.value({})),
        personStreamProvider.overrideWith((ref, id) => Stream.value(_person)),
        personProfileProvider.overrideWith(
          (ref, id) => Stream.value(empty ? null : _profile),
        ),
        personNotesProvider.overrideWith(
          (ref, id) => Stream.value(empty ? [] : _notes),
        ),
        personPhotoProvider.overrideWith((ref, id) async => null),
        journalTodayProvider.overrideWithValue(_date),
        journalEntriesProvider.overrideWith(
          (ref, date) => Stream.value(empty ? [] : [_entry]),
        ),
        journalDayProvider.overrideWith(
          (ref, date) => Stream.value(
            JournalDay(
              localDate: _date,
              mood: _entry.mood,
              createdAt: _now,
              updatedAt: _now,
            ),
          ),
        ),
        journalEntryProvider.overrideWith((ref, id) => Stream.value(_entry)),
        journalEntryFragmentsProvider.overrideWith(
          (ref, id) => Stream.value(_fragments),
        ),
        journalEntryPhotosProvider.overrideWith((ref, id) => Stream.value([])),
        journalMonthMarkersProvider.overrideWith(
          (ref, key) => Stream.value(
            empty
                ? []
                : [
                    JournalDayMarker(
                      localDate: _date,
                      hasEntries: true,
                      entryCount: 1,
                      dayMood: _entry.mood,
                    ),
                  ],
          ),
        ),
        reminderTodayProvider.overrideWithValue(_date),
        remindersForDateProvider.overrideWith(
          (ref, key) => Stream.value(empty ? [] : [_reminder]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildMaterialShim(theme.quiet, appTheme: theme),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: RepaintBoundary(key: boundary, child: child),
        ),
        home: page,
      ),
    );
  }
}

Widget _tab(Widget page, PrimaryDestination destination) => QThemeCanvas(
  child: QuietShellBackdropScope(
    child: Column(
      children: [
        Expanded(child: page),
        QPrimaryNav(selected: destination, onSelected: (_) {}),
      ],
    ),
  ),
);
Widget _sheet(Widget page) => QScreen(
  child: Align(alignment: Alignment.bottomCenter, child: page),
);

Future<void> _capture(WidgetTester tester, GlobalKey key, String path) async {
  if (!_export) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(loadQuietFonts);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  for (final theme in ProductThemes.all.where((t) => t.art != null)) {
    for (final compact in [false, true]) {
      testWidgets(
        '${theme.label}: all screens ${compact ? "320px large text" : "390px"}',
        (tester) async {
          tester.view.physicalSize = compact
              ? const Size(320, 640)
              : const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
                const MethodChannel('com.llfbandit.record/messages'),
                (_) async => null,
              );
          addTearDown(
            () => TestDefaultBinaryMessengerBinding
                .instance
                .defaultBinaryMessenger
                .setMockMethodCallHandler(
                  const MethodChannel('com.llfbandit.record/messages'),
                  null,
                ),
          );
          Future<void> saveCurrent(String name) async {
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${theme.label}: $name',
            );
            if (!compact) {
              final key = tester
                  .widget<_AuditHost>(find.byType(_AuditHost))
                  .boundary;
              await _capture(
                tester,
                key,
                'artwork/screens/${theme.art!.folder}/$name.png',
              );
            }
          }

          Future<void> review(
            String name,
            Widget page, {
            bool empty = false,
            double keyboard = 0,
          }) async {
            final key = GlobalKey();
            await tester.pumpWidget(
              _AuditHost(
                key: UniqueKey(),
                theme: theme,
                page: page,
                boundary: key,
                scale: compact ? 1.6 : 1,
                empty: empty,
                keyboard: keyboard,
              ),
            );
            await tester.pumpAndSettle();
            await tester.pumpQuietImages(const Duration(milliseconds: 60));
            expect(
              tester.takeException(),
              isNull,
              reason: '${theme.label}: $name',
            );
            expect(find.byType(QThemeCanvas), findsWidgets, reason: name);
            for (final painter in tester.widgetList<CustomPaint>(
              find.byType(CustomPaint),
            )) {
              if (painter.painter
                  case final IllustratedSurfacePainter surface) {
                expect(
                  surface.art,
                  theme.art,
                  reason: '$name leaked a different surface',
                );
              }
            }
            for (final art in tester.widgetList<QAnimatedIllustration>(
              find.byType(QAnimatedIllustration),
            )) {
              expect(
                art.asset,
                startsWith('assets/themes/Illustrated/${theme.art!.folder}/'),
                reason: name,
              );
            }
            expect(
              collectAssetImagePaths(tester).where(
                (p) => p.contains('Vintage-Diary') || p.contains('Neon-Arcade'),
              ),
              isEmpty,
              reason: name,
            );
            if (!compact) {
              await _capture(
                tester,
                key,
                'artwork/screens/${theme.art!.folder}/$name.png',
              );
            }
            if (const {
              'person',
              'person-empty',
              'settings',
              'profile-sheet',
              'design-gallery',
              'memory-editor',
              'reminders',
              'journal',
              'place-picker',
            }.contains(name)) {
              var moved = false;
              for (var pass = 0; pass < 3; pass++) {
                final scrollables = tester
                    .stateList<ScrollableState>(find.byType(Scrollable))
                    .toList();
                for (final scroll in scrollables) {
                  final position = scroll.position;
                  if (position.hasContentDimensions &&
                      axisDirectionToAxis(position.axisDirection) ==
                          Axis.vertical &&
                      position.maxScrollExtent > 0) {
                    position.jumpTo(position.maxScrollExtent);
                    moved = true;
                  }
                }
                await tester.pumpAndSettle();
              }
              expect(
                tester.takeException(),
                isNull,
                reason: '${theme.label}: $name lower sections',
              );
              if (moved) {
                await saveCurrent('$name-more');
                for (final scroll
                    in tester
                        .stateList<ScrollableState>(find.byType(Scrollable))
                        .toList()) {
                  if (scroll.position.hasContentDimensions &&
                      axisDirectionToAxis(scroll.position.axisDirection) ==
                          Axis.vertical) {
                    scroll.position.jumpTo(0);
                  }
                }
                await tester.pumpAndSettle();
              }
            }
          }

          await review(
            'today',
            _tab(const TodayScreen(), PrimaryDestination.today),
          );
          await review(
            'today-empty',
            _tab(const TodayScreen(), PrimaryDestination.today),
            empty: true,
          );
          await review(
            'birthdays',
            _tab(const HomeScreen(), PrimaryDestination.kin),
          );
          await review(
            'people',
            _tab(
              const HomeScreen(initialMode: HomeScreenMode.people),
              PrimaryDestination.kin,
            ),
          );
          await review(
            'people-empty',
            _tab(
              const HomeScreen(initialMode: HomeScreenMode.people),
              PrimaryDestination.kin,
            ),
            empty: true,
          );
          await review(
            'journal',
            _tab(const JournalHomeScreen(), PrimaryDestination.journal),
          );
          await review(
            'journal-day',
            const JournalDayScreen(dateKey: '2026-11-14'),
          );
          await tester.ensureVisible(find.text('Change day mood'));
          await tester.tap(find.text('Change day mood'));
          await saveCurrent('day-mood');
          await review(
            'journal-day-empty',
            const JournalDayScreen(dateKey: '2026-11-14'),
            empty: true,
          );
          await review(
            'memory',
            const JournalEntryScreen(dateKey: '2026-11-14', entryId: 'entry'),
          );
          await review(
            'memory-editor',
            JournalMemoryEditor(
              date: _date,
              position: 0,
              existing: _entry,
              existingFragments: _fragments,
            ),
          );
          await tester.ensureVisible(find.text('Joyful'));
          await tester.tap(find.text('Joyful'));
          await saveCurrent('memory-mood');
          await review(
            'memory-editor-empty',
            const JournalMemoryEditor(date: _date, position: 0),
          );
          await tester.tap(
            find.bySemanticsLabel('Add something to remember').last,
          );
          await saveCurrent('fragment-chooser');
          await review('person', const PersonScreen(personId: 'priya'));
          await review(
            'person-empty',
            const PersonScreen(personId: 'priya'),
            empty: true,
          );
          await review('reminders', const ReminderPlannerScreen());
          await review(
            'reminders-empty',
            const ReminderPlannerScreen(),
            empty: true,
          );
          await review('settings', const SettingsScreen());
          await review(
            'notification-inspector',
            const NotificationDebugScreen(),
          );
          await review('design-gallery', const GalleryScreen());
          await review('welcome', const WelcomeScreen());
          for (final page in [2, 3]) {
            await tester.tap(find.text('Next'));
            await saveCurrent('welcome-$page');
          }
          await review('birthday-sheet', _sheet(const AddPersonSheet()));
          await tester.ensureVisible(find.bySemanticsLabel('Choose month'));
          await tester.tap(find.bySemanticsLabel('Choose month'));
          await saveCurrent('month-picker');
          await review('profile-new', _sheet(ProfileSheet(person: _person)));
          await review(
            'profile-sheet',
            _sheet(ProfileSheet(person: _person, profile: _profile)),
          );
          await review(
            'reminder-sheet',
            _sheet(
              ReminderComposerSheet(
                date: _date,
                dayPart: ReminderDayPart.evening,
                existing: _reminder,
              ),
            ),
          );
          await review('place-picker', _sheet(const PlacePickerSheet()));
          // Open actual routed sheets to verify they inherit the product identity
          // outside the screen tree (including keyboard and pinned actions).
          for (final kind in [
            'note-editor',
            'gift-editor',
            'custom-editor',
            'date-note-editor',
            'choices',
            'moments',
            'photo-review',
            'audio-recorder',
            'profile-start',
            'link-birthday',
          ]) {
            await review(
              kind,
              Consumer(
                builder: (context, ref, _) => QScreen(
                  child: Center(
                    child: QButton.primary(
                      label: 'Open review',
                      onPressed: () {
                        switch (kind) {
                          case 'gift-editor':
                            showNoteEditorSheet(
                              context: context,
                              profileId: 'profile',
                              position: 0,
                              note: _notes[1],
                            );
                          case 'custom-editor':
                            showNoteEditorSheet(
                              context: context,
                              profileId: 'profile',
                              position: 0,
                              initialKind: NoteKind.custom,
                            );
                          case 'date-note-editor':
                            showNoteEditorSheet(
                              context: context,
                              profileId: 'profile',
                              position: 0,
                              initialKind: NoteKind.importantDate,
                            );
                          case 'note-editor':
                            showNoteEditorSheet(
                              context: context,
                              profileId: 'profile',
                              position: 0,
                              note: _notes.first,
                            );
                          case 'choices':
                            showQChoiceSheet(
                              context: context,
                              title: 'Keep this memory?',
                              choices: const [
                                QChoice('Keep it'),
                                QChoice('Delete', destructive: true),
                              ],
                            );
                          case 'profile-start':
                            showProfileCreationChooser(
                              context: context,
                              ref: ref,
                            );
                          case 'link-birthday':
                            showLinkExistingBirthdayPicker(
                              context: context,
                              ref: ref,
                            );
                          case 'photo-review':
                            showPhotoMemoryReview(
                              context: context,
                              photo: AssetImage(theme.art!.background),
                              caption: 'An afternoon to keep.',
                              displayName: 'Priya',
                            );
                          case 'audio-recorder':
                            recordJournalAudioDraft(context);
                          case 'moments':
                            showMomentsGallery(
                              context: context,
                              ref: ref,
                              person: _person,
                              photos: [_notes.last],
                              displayName: 'Priya',
                              profile: _profile,
                            );
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('Open review'));
            await tester.pumpAndSettle();
            await tester.pumpQuietImages(const Duration(milliseconds: 60));
            expect(
              tester.takeException(),
              isNull,
              reason: '${theme.label}: open $kind',
            );
            final context = tester.element(find.byType(QThemeCanvas).last);
            expect(context.appTheme.id, theme.id);
            if (!compact) {
              final boundary = tester
                  .widget<_AuditHost>(find.byType(_AuditHost))
                  .boundary;
              await _capture(
                tester,
                boundary,
                'artwork/screens/${theme.art!.folder}/$kind.png',
              );
            }
          }
          await review(
            'birthday-keyboard',
            _sheet(const AddPersonSheet()),
            keyboard: 280,
          );
          await review(
            'reminder-keyboard',
            _sheet(
              ReminderComposerSheet(
                date: _date,
                dayPart: ReminderDayPart.evening,
                existing: _reminder,
              ),
            ),
            keyboard: 280,
          );
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }
}
