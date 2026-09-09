import 'package:flutter_test/flutter_test.dart';
import 'package:kin/domain/models/birthday_occurrence.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/reminder_rule.dart';
import 'package:kin/domain/services/occurrence_calculator.dart';
import 'package:kin/domain/services/reminder_planner.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('ReminderPlanner', () {
    const planner = ReminderPlanner();

    final person = Person(
      id: 'person-1',
      displayName: 'Emma Stone',
      birthday: const PartialDate(month: 7, day: 28, year: 2002),
      location: const LocationModel(
        label: 'Dallas, Texas, United States',
        timezone: TimezoneModel('America/Chicago'),
      ),
      sortKey: 'emma stone',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final occurrence = BirthdayOccurrence(
      occurrenceYear: 2026,
      anchorUtc: DateTime.utc(2026, 7, 28, 5),
      personLocalStart: DateTime.utc(2026, 7, 28),
      deviceLocalEquivalent: DateTime.utc(2026, 7, 28),
      personTimeZone: 'America/Chicago',
      deviceTimeZone: 'Europe/London',
      ageTurning: 24,
    );

    final defaultRules = [
      ReminderRule(
        id: 'days-7',
        kind: ReminderRuleKind.daysBefore,
        offsetDays: 7,
        enabled: true,
        updatedAt: DateTime.utc(2026),
      ),
      ReminderRule(
        id: 'days-1',
        kind: ReminderRuleKind.daysBefore,
        offsetDays: 1,
        enabled: true,
        updatedAt: DateTime.utc(2026),
      ),
      ReminderRule(
        id: 'midnight',
        kind: ReminderRuleKind.atTheirMidnight,
        enabled: true,
        updatedAt: DateTime.utc(2026),
      ),
    ];

    test(
      'seeded defaults fire 7 days before, 1 day before, and at their midnight',
      () {
        const calculator = OccurrenceCalculator();
        final person = Person(
          id: 'testing-1',
          displayName: 'Testing 1',
          birthday: const PartialDate(month: 7, day: 31),
          location: const LocationModel(
            label: 'Chennai, Tamil Nadu, India',
            timezone: TimezoneModel('Asia/Kolkata'),
          ),
          sortKey: 'testing 1',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );
        final seededRules = [
          ReminderRule(
            id: 'default-days-7',
            kind: ReminderRuleKind.daysBefore,
            offsetDays: 7,
            localTime: '09:00',
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
          ReminderRule(
            id: 'default-days-1',
            kind: ReminderRuleKind.daysBefore,
            offsetDays: 1,
            localTime: '09:00',
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
          ReminderRule(
            id: 'default-at-midnight',
            kind: ReminderRuleKind.atTheirMidnight,
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
        ];

        // Plenty of lead time: 1 July 10:00 IST.
        final nowUtc = DateTime.utc(2026, 7, 1, 4, 30);
        final occurrence = calculator.next(
          date: person.birthday,
          personTimeZone: 'Asia/Kolkata',
          nowUtc: nowUtc,
          deviceTimeZone: 'Asia/Kolkata',
        );
        final plans = planner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: seededRules,
          notes: const [],
          notificationsEnabled: true,
          showDetailsOnLockScreen: true,
          nowUtc: nowUtc,
        );

        expect(plans.map((plan) => plan.ruleId), [
          'default-days-7',
          'default-days-1',
          'default-at-midnight',
        ]);

        final ist = tz.getLocation('Asia/Kolkata');
        expect(
          tz.TZDateTime.from(plans[0].fireAtUtc, ist),
          tz.TZDateTime(ist, 2026, 7, 24, 9),
        );
        expect(
          tz.TZDateTime.from(plans[1].fireAtUtc, ist),
          tz.TZDateTime(ist, 2026, 7, 30, 9),
        );
        expect(
          tz.TZDateTime.from(plans[2].fireAtUtc, ist),
          tz.TZDateTime(ist, 2026, 7, 31),
        );
      },
    );

    test(
      'drops advance reminders that already passed, keeps midnight',
      () {
        const calculator = OccurrenceCalculator();
        final person = Person(
          id: 'testing-1',
          displayName: 'Testing 1',
          birthday: const PartialDate(month: 7, day: 31),
          location: const LocationModel(
            label: 'Chennai, Tamil Nadu, India',
            timezone: TimezoneModel('Asia/Kolkata'),
          ),
          sortKey: 'testing 1',
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        );
        final seededRules = [
          ReminderRule(
            id: 'default-days-7',
            kind: ReminderRuleKind.daysBefore,
            offsetDays: 7,
            localTime: '09:00',
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
          ReminderRule(
            id: 'default-days-1',
            kind: ReminderRuleKind.daysBefore,
            offsetDays: 1,
            localTime: '09:00',
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
          ReminderRule(
            id: 'default-at-midnight',
            kind: ReminderRuleKind.atTheirMidnight,
            enabled: true,
            updatedAt: DateTime.utc(2026),
          ),
        ];

        // 30 July 23:08 IST — day-before 09:00 already passed.
        final nowUtc = DateTime.utc(2026, 7, 30, 17, 38);
        final occurrence = calculator.next(
          date: person.birthday,
          personTimeZone: 'Asia/Kolkata',
          nowUtc: nowUtc,
          deviceTimeZone: 'Asia/Kolkata',
        );
        final plans = planner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: seededRules,
          notes: const [],
          notificationsEnabled: true,
          showDetailsOnLockScreen: true,
          nowUtc: nowUtc,
        );

        expect(plans, hasLength(1));
        expect(plans.single.ruleId, 'default-at-midnight');
      },
    );

    test('produces deterministic stable identifiers', () {
      final plansA = planner.planForPerson(
        person: person,
        occurrence: occurrence,
        rules: defaultRules,
        notes: const [],
        notificationsEnabled: true,
        showDetailsOnLockScreen: true,
        nowUtc: DateTime.utc(2026),
      );
      final plansB = planner.planForPerson(
        person: person,
        occurrence: occurrence,
        rules: defaultRules,
        notes: const [],
        notificationsEnabled: true,
        showDetailsOnLockScreen: true,
        nowUtc: DateTime.utc(2026),
      );

      expect(
        plansA.map((plan) => plan.stableId),
        plansB.map((plan) => plan.stableId),
      );
    });

    test('drops deleted people and globally disabled reminders', () {
      final deleted = person.copyWith(deletedAt: DateTime.utc(2026));

      expect(
        planner.planForPerson(
          person: deleted,
          occurrence: occurrence,
          rules: defaultRules,
          notes: const [],
          notificationsEnabled: true,
          showDetailsOnLockScreen: true,
          nowUtc: DateTime.utc(2026),
        ),
        isEmpty,
      );

      expect(
        planner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: defaultRules,
          notes: const [],
          notificationsEnabled: false,
          showDetailsOnLockScreen: true,
          nowUtc: DateTime.utc(2026),
        ),
        isEmpty,
      );
    });

    test('filters disabled reminder rules', () {
      final rules = [
        defaultRules.first.copyWith(enabled: false),
        defaultRules[1],
      ];

      final plans = planner.planForPerson(
        person: person,
        occurrence: occurrence,
        rules: rules,
        notes: const [],
        notificationsEnabled: true,
        showDetailsOnLockScreen: true,
        nowUtc: DateTime.utc(2026),
      );

      expect(plans, hasLength(1));
      expect(plans.single.ruleId, 'days-1');
    });

    test('prevents duplicates within sixty seconds for the same person', () {
      final rules = [
        ReminderRule(
          id: 'morning',
          kind: ReminderRuleKind.morningOf,
          enabled: true,
          updatedAt: DateTime.utc(2026),
        ),
        ReminderRule(
          id: 'midnight',
          kind: ReminderRuleKind.atTheirMidnight,
          enabled: true,
          updatedAt: DateTime.utc(2026),
        ),
      ];

      final closeOccurrence = occurrence.copyWith(
        anchorUtc: DateTime.utc(2026, 7, 28, 8, 0, 30),
      );

      final plans = planner.planForPerson(
        person: person,
        occurrence: closeOccurrence,
        rules: rules,
        notes: const [],
        notificationsEnabled: true,
        showDetailsOnLockScreen: true,
        nowUtc: DateTime.utc(2026),
      );

      expect(plans, hasLength(1));
      expect(plans.single.ruleId, 'midnight');
    });

    test(
      'keeps separate plans for different people with the same birthday',
      () {
        final secondPerson = person.copyWith(
          id: 'person-2',
          displayName: 'Nina West',
          sortKey: 'nina west',
        );

        final emmaPlans = planner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: [defaultRules.last],
          notes: const [],
          notificationsEnabled: true,
          showDetailsOnLockScreen: true,
          nowUtc: DateTime.utc(2026),
        );
        final ninaPlans = planner.planForPerson(
          person: secondPerson,
          occurrence: occurrence,
          rules: [defaultRules.last],
          notes: const [],
          notificationsEnabled: true,
          showDetailsOnLockScreen: true,
          nowUtc: DateTime.utc(2026),
        );

        expect(emmaPlans.single.fireAtUtc, ninaPlans.single.fireAtUtc);
        expect(emmaPlans.single.stableId, isNot(ninaPlans.single.stableId));
      },
    );

    test('changes the fire instant when the occurrence changes', () {
      final original = planner
          .planForPerson(
            person: person,
            occurrence: occurrence,
            rules: [defaultRules.last],
            notes: const [],
            notificationsEnabled: true,
            showDetailsOnLockScreen: true,
            nowUtc: DateTime.utc(2026),
          )
          .single;

      final moved = planner
          .planForPerson(
            person: person.copyWith(
              location: const LocationModel(
                label: 'London, England, United Kingdom',
                timezone: TimezoneModel('Europe/London'),
              ),
            ),
            occurrence: occurrence.copyWith(
              anchorUtc: DateTime.utc(2026, 7, 27, 23),
              personTimeZone: 'Europe/London',
              personLocalStart: DateTime.utc(2026, 7, 28),
            ),
            rules: [defaultRules.last],
            notes: const [],
            notificationsEnabled: true,
            showDetailsOnLockScreen: true,
            nowUtc: DateTime.utc(2026),
          )
          .single;

      expect(original.stableId, moved.stableId);
      expect(original.fireAtUtc, isNot(moved.fireAtUtc));
    });

    test(
      'cross-year plans keep the same rule identity and move to the new year',
      () {
        final nextYear = occurrence.copyWith(
          occurrenceYear: 2027,
          anchorUtc: DateTime.utc(2027, 7, 28, 5),
          personLocalStart: DateTime.utc(2027, 7, 28),
          deviceLocalEquivalent: DateTime.utc(2027, 7, 28),
          ageTurning: 25,
        );

        final thisYearPlan = planner
            .planForPerson(
              person: person,
              occurrence: occurrence,
              rules: [defaultRules.last],
              notes: const [],
              notificationsEnabled: true,
              showDetailsOnLockScreen: true,
              nowUtc: DateTime.utc(2026),
            )
            .single;
        final nextYearPlan = planner
            .planForPerson(
              person: person,
              occurrence: nextYear,
              rules: [defaultRules.last],
              notes: const [],
              notificationsEnabled: true,
              showDetailsOnLockScreen: true,
              nowUtc: DateTime.utc(2026),
            )
            .single;

        expect(thisYearPlan.ruleId, nextYearPlan.ruleId);
        expect(thisYearPlan.occurrenceYear, 2026);
        expect(nextYearPlan.occurrenceYear, 2027);
        expect(thisYearPlan.stableId, isNot(nextYearPlan.stableId));
      },
    );

    test(
      'keeps sensitive details out when lock-screen previews are disabled',
      () {
        final plans = planner.planForPerson(
          person: person,
          occurrence: occurrence,
          rules: [defaultRules.first],
          notes: [
            Note(
              id: 'note-1',
              profileId: 'profile-1',
              kind: NoteKind.flower,
              value: 'red roses',
              position: 0,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          ],
          notificationsEnabled: true,
          showDetailsOnLockScreen: false,
          nowUtc: DateTime.utc(2026),
        );

        expect(plans.single.hidesSensitivePreview, isTrue);
        expect(plans.single.body, isNot(contains('red roses')));
      },
    );

    test('reconciles additions, updates, removals, and unchanged plans', () {
      final desired = planner.planForPerson(
        person: person,
        occurrence: occurrence,
        rules: [defaultRules.first, defaultRules.last],
        notes: const [],
        notificationsEnabled: true,
        showDetailsOnLockScreen: true,
        nowUtc: DateTime.utc(2026),
      );

      final current = [
        desired.first,
        desired.last.copyWith(body: 'Old body'),
        NotificationPlan(
          stableId: 999,
          source: NotificationPlanSource.birthday,
          personId: 'person-9',
          ruleId: 'old',
          occurrenceYear: 2025,
          fireAtUtc: DateTime.utc(2025),
          targetLocalInstant: const LocalScheduledMoment(
            timeZone: 'Europe/London',
            year: 2025,
            month: 1,
            day: 1,
            hour: 9,
            minute: 0,
          ),
          kind: NotificationPlanKind.birthdayUpcoming,
          payload: NotificationPayload.birthday(
            personId: 'person-9',
            ruleKind: ReminderRuleKind.daysBefore,
            occurrenceYear: 2025,
          ),
          title: 'Old title',
          body: 'Old body',
          hidesSensitivePreview: false,
        ),
      ];

      final result = planner.reconcile(current: current, desired: desired);

      expect(result.unchanged, hasLength(1));
      expect(result.toUpdate, hasLength(1));
      expect(result.toRemove, hasLength(1));
      expect(result.toAdd, isEmpty);
    });
  });
}
