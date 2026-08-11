import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_fragment_ops.dart';

void main() {
  final now = DateTime.utc(2026, 8, 12);

  JournalFragment frag(String id, JournalFragmentKind kind, int position) {
    return JournalFragment(
      id: id,
      entryId: 'e',
      kind: kind,
      position: position,
      textBody: kind == JournalFragmentKind.writing ? id : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('normalizePositions densifies 0..n-1', () {
    final normalized = JournalFragmentOps.normalizePositions([
      frag('a', JournalFragmentKind.writing, 4),
      frag('b', JournalFragmentKind.list, 9),
      frag('c', JournalFragmentKind.audio, 1),
    ]);
    expect(normalized.map((f) => f.position), [0, 1, 2]);
    expect(normalized.map((f) => f.id), ['a', 'b', 'c']);
  });

  test('moveUp / moveDown reorder without gaps', () {
    final start = JournalFragmentOps.normalizePositions([
      frag('a', JournalFragmentKind.writing, 0),
      frag('b', JournalFragmentKind.list, 1),
      frag('c', JournalFragmentKind.photograph, 2),
    ]);
    final moved = JournalFragmentOps.moveUp(start, 1);
    expect(moved.map((f) => f.id), ['b', 'a', 'c']);
    expect(moved.map((f) => f.position), [0, 1, 2]);

    final down = JournalFragmentOps.moveDown(moved, 0);
    expect(down.map((f) => f.id), ['a', 'b', 'c']);
  });

  test('removeAt renumbers remaining fragments', () {
    final start = JournalFragmentOps.normalizePositions([
      frag('a', JournalFragmentKind.writing, 0),
      frag('b', JournalFragmentKind.list, 1),
      frag('c', JournalFragmentKind.audio, 2),
    ]);
    final removed = JournalFragmentOps.removeAt(start, 1);
    expect(removed.map((f) => f.id), ['a', 'c']);
    expect(removed.map((f) => f.position), [0, 1]);
  });
}
