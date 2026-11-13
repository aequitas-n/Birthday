import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/home/application/gallery_memory.dart';
import 'package:kin/features/home/application/gallery_providers.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/home/presentation/portrait_gallery_carousel.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

import '../../support/quiet_test_app.dart';

/// Rebuild-count probe for People carousel swipe (Phase 2 performance).
void main() {
  setUpAll(loadQuietFonts);

  setUp(PortraitGalleryCarousel.debugResetBuildCount);

  testWidgets(
    'animating between pages keeps carousel rebuilds bounded',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(const _FixedClock()),
            galleryMemorySummariesProvider.overrideWith(
              (ref) => Stream.value(const <String, GalleryMemorySummary>{}),
            ),
            personPhotoProvider.overrideWith((ref, photoId) async => null),
            peopleStreamProvider.overrideWith((ref) => const Stream.empty()),
            profilesStreamProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: QuietTestApp(
            theme: QuietTheme.quietDefault(),
            child: SizedBox(
              width: 390,
              height: 700,
              child: PortraitGalleryCarousel(
                entries: [
                  _entry('a', 'Ada'),
                  _entry('b', 'Bea'),
                  _entry('c', 'Cia'),
                ],
              ),
            ),
          ),
        ),
      );
      // Fixed pumps — avoid pumpAndSettle (legacy setState-on-tick never idles).
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final pageView = tester.widget<PageView>(find.byType(PageView));
      final controller = pageView.controller!;
      expect(controller.hasClients, isTrue);

      PortraitGalleryCarousel.debugResetBuildCount();

      final target = controller.page!.round() + 1;
      unawaited(
        controller.animateToPage(
          target,
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pump(const Duration(milliseconds: 100));

      final buildsDuringSwipe = PortraitGalleryCarousel.debugBuildCount;

      // ignore: avoid_print — Phase 2 before/after evidence
      print('PHASE2_CAROUSEL_BUILDS=$buildsDuringSwipe');

      expect(
        buildsDuringSwipe,
        lessThan(3),
        reason:
            'Carousel rebuilt $buildsDuringSwipe times during a one-page '
            'animation; expected at most one settle rebuild (onPageChanged), '
            'not per-tick setState.',
      );
    },
  );
}

GalleryEntry _entry(String id, String name) {
  final person = Person(
    id: id,
    displayName: name,
    birthday: const PartialDate(month: 3, day: 7, year: 1990),
    sortKey: name.toLowerCase(),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  final profile = RelationshipProfile(
    id: 'prof-$id',
    personId: id,
    relationship: RelationshipKind.friend,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  return GalleryEntry(
    person: person,
    profile: profile,
    daysUntil: 100,
    turningAge: 36,
  );
}

class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026, 9, 11);
}
