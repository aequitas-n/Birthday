import 'package:meta/meta.dart';

@immutable
class BirthdayOccurrence {
  const BirthdayOccurrence({
    required this.occurrenceYear,
    required this.anchorUtc,
    required this.personLocalStart,
    required this.deviceLocalEquivalent,
    required this.personTimeZone,
    required this.deviceTimeZone,
    required this.ageTurning,
  });

  final int occurrenceYear;
  final DateTime anchorUtc;
  final DateTime personLocalStart;
  final DateTime deviceLocalEquivalent;
  final String personTimeZone;
  final String deviceTimeZone;
  final int? ageTurning;

  BirthdayOccurrence copyWith({
    int? occurrenceYear,
    DateTime? anchorUtc,
    DateTime? personLocalStart,
    DateTime? deviceLocalEquivalent,
    String? personTimeZone,
    String? deviceTimeZone,
    Object? ageTurning = _sentinel,
  }) {
    return BirthdayOccurrence(
      occurrenceYear: occurrenceYear ?? this.occurrenceYear,
      anchorUtc: anchorUtc ?? this.anchorUtc,
      personLocalStart: personLocalStart ?? this.personLocalStart,
      deviceLocalEquivalent:
          deviceLocalEquivalent ?? this.deviceLocalEquivalent,
      personTimeZone: personTimeZone ?? this.personTimeZone,
      deviceTimeZone: deviceTimeZone ?? this.deviceTimeZone,
      ageTurning: ageTurning == _sentinel
          ? this.ageTurning
          : ageTurning as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BirthdayOccurrence &&
        other.occurrenceYear == occurrenceYear &&
        other.anchorUtc == anchorUtc &&
        other.personLocalStart == personLocalStart &&
        other.deviceLocalEquivalent == deviceLocalEquivalent &&
        other.personTimeZone == personTimeZone &&
        other.deviceTimeZone == deviceTimeZone &&
        other.ageTurning == ageTurning;
  }

  @override
  int get hashCode => Object.hash(
    occurrenceYear,
    anchorUtc,
    personLocalStart,
    deviceLocalEquivalent,
    personTimeZone,
    deviceTimeZone,
    ageTurning,
  );
}

const _sentinel = Object();
