import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/features/home/application/home_providers.dart';

/// Cap for the Universal Home birthday preview — never the full timeline.
const kTodayUpcomingLimit = 3;

/// The next few birthdays for Today, already sorted by [homeGroupsProvider].
final todayUpcomingProvider = Provider<List<HomeEntry>>((ref) {
  final groups = ref.watch(homeGroupsProvider);
  return [
    for (final group in groups) ...group.entries,
  ].take(kTodayUpcomingLimit).toList(growable: false);
});

/// Birthdays falling on the local calendar day — stronger priority on Today.
final todayBirthdayProvider = Provider<List<HomeEntry>>((ref) {
  final groups = ref.watch(homeGroupsProvider);
  return groups
      .where((group) => group.section == HomeSection.today)
      .expand((group) => group.entries)
      .toList(growable: false);
});
