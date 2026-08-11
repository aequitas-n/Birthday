import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/note.dart';

void main() {
  group('Note remembered when', () {
    test('encodes and decodes date and time', () {
      final packed = Note.encodeRememberedWhen(
        date: '12 March 2025',
        time: '9:30 pm',
      );
      expect(packed, isNotNull);
      final (date, time) = Note.decodeRememberedWhen(packed);
      expect(date, '12 March 2025');
      expect(time, '9:30 pm');
      expect(Note.formatRememberedWhen(packed), '12 March 2025 · 9:30 pm');
    });

    test('allows date or time alone', () {
      expect(
        Note.formatRememberedWhen(
          Note.encodeRememberedWhen(date: 'Tuesday', time: ''),
        ),
        'Tuesday',
      );
      expect(
        Note.formatRememberedWhen(
          Note.encodeRememberedWhen(date: '', time: 'dusk'),
        ),
        'dusk',
      );
      expect(Note.encodeRememberedWhen(date: '  ', time: ''), isNull);
    });

    test('exposes display only on free notes', () {
      final note = Note(
        id: '1',
        profileId: 'p',
        kind: NoteKind.free,
        label: Note.encodeRememberedWhen(date: '7 Aug', time: 'noon'),
        value: 'He said he loves rain',
        position: 0,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      expect(note.rememberedWhenDisplay, '7 Aug · noon');

      final flower = note.copyWith(kind: NoteKind.flower);
      expect(flower.rememberedWhenDisplay, isNull);
    });
  });
}
