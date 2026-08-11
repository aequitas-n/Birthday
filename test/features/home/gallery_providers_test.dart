import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/home/application/gallery_providers.dart';

void main() {
  group('GalleryEntry', () {
    test('matchesQuery checks name, nickname, relationship, and place', () {
      final entry = GalleryEntry(
        person: Person(
          id: 'p1',
          displayName: 'Priya Raman',
          birthday: const PartialDate(month: 7, day: 28),
          location: const LocationModel(
            label: 'Chennai, India',
            timezone: TimezoneModel('Asia/Kolkata'),
          ),
          sortKey: 'priya raman',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
        profile: RelationshipProfile(
          id: 'pr1',
          personId: 'p1',
          nickname: 'Pri',
          relationship: RelationshipKind.friend,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
        daysUntil: 3,
        turningAge: null,
      );

      expect(entry.matchesQuery('pri'), isTrue);
      expect(entry.matchesQuery('FRIEND'), isTrue);
      expect(entry.matchesQuery('chennai'), isTrue);
      expect(entry.matchesQuery('xyz'), isFalse);
      expect(entry.primaryName, 'Pri');
    });

    test('pinned first, then soonest birthday within each group', () {
      GalleryEntry entry({
        required String name,
        required bool pinned,
        required int daysUntil,
      }) {
        return GalleryEntry(
          person: Person(
            id: name,
            displayName: name,
            birthday: const PartialDate(month: 1, day: 1),
            sortKey: name.toLowerCase(),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
          profile: RelationshipProfile(
            id: 'pr-$name',
            personId: name,
            isPinned: pinned,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
          daysUntil: daysUntil,
          turningAge: null,
        );
      }

      final entries =
          [
            entry(name: 'Helo', pinned: false, daysUntil: 176),
            entry(name: 'Hola', pinned: false, daysUntil: 3),
            entry(name: 'PinnedLater', pinned: true, daysUntil: 40),
            entry(name: 'PinnedSoon', pinned: true, daysUntil: 2),
          ]..sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            final byDays = a.daysUntil.compareTo(b.daysUntil);
            if (byDays != 0) return byDays;
            return a.person.sortKey.compareTo(b.person.sortKey);
          });

      expect(entries.map((e) => e.displayName).toList(), [
        'PinnedSoon',
        'PinnedLater',
        'Hola',
        'Helo',
      ]);
    });
  });
}
