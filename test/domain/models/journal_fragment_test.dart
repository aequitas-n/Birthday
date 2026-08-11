import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/journal_fragment.dart';

void main() {
  test('list encode/decode round-trips', () {
    final encoded = JournalFragment.encodeListItems(const [
      'Met Kavin',
      'Had dinner',
      '  ',
      'Walked around the temple',
    ]);
    expect(JournalFragment.decodeListItems(encoded), [
      'Met Kavin',
      'Had dinner',
      'Walked around the temple',
    ]);
  });

  test('preview body joins writing and list only', () {
    final now = DateTime.utc(2026);
    final body = JournalFragment.previewBodyFrom([
      JournalFragment(
        id: '1',
        entryId: 'e',
        kind: JournalFragmentKind.writing,
        position: 0,
        textBody: 'Quiet evening.',
        createdAt: now,
        updatedAt: now,
      ),
      JournalFragment(
        id: '2',
        entryId: 'e',
        kind: JournalFragmentKind.list,
        position: 1,
        textBody: JournalFragment.encodeListItems(const ['Tea', 'Walk']),
        createdAt: now,
        updatedAt: now,
      ),
      JournalFragment(
        id: '3',
        entryId: 'e',
        kind: JournalFragmentKind.photograph,
        position: 2,
        photoId: 'p',
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    expect(body, 'Quiet evening.\n\n• Tea\n• Walk');
  });
}
