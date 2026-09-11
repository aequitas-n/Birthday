import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' show PhotosCompanion;
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

/// Pick a camera/library photo, optional caption, save as a photo memory.
Future<Note?> addPhotoMemory({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  required int nextPosition,
  RelationshipProfile? profile,
}) async {
  final source = await _choosePhotoSource(context);
  if (source == null || !context.mounted) return null;

  final draft = await _pickDraft(source);
  if (draft == null || !context.mounted) return null;

  final caption = await _askCaption(context, draft: draft);
  if (!context.mounted) return null;
  // null = dismissed without Skip/Save; empty string = Skip.
  if (caption == null) return null;

  final ensured = await ensureProfileForPerson(ref, person, profile);
  final now = ref.read(clockProvider).now();
  final photoId = await _persistPhoto(
    ref: ref,
    personId: person.id,
    draft: draft,
    now: now,
  );

  final trimmed = caption.trim();
  final note = await ref
      .read(noteRepositoryProvider)
      .save(
        Note(
          id: '',
          profileId: ensured.id,
          kind: NoteKind.photo,
          value: photoId,
          label: trimmed.isEmpty ? null : trimmed,
          position: nextPosition,
          createdAt: now,
          updatedAt: now,
        ),
      );
  QuietHaptics.commit();
  return note;
}

Future<RelationshipProfile> ensureProfileForPerson(
  WidgetRef ref,
  Person person,
  RelationshipProfile? existing,
) async {
  if (existing != null) return existing;
  final now = ref.read(clockProvider).now();
  return ref
      .read(profileRepositoryProvider)
      .save(
        RelationshipProfile(
          id: '',
          personId: person.id,
          createdAt: now,
          updatedAt: now,
        ),
      );
}

Future<void> showPhotoMemoryReview({
  required BuildContext context,
  required ImageProvider photo,
  String? caption,
  String? displayName,
}) {
  QuietHaptics.open();
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      // Solid page — a translucent scrim left the gallery grid peeking
      // through around the contained photo.
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _PhotoMemoryReview(
            photo: photo,
            caption: caption,
            displayName: displayName,
          ),
        );
      },
    ),
  );
}

/// Full Moments section — every photo memory, newest first.
Future<void> showMomentsGallery({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  required List<Note> photos,
  required String displayName,
  RelationshipProfile? profile,
}) {
  QuietHaptics.open();
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _MomentsGalleryScreen(
            person: person,
            photos: photos,
            displayName: displayName,
            profile: profile,
          ),
        );
      },
    ),
  );
}

Future<ImageSource?> _choosePhotoSource(BuildContext context) async {
  final choice = await showQChoiceSheet(
    context: context,
    title: 'Save a photo',
    choices: const [
      QChoice('Take a photo', support: 'A moment you want to keep.'),
      QChoice('Choose from library'),
    ],
  );
  return switch (choice) {
    0 => ImageSource.camera,
    1 => ImageSource.gallery,
    _ => null,
  };
}

/// Returns caption text, empty string when skipped, or null when dismissed.
Future<String?> _askCaption(BuildContext context, {required _Draft draft}) {
  return showQSheet<String>(
    context: context,
    builder: (context) => _CaptionSheet(draft: draft),
  );
}

Future<_Draft?> _pickDraft(ImageSource source) async {
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
  return _Draft(
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

Future<String> _persistPhoto({
  required WidgetRef ref,
  required String personId,
  required _Draft draft,
  required DateTime now,
}) async {
  final write = await ref.read(imageStoreProvider).putJpeg(draft.bytes);
  await ref
      .read(kinDatabaseProvider)
      .into(ref.read(kinDatabaseProvider).photos)
      .insertOnConflictUpdate(
        PhotosCompanion.insert(
          id: write.id,
          personId: Value(personId),
          relPath: write.relativePath,
          width: draft.width,
          height: draft.height,
          bytes: write.bytes,
          createdAt: now.toUtc().millisecondsSinceEpoch,
        ),
      );
  return write.id;
}

class _Draft {
  const _Draft({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

class _CaptionSheet extends StatefulWidget {
  const _CaptionSheet({required this.draft});

  final _Draft draft;

  @override
  State<_CaptionSheet> createState() => _CaptionSheetState();
}

class _CaptionSheetState extends State<_CaptionSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return QSheet(
      title: 'Add a caption',
      bottom: QBottomActions(
        children: [
          QButton.tertiary(
            label: 'Skip',
            onPressed: () => Navigator.of(context).pop(''),
          ),
          QButton.primary(
            label: 'Save',
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
      // Scroll when the keyboard eats the sheet — otherwise the preview +
      // field overflow and paint over Skip / Save.
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QClip(
              radius: q.radius.lg,
              child: AspectRatio(
                // Shorter preview while typing so the field stays in view.
                aspectRatio: keyboardOpen ? 16 / 9 : 4 / 3,
                child: Image.memory(
                  widget.draft.bytes,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            SizedBox(height: q.space.xl),
            QField(
              controller: _controller,
              label: 'Caption',
              placeholder: 'What do you want to remember about this?',
              maxLines: 3,
              autofocus: true,
            ),
            SizedBox(height: q.space.md),
          ],
        ),
      ),
    );
  }
}

class _PhotoMemoryReview extends StatelessWidget {
  const _PhotoMemoryReview({
    required this.photo,
    this.caption,
    this.displayName,
  });

  final ImageProvider photo;
  final String? caption;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return ColoredBox(
      color: q.color.canvas,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(q.space.xl),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: QClip(
                          radius: q.radius.xl,
                          child: Image(
                            image: QuietDisplayImage.at(
                              photo,
                              context: context,
                              logicalWidth: constraints.maxWidth,
                              logicalHeight: constraints.maxHeight,
                            ),
                            fit: BoxFit.contain,
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            gaplessPlayback: true,
                            excludeFromSemantics: true,
                            errorBuilder: (context, error, stack) => SizedBox(
                              width: constraints.maxWidth * 0.5,
                              height: constraints.maxWidth * 0.5,
                              child: ColoredBox(
                                color: q.color.surface,
                                child: Center(
                                  child: Text(
                                    displayName ?? 'Memory',
                                    style: q.text.body.tinted(
                                      q.color.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (caption != null && caption!.isNotEmpty) ...[
                  SizedBox(height: q.space.xl),
                  Text(
                    caption!,
                    textAlign: TextAlign.center,
                    style: q.text.voiceMd.tinted(q.color.textPrimary),
                  ),
                ],
                SizedBox(height: q.space.md),
                Text(
                  'Tap to close',
                  style: q.text.metadata.tinted(q.color.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MomentsGalleryScreen extends ConsumerWidget {
  const _MomentsGalleryScreen({
    required this.person,
    required this.photos,
    required this.displayName,
    this.profile,
  });

  final Person person;
  final List<Note> photos;
  final String displayName;
  final RelationshipProfile? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final live =
        (ref.watch(personNotesProvider(person.id)).asData?.value ?? photos)
            .where((n) => n.isPhotoMemory)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: q.space.sm),
              child: Row(
                children: [
                  QIconButton(
                    glyph: QuietGlyph.chevronLeft,
                    onPressed: () => Navigator.of(context).pop(),
                    semanticLabel: 'Back',
                  ),
                  Expanded(
                    child: Text(
                      'Moments',
                      textAlign: TextAlign.center,
                      style: q.text.headline.tinted(q.color.textPrimary),
                    ),
                  ),
                  QButton.tertiary(
                    label: 'Add',
                    glyph: QuietGlyph.plus,
                    onPressed: () => addPhotoMemory(
                      context: context,
                      ref: ref,
                      person: person,
                      profile: profile,
                      nextPosition: live.length,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: live.isEmpty
                  ? Center(
                      child: Text(
                        'No photos yet.',
                        style: q.text.body.tinted(q.color.textSecondary),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        q.space.xl,
                        q.space.base,
                        q.space.xl,
                        q.space.xl,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: q.space.sm,
                        mainAxisSpacing: q.space.sm,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: live.length,
                      itemBuilder: (context, index) {
                        final note = live[index];
                        final image = ref
                            .watch(personPhotoProvider(note.photoId))
                            .asData
                            ?.value;
                        return _GalleryTile(
                          note: note,
                          displayName: displayName,
                          image: image,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatefulWidget {
  const _GalleryTile({
    required this.note,
    required this.displayName,
    this.image,
  });

  final Note note;
  final String displayName;
  final ImageProvider? image;

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _holding = false;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final caption = widget.note.caption;

    return QPressable(
      onTap: widget.image == null
          ? null
          : () => showPhotoMemoryReview(
              context: context,
              photo: widget.image!,
              caption: caption,
              displayName: widget.displayName,
            ),
      onLongPress: caption == null
          ? null
          : () => setState(() => _holding = true),
      radius: q.radius.lg,
      semanticLabel: caption == null
          ? 'Photo memory'
          : 'Photo memory, $caption',
      child: Listener(
        onPointerUp: (_) {
          if (_holding) setState(() => _holding = false);
        },
        onPointerCancel: (_) {
          if (_holding) setState(() => _holding = false);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            QClip(
              radius: q.radius.lg,
              child: QPhoto(
                displayName: widget.displayName,
                seed: widget.note.id,
                photo: widget.image,
              ),
            ),
            if (_holding && caption != null)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: q.color.scrim,
                    borderRadius: BorderRadius.circular(q.radius.lg),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(q.space.base),
                      child: Text(
                        caption,
                        textAlign: TextAlign.center,
                        style: q.text.body.tinted(q.color.textPrimary),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
