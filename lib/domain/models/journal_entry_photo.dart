import 'package:meta/meta.dart';

/// A photograph attached to a journal entry.
///
/// [photoId] references the shared `photos` table — image bytes are not stored
/// in the journal tables.
@immutable
class JournalEntryPhoto {
  const JournalEntryPhoto({
    required this.id,
    required this.entryId,
    required this.photoId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.caption,
    this.deletedAt,
  });

  final String id;
  final String entryId;
  final String photoId;
  final String? caption;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  JournalEntryPhoto copyWith({
    String? id,
    String? entryId,
    String? photoId,
    Object? caption = _sentinel,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
  }) {
    return JournalEntryPhoto(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      photoId: photoId ?? this.photoId,
      caption: caption == _sentinel ? this.caption : caption as String?,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalEntryPhoto &&
        other.id == id &&
        other.entryId == entryId &&
        other.photoId == photoId &&
        other.caption == caption &&
        other.position == position &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    photoId,
    caption,
    position,
    createdAt,
    updatedAt,
    deletedAt,
  );
}

const _sentinel = Object();
