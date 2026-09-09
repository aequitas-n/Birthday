import 'package:flutter/foundation.dart';

/// Presentation cursor over an ordered memory list.
///
/// Does **not** reorder repository data — only tracks which entry sits on top
/// of a circular visual deck.
@immutable
final class JournalDeckCursor {
  const JournalDeckCursor({
    required this.length,
    this.front = 0,
  }) : assert(length >= 0, 'length must be non-negative'),
       assert(front >= 0, 'front must be non-negative');

  final int length;

  /// Index into the repository-ordered list for the top card.
  final int front;

  bool get isEmpty => length == 0;

  /// 1-based position for "1 of N".
  int get position => length == 0 ? 0 : front + 1;

  /// Repository index for the card at [depth] (0 = top).
  int indexAtDepth(int depth) {
    if (length == 0) return 0;
    return (front + depth) % length;
  }

  JournalDeckCursor advance() {
    if (length <= 1) return this;
    return JournalDeckCursor(length: length, front: (front + 1) % length);
  }

  JournalDeckCursor retreat() {
    if (length <= 1) return this;
    return JournalDeckCursor(
      length: length,
      front: (front - 1 + length) % length,
    );
  }

  JournalDeckCursor withLength(int nextLength) {
    if (nextLength <= 0) {
      return const JournalDeckCursor(length: 0);
    }
    return JournalDeckCursor(
      length: nextLength,
      front: front % nextLength,
    );
  }
}
