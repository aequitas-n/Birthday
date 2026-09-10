import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/journal/q_today_empty_journal_invite.dart';
import 'package:kin/design/components/navigation/q_diary_chrome_strip.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/mood_illustration_metrics.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  group('null asset fallbacks (Default)', () {
    testWidgets('QScreen uses solid canvas — no Vintage background', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const QScreen(child: SizedBox.expand()),
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );

      final paths = collectAssetImagePaths(tester);
      expect(hasVintageDiaryAsset(paths), isFalse);
      expect(paths, isNot(contains(VintageDiaryAssets.background)));

      final canvas = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(QThemeCanvas),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(canvas.color, ProductThemes.quietDefault.quiet.color.canvas);
    });

    testWidgets('journal card / calendar / nav strip stay solid', (tester) async {
      await tester.pumpQuiet(
        const QScreen(
          child: Column(
            children: [
              Expanded(
                child: QJournalCardSurface(child: Text('memory')),
              ),
              Expanded(
                child: QCalendarSurface(child: Text('calendar')),
              ),
              QDiaryChromeStrip(child: Text('Today')),
            ],
          ),
        ),
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );

      final paths = collectAssetImagePaths(tester);
      expect(hasVintageDiaryAsset(paths), isFalse);
      expect(find.text('memory'), findsOneWidget);
      expect(find.text('calendar'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('mood illustration and empty invite render nothing decorative', (
      tester,
    ) async {
      await tester.pumpQuiet(
        QScreen(
          child: Column(
            children: [
              const QMoodIllustration(
                moodId: 'joyful',
                size: MoodIllustrationSize.picker,
              ),
              QTodayEmptyJournalInvite(
                child: SizedBox(
                  width: 200,
                  height: 280,
                  child: QJournalCardSurface(child: const Text('invite')),
                ),
              ),
            ],
          ),
        ),
        theme: const QuietTheme.quietDefault(),
        appTheme: ProductThemes.quietDefault,
      );

      final paths = collectAssetImagePaths(tester);
      expect(hasVintageDiaryAsset(paths), isFalse);
      expect(paths, isNot(contains(VintageDiaryAssets.excitedHome)));
      expect(find.byType(Image), findsNothing);
      expect(find.text('invite'), findsOneWidget);
    });
  });

  group('Vintage restoration assets', () {
    testWidgets('QScreen loads vintage-bg and mood empty invite uses Excited-home', (
      tester,
    ) async {
      await tester.pumpQuiet(
        QScreen(
          child: QTodayEmptyJournalInvite(
            child: SizedBox(
              width: 200,
              height: 280,
              child: QJournalCardSurface(
                child: QMoodIllustration(
                  moodId: 'calm',
                  size: MoodIllustrationSize.picker,
                ),
              ),
            ),
          ),
        ),
        theme: const QuietTheme.light(),
        appTheme: ProductThemes.vintageDiary,
      );

      final paths = collectAssetImagePaths(tester);
      expect(paths, contains(VintageDiaryAssets.background));
      expect(paths, contains(VintageDiaryAssets.journalCard));
      expect(paths, contains(VintageDiaryAssets.excitedHome));
      expect(paths, contains(VintageDiaryAssets.moodIllustration('calm')));
    });
  });

  group('Default ↔ Vintage isolation in the widget tree', () {
    testWidgets('switching product themes drops then restores Vintage paths', (
      tester,
    ) async {
      Future<Set<String>> pumpTheme({required bool vintage}) {
        return () async {
          await tester.pumpQuiet(
            QScreen(
              child: Column(
                children: [
                  Expanded(
                    child: QJournalCardSurface(
                      child: QMoodIllustration(
                        moodId: 'joyful',
                        size: MoodIllustrationSize.picker,
                      ),
                    ),
                  ),
                  const QDiaryChromeStrip(height: 56, child: Text('nav')),
                ],
              ),
            ),
            theme: vintage
                ? const QuietTheme.light()
                : const QuietTheme.quietDefault(),
            appTheme: vintage
                ? ProductThemes.vintageDiary
                : ProductThemes.quietDefault,
          );
          return collectAssetImagePaths(tester);
        }();
      }

      final vintagePaths = await pumpTheme(vintage: true);
      expect(hasVintageDiaryAsset(vintagePaths), isTrue);

      final defaultPaths = await pumpTheme(vintage: false);
      expect(hasVintageDiaryAsset(defaultPaths), isFalse);

      final restored = await pumpTheme(vintage: true);
      expect(restored, contains(VintageDiaryAssets.background));
      expect(restored, contains(VintageDiaryAssets.journalCard));
      expect(restored, contains(VintageDiaryAssets.chromeStrip));
    });
  });
}
