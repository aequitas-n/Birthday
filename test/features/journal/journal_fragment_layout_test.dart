import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/journal/q_journal_fragment.dart';
import 'package:kin/features/journal/presentation/journal_fragment_layout.dart';

void main() {
  group('JournalFragmentLayout', () {
    test('is deterministic for the same seeds', () {
      final a = JournalFragmentLayout.resolve(
        entryId: 'entry-1',
        position: 0,
        dateKey: '2026-10-24',
        hasPhotos: false,
        bodyLength: 80,
        title: 'A quiet afternoon',
      );
      final b = JournalFragmentLayout.resolve(
        entryId: 'entry-1',
        position: 0,
        dateKey: '2026-10-24',
        hasPhotos: false,
        bodyLength: 80,
        title: 'A quiet afternoon',
      );
      expect(a.kind, b.kind);
      expect(a.rotation, b.rotation);
      expect(a.widthFactor, b.widthFactor);
      expect(a.topGap, b.topGap);
      expect(a.leadingInset, b.leadingInset);
      expect(a.trailingInset, b.trailingInset);
      expect(a.showTape, b.showTape);
      expect(a.showClip, b.showClip);
      expect(a.seed, b.seed);
    });

    test('varies across entries on the same day', () {
      final a = JournalFragmentLayout.resolve(
        entryId: 'entry-1',
        position: 0,
        dateKey: '2026-10-24',
        hasPhotos: false,
      );
      final b = JournalFragmentLayout.resolve(
        entryId: 'entry-2',
        position: 1,
        dateKey: '2026-10-24',
        hasPhotos: false,
      );
      expect(
        a.rotation != b.rotation ||
            a.widthFactor != b.widthFactor ||
            a.kind != b.kind ||
            a.topGap != b.topGap ||
            a.trailingInset != b.trailingInset ||
            a.seed != b.seed,
        isTrue,
      );
    });

    test('forces photo print when photos exist', () {
      final layout = JournalFragmentLayout.resolve(
        entryId: 'entry-1',
        position: 0,
        dateKey: '2026-10-24',
        hasPhotos: true,
      );
      expect(layout.kind, QJournalFragmentKind.photoPrint);
      expect(layout.showTape, isFalse);
      expect(layout.showClip, isFalse);
    });

    test('long bodies become documents', () {
      final layout = JournalFragmentLayout.resolve(
        entryId: 'entry-long',
        position: 0,
        dateKey: '2026-10-24',
        hasPhotos: false,
        bodyLength: 240,
        title: 'Long afternoon',
      );
      expect(layout.kind, QJournalFragmentKind.document);
    });

    test('photo rotation is stable', () {
      final a = journalPhotoRotation(photoId: 'p1', position: 0);
      final b = journalPhotoRotation(photoId: 'p1', position: 0);
      expect(a, b);
    });
  });
}
