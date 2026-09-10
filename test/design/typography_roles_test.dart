import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/tokens/type_tokens.dart';

void main() {
  group('QuietTypography three-font architecture', () {
    const vintage = QuietTypography.vintageDiary();
    const defaults = QuietTypography.quietDefault();

    test('product universal is CourierPrime and theme cannot own it', () {
      expect(QuietTypography.universalFamily, 'CourierPrime');
      expect(vintage.expression.archiveFamily, QuietTypography.universalFamily);
      expect(defaults.expression.archiveFamily, QuietTypography.universalFamily);
    });

    for (final entry in [
      ('Vintage', vintage),
      ('Default', defaults),
    ]) {
      final label = entry.$1;
      final type = entry.$2;

      group(label, () {
        test('handwriting is Caveat; editorial is Fraunces; chrome is Courier', () {
          expect(type.expression.primaryFamily, 'Caveat');
          expect(type.expression.secondaryFamily, 'Fraunces');
        });

        test('universal / archive / chrome roles stay on CourierPrime', () {
          for (final style in [
            type.uiButton,
            type.uiNavigation,
            type.tab,
            type.uiLabel,
            type.uiBody,
            type.uiDate,
            type.uiTimestamp,
            type.uiCount,
            type.uiMetadata,
            type.supportingText,
            type.uiCaption,
            type.body,
            type.label,
            type.caption,
            type.metadata,
            type.buttonLabel,
            type.decorativeLabel,
            type.emptyStateBody,
            type.numeralSm,
            type.numeralMd,
            type.archiveBody,
            type.stampLabel,
            type.moodLabel,
          ]) {
            expect(style.fontFamily, 'CourierPrime');
          }
        });

        test('editorial interface roles use Fraunces', () {
          expect(type.appTitle.fontFamily, 'Fraunces');
          expect(type.pageTitle.fontFamily, 'Fraunces');
          expect(type.sectionTitle.fontFamily, 'Fraunces');
          expect(type.subsectionTitle.fontFamily, 'Fraunces');
          expect(type.displayTitle.fontFamily, 'Fraunces');
          expect(type.emptyStateTitle.fontFamily, 'Fraunces');
          expect(type.personName.fontFamily, 'Fraunces');
          expect(type.memoryTitle.fontFamily, 'Fraunces');
          expect(type.journalTitle.fontFamily, 'Fraunces');
          expect(type.editorialBody.fontFamily, 'Fraunces');
          expect(type.bodyEmphasis.fontFamily, 'Fraunces');
          expect(type.headline.fontFamily, 'Fraunces');
          expect(type.numeralLg.fontFamily, 'Fraunces');
          expect(type.numeralXl.fontFamily, 'Fraunces');
        });

        test('handwritten personal content uses Caveat', () {
          expect(type.diaryNote.fontFamily, 'Caveat');
          expect(type.journalPrompt.fontFamily, 'Caveat');
          expect(type.emotionalBody.fontFamily, 'Caveat');
          expect(type.annotation.fontFamily, 'Caveat');
          expect(type.journalWriting.fontFamily, 'Caveat');
          expect(type.handwrittenMd.fontFamily, 'Caveat');
          expect(type.handwrittenSm.fontFamily, 'Caveat');
        });

        test('visible styles never use Inter', () {
          final styles = [
            type.appTitle,
            type.pageTitle,
            type.sectionTitle,
            type.journalPrompt,
            type.diaryNote,
            type.personName,
            type.memoryTitle,
            type.editorialBody,
            type.journalWriting,
            type.emptyStateTitle,
            type.emptyStateBody,
            type.uiButton,
            type.uiNavigation,
            type.uiBody,
            type.uiDate,
            type.body,
            type.label,
            type.buttonLabel,
            type.voiceXl,
            type.numeralSm,
            type.numeralLg,
          ];
          for (final style in styles) {
            expect(style.fontFamily, isNot('Inter'));
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
  });
}
