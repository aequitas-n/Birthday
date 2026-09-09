import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/tokens/type_tokens.dart';

void main() {
  group('QuietTypography three-font architecture', () {
    const type = QuietTypography();

    test('product universal is CourierPrime and theme cannot own it', () {
      expect(QuietTypography.universalFamily, 'CourierPrime');
      expect(type.expression.archiveFamily, QuietTypography.universalFamily);
      expect(type.expression.primaryFamily, 'Caveat');
      expect(type.expression.secondaryFamily, 'Fraunces');
    });

    test('universal / archive / chrome roles stay on CourierPrime', () {
      for (final style in [
        type.uiButton,
        type.uiNavigation,
        type.uiLabel,
        type.uiBody,
        type.uiDate,
        type.uiTimestamp,
        type.uiCount,
        type.uiMetadata,
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
      ]) {
        expect(style.fontFamily, 'CourierPrime');
      }
    });

    test('editorial interface roles use Fraunces', () {
      expect(type.pageTitle.fontFamily, 'Fraunces');
      expect(type.sectionTitle.fontFamily, 'Fraunces');
      expect(type.displayTitle.fontFamily, 'Fraunces');
      expect(type.emptyStateTitle.fontFamily, 'Fraunces');
      expect(type.personName.fontFamily, 'Fraunces');
      expect(type.memoryTitle.fontFamily, 'Fraunces');
      expect(type.journalTitle.fontFamily, 'Fraunces');
      expect(type.editorialBody.fontFamily, 'Fraunces');
      expect(type.headline.fontFamily, 'Fraunces');
      expect(type.numeralLg.fontFamily, 'Fraunces');
      expect(type.numeralXl.fontFamily, 'Fraunces');
    });

    test('handwritten personal content uses Caveat', () {
      expect(type.diaryNote.fontFamily, 'Caveat');
      expect(type.emotionalBody.fontFamily, 'Caveat');
      expect(type.annotation.fontFamily, 'Caveat');
      expect(type.journalWriting.fontFamily, 'Caveat');
      expect(type.handwrittenMd.fontFamily, 'Caveat');
      expect(type.handwrittenSm.fontFamily, 'Caveat');
    });

    test('visible styles never use Inter', () {
      final styles = [
        type.pageTitle,
        type.sectionTitle,
        type.displayTitle,
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

    test('Fraunces headings stay editorial without dominating the page', () {
      expect(type.pageTitle.fontSize, closeTo(32, 0.5));
      expect(type.sectionTitle.fontSize, closeTo(22, 0.5));
    });

    test('journalWriting is tuned for readable handwriting on paper', () {
      expect(type.journalWriting.fontSize, closeTo(20, 0.5));
      expect(type.journalWriting.height, closeTo(1.5, 0.05));
    });
  });
}
