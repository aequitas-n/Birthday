import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/product_themes.dart';

void main() {
  test(
    'all current themes share functional type and own two expressive voices',
    () {
      final headings = <String>{};
      final pairings = <(String, String)>{};
      final catalog =
          jsonDecode(File('assets/fonts/catalog.json').readAsStringSync())
              as Map<String, dynamic>;
      for (final theme in ProductThemes.all) {
        final type = theme.quiet.text;
        expect(type.uiFamily, 'DMSans', reason: theme.label);
        expect(type.metadataFamily, 'DMMono', reason: theme.label);
        for (final style in [
          type.uiButton,
          type.uiNavigation,
          type.uiInput,
          type.uiBody,
        ]) {
          expect(style.fontFamily, 'DMSans', reason: theme.label);
        }
        for (final style in [
          type.uiDate,
          type.uiTimestamp,
          type.uiCount,
          type.uiMetadata,
        ]) {
          expect(style.fontFamily, 'DMMono', reason: theme.label);
        }
        headings.add(type.pageTitle.fontFamily!);
        pairings.add((type.headingFamily, type.journalFamily));
        expect(type.pageTitle.fontFamily, type.headingFamily);
        expect(type.journalWriting.fontFamily, type.journalFamily);
        expect(
          type.pageTitle.fontFamily,
          isNot(type.journalWriting.fontFamily),
        );
        expect(type.journalWriting.fontSize, greaterThanOrEqualTo(17));
        expect(type.journalWriting.height, greaterThanOrEqualTo(1.4));
        expect(type.uiButton.fontSize, 14);
        for (final family in [
          type.headingFamily,
          type.journalFamily,
          type.uiFamily,
          type.metadataFamily,
        ]) {
          expect(
            catalog,
            contains(family),
            reason: '$family must be available offline',
          );
          for (final file in catalog[family] as List<dynamic>) {
            final font = File('assets/fonts/$file');
            expect(font.existsSync(), isTrue, reason: family);
            expect(font.lengthSync(), greaterThan(10000));
          }
        }
        if (type.headingFamily != 'Fraunces') {
          expect(
            type.pageTitle.fontVariations,
            isNull,
            reason: 'Do not pass Fraunces axes to ${theme.label}',
          );
        }
        expect(
          type.uiCount.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      }
      expect(headings, hasLength(8));
      expect(pairings, hasLength(8));
    },
  );

  test(
    'type metrics are optically adjusted rather than one scale for every font',
    () {
      final comic = ProductThemes.sundayComics.quiet.text;
      final arcade = ProductThemes.neonArcade.quiet.text;
      final vintage = ProductThemes.vintageDiary.quiet.text;
      expect(comic.pageTitle.fontSize, greaterThan(arcade.pageTitle.fontSize!));
      expect(comic.pageTitle.letterSpacing, greaterThan(0));
      expect(
        arcade.journalWriting.fontSize,
        lessThan(vintage.journalWriting.fontSize!),
      );
      expect(
        arcade.journalWriting.height,
        greaterThan(vintage.journalWriting.height!),
      );
      // Utility controls retain their dimensions and family across themes.
      expect(comic.uiButton, arcade.uiButton);
      expect(vintage.uiDate, arcade.uiDate);
    },
  );
}
