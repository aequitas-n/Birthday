import 'dart:convert';

import 'package:meta/meta.dart';

/// How a piece of a memory is expressed.
///
/// Kept as a closed set on purpose — this is not a generic block editor.
enum JournalFragmentKind {
  writing,
  list,
  photograph,
  audio;

  static JournalFragmentKind fromStorage(String value) {
    return switch (value) {
      'writing' => JournalFragmentKind.writing,
      'list' => JournalFragmentKind.list,
      'photograph' => JournalFragmentKind.photograph,
      'audio' => JournalFragmentKind.audio,
      _ => JournalFragmentKind.writing,
    };
  }

  String get storageValue => name;
}

/// One ordered piece inside a journal memory.
@immutable
class JournalFragment {
  const JournalFragment({
    required this.id,
    required this.entryId,
    required this.kind,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.textBody,
    this.photoId,
    this.caption,
    this.audioRelPath,
    this.audioDurationMs,
    this.deletedAt,
  });

  final String id;
  final String entryId;
  final JournalFragmentKind kind;
  final int position;

  /// Writing prose, or JSON array of list item strings for list fragments.
  final String? textBody;

  /// Shared `photos.id` for photograph fragments.
  final String? photoId;
  final String? caption;

  /// App-documents-relative path for audio fragments (see Journal audio module).
  final String? audioRelPath;
  final int? audioDurationMs;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  List<String> get listItems {
    if (kind != JournalFragmentKind.list) return const [];
    return decodeListItems(textBody);
  }

  static String encodeListItems(List<String> items) {
    final cleaned = [
      for (final item in items)
        if (item.trim().isNotEmpty) item.trim(),
    ];
    return jsonEncode(cleaned);
  }

  static List<String> decodeListItems(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final item in decoded)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ];
    } on Object {
      // Legacy / pasted plain text — one item per line.
      return [
        for (final line in raw.split('\n'))
          if (line.trim().isNotEmpty) line.trim(),
      ];
    }
  }

  /// Flatten writing (+ list bullets) for denormalized entry body preview.
  static String previewBodyFrom(Iterable<JournalFragment> fragments) {
    final parts = <String>[];
    for (final fragment in fragments) {
      switch (fragment.kind) {
        case JournalFragmentKind.writing:
          final text = fragment.textBody?.trim();
          if (text != null && text.isNotEmpty) parts.add(text);
        case JournalFragmentKind.list:
          final items = fragment.listItems;
          if (items.isNotEmpty) {
            parts.add(items.map((item) => '• $item').join('\n'));
          }
        case JournalFragmentKind.photograph:
        case JournalFragmentKind.audio:
          break;
      }
    }
    return parts.join('\n\n');
  }

  JournalFragment copyWith({
    String? id,
    String? entryId,
    JournalFragmentKind? kind,
    int? position,
    Object? textBody = _sentinel,
    Object? photoId = _sentinel,
    Object? caption = _sentinel,
    Object? audioRelPath = _sentinel,
    Object? audioDurationMs = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _sentinel,
  }) {
    return JournalFragment(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      kind: kind ?? this.kind,
      position: position ?? this.position,
      textBody: textBody == _sentinel ? this.textBody : textBody as String?,
      photoId: photoId == _sentinel ? this.photoId : photoId as String?,
      caption: caption == _sentinel ? this.caption : caption as String?,
      audioRelPath: audioRelPath == _sentinel
          ? this.audioRelPath
          : audioRelPath as String?,
      audioDurationMs: audioDurationMs == _sentinel
          ? this.audioDurationMs
          : audioDurationMs as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == _sentinel
          ? this.deletedAt
          : deletedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is JournalFragment &&
        other.id == id &&
        other.entryId == entryId &&
        other.kind == kind &&
        other.position == position &&
        other.textBody == textBody &&
        other.photoId == photoId &&
        other.caption == caption &&
        other.audioRelPath == audioRelPath &&
        other.audioDurationMs == audioDurationMs &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    entryId,
    kind,
    position,
    textBody,
    photoId,
    caption,
    audioRelPath,
    audioDurationMs,
    createdAt,
    updatedAt,
    deletedAt,
  );
}

const _sentinel = Object();
