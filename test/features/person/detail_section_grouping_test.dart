import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/features/person/presentation/detail_kind_picker.dart';

void main() {
  Note note(NoteKind kind, String value) => Note(
    id: value,
    profileId: 'p',
    kind: kind,
    value: value,
    position: 0,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('groups notes into Favorites, Gift, Plan, Note in order', () {
    final grouped = groupNotesByDetailSection([
      note(NoteKind.plan, 'Trip'),
      note(NoteKind.free, 'Said this'),
      note(NoteKind.plan, 'Café'),
      note(NoteKind.flower, 'Peonies'),
      note(NoteKind.giftIdea, 'Mug'),
    ]);

    expect(grouped.map((e) => e.$1), [
      DetailKindSection.favorites,
      DetailKindSection.gift,
      DetailKindSection.plan,
      DetailKindSection.note,
    ]);
    expect(grouped[0].$2.single.value, 'Peonies');
    expect(grouped[1].$2.single.value, 'Mug');
    expect(grouped[2].$2.map((n) => n.value), ['Trip', 'Café']);
    expect(grouped[3].$2.single.value, 'Said this');
  });

  test('hides retired gift ideas from the active gift section', () {
    final grouped = groupNotesByDetailSection([
      note(NoteKind.giftIdea, 'Mug'),
      Note(
        id: 'given',
        profileId: 'p',
        kind: NoteKind.giftIdea,
        value: 'Scarf',
        position: 1,
        isRetired: true,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    ]);

    expect(grouped.map((e) => e.$1), [DetailKindSection.gift]);
    expect(grouped.single.$2.map((n) => n.value), ['Mug']);
  });

  test('respects custom section order', () {
    final grouped = groupNotesByDetailSection(
      [
        note(NoteKind.plan, 'Trip'),
        note(NoteKind.free, 'Said this'),
      ],
      order: const [
        DetailKindSection.note,
        DetailKindSection.plan,
        DetailKindSection.favorites,
        DetailKindSection.gift,
      ],
    );

    expect(grouped.map((e) => e.$1), [
      DetailKindSection.note,
      DetailKindSection.plan,
    ]);
  });

  test('favorites share one kind header per subtype cluster', () {
    final flowers = [
      note(NoteKind.flower, 'Ghds'),
      note(NoteKind.flower, 'Vzhs'),
      note(NoteKind.colour, 'Blue'),
    ];
    final headers = notesWithKindHeaders(
      DetailKindSection.favorites,
      flowers,
    ).toList();

    expect(headers.map((e) => e.$1), [
      'Favorite flower',
      null,
      'Favorite color',
    ]);
    expect(headers.map((e) => e.$2.value), ['Ghds', 'Vzhs', 'Blue']);
  });

  test('favorite kinds omit repeated row subtitle', () {
    expect(noteRowSubtitle(note(NoteKind.flower, 'Ghds')), isNull);
    expect(noteRowSubtitle(note(NoteKind.plan, 'Trip')), isNull);
    expect(
      noteRowSubtitle(
        Note(
          id: 'c',
          profileId: 'p',
          kind: NoteKind.custom,
          value: 'x',
          label: 'Nickname',
          position: 0,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ),
      'Nickname',
    );
  });
}
