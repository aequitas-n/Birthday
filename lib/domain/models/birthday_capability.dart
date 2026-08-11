import 'package:kin/domain/models/person.dart';
import 'package:meta/meta.dart';

/// Required 1:1 birthday capability for a [Person].
///
/// Physically inlined on `people`; exposed as a capability in domain code.
@immutable
class BirthdayCapability {
  const BirthdayCapability({
    required this.displayName,
    required this.date,
    this.location,
  });

  final String displayName;
  final PartialDate date;
  final LocationModel? location;

  BirthdayCapability copyWith({
    String? displayName,
    PartialDate? date,
    Object? location = _sentinel,
  }) {
    return BirthdayCapability(
      displayName: displayName ?? this.displayName,
      date: date ?? this.date,
      location: location == _sentinel
          ? this.location
          : location as LocationModel?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BirthdayCapability &&
        other.displayName == displayName &&
        other.date == date &&
        other.location == location;
  }

  @override
  int get hashCode => Object.hash(displayName, date, location);
}

const _sentinel = Object();
