import 'package:meta/meta.dart';

enum NoteKind {
  flower,
  colour,
  food,
  dessert,
  drink,
  movie,
  music,
  restaurant,
  giftIdea,
  /// Something you want to do *for* or *with* them — a trip, a café, a surprise.
  /// Distinct from favorites (about them) and gift ideas (things to give).
  plan,
  /// A place they love — a beach, a city, a neighbourhood. Not a restaurant.
  place,
  importantDate,
  free,
  custom,
  /// A photograph saved as a memory. [Note.value] holds the photos.id;
  /// [Note.label] is an optional caption.
  photo
  ;

  static NoteKind fromStorage(String value) {
    return switch (value) {
      'gift_idea' => NoteKind.giftIdea,
      'important_date' => NoteKind.importantDate,
      'free' => NoteKind.free,
      'custom' => NoteKind.custom,
      'photo' => NoteKind.photo,
      'plan' => NoteKind.plan,
      'place' => NoteKind.place,
      // Legacy: coffee used to be its own kind; treat as drink going forward.
      'coffee' => NoteKind.drink,
      _ => values.firstWhere((entry) => entry.name == value),
    };
  }

  String get storageValue => switch (this) {
    NoteKind.giftIdea => 'gift_idea',
    NoteKind.importantDate => 'important_date',
    NoteKind.free => 'free',
    NoteKind.custom => 'custom',
    NoteKind.photo => 'photo',
    NoteKind.plan => 'plan',
    NoteKind.place => 'place',
    _ => name,
  };
}

@immutable
class Note {
  const Note({
    required this.id,
    required this.profileId,
    required this.kind,
    required this.value,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.label,
    this.isRetired = false,
    this.deletedAt,
    this.syncRev = 0,
  });

  final String id;
  final String profileId;
  final NoteKind kind;
  final String? label;
  final String value;
  final bool isRetired;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncRev;

  bool get isPhotoMemory => kind == NoteKind.photo;

  /// Content-hash id into `photos` when [isPhotoMemory].
  String? get photoId => isPhotoMemory ? value : null;

  String? get caption {
    final text = label?.trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  /// Free-form "when they said this" line for [NoteKind.free], if set.
  ///
  /// Stored in [label] as `date\\u001Ftime` (either part may be empty).
  String? get rememberedWhenDisplay {
    if (kind != NoteKind.free) return null;
    return formatRememberedWhen(label);
  }

  /// Pack typed date/time into the free-note label slot. Null if both blank.
  static String? encodeRememberedWhen({String? date, String? time}) {
    final d = date?.trim() ?? '';
    final t = time?.trim() ?? '';
    if (d.isEmpty && t.isEmpty) return null;
    return '$d$_whenSep$t';
  }

  static (String?, String?) decodeRememberedWhen(String? raw) {
    if (raw == null || raw.isEmpty) return (null, null);
    final parts = raw.split(_whenSep);
    if (parts.length == 1) {
      final only = parts[0].trim();
      return only.isEmpty ? (null, null) : (only, null);
    }
    final date = parts[0].trim();
    final time = parts.sublist(1).join(_whenSep).trim();
    return (
      date.isEmpty ? null : date,
      time.isEmpty ? null : time,
    );
  }

  static String? formatRememberedWhen(String? raw) {
    final (date, time) = decodeRememberedWhen(raw);
    if (date != null && time != null) return '$date · $time';
    return date ?? time;
  }

  Note copyWith({
    String? id,
    String? profileId,
    NoteKind? kind,
    Object? label = _sentinel,
    String? value,
    bool? isRetired,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? syncRev,
  }) {
    return Note(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      kind: kind ?? this.kind,
      label: label == _sentinel ? this.label : label as String?,
      value: value ?? this.value,
      isRetired: isRetired ?? this.isRetired,
      position: position ?? this.position,
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
    return other is Note &&
        other.id == id &&
        other.profileId == profileId &&
        other.kind == kind &&
        other.label == label &&
        other.value == value &&
        other.isRetired == isRetired &&
        other.position == position &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.syncRev == syncRev;
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    kind,
    label,
    value,
    isRetired,
    position,
    createdAt,
    updatedAt,
    deletedAt,
    syncRev,
  );
}

const _sentinel = Object();

/// Separates typed date and time inside a free note's label.
const _whenSep = '\u001F';
