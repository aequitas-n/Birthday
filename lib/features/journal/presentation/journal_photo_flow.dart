import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' show PhotosCompanion;
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_entry_photo.dart';
import 'package:kin/domain/models/journal_fragment.dart';

/// Draft photograph before it is persisted to the shared image store.
class JournalPhotoDraft {
  const JournalPhotoDraft({
    required this.bytes,
    required this.width,
    required this.height,
    this.caption,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final String? caption;

  JournalPhotoDraft copyWith({String? caption}) {
    return JournalPhotoDraft(
      bytes: bytes,
      width: width,
      height: height,
      caption: caption ?? this.caption,
    );
  }
}

/// Pick one photo from camera or library and normalize for journal storage.
Future<JournalPhotoDraft?> pickJournalPhotoDraft(BuildContext context) async {
  final source = await _choosePhotoSource(context);
  if (source == null) return null;
  return _pickDraft(source);
}

Future<ImageSource?> _choosePhotoSource(BuildContext context) async {
  final choice = await showQChoiceSheet(
    context: context,
    title: 'Add a photograph',
    choices: const [
      QChoice('Take a photo'),
      QChoice('Choose from library'),
    ],
  );
  return switch (choice) {
    0 => ImageSource.camera,
    1 => ImageSource.gallery,
    _ => null,
  };
}

Future<JournalPhotoDraft?> _pickDraft(ImageSource source) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: source,
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 92,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final normalized = _normalize(decoded);
  return JournalPhotoDraft(
    bytes: Uint8List.fromList(img.encodeJpg(normalized, quality: 85)),
    width: normalized.width,
    height: normalized.height,
  );
}

img.Image _normalize(img.Image image) {
  final longest = image.width > image.height ? image.width : image.height;
  if (longest <= 1024) return image;
  final scale = 1024 / longest;
  return img.copyResize(
    image,
    width: (image.width * scale).round(),
    height: (image.height * scale).round(),
    interpolation: img.Interpolation.average,
  );
}

/// Persist bytes to the shared image store + `photos` table (no personId).
Future<String> persistJournalPhoto({
  required WidgetRef ref,
  required JournalPhotoDraft draft,
  required DateTime now,
}) async {
  final write = await ref.read(imageStoreProvider).putJpeg(draft.bytes);
  await ref
      .read(kinDatabaseProvider)
      .into(ref.read(kinDatabaseProvider).photos)
      .insertOnConflictUpdate(
        PhotosCompanion.insert(
          id: write.id,
          personId: const Value(null),
          relPath: write.relativePath,
          width: draft.width,
          height: draft.height,
          bytes: write.bytes,
          createdAt: now.toUtc().millisecondsSinceEpoch,
        ),
      );
  return write.id;
}

/// Attach a draft as a photograph fragment for an existing memory.
///
/// Composition source of truth is JournalFragment. Legacy
/// JournalEntryPhoto rows are synced inside JournalRepository.saveMemory.
Future<JournalFragment> attachJournalPhotographFragment({
  required WidgetRef ref,
  required JournalEntry entry,
  required List<JournalFragment> existingFragments,
  required JournalPhotoDraft draft,
}) async {
  final now = ref.read(clockProvider).now();
  final photoId = await persistJournalPhoto(ref: ref, draft: draft, now: now);
  QuietHaptics.commit();
  final next = [
    ...existingFragments,
    JournalFragment(
      id: '',
      entryId: entry.id,
      kind: JournalFragmentKind.photograph,
      position: existingFragments.length,
      photoId: photoId,
      caption: draft.caption,
      createdAt: now,
      updatedAt: now,
    ),
  ];
  await ref
      .read(journalRepositoryProvider)
      .saveMemory(
        entry: entry,
        fragments: next,
      );
  final saved = await ref
      .read(journalRepositoryProvider)
      .watchFragmentsForEntry(entry.id)
      .first;
  return saved.last;
}

/// Deprecated dual-write path. Prefer [attachJournalPhotographFragment].
@Deprecated('Use attachJournalPhotographFragment — fragments are authoritative')
Future<JournalEntryPhoto> attachJournalPhoto({
  required WidgetRef ref,
  required String entryId,
  required JournalPhotoDraft draft,
  required int position,
}) async {
  final now = ref.read(clockProvider).now();
  final photoId = await persistJournalPhoto(ref: ref, draft: draft, now: now);
  QuietHaptics.commit();
  return ref
      .read(journalRepositoryProvider)
      .saveEntryPhoto(
        JournalEntryPhoto(
          id: '',
          entryId: entryId,
          photoId: photoId,
          caption: draft.caption,
          position: position,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

/// Resolve a shared photo id to an [ImageProvider] for Journal UI.
Future<ImageProvider?> resolveJournalPhoto(
  WidgetRef ref,
  String photoId,
) async {
  if (photoId.isEmpty) return null;
  final database = ref.read(kinDatabaseProvider);
  final row =
      await (database.select(database.photos)
            ..where((tbl) => tbl.id.equals(photoId))
            ..where((tbl) => tbl.deletedAt.isNull()))
          .getSingleOrNull();
  if (row == null) return null;
  final file = await ref.read(imageStoreProvider).resolve(row.relPath);
  return FileImage(File(file.path));
}
