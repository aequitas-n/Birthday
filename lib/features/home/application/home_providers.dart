import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';

final peopleStreamProvider = StreamProvider<List<Person>>((ref) {
  return ref.watch(personRepositoryProvider).watchAll();
});

final profilesStreamProvider = StreamProvider<List<RelationshipProfile>>((ref) {
  return ref.watch(profileRepositoryProvider).watchAll();
});

final homeGroupsProvider = Provider<List<HomeGroup>>((ref) {
  final people =
      ref.watch(peopleStreamProvider).asData?.value ?? const <Person>[];
  final profiles =
      ref.watch(profilesStreamProvider).asData?.value ??
      const <RelationshipProfile>[];
  final profilesByPerson = <String, RelationshipProfile>{
    for (final profile in profiles) profile.personId: profile,
  };
  final now = ref.watch(clockProvider).now().toLocal();
  final buckets = <HomeSection, List<HomeEntry>>{
    HomeSection.today: [],
    HomeSection.thisWeek: [],
    HomeSection.thisMonth: [],
    HomeSection.later: [],
  };

  for (final person in people) {
    final nextDate = _nextOccurrence(person.birthday, now);
    final daysUntil = nextDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    final section = switch (daysUntil) {
      0 => HomeSection.today,
      >= 1 && <= 7 => HomeSection.thisWeek,
      >= 8 && <= 31 => HomeSection.thisMonth,
      _ => HomeSection.later,
    };
    buckets[section]!.add(
      HomeEntry(
        person: person,
        profile: profilesByPerson[person.id],
        nextBirthday: nextDate,
        daysUntil: daysUntil,
        turningAge: person.birthday.year == null
            ? null
            : (nextDate.year - person.birthday.year!),
      ),
    );
  }

  return buckets.entries
      .where((entry) => entry.value.isNotEmpty)
      .map(
        (entry) => HomeGroup(
          section: entry.key,
          entries: entry.value
            ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil)),
        ),
      )
      .toList(growable: false);
});

enum HomeSection {
  today('Today'),
  thisWeek('This week'),
  thisMonth('This month'),
  later('Later this year')
  ;

  const HomeSection(this.label);

  final String label;
}

class HomeGroup {
  const HomeGroup({required this.section, required this.entries});

  final HomeSection section;
  final List<HomeEntry> entries;
}

class HomeEntry {
  const HomeEntry({
    required this.person,
    required this.nextBirthday,
    required this.daysUntil,
    required this.turningAge,
    this.profile,
  });

  final Person person;
  final RelationshipProfile? profile;
  final DateTime nextBirthday;
  final int daysUntil;
  final int? turningAge;

  /// Next birthday date and place, e.g. `7 July · Chennai`.
  String? get nextBirthdayLine {
    final date = _formatBirthdayDate(nextBirthday);
    final place = _shortPlace(person.location?.label);
    if (daysUntil == 0 && turningAge != null) {
      return place == null
          ? 'Turns $turningAge · $date'
          : 'Turns $turningAge · $date · $place';
    }
    if (place == null) return date;
    return '$date · $place';
  }

  /// Day + month only for hanging birthday strips, e.g. `7 August`.
  String get birthdayDateLabel => _formatBirthdayDate(nextBirthday);

  /// Secondary countdown, e.g. `344 days`.
  String get countdownText {
    return switch (daysUntil) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '$daysUntil days',
    };
  }

  /// Legacy subtitle retained for tests — prefer [nextBirthdayLine].
  String? get subtitle => nextBirthdayLine;
}

String _formatBirthdayDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String? _shortPlace(String? label) {
  final trimmed = label?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final parts = trimmed.split(',').map((part) => part.trim()).toList();
  return parts.isEmpty ? trimmed : parts.first;
}

DateTime _nextOccurrence(PartialDate birthday, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final thisYear = _safeDate(now.year, birthday.month, birthday.day);
  if (!thisYear.isBefore(today)) return thisYear;
  return _safeDate(now.year + 1, birthday.month, birthday.day);
}

DateTime _safeDate(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  final clampedDay = day > lastDay ? lastDay : day;
  return DateTime(year, month, clampedDay);
}
