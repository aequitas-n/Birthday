import 'package:meta/meta.dart';

enum RelationshipKind {
  sister,
  brother,
  mother,
  father,
  child,
  partner,
  spouse,
  friend,
  colleague,
  family,
  other;

  static RelationshipKind? fromStorage(String? value) {
    if (value == null || value.isEmpty) return null;
    // Legacy V1 stored a single "parent" kind before Mother/Father split.
    if (value == 'parent') return RelationshipKind.family;
    return values.firstWhere(
      (entry) => entry.name == value,
      orElse: () => RelationshipKind.other,
    );
  }
}

/// Optional 0:1 relationship profile capability for a Person.
@immutable
class RelationshipProfile {
  const RelationshipProfile({
    required this.id,
    required this.personId,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.relationship,
    this.relationshipLabel,
    this.photoId,
    this.isPinned = false,
    this.deletedAt,
    this.syncRev = 0,
  });

  final String id;
  final String personId;
  final String? nickname;
  final RelationshipKind? relationship;
  final String? relationshipLabel;
  final String? photoId;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncRev;

  bool get isDeleted => deletedAt != null;

  String get relationshipDisplayLabel {
    if (relationship == RelationshipKind.other &&
        relationshipLabel != null &&
        relationshipLabel!.trim().isNotEmpty) {
      return relationshipLabel!.trim();
    }
    return switch (relationship) {
      RelationshipKind.sister => 'Sister',
      RelationshipKind.brother => 'Brother',
      RelationshipKind.mother => 'Mother',
      RelationshipKind.father => 'Father',
      RelationshipKind.child => 'Child',
      RelationshipKind.partner => 'Partner',
      RelationshipKind.spouse => 'Spouse',
      RelationshipKind.friend => 'Friend',
      RelationshipKind.colleague => 'Colleague',
      RelationshipKind.family => 'Family',
      RelationshipKind.other => 'Other',
      null => '',
    };
  }

  RelationshipProfile copyWith({
    String? id,
    String? personId,
    Object? nickname = _sentinel,
    Object? relationship = _sentinel,
    Object? relationshipLabel = _sentinel,
    Object? photoId = _sentinel,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
    int? syncRev,
  }) {
    return RelationshipProfile(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      nickname: nickname == _sentinel ? this.nickname : nickname as String?,
      relationship: relationship == _sentinel
          ? this.relationship
          : relationship as RelationshipKind?,
      relationshipLabel: relationshipLabel == _sentinel
          ? this.relationshipLabel
          : relationshipLabel as String?,
      photoId: photoId == _sentinel ? this.photoId : photoId as String?,
      isPinned: isPinned ?? this.isPinned,
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
    return other is RelationshipProfile &&
        other.id == id &&
        other.personId == personId &&
        other.nickname == nickname &&
        other.relationship == relationship &&
        other.relationshipLabel == relationshipLabel &&
        other.photoId == photoId &&
        other.isPinned == isPinned &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt &&
        other.syncRev == syncRev;
  }

  @override
  int get hashCode => Object.hash(
    id,
    personId,
    nickname,
    relationship,
    relationshipLabel,
    photoId,
    isPinned,
    createdAt,
    updatedAt,
    deletedAt,
    syncRev,
  );
}

const _sentinel = Object();
