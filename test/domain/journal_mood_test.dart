import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/vintage_mood.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';
import 'package:kin/domain/models/journal_mood.dart';

void main() {
  group('JournalMood vocabulary', () {
    test('ships exactly eight moods', () {
      expect(JournalMood.values, hasLength(8));
      expect(
        JournalMood.values.map((m) => m.displayName).toList(),
        [
          'Joyful',
          'Calm',
          'Sad',
          'Affection',
          'Anxious',
          'Frustrated',
          'Surprised',
          'Neutral',
        ],
      );
    });

    test('migrates retired storage ids', () {
      expect(JournalMood.fromStorage('excited'), JournalMood.joyful);
      expect(JournalMood.fromStorage('reflective'), JournalMood.calm);
      expect(JournalMood.fromStorage('nostalgic'), JournalMood.affection);
      expect(JournalMood.fromStorage('grateful'), JournalMood.affection);
    });

    test('every mood has an illustration asset', () {
      for (final mood in JournalMood.values) {
        expect(
          VintageMoodTheme.assetFor(mood.storageValue),
          isNotNull,
          reason: mood.name,
        );
      }
    });

    test('Excited-home is not part of the mood picker set', () {
      expect(
        JournalMood.values.map(
          (m) => VintageMoodTheme.assetFor(m.storageValue),
        ),
        isNot(contains(VintageDiaryAssets.excitedHome)),
      );
      expect(
        VintageMoodTheme.assetFor('excited'),
        isNull,
      );
    });
  });
}
