import 'dart:io';

import 'package:flutter/cupertino.dart'
    show cupertinoTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show materialTextSelectionHandleControls;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/core/clock.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/journal/q_journal_add_fragment_cue.dart';
import 'package:kin/design/components/journal/q_journal_mood_picker.dart';
import 'package:kin/design/components/journal/q_journal_photo_print.dart';
import 'package:kin/design/components/journal/q_journal_writing_surface.dart';
import 'package:kin/design/components/journal/q_mood_illustration.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/media/quiet_display_image.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/theme/vintage_mood.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/journal_mood.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/audio/journal_audio_flow.dart';
import 'package:kin/features/journal/audio/journal_audio_module.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_fragment_catalog.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_photo_flow.dart';

/// Opens the diary writing experience for creating or editing a memory.
Future<JournalEntry?> openJournalMemoryEditor({
  required BuildContext context,
  required LocalCalendarDate date,
  required int position,
  JournalEntry? existing,
  List<JournalFragment> existingFragments = const [],
}) {
  QuietHaptics.open();
  return Navigator.of(context).push<JournalEntry>(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: JournalMemoryEditor(
            date: date,
            position: position,
            existing: existing,
            existingFragments: existingFragments,
          ),
        );
      },
    ),
  );
}

/// Full-page memory composer — assemble fragments, not a form.
class JournalMemoryEditor extends ConsumerStatefulWidget {
  const JournalMemoryEditor({
    required this.date,
    required this.position,
    this.existing,
    this.existingFragments = const [],
    super.key,
  });

  final LocalCalendarDate date;
  final int position;
  final JournalEntry? existing;
  final List<JournalFragment> existingFragments;

  @override
  ConsumerState<JournalMemoryEditor> createState() =>
      _JournalMemoryEditorState();
}

class _JournalMemoryEditorState extends ConsumerState<JournalMemoryEditor> {
  late final TextEditingController _titleController;
  late final FocusNode _titleFocus;
  JournalMood? _mood;
  var _saving = false;
  late final List<_DraftFragment> _fragments;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _titleFocus = FocusNode();
    _mood = existing?.mood;
    _fragments = [
      for (final fragment in widget.existingFragments)
        _DraftFragment.fromPersisted(fragment),
    ];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    for (final fragment in _fragments) {
      fragment.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final editing = widget.existing != null;

    return QScreen(
      child: QMeasure(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.gutter - q.space.sm,
                q.space.base,
                context.gutter,
                0,
              ),
              child: Row(
                children: [
                  QIconButton(
                    glyph: QuietGlyph.close,
                    onPressed: () => Navigator.of(context).pop(),
                    semanticLabel: 'Close',
                  ),
                  Expanded(
                    child: Text(
                      _formatDate(widget.date),
                      textAlign: TextAlign.center,
                      textScaler: context.structuralTextScaler,
                      style: q.inked(
                        q.text.uiDate,
                        tone: QuietInkTone.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: q.space.xl),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.gutter,
                  q.space.lg,
                  context.gutter,
                  q.space.emptiness,
                ),
                children: [
                  _DiaryTitleLine(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    autofocus: !editing && _fragments.isEmpty,
                  ),
                  SizedBox(height: q.space.lg),
                  _MoodButton(
                    mood: _mood,
                    onPressed: _pickMood,
                  ),
                  SizedBox(height: q.space.xl),
                  if (_fragments.isEmpty) ...[
                    Text(
                      'What do you want to remember?',
                      style: q.inked(q.text.emptyStateBody),
                    ),
                    SizedBox(height: q.space.lg),
                    QJournalAddFragmentCue(
                      choices: _fragmentChoices(0),
                    ),
                  ] else ...[
                    for (var i = 0; i < _fragments.length; i++) ...[
                      _FragmentEditor(
                        draft: _fragments[i],
                        onChanged: () => setState(() {}),
                        onActions: () => _fragmentActions(i),
                      ),
                      SizedBox(height: q.space.md),
                      QJournalAddFragmentCue(
                        choices: _fragmentChoices(i + 1),
                        label: 'Add fragment',
                      ),
                      SizedBox(height: q.space.lg),
                    ],
                  ],
                  SizedBox(height: q.space.xl),
                  QButton.primary(
                    label: editing ? 'Save changes' : 'Save memory',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMood() async {
    var selected = _mood;
    final result = await showQSheet<_MoodPick>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = context.quiet;
            return QSheet(
              title: 'Mood',
              bottom: QBottomActions(
                children: [
                  QButton.tertiary(
                    label: 'Not now',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  QButton.primary(
                    label: 'Save',
                    onPressed: () =>
                        Navigator.of(context).pop(_MoodPick(selected)),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How did this memory feel?',
                    style: q.inked(
                      q.text.uiBody,
                      surface: QuietSurfaceKind.paper,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                  SizedBox(height: q.space.lg),
                  QJournalMoodPicker(
                    selectedId: selected?.storageValue,
                    options: [
                      for (final mood in JournalMood.values)
                        (mood.storageValue, mood.displayName),
                    ],
                    onSelected: (id) {
                      setModalState(() {
                        selected = id == null
                            ? null
                            : JournalMood.fromStorage(id);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() => _mood = result.mood);
  }

  List<(String, VoidCallback)> _fragmentChoices(int index) {
    return [
      for (final choice in journalFragmentChoices())
        (choice.title, () => _addFragment(index, choice.kind)),
    ];
  }

  Future<void> _addFragment(int index, JournalFragmentKind kind) async {
    switch (kind) {
      case JournalFragmentKind.writing:
        setState(() {
          _fragments.insert(index, _DraftFragment.writing());
        });
      case JournalFragmentKind.list:
        setState(() {
          _fragments.insert(index, _DraftFragment.list());
        });
      case JournalFragmentKind.photograph:
        final draft = await pickJournalPhotoDraft(context);
        if (draft == null || !mounted) return;
        setState(() {
          _fragments.insert(index, _DraftFragment.photographDraft(draft));
        });
      case JournalFragmentKind.audio:
        if (!JournalAudioModule.enabled) return;
        final draft = await recordJournalAudioDraft(context);
        if (draft == null || !mounted) return;
        setState(() {
          _fragments.insert(index, _DraftFragment.audioDraft(draft));
        });
    }
  }

  Future<void> _fragmentActions(int index) async {
    final choice = await showQChoiceSheet(
      context: context,
      title: 'Fragment',
      choices: [
        if (index > 0) const QChoice('Move up'),
        if (index < _fragments.length - 1) const QChoice('Move down'),
        const QChoice('Remove', destructive: true),
      ],
    );
    if (choice == null || !mounted) return;

    final canMoveUp = index > 0;
    final canMoveDown = index < _fragments.length - 1;
    setState(() {
      if (canMoveUp && choice == 0) {
        final item = _fragments.removeAt(index);
        _fragments.insert(index - 1, item);
        return;
      }
      final removeIndex = canMoveUp
          ? (canMoveDown ? 2 : 1)
          : (canMoveDown ? 1 : 0);
      if (canMoveDown && choice == (canMoveUp ? 1 : 0)) {
        final item = _fragments.removeAt(index);
        _fragments.insert(index + 1, item);
        return;
      }
      if (choice == removeIndex) {
        _fragments.removeAt(index).dispose();
      }
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    final now = ref.read(clockProvider).now();
    final existing = widget.existing;

    try {
      final entryId = existing?.id ?? '';
      final built = <JournalFragment>[];
      for (var i = 0; i < _fragments.length; i++) {
        final draft = _fragments[i];
        final fragment = await draft.toFragment(
          entryId: entryId,
          position: i,
          now: now,
          ref: ref,
        );
        if (fragment != null) built.add(fragment);
      }

      final saved = await ref
          .read(journalRepositoryProvider)
          .saveMemory(
            entry: JournalEntry(
              id: entryId,
              localDate: widget.date,
              title: title,
              body: JournalFragment.previewBodyFrom(built),
              mood: _mood,
              position: existing?.position ?? widget.position,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
            ),
            fragments: built,
          );

      QuietHaptics.commit();
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on Object {
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
  }

  String _formatDate(LocalCalendarDate date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MoodPick {
  const _MoodPick(this.mood);
  final JournalMood? mood;
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.onPressed,
  });

  final JournalMood? mood;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final label = mood?.displayName ?? 'Add mood';

    return Align(
      alignment: Alignment.centerLeft,
      child: QPressable(
        onTap: onPressed,
        radius: q.radius.md,
        semanticLabel: mood == null ? 'Add mood' : 'Mood $label',
        semanticHint: 'Opens mood choices',
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: q.space.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mood != null)
                QMoodIllustration(
                  moodId: mood!.storageValue,
                  size: MoodIllustrationSize.picker,
                )
              else
                Text(
                  '·',
                  style: q.text.uiMetadata.tinted(q.canvas.secondary),
                ),
              SizedBox(width: q.space.sm),
              Text(
                label,
                style: q.text.uiMetadata.tinted(q.canvas.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DraftFragment {
  _DraftFragment._({
    required this.kind,
    this.id,
    this.writing,
    List<TextEditingController>? listItems,
    this.photoId,
    this.photoDraft,
    this.audioRelPath,
    this.audioDraft,
    this.audioDurationMs,
    this.caption,
  }) : listItems = listItems ?? [];

  factory _DraftFragment.writing([String text = '']) => _DraftFragment._(
    kind: JournalFragmentKind.writing,
    writing: TextEditingController(text: text),
  );

  factory _DraftFragment.list([List<String> items = const ['']]) =>
      _DraftFragment._(
        kind: JournalFragmentKind.list,
        listItems: [
          for (final item in (items.isEmpty ? const [''] : items))
            TextEditingController(text: item),
        ],
      );

  factory _DraftFragment.photographDraft(JournalPhotoDraft draft) =>
      _DraftFragment._(
        kind: JournalFragmentKind.photograph,
        photoDraft: draft,
        caption: draft.caption,
      );

  factory _DraftFragment.audioDraft(JournalAudioDraft draft) =>
      _DraftFragment._(
        kind: JournalFragmentKind.audio,
        audioDraft: draft,
        audioDurationMs: draft.durationMs,
      );

  factory _DraftFragment.fromPersisted(JournalFragment fragment) {
    switch (fragment.kind) {
      case JournalFragmentKind.writing:
        return _DraftFragment._(
          kind: JournalFragmentKind.writing,
          id: fragment.id,
          writing: TextEditingController(text: fragment.textBody ?? ''),
        );
      case JournalFragmentKind.list:
        final items = fragment.listItems;
        return _DraftFragment._(
          kind: JournalFragmentKind.list,
          id: fragment.id,
          listItems: [
            for (final item in (items.isEmpty ? const [''] : items))
              TextEditingController(text: item),
          ],
        );
      case JournalFragmentKind.photograph:
        return _DraftFragment._(
          kind: JournalFragmentKind.photograph,
          id: fragment.id,
          photoId: fragment.photoId,
          caption: fragment.caption,
        );
      case JournalFragmentKind.audio:
        return _DraftFragment._(
          kind: JournalFragmentKind.audio,
          id: fragment.id,
          audioRelPath: fragment.audioRelPath,
          audioDurationMs: fragment.audioDurationMs,
          caption: fragment.caption,
        );
    }
  }

  final JournalFragmentKind kind;
  final String? id;
  final TextEditingController? writing;
  final List<TextEditingController> listItems;
  final String? photoId;
  final JournalPhotoDraft? photoDraft;
  String? audioRelPath;
  final JournalAudioDraft? audioDraft;
  final int? audioDurationMs;
  final String? caption;

  void dispose() {
    writing?.dispose();
    for (final item in listItems) {
      item.dispose();
    }
    final draft = audioDraft;
    if (draft != null && audioRelPath == null) {
      final file = File(draft.tempPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }

  Future<JournalFragment?> toFragment({
    required String entryId,
    required int position,
    required DateTime now,
    required WidgetRef ref,
  }) async {
    switch (kind) {
      case JournalFragmentKind.writing:
        final text = writing?.text.trim() ?? '';
        if (text.isEmpty) return null;
        return JournalFragment(
          id: id ?? '',
          entryId: entryId,
          kind: kind,
          position: position,
          textBody: text,
          createdAt: now,
          updatedAt: now,
        );
      case JournalFragmentKind.list:
        final items = [
          for (final controller in listItems)
            if (controller.text.trim().isNotEmpty) controller.text.trim(),
        ];
        if (items.isEmpty) return null;
        return JournalFragment(
          id: id ?? '',
          entryId: entryId,
          kind: kind,
          position: position,
          textBody: JournalFragment.encodeListItems(items),
          createdAt: now,
          updatedAt: now,
        );
      case JournalFragmentKind.photograph:
        var resolvedPhotoId = photoId;
        if (resolvedPhotoId == null && photoDraft != null) {
          resolvedPhotoId = await persistJournalPhoto(
            ref: ref,
            draft: photoDraft!,
            now: now,
          );
        }
        if (resolvedPhotoId == null || resolvedPhotoId.isEmpty) return null;
        return JournalFragment(
          id: id ?? '',
          entryId: entryId,
          kind: kind,
          position: position,
          photoId: resolvedPhotoId,
          caption: caption,
          createdAt: now,
          updatedAt: now,
        );
      case JournalFragmentKind.audio:
        var path = audioRelPath;
        var duration = audioDurationMs;
        if (path == null && audioDraft != null) {
          path = await persistJournalAudioDraft(draft: audioDraft!);
          duration = audioDraft!.durationMs;
        }
        if (path == null || path.isEmpty) return null;
        return JournalFragment(
          id: id ?? '',
          entryId: entryId,
          kind: kind,
          position: position,
          audioRelPath: path,
          audioDurationMs: duration,
          caption: caption,
          createdAt: now,
          updatedAt: now,
        );
    }
  }
}

class _FragmentEditor extends StatelessWidget {
  const _FragmentEditor({
    required this.draft,
    required this.onChanged,
    required this.onActions,
  });

  final _DraftFragment draft;
  final VoidCallback onChanged;
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                switch (draft.kind) {
                  JournalFragmentKind.writing => 'Writing',
                  JournalFragmentKind.list => 'List',
                  JournalFragmentKind.photograph => 'Photograph',
                  JournalFragmentKind.audio => 'Audio',
                },
                textScaler: context.structuralTextScaler,
                style: q.inked(q.text.uiCaption, tone: QuietInkTone.secondary),
              ),
            ),
            QIconButton(
              glyph: QuietGlyph.ellipsis,
              onPressed: onActions,
              semanticLabel: 'Fragment actions',
            ),
          ],
        ),
        SizedBox(height: q.space.sm),
        switch (draft.kind) {
          JournalFragmentKind.writing => QJournalWritingSurface(
            controller: draft.writing,
            minLines: 3,
            placeholder: 'Write what you remember.',
            onChanged: (_) => onChanged(),
          ),
          JournalFragmentKind.list => _ListFragmentEditor(
            draft: draft,
            onChanged: onChanged,
          ),
          JournalFragmentKind.photograph => _PhotoFragmentView(draft: draft),
          JournalFragmentKind.audio => _AudioFragmentView(draft: draft),
        },
      ],
    );
  }
}

class _ListFragmentEditor extends StatelessWidget {
  const _ListFragmentEditor({
    required this.draft,
    required this.onChanged,
  });

  final _DraftFragment draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      children: [
        for (var i = 0; i < draft.listItems.length; i++)
          _ListItemField(
            controller: draft.listItems[i],
            onSubmit: () {
              draft.listItems.insert(i + 1, TextEditingController());
              onChanged();
            },
            onEmptyBackspace: () {
              if (draft.listItems.length <= 1) return;
              draft.listItems.removeAt(i).dispose();
              onChanged();
            },
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: QButton.tertiary(
            label: 'Add point',
            onPressed: () {
              draft.listItems.add(TextEditingController());
              onChanged();
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Press Enter or add another point.',
            style: q.inked(q.text.uiCaption, tone: QuietInkTone.secondary),
          ),
        ),
      ],
    );
  }
}

class _ListItemField extends StatefulWidget {
  const _ListItemField({
    required this.controller,
    required this.onSubmit,
    required this.onEmptyBackspace,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onEmptyBackspace;

  @override
  State<_ListItemField> createState() => _ListItemFieldState();
}

class _ListItemFieldState extends State<_ListItemField> {
  late final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final style = q.inked(q.text.journalWriting);

    return Padding(
      padding: EdgeInsets.only(bottom: q.space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: style),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (event) {
                if (event is! KeyDownEvent) return;
                if (event.logicalKey == LogicalKeyboardKey.backspace &&
                    widget.controller.text.isEmpty) {
                  widget.onEmptyBackspace();
                }
              },
              child: EditableText(
                controller: widget.controller,
                focusNode: _focus,
                style: style,
                cursorColor: q.color.accent,
                backgroundCursorColor: q.color.canvas,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.onSubmit(),
                selectionColor: q.color.selection,
                cursorOpacityAnimates: !context.prefersReducedMotion,
                selectionControls: defaultTargetPlatform == TargetPlatform.iOS
                    ? cupertinoTextSelectionHandleControls
                    : materialTextSelectionHandleControls,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFragmentView extends ConsumerWidget {
  const _PhotoFragmentView({required this.draft});

  final _DraftFragment draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final image = draft.photoDraft != null
        ? MemoryImage(draft.photoDraft!.bytes)
        : (draft.photoId == null
              ? null
              : ref.watch(journalPhotoProvider(draft.photoId!)).asData?.value);

    if (image == null) {
      return Text(
        'Photograph',
        style: q.inked(q.text.uiBody, tone: QuietInkTone.secondary),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: QJournalPhotoPrint(
          caption: draft.caption,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Image(
                image: QuietDisplayImage.maybeAt(
                  image,
                  context: context,
                  constraints: constraints,
                ),
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AudioFragmentView extends StatelessWidget {
  const _AudioFragmentView({required this.draft});

  final _DraftFragment draft;

  @override
  Widget build(BuildContext context) {
    final path = draft.audioRelPath;
    if (path != null) {
      return JournalAudioPlayback(
        relativePath: path,
        durationMs: draft.audioDurationMs,
        caption: draft.caption,
      );
    }
    if (draft.audioDraft != null) {
      return JournalAudioPlayback(
        relativePath: draft.audioDraft!.tempPath,
        durationMs: draft.audioDraft!.durationMs,
        caption: 'New recording',
      );
    }
    final q = context.quiet;
    return Text(
      'Audio',
      style: q.inked(q.text.uiBody, tone: QuietInkTone.secondary),
    );
  }
}

/// Large untitled title line — open page, not a labeled form field.
class _DiaryTitleLine extends StatefulWidget {
  const _DiaryTitleLine({
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;

  @override
  State<_DiaryTitleLine> createState() => _DiaryTitleLineState();
}

class _DiaryTitleLineState extends State<_DiaryTitleLine>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => true;

  late final TextSelectionGestureDetectorBuilder _gestures =
      TextSelectionGestureDetectorBuilder(delegate: this);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  void _onText() => setState(() {});

  void _onFocus() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final style = q.inked(q.text.memoryTitle);
    final empty = widget.controller.text.isEmpty;
    final focused = widget.focusNode.hasFocus;

    final editable = EditableText(
      key: editableTextKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: style,
      cursorColor: q.color.accent,
      backgroundCursorColor: q.color.canvas,
      maxLines: null,
      minLines: 1,
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      autofocus: widget.autofocus,
      selectionColor: q.color.selection,
      cursorOpacityAnimates: !context.prefersReducedMotion,
      selectionControls: defaultTargetPlatform == TargetPlatform.iOS
          ? cupertinoTextSelectionHandleControls
          : materialTextSelectionHandleControls,
      rendererIgnoresPointer: true,
      showSelectionHandles: true,
    );

    return Semantics(
      textField: true,
      label: 'Title',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: focused ? q.color.hairlineStrong : q.color.hairline,
              width: focused ? 1 : context.hairlineWidth,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: q.space.sm),
          child: Stack(
            children: [
              if (empty)
                IgnorePointer(
                  child: Text(
                    'Untitled',
                    textScaler: context.nameTextScaler,
                    style: q.inked(
                      q.text.memoryTitle,
                      tone: QuietInkTone.secondary,
                    ),
                  ),
                ),
              _gestures.buildGestureDetector(
                behavior: HitTestBehavior.translucent,
                child: editable,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
