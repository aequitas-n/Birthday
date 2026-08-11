import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/local/database/kin_database.dart';
import 'package:kin/data/repositories/journal_repository_drift.dart';
import 'package:kin/domain/models/journal_day.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_entry_photo.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';

void main() {
  group('DriftJournalRepository', () {
    late KinDatabase database;
    late DriftJournalRepository repository;

    setUp(() {
      database = KinDatabase(NativeDatabase.memory());
      repository = DriftJournalRepository(
        database,
        _FixedIdGenerator(),
        const _FixedClock(),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('creates a journal day with mood', () async {
      const date = LocalCalendarDate(year: 2026, month: 10, day: 15);
      final saved = await repository.upsertDay(
        JournalDay(
          localDate: date,
          mood: JournalMood.reflective,
          createdAt: DateTime.utc(2026, 10, 15),
          updatedAt: DateTime.utc(2026, 10, 15),
        ),
      );

      final watched = await repository.watchDay(date).first;
      expect(saved.localDate, date);
      expect(watched?.mood, JournalMood.reflective);
    });

    test('creates multiple entries on the same day with ordering', () async {
      const date = LocalCalendarDate(year: 2026, month: 3, day: 4);
      await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'Walked through the rain',
          body: 'Unexpected and quiet.',
          position: 0,
          createdAt: DateTime.utc(2026, 3, 4),
          updatedAt: DateTime.utc(2026, 3, 4),
        ),
      );
      await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'Had coffee',
          body: 'With an old friend.',
          mood: JournalMood.calm,
          position: 1,
          createdAt: DateTime.utc(2026, 3, 4, 14),
          updatedAt: DateTime.utc(2026, 3, 4, 14),
        ),
      );

      final entries = await repository.watchEntriesForDay(date).first;
      expect(entries, hasLength(2));
      expect(entries[0].title, 'Walked through the rain');
      expect(entries[1].title, 'Had coffee');
      expect(entries[1].mood, JournalMood.calm);
    });

    test('persists journal entry photo relation', () async {
      const date = LocalCalendarDate(year: 2026, month: 5, day: 1);
      await database
          .into(database.photos)
          .insert(
            PhotosCompanion.insert(
              id: 'photo-journal-1',
              relPath: 'journal/test.jpg',
              width: 100,
              height: 100,
              bytes: 1000,
              createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
            ),
          );

      final entry = await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'Found an old letter',
          body: 'In the desk drawer.',
          position: 0,
          createdAt: DateTime.utc(2026, 5),
          updatedAt: DateTime.utc(2026, 5),
        ),
      );

      await repository.saveEntryPhoto(
        JournalEntryPhoto(
          id: '',
          entryId: entry.id,
          photoId: 'photo-journal-1',
          caption: 'The envelope',
          position: 0,
          createdAt: DateTime.utc(2026, 5),
          updatedAt: DateTime.utc(2026, 5),
        ),
      );

      final photos = await repository.watchPhotosForEntry(entry.id).first;
      expect(photos, hasLength(1));
      expect(photos.first.photoId, 'photo-journal-1');
      expect(photos.first.caption, 'The envelope');
    });

    test('month markers reflect entries and day mood', () async {
      const date = LocalCalendarDate(year: 2026, month: 8, day: 11);
      await repository.upsertDay(
        JournalDay(
          localDate: date,
          mood: JournalMood.grateful,
          createdAt: DateTime.utc(2026, 8, 11),
          updatedAt: DateTime.utc(2026, 8, 11),
        ),
      );
      await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'Unexpected news',
          body: 'Good news.',
          position: 0,
          createdAt: DateTime.utc(2026, 8, 11),
          updatedAt: DateTime.utc(2026, 8, 11),
        ),
      );

      final markers = await repository
          .watchMonthMarkers(year: 2026, month: 8)
          .first;
      final marker = markers.singleWhere(
        (m) => m.localDate == date,
      );
      expect(marker.entryCount, 1);
      expect(marker.dayMood, JournalMood.grateful);
    });

    test(
      'saveMemory persists ordered fragments and denormalized body',
      () async {
        const date = LocalCalendarDate(year: 2026, month: 9, day: 12);
        final now = DateTime.utc(2026, 9, 12);
        await database
            .into(database.photos)
            .insert(
              PhotosCompanion.insert(
                id: 'photo-frag-1',
                relPath: 'journal/frag.jpg',
                width: 100,
                height: 100,
                bytes: 1000,
                createdAt: now.millisecondsSinceEpoch,
              ),
            );

        final saved = await repository.saveMemory(
          entry: JournalEntry(
            id: '',
            localDate: date,
            title: 'A strange evening',
            body: '',
            position: 0,
            createdAt: now,
            updatedAt: now,
          ),
          fragments: [
            JournalFragment(
              id: '',
              entryId: '',
              kind: JournalFragmentKind.writing,
              position: 0,
              textBody: 'I was not planning to go anywhere.',
              createdAt: now,
              updatedAt: now,
            ),
            JournalFragment(
              id: '',
              entryId: '',
              kind: JournalFragmentKind.list,
              position: 1,
              textBody: JournalFragment.encodeListItems(const [
                'Met Kavin',
                'Had dinner',
              ]),
              createdAt: now,
              updatedAt: now,
            ),
            JournalFragment(
              id: '',
              entryId: '',
              kind: JournalFragmentKind.photograph,
              position: 2,
              photoId: 'photo-frag-1',
              caption: 'Outside',
              createdAt: now,
              updatedAt: now,
            ),
          ],
        );

        final fragments = await repository
            .watchFragmentsForEntry(saved.id)
            .first;
        expect(fragments.map((f) => f.kind), [
          JournalFragmentKind.writing,
          JournalFragmentKind.list,
          JournalFragmentKind.photograph,
        ]);
        expect(fragments[1].listItems, ['Met Kavin', 'Had dinner']);
        expect(saved.body, contains('I was not planning'));
        expect(saved.body, contains('• Met Kavin'));

        final trimmed = await repository.saveMemory(
          entry: saved,
          fragments: [fragments.first, fragments.last],
        );
        final after = await repository.watchFragmentsForEntry(trimmed.id).first;
        expect(after, hasLength(2));
        expect(after.map((f) => f.kind), [
          JournalFragmentKind.writing,
          JournalFragmentKind.photograph,
        ]);
      },
    );

    test('soft deletes an entry', () async {
      const date = LocalCalendarDate(year: 2026, month: 6, day: 1);
      final entry = await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'Temporary',
          body: 'Will be removed.',
          position: 0,
          createdAt: DateTime.utc(2026, 6),
          updatedAt: DateTime.utc(2026, 6),
        ),
      );

      await repository.softDeleteEntry(entry.id);
      final entries = await repository.watchEntriesForDay(date).first;
      expect(entries, isEmpty);
      final watched = await repository.watchEntry(entry.id).first;
      expect(watched, isNull);
    });

    test('reorders photos by position on save', () async {
      const date = LocalCalendarDate(year: 2026, month: 7, day: 2);
      final entry = await repository.saveEntry(
        JournalEntry(
          id: '',
          localDate: date,
          title: 'With photos',
          body: '',
          position: 0,
          createdAt: DateTime.utc(2026, 7, 2),
          updatedAt: DateTime.utc(2026, 7, 2),
        ),
      );

      for (final id in ['photo-a', 'photo-b']) {
        await database
            .into(database.photos)
            .insert(
              PhotosCompanion.insert(
                id: id,
                relPath: 'journal/$id.jpg',
                width: 100,
                height: 100,
                bytes: 1000,
                createdAt: DateTime.utc(2026).millisecondsSinceEpoch,
              ),
            );
      }

      final first = await repository.saveEntryPhoto(
        JournalEntryPhoto(
          id: '',
          entryId: entry.id,
          photoId: 'photo-a',
          position: 0,
          createdAt: DateTime.utc(2026, 7, 2),
          updatedAt: DateTime.utc(2026, 7, 2),
        ),
      );
      final second = await repository.saveEntryPhoto(
        JournalEntryPhoto(
          id: '',
          entryId: entry.id,
          photoId: 'photo-b',
          position: 1,
          createdAt: DateTime.utc(2026, 7, 2),
          updatedAt: DateTime.utc(2026, 7, 2),
        ),
      );

      await repository.saveEntryPhoto(
        first.copyWith(position: 1, updatedAt: DateTime.utc(2026, 7, 3)),
      );
      await repository.saveEntryPhoto(
        second.copyWith(position: 0, updatedAt: DateTime.utc(2026, 7, 3)),
      );

      final photos = await repository.watchPhotosForEntry(entry.id).first;
      expect(photos.map((p) => p.photoId), ['photo-b', 'photo-a']);
    });

    test('saveEntry cannot diverge body from live fragments', () async {
      const date = LocalCalendarDate(year: 2026, month: 11, day: 1);
      final now = DateTime.utc(2026, 11);
      final saved = await repository.saveMemory(
        entry: JournalEntry(
          id: '',
          localDate: date,
          title: 'Protected body',
          body: 'ignored',
          position: 0,
          createdAt: now,
          updatedAt: now,
        ),
        fragments: [
          JournalFragment(
            id: '',
            entryId: '',
            kind: JournalFragmentKind.writing,
            position: 0,
            textBody: 'Authoritative writing.',
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final tampered = await repository.saveEntry(
        saved.copyWith(body: 'Tampered preview'),
      );
      expect(tampered.body, 'Authoritative writing.');
    });

    test('moveFragment reorders A B C into B A C', () async {
      const date = LocalCalendarDate(year: 2026, month: 11, day: 2);
      final now = DateTime.utc(2026, 11, 2);
      final saved = await repository.saveMemory(
        entry: JournalEntry(
          id: '',
          localDate: date,
          title: 'Order',
          body: '',
          position: 0,
          createdAt: now,
          updatedAt: now,
        ),
        fragments: [
          for (final (i, kind) in [
            JournalFragmentKind.writing,
            JournalFragmentKind.list,
            JournalFragmentKind.audio,
          ].indexed)
            JournalFragment(
              id: '',
              entryId: '',
              kind: kind,
              position: i,
              textBody: kind == JournalFragmentKind.writing
                  ? 'A'
                  : kind == JournalFragmentKind.list
                  ? JournalFragment.encodeListItems(const ['B'])
                  : null,
              audioRelPath: kind == JournalFragmentKind.audio
                  ? 'journal_audio/test.m4a'
                  : null,
              audioDurationMs: kind == JournalFragmentKind.audio ? 1200 : null,
              createdAt: now,
              updatedAt: now,
            ),
        ],
      );

      await repository.moveFragment(
        entryId: saved.id,
        fromIndex: 1,
        toIndex: 0,
      );
      final fragments = await repository.watchFragmentsForEntry(saved.id).first;
      expect(fragments.map((f) => f.kind), [
        JournalFragmentKind.list,
        JournalFragmentKind.writing,
        JournalFragmentKind.audio,
      ]);
      expect(fragments.map((f) => f.position), [0, 1, 2]);
    });

    test('day mood and entry mood stay independent', () async {
      const date = LocalCalendarDate(year: 2026, month: 11, day: 3);
      final now = DateTime.utc(2026, 11, 3);
      await repository.upsertDay(
        JournalDay(
          localDate: date,
          mood: JournalMood.calm,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.saveMemory(
        entry: JournalEntry(
          id: '',
          localDate: date,
          title: 'Unexpected call',
          body: '',
          mood: JournalMood.anxious,
          position: 0,
          createdAt: now,
          updatedAt: now,
        ),
        fragments: const [],
      );

      final day = await repository.watchDay(date).first;
      final entry = (await repository.watchEntriesForDay(date).first).single;
      expect(day?.mood, JournalMood.calm);
      expect(entry.mood, JournalMood.anxious);
    });
  });
}

class _FixedClock extends Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 8, 11, 12);
}

class _FixedIdGenerator extends IdGenerator {
  _FixedIdGenerator();

  var _n = 0;

  @override
  String next() {
    _n += 1;
    return 'journal-id-$_n';
  }
}
