import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/journal/journal_deck_cursor.dart';
import 'package:kin/design/components/journal/q_journal_card_deck.dart';
import 'package:kin/design/components/journal/q_journal_memory_card.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  group('JournalDeckCursor', () {
    test('advances circularly without mutating length', () {
      var cursor = const JournalDeckCursor(length: 5);
      expect(cursor.position, 1);
      cursor = cursor.advance();
      expect(cursor.front, 1);
      expect(cursor.position, 2);
      for (var i = 0; i < 4; i++) {
        cursor = cursor.advance();
      }
      expect(cursor.front, 0);
      expect(cursor.position, 1);
    });

    test('retreat wraps', () {
      var cursor = const JournalDeckCursor(length: 3);
      cursor = cursor.retreat();
      expect(cursor.front, 2);
      expect(cursor.indexAtDepth(0), 2);
      expect(cursor.indexAtDepth(1), 0);
    });

    test('single item is a no-op', () {
      const cursor = JournalDeckCursor(length: 1);
      expect(cursor.advance().front, 0);
      expect(cursor.retreat().front, 0);
    });
  });

  group('QJournalCardDeck', () {
    List<QJournalDeckItem> items(int n) => [
      for (var i = 0; i < n; i++)
        QJournalDeckItem(
          id: 'e$i',
          title: 'Memory $i',
          body: 'Body for memory $i that is long enough to truncate.',
          fragmentLabel: 'writing',
        ),
    ];

    testWidgets('empty items render nothing', (tester) async {
      await tester.pumpQuiet(
        QJournalCardDeck(items: const [], onOpen: (_) {}),
        surfaceSize: const Size(390, 640),
      );
      expect(find.byType(QJournalMemoryCard), findsNothing);
    });

    testWidgets('one memory shows a single card, no fake layers', (
      tester,
    ) async {
      await tester.pumpQuiet(
        QJournalCardDeck(items: items(1), onOpen: (_) {}),
        surfaceSize: const Size(390, 640),
      );
      expect(find.byType(QJournalMemoryCard), findsOneWidget);
      expect(find.text('Memory 0'), findsOneWidget);
      expect(find.text('No. 01'), findsOneWidget);
    });

    testWidgets('all cards share identical geometry', (tester) async {
      await tester.pumpQuiet(
        QJournalCardDeck(items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );
      final cards = tester.widgetList<QJournalMemoryCard>(
        find.byType(QJournalMemoryCard),
      );
      expect(cards.length, greaterThanOrEqualTo(2));

      final sizes = find
          .byType(QJournalMemoryCard)
          .evaluate()
          .map((e) => e.size!)
          .toList();
      final first = sizes.first;
      for (final size in sizes) {
        expect(size.width, closeTo(first.width, 0.5));
        expect(size.height, closeTo(first.height, 0.5));
        expect(
          size.width / size.height,
          closeTo(QJournalMemoryCard.aspectRatio, 0.01),
        );
      }
    });

    testWidgets('circular advance cycles front card', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      expect(key.currentState!.cursor.front, 0);
      expect(find.text('Memory 0'), findsWidgets);

      key.currentState!.debugAdvance();
      await tester.pump();
      expect(key.currentState!.cursor.front, 1);
      expect(key.currentState!.frontItem!.id, 'e1');

      key.currentState!.debugAdvance();
      await tester.pump();
      key.currentState!.debugAdvance();
      await tester.pump();
      expect(key.currentState!.cursor.front, 0);
    });

    testWidgets('retreat restores previous front', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );
      key.currentState!.debugAdvance();
      await tester.pump();
      key.currentState!.debugRetreat();
      await tester.pump();
      expect(key.currentState!.cursor.front, 0);
    });

    testWidgets('tap opens front memory', (tester) async {
      String? opened;
      await tester.pumpQuiet(
        QJournalCardDeck(
          items: items(2),
          onOpen: (item) => opened = item.id,
        ),
        surfaceSize: const Size(390, 720),
      );
      await tester.tap(find.text('Memory 0').first);
      await tester.pump();
      expect(opened, 'e0');
    });

    testWidgets('insufficient drag snaps back without advancing', (
      tester,
    ) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      final center = tester.getCenter(find.byType(QJournalCardDeck));
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(-40, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(key.currentState!.cursor.front, 0);
    });

    testWidgets('swipe left advances to next card', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      final center = tester.getCenter(find.byType(QJournalMemoryCard).first);
      await tester.dragFrom(center, const Offset(-180, 0));
      await tester.pumpAndSettle();

      expect(key.currentState!.cursor.front, 1);
      expect(key.currentState!.frontItem!.id, 'e1');
    });

    testWidgets('swipe right also advances forward', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      final center = tester.getCenter(find.byType(QJournalMemoryCard).first);
      await tester.dragFrom(center, const Offset(180, 0));
      await tester.pumpAndSettle();

      expect(key.currentState!.cursor.front, 1);
      expect(key.currentState!.frontItem!.id, 'e1');
    });

    testWidgets('either swipe direction cycles 1→2→3→1', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      Future<void> swipe(Offset delta) async {
        final center = tester.getCenter(find.byType(QJournalMemoryCard).first);
        await tester.dragFrom(center, delta);
        await tester.pumpAndSettle();
      }

      await swipe(const Offset(-180, 0));
      expect(key.currentState!.cursor.front, 1);
      await swipe(const Offset(180, 0));
      expect(key.currentState!.cursor.front, 2);
      await swipe(const Offset(-180, 0));
      expect(key.currentState!.cursor.front, 0);
      await swipe(const Offset(180, 0));
      expect(key.currentState!.cursor.front, 1);
    });

    testWidgets('vertical swipe does not change front', (tester) async {
      final key = GlobalKey<QJournalCardDeckState>();
      await tester.pumpQuiet(
        QJournalCardDeck(key: key, items: items(3), onOpen: (_) {}),
        surfaceSize: const Size(390, 720),
      );

      final center = tester.getCenter(find.byType(QJournalMemoryCard).first);
      await tester.dragFrom(center, const Offset(20, -200));
      await tester.pumpAndSettle();

      expect(key.currentState!.cursor.front, 0);
    });

    testWidgets('counter maps position', (tester) async {
      await tester.pumpQuiet(
        const QJournalDeckCounter(position: 3, total: 8),
        surfaceSize: const Size(200, 80),
      );
      expect(find.text('3 of 8'), findsOneWidget);
    });
  });
}
