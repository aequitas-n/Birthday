import 'package:flutter/foundation.dart';
import 'package:kin/design/components/journal/q_journal_fragment.dart';

/// Deterministic layout variation for a journal day archive.
///
/// Controlled asymmetry — not random scrapbook chaos. Same inputs always
/// produce the same composition after rebuild, navigation, and restart.
@immutable
final class JournalFragmentLayout {
  /// Resolves layout for one entry in a day collection.
  factory JournalFragmentLayout.resolve({
    required String entryId,
    required int position,
    required String dateKey,
    required bool hasPhotos,
    int bodyLength = 0,
    String? title,
  }) {
    final seed = _stableHash('$dateKey|$entryId|$position');
    final titleLen = title?.length ?? 0;

    final kind = hasPhotos
        ? QJournalFragmentKind.photoPrint
        : _resolveKind(seed: seed, bodyLength: bodyLength, titleLen: titleLen);

    // Rotation kept subtle (± ~2.5°). Photos get even less.
    final rotBucket = (seed >> 3) % 5;
    final rotation = hasPhotos
        ? (rotBucket - 2) * 0.008
        : (rotBucket - 2) * 0.014;

    // Width extremes: short scraps narrower; long manuscript fuller.
    final widthBucket = (seed >> 6) % 6;
    var widthFactor = 0.72 + widthBucket * 0.045;
    if (bodyLength > 180) widthFactor = widthFactor.clamp(0.88, 1.0);
    if (bodyLength < 40 && !hasPhotos) {
      widthFactor = widthFactor.clamp(0.68, 0.86);
    }

    final gapBucket = (seed >> 9) % 5;
    final topGap = 12.0 + gapBucket * 8.0;

    // Alternate leading / trailing bias for intentional asymmetry.
    final alignBucket = (seed >> 12) % 4;
    final leadingInset = switch (alignBucket) {
      0 => 0.0,
      1 => 12.0,
      2 => 28.0,
      _ => 8.0,
    };
    final trailingInset = switch (alignBucket) {
      0 => 16.0,
      1 => 0.0,
      2 => 4.0,
      _ => 24.0,
    };

    final showTape =
        !hasPhotos &&
        (kind == QJournalFragmentKind.scrap || (seed >> 15) % 5 == 0);
    final showClip =
        !hasPhotos &&
        kind == QJournalFragmentKind.diary &&
        (seed >> 17) % 3 == 0;

    return JournalFragmentLayout._(
      kind: kind,
      rotation: rotation,
      widthFactor: widthFactor.clamp(0.68, 1.0),
      topGap: topGap,
      leadingInset: leadingInset,
      trailingInset: trailingInset,
      showTape: showTape,
      showClip: showClip,
      seed: seed,
    );
  }

  const JournalFragmentLayout._({
    required this.kind,
    required this.rotation,
    required this.widthFactor,
    required this.topGap,
    required this.leadingInset,
    required this.trailingInset,
    required this.showTape,
    required this.showClip,
    required this.seed,
  });

  final QJournalFragmentKind kind;
  final double rotation;
  final double widthFactor;
  final double topGap;
  final double leadingInset;
  final double trailingInset;
  final bool showTape;
  final bool showClip;
  final int seed;

  static QJournalFragmentKind _resolveKind({
    required int seed,
    required int bodyLength,
    required int titleLen,
  }) {
    if (bodyLength > 220) return QJournalFragmentKind.document;
    if (bodyLength < 50 && titleLen < 28) {
      return seed.isEven
          ? QJournalFragmentKind.scrap
          : QJournalFragmentKind.typewritten;
    }
    const kinds = <QJournalFragmentKind>[
      QJournalFragmentKind.typewritten,
      QJournalFragmentKind.diary,
      QJournalFragmentKind.scrap,
      QJournalFragmentKind.typewritten,
      QJournalFragmentKind.document,
    ];
    return kinds[seed % kinds.length];
  }

  /// Stable non-cryptographic hash for layout seeding.
  static int _stableHash(String input) {
    var hash = 0x811c9dc5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}

/// Deterministic photo print rotation from photo id + position.
double journalPhotoRotation({
  required String photoId,
  required int position,
}) {
  final seed = JournalFragmentLayout._stableHash('$photoId|$position');
  final bucket = seed % 5;
  return (bucket - 2) * 0.012;
}
