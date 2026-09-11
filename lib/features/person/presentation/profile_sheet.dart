import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/data/local/database/kin_database.dart' show PhotosCompanion;
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/fields/q_note_kind_picker.dart';
import 'package:kin/design/components/media/q_photo.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/components/surfaces/q_surface.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/domain/models/profile.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'detail_kind_picker.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'memory_actions.dart';
// ignore: always_use_package_imports -- ARCH-03: relative within a feature
import 'photo_memory_flow.dart';

Future<void> showProfileSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Person person,
  RelationshipProfile? profile,
}) {
  return showQSheet<void>(
    context: context,
    builder: (context) => ProfileSheet(person: person, profile: profile),
  );
}

/// Opens the text-detail editor (favorites, gift ideas, free notes).
Future<void> showNoteEditorSheet({
  required BuildContext context,
  required String profileId,
  required int position,
  Note? note,
  NoteKind? initialKind,
}) {
  QuietHaptics.open();
  return showQSheet<void>(
    context: context,
    builder: (context) => _NoteEditorSheet(
      profileId: profileId,
      position: position,
      note: note,
      initialKind: initialKind,
    ),
  );
}

class ProfileSheet extends ConsumerStatefulWidget {
  const ProfileSheet({required this.person, this.profile, super.key});

  final Person person;
  final RelationshipProfile? profile;

  @override
  ConsumerState<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends ConsumerState<ProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _customRelationshipController;
  RelationshipKind? _relationship;
  RelationshipProfile? _cachedLiveProfile;
  DraftPhoto? _draftPhoto;
  bool _removePhoto = false;
  bool _saving = false;
  bool _showNameError = false;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: widget.person.displayName);
    _nicknameController = TextEditingController(text: profile?.nickname ?? '');
    _customRelationshipController = TextEditingController(
      text: profile?.relationshipLabel ?? '',
    );
    _relationship = profile?.relationship;
    _nameController.addListener(() {
      if (mounted) setState(() {});
    });
    if (widget.profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshLiveProfile());
    }
  }

  Future<void> _refreshLiveProfile() async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .readForPerson(widget.person.id);
    if (!mounted || profile == null) return;
    if (profile != _cachedLiveProfile) {
      setState(() => _cachedLiveProfile = profile);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _customRelationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final effectiveProfile = widget.profile ?? _cachedLiveProfile;
    final existingPhoto = ref.watch(
      personPhotoProvider(_removePhoto ? null : effectiveProfile?.photoId),
    );
    final notes = effectiveProfile == null
        ? const <Note>[]
        : (ref.watch(personNotesProvider(widget.person.id)).asData?.value ??
              const <Note>[]);

    final hasPhoto =
        _draftPhoto != null ||
        (effectiveProfile?.photoId != null && !_removePhoto);
    final sheetTitle = _nameController.text.trim().isEmpty
        ? widget.person.displayName
        : _nameController.text.trim();

    return QSheet(
      // The person is the title. "Relationship Profile" is the name of a
      // database row, and nobody opens a database row about someone they love.
      title: sheetTitle,
      bottom: QBottomActions(
        children: [
          QButton.tertiary(
            label: 'Not now',
            onPressed: () => Navigator.of(context).pop(),
          ),
          QButton.primary(label: 'Save', loading: _saving, onPressed: _save),
        ],
      ),
      child: SingleChildScrollView(
        // Keyboard clearance is owned by QSheet. Padding here used to double
        // the inset and leave a hollow band above the keys.
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PortraitPlate(
              person: widget.person,
              photo: _draftPhoto == null
                  ? existingPhoto.asData?.value
                  : MemoryImage(_draftPhoto!.bytes),
              hasPhoto: hasPhoto,
              onTap: () => _showPhotoActions(context),
            ),
            if (_photoError != null) ...[
              SizedBox(height: q.space.sm),
              Text(
                _photoError!,
                style: q.text.metadata.tinted(q.color.danger),
              ),
            ],
            SizedBox(height: q.space.xxl),
            QField(
              controller: _nameController,
              label: 'Name',
              placeholder: 'Their name',
              helper: 'The name on their birthday — you can change it anytime.',
              error: _showNameError ? 'Add a name.' : null,
              onChanged: (_) {
                if (_showNameError) setState(() => _showNameError = false);
              },
            ),
            SizedBox(height: q.space.xl),
            QField(
              controller: _nicknameController,
              label: 'Nickname',
              placeholder: 'What you actually call them',
            ),
            const QSectionTitle(
              'How you know them',
              support: 'Pick one, or describe it yourself.',
            ),
            QPillGroup(
              options: _relationshipLabels,
              selected: _relationship == null
                  ? null
                  : _relationshipPill(_relationship!),
              onSelected: (label) => setState(
                () => _relationship = _relationshipFor(label),
              ),
            ),
            if (_relationship == RelationshipKind.other) ...[
              SizedBox(height: q.space.base),
              QField(
                controller: _customRelationshipController,
                label: 'Custom relationship',
                placeholder: 'How do you describe them?',
              ),
            ],
            SizedBox(height: q.space.xxl),
            _MemoriesBook(
              notes: notes,
              profileId: effectiveProfile?.id ?? '',
              person: widget.person,
              profile: effectiveProfile,
              onMemoriesChanged: _refreshLiveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhotoActions(BuildContext context) async {
    final effectiveProfile = widget.profile ?? _cachedLiveProfile;
    final canRemove =
        _draftPhoto != null ||
        (effectiveProfile?.photoId != null && !_removePhoto);

    final choice = await showQChoiceSheet(
      context: context,
      title: 'Their photograph',
      choices: [
        const QChoice('Take a photo'),
        const QChoice('Choose from library'),
        if (canRemove) const QChoice('Remove photo', destructive: true),
      ],
    );
    if (choice == null) return;

    switch (choice) {
      case 0:
        await _pickPhoto(ImageSource.camera);
      case 1:
        await _pickPhoto(ImageSource.gallery);
      case 2:
        setState(() {
          _draftPhoto = null;
          _removePhoto = true;
        });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 92,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      if (mounted) {
        setState(
          () => _photoError =
              'That photo could not be read. Try another image.',
        );
      }
      return;
    }
    final normalized = _normalizePhoto(decoded);
    setState(() {
      _photoError = null;
      _removePhoto = false;
      _draftPhoto = DraftPhoto(
        bytes: Uint8List.fromList(img.encodeJpg(normalized, quality: 85)),
        width: normalized.width,
        height: normalized.height,
      );
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    if (_saving) return;

    setState(() => _saving = true);
    try {
      final now = ref.read(clockProvider).now();
      var existing = widget.profile ?? _cachedLiveProfile;
      if (existing == null) {
        existing = await ref
            .read(profileRepositoryProvider)
            .readForPerson(widget.person.id);
        if (existing != null && mounted) {
          setState(() => _cachedLiveProfile = existing);
        }
      }
      var photoId = _removePhoto ? null : existing?.photoId;
      if (_draftPhoto != null) {
        photoId = await _persistPhoto(draft: _draftPhoto!, now: now);
      }

      if (name != widget.person.displayName.trim()) {
        await ref
            .read(personRepositoryProvider)
            .save(widget.person.copyWith(displayName: name));
        try {
          await ref.read(notificationCoordinatorProvider).synchronize();
        } on Object {
          // Reminder sync is best-effort.
        }
      }

      await ref
          .read(profileRepositoryProvider)
          .save(
            RelationshipProfile(
              id: existing?.id ?? '',
              personId: widget.person.id,
              nickname: _nicknameController.text.trim().isEmpty
                  ? null
                  : _nicknameController.text.trim(),
              relationship: _relationship,
              relationshipLabel: _relationship == RelationshipKind.other
                  ? _customRelationshipController.text.trim()
                  : null,
              photoId: photoId,
              isPinned: existing?.isPinned ?? false,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
              syncRev: existing?.syncRev ?? 0,
            ),
          );
      if (mounted) {
        QuietHaptics.commit();
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<String> _persistPhoto({
    required DraftPhoto draft,
    required DateTime now,
  }) async {
    final write = await ref.read(imageStoreProvider).putJpeg(draft.bytes);
    await ref
        .read(kinDatabaseProvider)
        .into(ref.read(kinDatabaseProvider).photos)
        .insertOnConflictUpdate(
          PhotosCompanion.insert(
            id: write.id,
            personId: Value(widget.person.id),
            relPath: write.relativePath,
            width: draft.width,
            height: draft.height,
            bytes: write.bytes,
            createdAt: now.toUtc().millisecondsSinceEpoch,
          ),
        );
    return write.id;
  }
}

class DraftPhoto {
  const DraftPhoto({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

/// The photograph, as the plate at the front of the book.
///
/// A wide portrait rather than a circular avatar with a "Choose a photo" button
/// underneath it. The circle-plus-button arrangement is a settings row: it puts
/// a control where a face should be, and it forces the name to be printed twice
/// — once in the sheet title and once below the picture.
class _PortraitPlate extends StatelessWidget {
  const _PortraitPlate({
    required this.person,
    required this.photo,
    required this.hasPhoto,
    required this.onTap,
  });

  final Person person;
  final ImageProvider? photo;
  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QPressable(
      onTap: onTap,
      radius: q.radius.lg,
      semanticLabel: hasPhoto
          ? 'Change photo of ${person.displayName}'
          : 'Add a photo of ${person.displayName}',
      child: QClip(
        radius: q.radius.lg,
        child: AspectRatio(
          // Landscape, so the plate reads as a photograph on a page rather
          // than as an enlarged avatar.
          aspectRatio: 3 / 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: QPhoto(
                  displayName: person.displayName,
                  seed: person.id,
                  photo: photo,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: q.photo.cardScrim,
                        stops: q.photo.cardScrimStops,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: q.space.base,
                right: q.space.base,
                bottom: q.space.base,
                child: Row(
                  children: [
                    QGlyphIcon(
                      QuietGlyph.camera,
                      color: q.photo.onImagePrimary,
                      size: context.structuralTextScaler.scale(16),
                    ),
                    SizedBox(width: q.space.sm),
                    Text(
                      hasPhoto ? 'Change photo' : 'Add a photo',
                      style: context.onImage(q.text.buttonLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoriesBook extends ConsumerStatefulWidget {
  const _MemoriesBook({
    required this.notes,
    required this.profileId,
    required this.person,
    required this.profile,
    this.onMemoriesChanged,
  });

  final List<Note> notes;
  final String profileId;
  final Person person;
  final RelationshipProfile? profile;
  final VoidCallback? onMemoriesChanged;

  @override
  ConsumerState<_MemoriesBook> createState() => _MemoriesBookState();
}

class _MemoriesBookState extends ConsumerState<_MemoriesBook> {
  List<DetailKindSection> _order = List<DetailKindSection>.from(
    DetailKindSection.defaultOrder,
  );

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final order = await loadDetailKindSectionOrder();
    if (!mounted) return;
    setState(() => _order = order);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final notes = widget.notes;
    final person = widget.person;
    final profile = widget.profile;
    final photoNotes = notes.where((n) => n.isPhotoMemory).toList();
    final grouped = groupNotesByDetailSection(notes, order: _order);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QSectionTitle(
          'What you remember',
          support: notes.isEmpty
              ? null
              : 'Tap a detail to edit it, or a photo to review it.',
          trailing: QButton.tertiary(
            label: 'Add',
            glyph: QuietGlyph.plus,
            onPressed: () async {
              await showAddMemoryChooser(
                context: context,
                ref: ref,
                person: person,
                profile: profile,
                nextPosition: notes.length,
              );
              widget.onMemoriesChanged?.call();
            },
          ),
        ),
        if (notes.isEmpty)
          Text(
            profile == null
                ? 'Add a photo, note what they love, or a plan you want to '
                    'make for them — details save as you go.'
                : 'Nothing yet. Save a photo, note what they love, or a plan '
                    'you want to make for them.',
            style: q.text.body.tinted(context.controlInkSecondary),
          ),
        if (photoNotes.isNotEmpty) ...[
          SizedBox(height: q.space.sm),
          _PhotoJournalSection(
            notes: photoNotes,
            displayName: person.displayName,
          ),
        ],
        for (final (section, sectionNotes) in grouped) ...[
          SizedBox(height: q.space.xxl),
          _JournalSection(
            section: section,
            title: section.title,
            notes: sectionNotes,
            nextPosition: notes.length,
          ),
        ],
      ],
    );
  }
}

class _PhotoJournalSection extends ConsumerWidget {
  const _PhotoJournalSection({
    required this.notes,
    required this.displayName,
  });

  final List<Note> notes;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Moments', style: q.text.headline.tinted(context.controlInk)),
        SizedBox(height: q.space.md),
        Wrap(
          spacing: q.space.sm,
          runSpacing: q.space.sm,
          children: [
            for (final note in notes)
              _PhotoJournalTile(
                note: note,
                displayName: displayName,
                image: ref
                    .watch(personPhotoProvider(note.photoId))
                    .asData
                    ?.value,
              ),
          ],
        ),
      ],
    );
  }
}

class _PhotoJournalTile extends StatelessWidget {
  const _PhotoJournalTile({
    required this.note,
    required this.displayName,
    this.image,
  });

  final Note note;
  final String displayName;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QPressable(
      onTap: () => showQSheet<void>(
        context: context,
        builder: (context) => _PhotoMemoryActionsSheet(
          note: note,
          displayName: displayName,
          image: image,
        ),
      ),
      radius: q.radius.lg,
      semanticLabel: 'Photo memory',
      semanticHint: 'Review or remove',
      child: SizedBox(
        width: 96,
        height: 128,
        child: QClip(
          radius: q.radius.lg,
          child: QPhoto(
            displayName: displayName,
            seed: note.id,
            photo: image,
          ),
        ),
      ),
    );
  }
}

class _PhotoMemoryActionsSheet extends ConsumerWidget {
  const _PhotoMemoryActionsSheet({
    required this.note,
    required this.displayName,
    this.image,
  });

  final Note note;
  final String displayName;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return QSheet(
      title: 'Photo memory',
      bottom: QBottomActions(
        children: [
          QButton.destructive(
            label: 'Remove',
            onPressed: () async {
              await ref.read(noteRepositoryProvider).softDelete(note.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          QButton.primary(
            label: 'Review',
            onPressed: image == null
                ? null
                : () async {
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await showPhotoMemoryReview(
                      context: context,
                      photo: image!,
                      caption: note.caption,
                      displayName: displayName,
                    );
                  },
          ),
        ],
      ),
      child: Text(
        'A moment you saved. Open it full-screen, or remove it if it no '
        'longer belongs here.',
        style: context.quiet.text.body.tinted(
          context.controlInkSecondary,
        ),
      ),
    );
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection({
    required this.section,
    required this.title,
    required this.notes,
    required this.nextPosition,
  });

  final DetailKindSection section;
  final String title;
  final List<Note> notes;
  final int nextPosition;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: q.text.headline.tinted(context.controlInk)),
        SizedBox(height: q.space.sm),
        for (final (header, note) in notesWithKindHeaders(section, notes)) ...[
          if (header != null) ...[
            if (note != notes.first) SizedBox(height: q.space.md),
            Text(
              header,
              textScaler: context.structuralTextScaler,
              style: q.text.metadata.tinted(context.controlInkSecondary),
            ),
            SizedBox(height: q.space.xs),
          ] else if (note != notes.first)
            Padding(
              padding: EdgeInsets.symmetric(vertical: q.space.xs),
              child: const QHairline(),
            ),
          _MemoryRow(
            key: ValueKey<String>(note.id),
            note: note,
            nextPosition: nextPosition,
          ),
        ],
      ],
    );
  }
}

class _MemoryRow extends StatelessWidget {
  const _MemoryRow({
    required this.note,
    required this.nextPosition,
    super.key,
  });

  final Note note;
  final int nextPosition;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final subtitle = noteRowSubtitle(note);
    final semantic = subtitle == null
        ? (DetailKindSection.forKind(note.kind) == DetailKindSection.favorites
              ? '${detailKindLabel(note.kind)}: ${note.value}'
              : note.value)
        : '$subtitle: ${note.value}';

    // Tap adds another detail (same category). Long-press opens Remove.
    return QPressable(
      onTap: () => showNoteEditorSheet(
        context: context,
        profileId: note.profileId,
        position: nextPosition,
        initialKind: note.kind,
      ),
      onLongPress: () => showNoteEditorSheet(
        context: context,
        profileId: note.profileId,
        position: note.position,
        note: note,
      ),
      radius: q.radius.md,
      semanticLabel: semantic,
      semanticHint: 'Add another detail. Long press to remove.',
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: q.space.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.value,
              style: q.text.bodyLg.tinted(context.controlInk),
            ),
            if (subtitle != null) ...[
              SizedBox(height: q.space.xs),
              Text(
                subtitle,
                textScaler: context.structuralTextScaler,
                style: q.text.metadata.tinted(context.controlInkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteEditorSheet extends ConsumerStatefulWidget {
  const _NoteEditorSheet({
    required this.profileId,
    required this.position,
    this.note,
    this.initialKind,
  });

  final String profileId;
  final int position;
  final Note? note;
  final NoteKind? initialKind;

  bool get isEditing => note != null;

  @override
  ConsumerState<_NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends ConsumerState<_NoteEditorSheet> {
  late final TextEditingController _valueController;
  late final TextEditingController _labelController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late NoteKind _kind;
  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.note;
    _kind = existing?.kind ?? widget.initialKind ?? NoteKind.flower;
    _valueController = TextEditingController(text: existing?.value ?? '');
    _labelController = TextEditingController(
      text: existing?.kind == NoteKind.custom ? (existing?.label ?? '') : '',
    );
    final when = existing?.kind == NoteKind.free
        ? Note.decodeRememberedWhen(existing?.label)
        : (null, null);
    _dateController = TextEditingController(text: when.$1 ?? '');
    _timeController = TextEditingController(text: when.$2 ?? '');
  }

  @override
  void dispose() {
    _valueController.dispose();
    _labelController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final existing = widget.note;
    final isActiveGift =
        existing != null &&
        existing.kind == NoteKind.giftIdea &&
        !existing.isRetired;
    final valueError = _showErrors && _valueController.text.trim().isEmpty
        ? 'Write something to remember.'
        : null;
    final customLabelError =
        _showErrors &&
            _kind == NoteKind.custom &&
            _labelController.text.trim().isEmpty
        ? 'Name this detail.'
        : null;

    return QSheet(
      title: widget.isEditing ? 'Edit detail' : 'Add a detail',
      bottom: QBottomActions(
        children: [
          if (widget.isEditing)
            QButton.destructive(
              label: 'Remove',
              onPressed: _saving ? null : _remove,
            )
          else
            QButton.tertiary(
              label: 'Not now',
              onPressed: () => Navigator.of(context).pop(),
            ),
          if (isActiveGift)
            QButton.tertiary(
              label: 'Mark as given',
              onPressed: _saving ? null : _markGiven,
            ),
          QButton.primary(
            label: 'Save',
            loading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailKindPicker(
              selected: _kind,
              onSelected: (kind) => setState(() => _kind = kind),
            ),
            if (_kind == NoteKind.custom) ...[
              SizedBox(height: q.space.xl),
              QField(
                controller: _labelController,
                label: 'Category',
                placeholder: 'What do you want to remember?',
                error: customLabelError,
                onChanged: (_) {
                  if (_showErrors) setState(() => _showErrors = false);
                },
              ),
            ],
            SizedBox(height: q.space.xl),
            QField(
              controller: _valueController,
              label: _kind == NoteKind.custom
                  ? 'Detail'
                  : _noteLabelForKind(_kind),
              placeholder: _placeholderForKind(_kind),
              maxLines: 4,
              error: valueError,
              onChanged: (_) {
                if (_showErrors) setState(() => _showErrors = false);
              },
            ),
            if (_kind == NoteKind.free) ...[
              SizedBox(height: q.space.xl),
              QField(
                controller: _dateController,
                label: 'Date',
                placeholder: '12 March 2025',
                textInputAction: TextInputAction.next,
              ),
              QField(
                controller: _timeController,
                label: 'Time',
                placeholder: '9:30 pm',
                textInputAction: TextInputAction.done,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final value = _valueController.text.trim();
    final customLabel = _kind == NoteKind.custom
        ? _labelController.text.trim()
        : null;
    if (value.isEmpty ||
        (_kind == NoteKind.custom &&
            (customLabel == null || customLabel.isEmpty)) ||
        _saving) {
      setState(() => _showErrors = true);
      return;
    }

    final whenLabel = _kind == NoteKind.free
        ? Note.encodeRememberedWhen(
            date: _dateController.text,
            time: _timeController.text,
          )
        : null;

    _saving = true;
    setState(() {});
    try {
      final now = ref.read(clockProvider).now();
      final existing = widget.note;
      final label = _kind == NoteKind.custom ? customLabel : whenLabel;
      await ref
          .read(noteRepositoryProvider)
          .save(
            existing == null
                ? Note(
                    id: '',
                    profileId: widget.profileId,
                    kind: _kind,
                    label: label,
                    value: value,
                    position: widget.position,
                    createdAt: now,
                    updatedAt: now,
                  )
                : existing.copyWith(
                    kind: _kind,
                    label: label,
                    value: value,
                    updatedAt: now,
                  ),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      _saving = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _markGiven() async {
    final existing = widget.note;
    if (existing == null || _saving) return;

    _saving = true;
    setState(() {});
    try {
      await ref.read(noteRepositoryProvider).retire(existing.id, value: true);
      if (mounted) Navigator.of(context).pop();
    } finally {
      _saving = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _remove() async {
    final existing = widget.note;
    if (existing == null || _saving) return;

    _saving = true;
    setState(() {});
    try {
      await ref.read(noteRepositoryProvider).softDelete(existing.id);
      if (mounted) Navigator.of(context).pop();
    } finally {
      _saving = false;
      if (mounted) setState(() {});
    }
  }
}

img.Image _normalizePhoto(img.Image image) {
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

/// Relationship labels, in the order they are offered.
final List<String> _relationshipLabels = RelationshipKind.values
    .map(_relationshipPill)
    .toList(growable: false);

RelationshipKind _relationshipFor(String label) => RelationshipKind.values
    .firstWhere((kind) => _relationshipPill(kind) == label);

String _relationshipPill(RelationshipKind value) {
  return switch (value) {
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
    RelationshipKind.other => 'Custom',
  };
}

String _noteLabelForKind(NoteKind kind) => detailKindLabel(kind);

String _placeholderForKind(NoteKind kind) {
  return switch (kind) {
    NoteKind.flower => 'Peonies, the pale ones',
    NoteKind.colour => 'Soft green',
    NoteKind.food => 'Lemon rice on bad days',
    NoteKind.dessert => 'Basbousa',
    NoteKind.drink => 'Flat white, chai, sparkling water with lime',
    NoteKind.movie => 'Before Sunrise',
    NoteKind.music => 'Old ghazals on Sunday mornings',
    NoteKind.restaurant => 'The corner ramen place',
    NoteKind.place => 'The beach near Mahabalipuram',
    NoteKind.giftIdea => 'That ceramics class downtown',
    NoteKind.plan => 'Surprise trip to Kerala',
    NoteKind.importantDate => 'Moved to Chennai in 2023',
    NoteKind.free => 'Something they mentioned in passing',
    NoteKind.custom => 'The detail itself',
    NoteKind.photo => 'A moment you want to keep',
  };
}
