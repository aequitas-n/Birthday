import 'package:kin/domain/models/journal_fragment.dart';

/// Pure list operations for ordered memory fragments.
///
/// Positions are always dense `0..n-1`. UI and repository share this so
/// composition order cannot drift from ad-hoc arithmetic.
abstract final class JournalFragmentOps {
  static List<JournalFragment> normalizePositions(
    Iterable<JournalFragment> fragments,
  ) {
    final list = fragments.toList(growable: false);
    return [
      for (var i = 0; i < list.length; i++) list[i].copyWith(position: i),
    ];
  }

  static List<JournalFragment> insertAt(
    List<JournalFragment> fragments,
    int index,
    JournalFragment fragment,
  ) {
    final next = List<JournalFragment>.of(fragments);
    final clamped = index.clamp(0, next.length);
    next.insert(clamped, fragment);
    return normalizePositions(next);
  }

  static List<JournalFragment> removeAt(
    List<JournalFragment> fragments,
    int index,
  ) {
    if (index < 0 || index >= fragments.length) {
      return normalizePositions(fragments);
    }
    final next = List<JournalFragment>.of(fragments)..removeAt(index);
    return normalizePositions(next);
  }

  static List<JournalFragment> removeById(
    List<JournalFragment> fragments,
    String id,
  ) {
    final next = [
      for (final fragment in fragments)
        if (fragment.id != id) fragment,
    ];
    return normalizePositions(next);
  }

  /// Swap neighbor toward the start of the memory (`index` with `index - 1`).
  static List<JournalFragment> moveUp(
    List<JournalFragment> fragments,
    int index,
  ) {
    if (index <= 0 || index >= fragments.length) {
      return normalizePositions(fragments);
    }
    return moveTo(fragments, index, index - 1);
  }

  /// Swap neighbor toward the end of the memory (`index` with `index + 1`).
  static List<JournalFragment> moveDown(
    List<JournalFragment> fragments,
    int index,
  ) {
    if (index < 0 || index >= fragments.length - 1) {
      return normalizePositions(fragments);
    }
    return moveTo(fragments, index, index + 1);
  }

  static List<JournalFragment> moveTo(
    List<JournalFragment> fragments,
    int from,
    int to,
  ) {
    if (from < 0 ||
        from >= fragments.length ||
        to < 0 ||
        to >= fragments.length ||
        from == to) {
      return normalizePositions(fragments);
    }
    final next = List<JournalFragment>.of(fragments);
    final item = next.removeAt(from);
    next.insert(to, item);
    return normalizePositions(next);
  }
}
