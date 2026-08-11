import 'package:kin/domain/models/birthday_occurrence.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/reminder_rule.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderPlanner {
  const ReminderPlanner();

  List<NotificationPlan> planForPerson({
    required Person person,
    required BirthdayOccurrence occurrence,
    required List<ReminderRule> rules,
    required List<Note> notes,
    required bool notificationsEnabled,
    required bool showDetailsOnLockScreen,
    required DateTime nowUtc,
  }) {
    if (person.isDeleted || !notificationsEnabled) return const [];

    final activeRules = rules.where(
      (rule) => rule.enabled && rule.deletedAt == null,
    );
    final plans = <_RankedPlan>[];
    for (final rule in activeRules) {
      final fireAtUtc = _resolveFireAtUtc(occurrence: occurrence, rule: rule);
      if (fireAtUtc == null || !fireAtUtc.isAfter(nowUtc.toUtc())) {
        continue;
      }

      final selectedNote = showDetailsOnLockScreen
          ? _selectMemoryDetail(notes)
          : null;
      final copy = _composeCopy(
        person: person,
        occurrence: occurrence,
        rule: rule,
        note: selectedNote,
      );
      final targetLocal = _targetLocalMoment(
        rule: rule,
        occurrence: occurrence,
      );
      plans.add(
        _RankedPlan(
          rank: _ruleRank(rule.kind),
          plan: NotificationPlan(
            stableId: _stableNotificationId(
              personId: person.id,
              ruleId: rule.id,
              occurrenceYear: occurrence.occurrenceYear,
            ),
            personId: person.id,
            ruleId: rule.id,
            occurrenceYear: occurrence.occurrenceYear,
            fireAtUtc: fireAtUtc,
            targetLocalInstant: targetLocal,
            kind: _planKind(rule.kind),
            payload: NotificationPayload(
              version: 1,
              personId: person.id,
              ruleKind: rule.kind,
              occurrenceYear: occurrence.occurrenceYear,
            ),
            title: copy.title,
            body: copy.body,
            hidesSensitivePreview: !showDetailsOnLockScreen,
          ),
        ),
      );
    }

    plans.sort((a, b) {
      final byTime = a.plan.fireAtUtc.compareTo(b.plan.fireAtUtc);
      if (byTime != 0) return byTime;
      final byRank = b.rank.compareTo(a.rank);
      if (byRank != 0) return byRank;
      return a.plan.ruleId.compareTo(b.plan.ruleId);
    });

    return _collapseDuplicates(
      plans,
    ).map((entry) => entry.plan).toList(growable: false);
  }

  NotificationPlanReconciliation reconcile({
    required List<NotificationPlan> current,
    required List<NotificationPlan> desired,
  }) {
    final currentById = {for (final plan in current) plan.stableId: plan};
    final desiredById = {for (final plan in desired) plan.stableId: plan};

    final toAdd = <NotificationPlan>[];
    final toUpdate = <NotificationPlan>[];
    final unchanged = <NotificationPlan>[];
    final toRemove = <NotificationPlan>[];

    for (final desiredPlan in desired) {
      final existing = currentById[desiredPlan.stableId];
      if (existing == null) {
        toAdd.add(desiredPlan);
      } else if (existing == desiredPlan) {
        unchanged.add(desiredPlan);
      } else {
        toUpdate.add(desiredPlan);
      }
    }

    for (final currentPlan in current) {
      if (!desiredById.containsKey(currentPlan.stableId)) {
        toRemove.add(currentPlan);
      }
    }

    return NotificationPlanReconciliation(
      toAdd: List.unmodifiable(toAdd),
      toUpdate: List.unmodifiable(toUpdate),
      toRemove: List.unmodifiable(toRemove),
      unchanged: List.unmodifiable(unchanged),
    );
  }

  DateTime? _resolveFireAtUtc({
    required BirthdayOccurrence occurrence,
    required ReminderRule rule,
  }) {
    final deviceLocation = tz.getLocation(occurrence.deviceTimeZone);
    final clock = _deviceLocalClock(rule);
    return switch (rule.kind) {
      ReminderRuleKind.atTheirMidnight => occurrence.anchorUtc.toUtc(),
      ReminderRuleKind.daysBefore =>
        rule.offsetDays == null
            ? null
            : _deviceLocalDaysBefore(
                deviceLocation: deviceLocation,
                occurrence: occurrence,
                offsetDays: rule.offsetDays!,
                hour: clock.hour,
                minute: clock.minute,
              ).toUtc(),
      ReminderRuleKind.morningOf => tz.TZDateTime(
        deviceLocation,
        occurrence.deviceLocalEquivalent.year,
        occurrence.deviceLocalEquivalent.month,
        occurrence.deviceLocalEquivalent.day,
        clock.hour,
        clock.minute,
      ).toUtc(),
    };
  }

  LocalScheduledMoment _targetLocalMoment({
    required ReminderRule rule,
    required BirthdayOccurrence occurrence,
  }) {
    final clock = _deviceLocalClock(rule);
    return switch (rule.kind) {
      ReminderRuleKind.atTheirMidnight => LocalScheduledMoment(
        timeZone: occurrence.personTimeZone,
        year: occurrence.personLocalStart.year,
        month: occurrence.personLocalStart.month,
        day: occurrence.personLocalStart.day,
        hour: occurrence.personLocalStart.hour,
        minute: occurrence.personLocalStart.minute,
      ),
      ReminderRuleKind.daysBefore => () {
        final date = _daysBeforeDate(
          occurrence: occurrence,
          offsetDays: rule.offsetDays ?? 0,
        );
        return LocalScheduledMoment(
          timeZone: occurrence.deviceTimeZone,
          year: date.year,
          month: date.month,
          day: date.day,
          hour: clock.hour,
          minute: clock.minute,
        );
      }(),
      ReminderRuleKind.morningOf => LocalScheduledMoment(
        timeZone: occurrence.deviceTimeZone,
        year: occurrence.deviceLocalEquivalent.year,
        month: occurrence.deviceLocalEquivalent.month,
        day: occurrence.deviceLocalEquivalent.day,
        hour: clock.hour,
        minute: clock.minute,
      ),
    };
  }

  tz.TZDateTime _deviceLocalDaysBefore({
    required tz.Location deviceLocation,
    required BirthdayOccurrence occurrence,
    required int offsetDays,
    required int hour,
    required int minute,
  }) {
    final date = _daysBeforeDate(
      occurrence: occurrence,
      offsetDays: offsetDays,
    );
    return tz.TZDateTime(
      deviceLocation,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  DateTime _daysBeforeDate({
    required BirthdayOccurrence occurrence,
    required int offsetDays,
  }) {
    return DateTime.utc(
      occurrence.personLocalStart.year,
      occurrence.personLocalStart.month,
      occurrence.personLocalStart.day,
    ).subtract(Duration(days: offsetDays));
  }

  ({int hour, int minute}) _deviceLocalClock(ReminderRule rule) {
    final raw = rule.localTime ?? '09:00';
    final parts = raw.split(':');
    if (parts.length < 2) {
      return (hour: 9, minute: 0);
    }
    return (
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  _NotificationCopy _composeCopy({
    required Person person,
    required BirthdayOccurrence occurrence,
    required ReminderRule rule,
    required Note? note,
  }) {
    final displayName = person.displayName.trim();
    final turningAge = occurrence.ageTurning;
    final city = person.location?.label.split(',').first.trim();
    return switch (rule.kind) {
      ReminderRuleKind.daysBefore => _NotificationCopy(
        title: turningAge == null
            ? "$displayName's birthday is coming up."
            : '$displayName turns $turningAge ${rule.offsetDays == 1 ? 'tomorrow' : 'soon'}.',
        body: note == null
            ? 'A little time to think ahead.'
            : _detailSentence(note),
      ),
      ReminderRuleKind.atTheirMidnight => _NotificationCopy(
        title: city == null || city.isEmpty
            ? "It's $displayName's birthday."
            : "It's $displayName's birthday in $city.",
        body: turningAge == null
            ? 'Their day has just begun.'
            : '$displayName is $turningAge today.',
      ),
      ReminderRuleKind.morningOf => _NotificationCopy(
        title: turningAge == null
            ? "$displayName's birthday is today."
            : '$displayName turns $turningAge today.',
        body: note == null ? 'A good day to reach out.' : _detailSentence(note),
      ),
    };
  }

  Note? _selectMemoryDetail(List<Note> notes) {
    final eligible =
        notes.where((note) => !_excludedFromCopy(note)).toList(growable: false)
          ..sort((a, b) {
            final byPosition = a.position.compareTo(b.position);
            if (byPosition != 0) return byPosition;
            return a.id.compareTo(b.id);
          });
    return eligible.isEmpty ? null : eligible.first;
  }

  bool _excludedFromCopy(Note note) {
    if (note.deletedAt != null) return true;
    if (note.kind == NoteKind.free ||
        note.kind == NoteKind.importantDate ||
        note.kind == NoteKind.photo ||
        note.kind == NoteKind.plan) {
      return true;
    }
    if (note.kind == NoteKind.giftIdea && note.isRetired) return true;
    return false;
  }

  String _detailSentence(Note note) {
    final value = note.value.trim();
    if (value.isEmpty) return 'A good day to reach out.';
    return switch (note.kind) {
      NoteKind.flower => 'They love $value.',
      NoteKind.colour => '$value, if you need a cue.',
      NoteKind.food => 'They love $value.',
      NoteKind.dessert => '$value would land well.',
      NoteKind.drink => '$value, if you are still deciding.',
      NoteKind.movie => '$value still means something to them.',
      NoteKind.music => '$value might feel like them.',
      NoteKind.restaurant => '$value could be a good place to start.',
      NoteKind.place => '$value is a place they love.',
      NoteKind.giftIdea => value,
      NoteKind.plan => value,
      NoteKind.custom => value,
      NoteKind.importantDate => value,
      NoteKind.free => value,
      NoteKind.photo => 'A good day to reach out.',
    };
  }

  NotificationPlanKind _planKind(ReminderRuleKind kind) {
    return switch (kind) {
      ReminderRuleKind.atTheirMidnight => NotificationPlanKind.birthdayToday,
      ReminderRuleKind.morningOf => NotificationPlanKind.birthdayToday,
      ReminderRuleKind.daysBefore => NotificationPlanKind.birthdayUpcoming,
    };
  }

  int _ruleRank(ReminderRuleKind kind) {
    return switch (kind) {
      ReminderRuleKind.atTheirMidnight => 3,
      ReminderRuleKind.morningOf => 2,
      ReminderRuleKind.daysBefore => 1,
    };
  }

  List<_RankedPlan> _collapseDuplicates(List<_RankedPlan> plans) {
    final collapsed = <_RankedPlan>[];
    for (final entry in plans) {
      if (collapsed.isEmpty) {
        collapsed.add(entry);
        continue;
      }

      final previous = collapsed.last;
      final samePerson = previous.plan.personId == entry.plan.personId;
      final secondsApart = entry.plan.fireAtUtc
          .difference(previous.plan.fireAtUtc)
          .inSeconds
          .abs();
      if (samePerson && secondsApart <= 60) {
        if (entry.rank > previous.rank) {
          collapsed[collapsed.length - 1] = entry;
        }
        continue;
      }
      collapsed.add(entry);
    }
    return collapsed;
  }
}

int _stableNotificationId({
  required String personId,
  required String ruleId,
  required int occurrenceYear,
}) {
  final seed = '$personId|$ruleId|$occurrenceYear';
  var hash = 0x811C9DC5;
  for (final codeUnit in seed.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

class _NotificationCopy {
  const _NotificationCopy({required this.title, required this.body});

  final String title;
  final String body;
}

class _RankedPlan {
  const _RankedPlan({required this.rank, required this.plan});

  final int rank;
  final NotificationPlan plan;
}
