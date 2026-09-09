@Tags(['golden'])
library;

import 'dart:async';

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/home/application/gallery_memory.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../support/quiet_test_app.dart';

/// Product-surface goldens for Kin → People (V4 hybrid carousel).
void main() {
  setUpAll(loadQuietFonts);

  const clock = _FixedClock();

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

  List<Override> baseOverrides({
    required List<Person> people,
    required List<RelationshipProfile> profiles,
    Map<String, GalleryMemorySummary> memories = const {},
  }) {
    return [
      clockProvider.overrideWithValue(clock),
      peopleStreamProvider.overrideWith((ref) => Stream.value(people)),
      profilesStreamProvider.overrideWith((ref) => Stream.value(profiles)),
      galleryMemorySummariesProvider.overrideWith(
        (ref) => Stream.value(memories),
      ),
      personPhotoProvider.overrideWith((ref, photoId) async => null),
    ];
  }

  final specimens = <String, List<Override>>{
    'empty': baseOverrides(
      people: const [],
      profiles: const [],
    ),
    'one-person': baseOverrides(
      people: [person(id: 'p1', name: 'Ganesh')],
      profiles: [
        profile(
          id: 'pr1',
          personId: 'p1',
          nickname: 'Ganesh',
          relationship: RelationshipKind.brother,
        ),
      ],
    ),
    'multiple-people': baseOverrides(
      people: [
        person(id: 'p1', name: 'Ganesh'),
        person(id: 'p2', name: 'Mom'),
        person(id: 'p3', name: 'Shivani'),
      ],
      profiles: [
        profile(
          id: 'pr1',
          personId: 'p1',
          nickname: 'Ganesh',
          relationship: RelationshipKind.brother,
        ),
        profile(
          id: 'pr2',
          personId: 'p2',
          nickname: 'Mom',
          relationship: RelationshipKind.mother,
        ),
        profile(
          id: 'pr3',
          personId: 'p3',
          nickname: 'Shivani',
          relationship: RelationshipKind.friend,
        ),
      ],
    ),
    'with-memories': baseOverrides(
      people: [person(id: 'p1', name: 'Ganesh')],
      profiles: [
        profile(
          id: 'pr1',
          personId: 'p1',
          nickname: 'Ganesh',
          relationship: RelationshipKind.brother,
        ),
      ],
      memories: {
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
          Note(
            id: 'n2',
            profileId: 'pr1',
            kind: NoteKind.flower,
            value: 'Peonies',
            position: 1,
            createdAt: DateTime.utc(2026, 1, 2),
            updatedAt: DateTime.utc(2026, 1, 2),
          ),
        ]),
      },
    ),
  };

  Future<void> pumpPeople(
    WidgetTester tester, {
    required QuietTheme theme,
    required List<Override> overrides,
  }) async {
    const size = Size(390, 844);
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

    // Single root [ProviderScope] — nested scopes under [QuietTestApp] do not
    // reliably feed StreamProvider overrides into the gallery.
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildMaterialShim(theme),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: ColoredBox(
                color: theme.color.canvas,
                child: DefaultTextStyle(
                  style: theme.text.body.tinted(theme.color.textPrimary),
                  child: const HomeScreen(initialMode: HomeScreenMode.people),
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

  for (final themeEntry in quietThemes.entries) {
    for (final specimen in specimens.entries) {
      testWidgets(
        'people-${specimen.key}-${themeEntry.key}',
        (tester) async {
          await pumpPeople(
            tester,
            theme: themeEntry.value,
            overrides: specimen.value,
          );

          if (specimen.key != 'empty') {
            expect(find.text('Search people'), findsOneWidget);
          }

          await expectLater(
            find.byType(HomeScreen),
            matchesGoldenFile(
              'goldens/people-${specimen.key}-${themeEntry.key}.png',
            ),
          );
        },
      );
    }
  }
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 7, 28, 12);
}
