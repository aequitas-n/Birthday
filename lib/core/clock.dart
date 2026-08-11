import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable time source.
///
/// The architecture guard bans direct `DateTime.now()` calls everywhere else so
/// timezone and migration tests can pin time deterministically.
class Clock {
  const Clock();

  DateTime now() => DateTime.now().toUtc();
}

final clockProvider = Provider<Clock>((ref) => const Clock());
