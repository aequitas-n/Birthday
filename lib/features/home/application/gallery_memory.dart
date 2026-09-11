import 'package:kin/domain/models/note.dart';

/// Memory metadata for a relationship gallery card.
class GalleryMemorySummary {
  const GalleryMemorySummary._({
    required this.count,
    this.latestPreview,
    this.latestAt,
    this.notePreview,
    this.momentPreview,
  });

  factory GalleryMemorySummary.fromNotes(List<Note> notes) {
    if (notes.isEmpty) return const GalleryMemorySummary._(count: 0);

    final sorted = [...notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final latest = sorted.first;

    final notesOnly = sorted.where((n) => !n.isPhotoMemory).toList();
    final momentsOnly = sorted.where((n) => n.isPhotoMemory).toList();

    return GalleryMemorySummary._(
      count: notes.length,
      latestPreview: _previewFor(latest),
      latestAt: latest.updatedAt,
      notePreview: notesOnly.isEmpty ? null : _previewFor(notesOnly.first),
      momentPreview:
          momentsOnly.isEmpty ? null : _momentPreview(momentsOnly.first),
    );
  }

  final int count;
  final String? latestPreview;
  final DateTime? latestAt;

  /// Latest non-photo note preview (relationship detail).
  final String? notePreview;

  /// Latest photo-memory caption or a short fallback.
  final String? momentPreview;

  bool get hasMemories => count > 0;

  bool get hasLatestPreview {
    final preview = latestPreview?.trim();
    return preview != null && preview.isNotEmpty;
  }

  bool get hasNote {
    final preview = notePreview?.trim();
    return preview != null && preview.isNotEmpty;
  }

  bool get hasMoment {
    final preview = momentPreview?.trim();
    return preview != null && preview.isNotEmpty;
  }

  String countLabel() => count == 1 ? '1 memory' : '$count memories';

  String? relativeLatestLabel(DateTime now) {
    final at = latestAt;
    if (at == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final then = DateTime(at.year, at.month, at.day);
    final days = today.difference(then).inDays;
    return switch (days) {
      0 => 'Today',
      1 => '1 day ago',
      _ => '$days days ago',
    };
  }
}

String? _previewFor(Note note) {
  if (note.isPhotoMemory) return note.caption;
  final value = note.value.trim();
  if (value.isEmpty) return null;
  final kind = _noteKindLabel(note);
  if (kind == null) return value;
  return '$value — $kind';
}

/// Kind cue for a relationship detail preview (omitted for bare free notes).
String? _noteKindLabel(Note note) {
  return switch (note.kind) {
    NoteKind.photo || NoteKind.free => null,
    NoteKind.custom => () {
      final custom = note.label?.trim();
      if (custom != null && custom.isNotEmpty) return custom;
      return 'Something else';
    }(),
    NoteKind.flower => 'Favorite flower',
    NoteKind.colour => 'Favorite color',
    NoteKind.food => 'Favorite food',
    NoteKind.dessert => 'Favorite dessert',
    NoteKind.drink => 'Favorite drink',
    NoteKind.movie => 'Favorite movie',
    NoteKind.music => 'Favorite music',
    NoteKind.restaurant => 'Favorite restaurant',
    NoteKind.place => 'Favorite place',
    NoteKind.giftIdea => 'Gift idea',
    NoteKind.plan => 'Plan',
    NoteKind.importantDate => 'Important date',
  };
}

String _momentPreview(Note note) {
  final caption = note.caption?.trim();
  if (caption != null && caption.isNotEmpty) return caption;
  return 'A moment';
}
