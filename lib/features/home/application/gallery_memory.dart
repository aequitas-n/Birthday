import 'package:kin/domain/models/note.dart';

/// Memory metadata for a relationship gallery card.
class GalleryMemorySummary {
  const GalleryMemorySummary._({
    required this.count,
    this.latestPreview,
    this.latestAt,
  });

  factory GalleryMemorySummary.fromNotes(List<Note> notes) {
    if (notes.isEmpty) return const GalleryMemorySummary._(count: 0);

    final sorted = [...notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final latest = sorted.first;
    return GalleryMemorySummary._(
      count: notes.length,
      latestPreview: _previewFor(latest),
      latestAt: latest.updatedAt,
    );
  }

  final int count;
  final String? latestPreview;
  final DateTime? latestAt;

  bool get hasMemories => count > 0;

  bool get hasLatestPreview {
    final preview = latestPreview?.trim();
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
  return value.isEmpty ? null : value;
}
