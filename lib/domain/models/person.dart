import 'package:kin/domain/models/birthday_capability.dart';
import 'package:meta/meta.dart';

@immutable
class PartialDate {
  const PartialDate({required this.month, required this.day, this.year})
    : assert(month >= 1 && month <= 12, 'Month must be 1-12.'),
      assert(day >= 1 && day <= 31, 'Day must be 1-31.');

  final int month;
  final int day;
  final int? year;

  bool get hasKnownYear => year != null;

  PartialDate copyWith({int? month, int? day, Object? year = _sentinel}) {
    return PartialDate(
      month: month ?? this.month,
      day: day ?? this.day,
      year: year == _sentinel ? this.year : year as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PartialDate &&
        other.month == month &&
        other.day == day &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(month, day, year);
}

@immutable
class TimezoneModel {
  const TimezoneModel(this.ianaName)
    : assert(ianaName.length >= 3, 'Timezone must be non-empty.');

  final String ianaName;

  @override
  bool operator ==(Object other) =>
      other is TimezoneModel && other.ianaName == ianaName;

  @override
  int get hashCode => ianaName.hashCode;

  @override
  String toString() => ianaName;
}

@immutable
class LocationModel {
  const LocationModel({required this.label, this.timezone});

  final String label;
  final TimezoneModel? timezone;

  LocationModel copyWith({String? label, Object? timezone = _sentinel}) {
    return LocationModel(
      label: label ?? this.label,
      timezone: timezone == _sentinel
          ? this.timezone
          : timezone as TimezoneModel?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocationModel &&
        other.label == label &&
        other.timezone == timezone;
  }

  @override
  int get hashCode => Object.hash(label, timezone);
}

/// Durable root identity. Birthday is required; Profile is optional.
@immutable
class Person {
  const Person({
    required this.id,
    required this.displayName,
    required this.birthday,
    required this.sortKey,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.deletedAt,
    this.syncRev = 0,
  });

  final String id;
  final String displayName;
  final PartialDate birthday;
  final LocationModel? location;
  final String sortKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncRev;

  bool get isDeleted => deletedAt != null;

  /// Domain view of the required birthday capability (storage remains inlined).
  BirthdayCapability get birthdayCapability => BirthdayCapability(
    displayName: displayName,
    date: birthday,
    location: location,
  );

  Person copyWith({
    String? id,
    String? displayName,
    PartialDate? birthday,
    Object? location = _sentinel,
    String? sortKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? syncRev,
  }) {
    return Person(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      birthday: birthday ?? this.birthday,
      location: location == _sentinel
          ? this.location
          : location as LocationModel?,
      sortKey: sortKey ?? this.sortKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
      syncRev: syncRev ?? this.syncRev,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Person &&
        other.id == id &&
        other.displayName == displayName &&
        other.birthday == birthday &&
        other.location == location &&
        other.sortKey == sortKey &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.syncRev == syncRev;
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    birthday,
    location,
    sortKey,
    createdAt,
    updatedAt,
    deletedAt,
    syncRev,
  );
}

const _sentinel = Object();
