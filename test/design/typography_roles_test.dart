import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/tokens/type_tokens.dart';

void main() {
  group('QuietTypography shared roles + theme expression', () {
    const vintage = QuietTypography.vintageDiary();
    const defaults = QuietTypography.quietDefault();

    final personalRoles = <TextStyle Function(QuietTypography)>[
      (t) => t.diaryNote,
      (t) => t.journalPrompt,
      (t) => t.emotionalBody,
      (t) => t.annotation,
      (t) => t.journalWriting,
      (t) => t.handwrittenMd,
      (t) => t.handwrittenSm,
      (t) => t.handwrittenLabel,
    ];

    final editorialRoles = <TextStyle Function(QuietTypography)>[
      (t) => t.appTitle,
      (t) => t.pageTitle,
      (t) => t.sectionTitle,
      (t) => t.subsectionTitle,
      (t) => t.displayTitle,
      (t) => t.emptyStateTitle,
      (t) => t.personName,
      (t) => t.memoryTitle,
      (t) => t.journalTitle,
      (t) => t.editorialBody,
      (t) => t.bodyEmphasis,
      (t) => t.headline,
      (t) => t.numeralLg,
      (t) => t.numeralXl,
    ];

    final chromeRoles = <TextStyle Function(QuietTypography)>[
      (t) => t.uiButton,
      (t) => t.uiNavigation,
      (t) => t.tab,
      (t) => t.uiLabel,
      (t) => t.uiBody,
      (t) => t.uiDate,
      (t) => t.uiTimestamp,
      (t) => t.uiCount,
      (t) => t.uiMetadata,
      (t) => t.supportingText,
      (t) => t.uiCaption,
      (t) => t.body,
      (t) => t.label,
      (t) => t.caption,
      (t) => t.metadata,
      (t) => t.buttonLabel,
      (t) => t.decorativeLabel,
      (t) => t.emptyStateBody,
      (t) => t.numeralSm,
      (t) => t.numeralMd,
      (t) => t.archiveBody,
      (t) => t.stampLabel,
      (t) => t.moodLabel,
    ];

    test('product universal is CourierPrime and theme cannot own it', () {
      expect(QuietTypography.universalFamily, 'CourierPrime');
      expect(vintage.expression.archiveFamily, QuietTypography.universalFamily);
      expect(
        defaults.expression.archiveFamily,
        QuietTypography.universalFamily,
      );
    });

    test('Default expression never uses Caveat', () {
      expect(defaults.expression.primaryFamily, isNot('Caveat'));
      expect(defaults.expression.secondaryFamily, isNot('Caveat'));
      for (final role in [
        ...personalRoles,
        ...editorialRoles,
        ...chromeRoles,
      ]) {
        expect(role(defaults).fontFamily, isNot('Caveat'));
      }
    });

    test('Default personal/journal voice uses CourierPrime', () {
      expect(defaults.expression.primaryFamily, 'CourierPrime');
      for (final role in personalRoles) {
        expect(role(defaults).fontFamily, 'CourierPrime');
      }
    });

    test('Default editorial voice uses Fraunces', () {
      expect(defaults.expression.secondaryFamily, 'Fraunces');
      for (final role in editorialRoles) {
        expect(role(defaults).fontFamily, 'Fraunces');
      }
    });

    test('Vintage retains Caveat for personal/journal roles', () {
      expect(vintage.expression.primaryFamily, 'Caveat');
      expect(vintage.expression.secondaryFamily, 'Fraunces');
      for (final role in personalRoles) {
        expect(role(vintage).fontFamily, 'Caveat');
      }
    });

    test('Vintage editorial voice stays Fraunces', () {
      for (final role in editorialRoles) {
        expect(role(vintage).fontFamily, 'Fraunces');
      }
    });

    for (final entry in [
      ('Vintage', vintage),
      ('Default', defaults),
    ]) {
      final label = entry.$1;
      final type = entry.$2;

      group(label, () {
        test('universal / archive / chrome roles stay on CourierPrime', () {
          for (final role in chromeRoles) {
            expect(role(type).fontFamily, 'CourierPrime');
          }
        });

        test('visible styles never use Inter', () {
          for (final role in [
            ...personalRoles,
            ...editorialRoles,
            ...chromeRoles.take(8),
          ]) {
            expect(role(type).fontFamily, isNot('Inter'));
          }
        });

        test('shared metrics stay stable across themes', () {
          expect(type.pageTitle.fontSize, closeTo(32, 0.5));
          expect(type.sectionTitle.fontSize, closeTo(22, 0.5));
          expect(type.journalWriting.fontSize, closeTo(20, 0.5));
          expect(type.journalWriting.height, closeTo(1.5, 0.05));
          expect(type.journalWriting.fontWeight, FontWeight.w400);
          expect(type.journalPrompt.fontWeight, FontWeight.w400);
        });
      });
    }

    test('Default and Vintage share semantic metrics', () {
      expect(defaults.pageTitle.fontSize, vintage.pageTitle.fontSize);
      expect(defaults.sectionTitle.fontSize, vintage.sectionTitle.fontSize);
      expect(defaults.journalWriting.fontSize, vintage.journalWriting.fontSize);
      expect(defaults.uiMetadata.fontSize, vintage.uiMetadata.fontSize);
      expect(defaults.personName.fontSize, vintage.personName.fontSize);
    });

    test(
      'Today empty-journal roles resolve via expression not hardcoded Caveat',
      () {
        expect(defaults.journalPrompt.fontFamily, 'CourierPrime');
        expect(defaults.journalWriting.fontFamily, 'CourierPrime');
        expect(vintage.journalPrompt.fontFamily, 'Caveat');
        expect(vintage.journalWriting.fontFamily, 'Caveat');
      },
    );
  });
}
