import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/tokens/neon_arcade_tokens.dart';
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

    test('Vintage theme provides an illustration for every mood', () {
      final mood = ProductThemes.vintageDiary.assets.mood;
      for (final entry in JournalMood.values) {
        expect(
          mood.illustration(entry.storageValue),
          isNotNull,
          reason: entry.name,
        );
      }
    });

    test('Default theme intentionally has no mood illustrations', () {
      final mood = ProductThemes.quietDefault.assets.mood;
      for (final entry in JournalMood.values) {
        expect(mood.illustration(entry.storageValue), isNull);
      }
      expect(mood.emptyInvite, isNull);
    });

    test('Excited-home is not part of the mood picker set', () {
      final mood = ProductThemes.vintageDiary.assets.mood;
      expect(
        JournalMood.values.map((m) => mood.illustration(m.storageValue)),
        isNot(contains(VintageDiaryAssets.excitedHome)),
      );
      expect(mood.illustration('excited'), isNull);
      expect(mood.emptyInvite, ProductThemes.vintageDiary.art!.atlas);
    });

    test('Neon Excited-home is invite-only, not a picker mood', () {
      final mood = ProductThemes.neonArcade.assets.mood;
      expect(
        JournalMood.values.map((m) => mood.illustration(m.storageValue)),
        isNot(contains(NeonArcadeAssets.excitedHome)),
      );
      expect(mood.illustration('excited'), isNull);
      expect(mood.emptyInvite, ProductThemes.neonArcade.art!.atlas);
    });
  });
}
