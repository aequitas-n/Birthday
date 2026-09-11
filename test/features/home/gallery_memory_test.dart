import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/features/home/application/gallery_memory.dart';

void main() {
  group('GalleryMemorySummary', () {
    test('fromNotes returns empty summary for no notes', () {
      final summary = GalleryMemorySummary.fromNotes(const []);
      expect(summary.count, 0);
      expect(summary.hasMemories, isFalse);
      expect(summary.hasLatestPreview, isFalse);
    });

    test('fromNotes counts notes and picks latest text memory', () {
      final summary = GalleryMemorySummary.fromNotes([
        Note(
          id: 'n1',
          profileId: 'p1',
          kind: NoteKind.flower,
          value: 'Peonies',
          position: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
        Note(
          id: 'n2',
          profileId: 'p1',
          kind: NoteKind.free,
          value: 'That late-night drive',
          position: 1,
          createdAt: DateTime.utc(2026, 1, 2),
          updatedAt: DateTime.utc(2026, 1, 5),
        ),
      ]);

      expect(summary.count, 2);
      expect(summary.countLabel(), '2 memories');
      expect(summary.latestPreview, 'That late-night drive');
      expect(
        summary.relativeLatestLabel(DateTime.utc(2026, 1, 8)),
        '3 days ago',
      );
    });

    test('fromNotes uses photo caption when latest note is a photo', () {
      final summary = GalleryMemorySummary.fromNotes([
        Note(
          id: 'photo-1',
          profileId: 'p1',
          kind: NoteKind.photo,
          value: 'photo-hash',
          label: 'At the beach',
          position: 0,
          createdAt: DateTime.utc(2026, 2),
          updatedAt: DateTime.utc(2026, 2),
        ),
      ]);

      expect(summary.latestPreview, 'At the beach');
      expect(summary.hasLatestPreview, isTrue);
    });

    test('fromNotes omits preview when photo has no caption', () {
      final summary = GalleryMemorySummary.fromNotes([
        Note(
          id: 'photo-1',
          profileId: 'p1',
          kind: NoteKind.photo,
          value: 'photo-hash',
          position: 0,
          createdAt: DateTime.utc(2026, 2),
          updatedAt: DateTime.utc(2026, 2),
        ),
      ]);

      expect(summary.hasMemories, isTrue);
      expect(summary.hasLatestPreview, isFalse);
      expect(summary.hasNote, isFalse);
      expect(summary.hasMoment, isTrue);
      expect(summary.momentPreview, 'A moment');
    });

    test('fromNotes splits latest note and moment previews', () {
      final summary = GalleryMemorySummary.fromNotes([
        Note(
          id: 'n1',
          profileId: 'p1',
          kind: NoteKind.flower,
          value: 'Peonies',
          position: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026, 1, 3),
        ),
        Note(
          id: 'photo-1',
          profileId: 'p1',
          kind: NoteKind.photo,
          value: 'photo-hash',
          label: 'At the beach',
          position: 1,
          createdAt: DateTime.utc(2026, 2),
          updatedAt: DateTime.utc(2026, 2),
        ),
      ]);

      expect(summary.notePreview, 'Peonies — Favorite flower');
      expect(summary.momentPreview, 'At the beach');
      expect(summary.hasNote, isTrue);
      expect(summary.hasMoment, isTrue);
    });

    test('fromNotes appends kind label for favorite place notes', () {
      final summary = GalleryMemorySummary.fromNotes([
        Note(
          id: 'n1',
          profileId: 'p1',
          kind: NoteKind.place,
          value: 'The beach near Mahabalipuram',
          position: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ]);

      expect(
        summary.notePreview,
        'The beach near Mahabalipuram — Favorite place',
      );
    });
  });
}
