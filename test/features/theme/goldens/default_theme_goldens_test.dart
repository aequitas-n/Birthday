@Tags(['golden'])
library;

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/domain/models/settings.dart';
import 'package:kin/features/home/application/gallery_memory.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/presentation/journal_day_screen.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/settings/presentation/settings_screen.dart';
import 'package:kin/features/today/application/today_providers.dart';
import 'package:kin/features/today/presentation/today_screen.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../../support/quiet_test_app.dart';

/// Dedicated Default product-theme visual baseline.
///
/// These goldens must never reuse Vintage Quiet contrast variants as proof of
/// Default — they always pump [ProductThemes.quietDefault].
void main() {
  setUpAll(() {
    loadQuietFonts();
    tzdata.initializeTimeZones();
  });

  const today = LocalCalendarDate(year: 2026, month: 8, day: 11);
  const clock = _FixedClock();
  const settings = AppSettings();
  final defaultTheme = ProductThemes.quietDefault;

  Person person({
    required String id,
    required String name,
    int month = 7,
    int day = 28,
  }) {
    return Person(
      id: id,
      displayName: name,
      birthday: PartialDate(month: month, day: day, year: 1990),
      sortKey: name.toLowerCase(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  RelationshipProfile profile({
    required String id,
    required String personId,
    String? nickname,
    RelationshipKind relationship = RelationshipKind.family,
  }) {
    return RelationshipProfile(
      id: id,
      personId: personId,
      nickname: nickname,
      relationship: relationship,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  Future<void> pumpDefault(
    WidgetTester tester, {
    required Widget child,
    List<Override> overrides = const [],
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(
            defaultTheme.quiet,
            appTheme: defaultTheme,
          ),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: ColoredBox(
                color: defaultTheme.quiet.color.canvas,
                child: DefaultTextStyle(
                  style: defaultTheme.quiet.text.body.tinted(
                    defaultTheme.quiet.color.textPrimary,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('default-today-empty', (tester) async {
    await pumpDefault(
      tester,
      overrides: [
        clockProvider.overrideWithValue(clock),
        journalTodayProvider.overrideWithValue(today),
        reminderTodayProvider.overrideWithValue(today),
        initialAppSettingsProvider.overrideWithValue(settings),
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        journalEntriesProvider.overrideWith(
          (ref, key) => Stream.value(const []),
        ),
        remindersForDateProvider.overrideWith(
          (ref, key) => Stream.value(const []),
        ),
        todayActiveRemindersProvider.overrideWith((ref) => const []),
        todayUpcomingProvider.overrideWithValue(const []),
        todayBirthdayProvider.overrideWithValue(const []),
        peopleStreamProvider.overrideWith((ref) => Stream.value(const [])),
        profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: const TodayScreen(),
    );

    final paths = collectAssetImagePaths(tester);
    expect(hasVintageDiaryAsset(paths), isFalse);

    await expectLater(
      find.byType(TodayScreen),
      matchesGoldenFile('goldens/default-today-empty.png'),
    );
  });

  testWidgets('default-today-populated', (tester) async {
    final entries = [
      JournalEntry(
        id: 'e1',
        localDate: today,
        title: 'The rain came just before dinner',
        body: 'Walked home without an umbrella.',
        position: 0,
        createdAt: DateTime.utc(2026, 8, 11),
        updatedAt: DateTime.utc(2026, 8, 11),
      ),
    ];
    final people = [
      person(id: 'p1', name: 'Kavin', month: 8, day: 20),
      person(id: 'p2', name: 'Shivani', month: 9, day: 1),
    ];
    final upcoming = [
      HomeEntry(
        person: people[0],
        nextBirthday: DateTime(2026, 8, 20),
        daysUntil: 9,
        turningAge: null,
      ),
      HomeEntry(
        person: people[1],
        nextBirthday: DateTime(2026, 9, 1),
        daysUntil: 21,
        turningAge: null,
      ),
    ];

    await pumpDefault(
      tester,
      overrides: [
        clockProvider.overrideWithValue(clock),
        journalTodayProvider.overrideWithValue(today),
        reminderTodayProvider.overrideWithValue(today),
        initialAppSettingsProvider.overrideWithValue(settings),
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        journalEntriesProvider.overrideWith(
          (ref, key) => Stream.value(entries),
        ),
        remindersForDateProvider.overrideWith(
          (ref, key) => Stream.value(const []),
        ),
        todayActiveRemindersProvider.overrideWith((ref) => const []),
        todayUpcomingProvider.overrideWithValue(upcoming),
        todayBirthdayProvider.overrideWithValue(const []),
        peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
        profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
      ],
      child: const TodayScreen(),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(TodayScreen),
      matchesGoldenFile('goldens/default-today-populated.png'),
    );
  });

  testWidgets('default-kin-birthdays', (tester) async {
    final people = [
      person(id: 'p1', name: 'Ganesh'),
      person(id: 'p2', name: 'Mom', month: 3, day: 12),
    ];
    await pumpDefault(
      tester,
      overrides: [
        clockProvider.overrideWithValue(clock),
        peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
        profilesStreamProvider.overrideWith((ref) => Stream.value(const [])),
        galleryMemorySummariesProvider.overrideWith(
          (ref) => Stream.value(const {}),
        ),
        personPhotoProvider.overrideWith((ref, photoId) async => null),
      ],
      child: const HomeScreen(initialMode: HomeScreenMode.birthdays),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/default-kin-birthdays.png'),
    );
  });

  testWidgets('default-people', (tester) async {
    final people = [person(id: 'p1', name: 'Ganesh')];
    final profiles = [
      profile(
        id: 'pr1',
        personId: 'p1',
        nickname: 'Ganesh',
        relationship: RelationshipKind.brother,
      ),
    ];
    await pumpDefault(
      tester,
      overrides: [
        clockProvider.overrideWithValue(clock),
        peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
        profilesStreamProvider.overrideWith((ref) => Stream.value(profiles)),
        galleryMemorySummariesProvider.overrideWith(
          (ref) => Stream.value({
            'pr1': GalleryMemorySummary.fromNotes([
              Note(
                id: 'n1',
                profileId: 'pr1',
                kind: NoteKind.free,
                value: 'That late-night drive',
                position: 0,
                createdAt: DateTime.utc(2026),
                updatedAt: DateTime.utc(2026, 1, 5),
              ),
            ]),
          }),
        ),
        personPhotoProvider.overrideWith((ref, photoId) async => null),
      ],
      child: const HomeScreen(initialMode: HomeScreenMode.people),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/default-people.png'),
    );
  });

  testWidgets('default-journal-home', (tester) async {
    await pumpDefault(
      tester,
      overrides: [
        journalTodayProvider.overrideWithValue(
          const LocalCalendarDate(year: 2026, month: 10, day: 15),
        ),
        journalMonthMarkersProvider.overrideWith(
          (ref, key) => Stream.value(const []),
        ),
      ],
      child: const JournalHomeScreen(),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(JournalHomeScreen),
      matchesGoldenFile('goldens/default-journal-home.png'),
    );
  });

  testWidgets('default-journal-day', (tester) async {
    final day = today;
    await pumpDefault(
      tester,
      overrides: [
        clockProvider.overrideWithValue(clock),
        journalTodayProvider.overrideWithValue(day),
        journalDayProvider.overrideWith(
          (ref, key) => Stream.value(null),
        ),
        journalEntriesProvider.overrideWith(
          (ref, key) => Stream.value([
            JournalEntry(
              id: 'e1',
              localDate: day,
              title: 'Quiet streets after midnight',
              body: 'Still thinking about the conversation.',
              position: 0,
              createdAt: DateTime.utc(2026, 8, 11),
              updatedAt: DateTime.utc(2026, 8, 11),
            ),
          ]),
        ),
      ],
      child: const QScreen(
        child: JournalDayScreen(dateKey: '2026-08-11'),
      ),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(JournalDayScreen),
      matchesGoldenFile('goldens/default-journal-day.png'),
    );
  });

  testWidgets('default-settings', (tester) async {
    await pumpDefault(
      tester,
      overrides: [
        initialAppSettingsProvider.overrideWithValue(settings),
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        notificationStatusProvider.overrideWith(
          (ref) async => const NotificationRuntimeStatus(
            notificationsEnabled: false,
            notificationPermission: AndroidCapabilityState.granted,
            exactAlarmPermission: AndroidCapabilityState.granted,
            deviceTimeZone: 'Asia/Kolkata',
            pendingCount: 0,
            plannedCount: 0,
            lastReconciledAt: null,
          ),
        ),
      ],
      child: const SettingsScreen(),
    );

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Default'), findsWidgets);
    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/default-settings.png'),
    );
  });

  testWidgets('default-bottom-navigation', (tester) async {
    await pumpDefault(
      tester,
      child: QScreen(
        bottom: QPrimaryNav(
          selected: PrimaryDestination.today,
          onSelected: (_) {},
        ),
        child: const SizedBox.expand(),
      ),
    );

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(QScreen),
      matchesGoldenFile('goldens/default-bottom-navigation.png'),
    );
  });

  testWidgets('default-choice-sheet', (tester) async {
    await pumpDefault(
      tester,
      child: Builder(
        builder: (context) {
          return QScreen(
            child: Center(
              child: QButton(
                label: 'Open',
                onPressed: () {
                  showQChoiceSheet(
                    context: context,
                    title: 'Theme',
                    selectedIndex: 0,
                    choices: const [
                      QChoice('Default', support: 'Warm paper, black ink.'),
                      QChoice(
                        'Vintage Diary',
                        support: 'Aged parchment on a dark desk.',
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(hasVintageDiaryAsset(collectAssetImagePaths(tester)), isFalse);
    await expectLater(
      find.byType(QScreen).last,
      matchesGoldenFile('goldens/default-choice-sheet.png'),
    );
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime(2026, 8, 11, 10);
}
