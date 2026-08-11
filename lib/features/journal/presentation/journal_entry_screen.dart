import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/design/components/buttons/q_icon_button.dart';
import 'package:kin/design/components/journal/q_journal_photo_print.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/glyphs/quiet_glyphs.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/journal_entry.dart';
import 'package:kin/domain/models/journal_fragment.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/journal/audio/journal_audio_flow.dart';
import 'package:kin/features/journal/audio/journal_audio_module.dart';
// ignore: always_use_package_imports -- ARCH-03
import 'journal_memory_editor.dart';

/// Full story for one journal memory — composed archive page.
class JournalEntryScreen extends ConsumerWidget {
  const JournalEntryScreen({
    required this.dateKey,
    required this.entryId,
    super.key,
  });

  final String dateKey;
  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final j = q.journal;
    final entry = ref.watch(journalEntryProvider(entryId));
    final fragments = ref.watch(journalEntryFragmentsProvider(entryId));
    final date = LocalCalendarDate.parseStorage(dateKey);

    final model = entry.asData?.value;
    if (model == null && entry.isLoading) {
      return QScreen(canvasColor: j.desk, child: const SizedBox.shrink());
    }
    if (model == null) {
      return QScreen(
        canvasColor: j.desk,
        child: Center(
          child: Text(
            'This memory is no longer here.',
            style: q.text.archiveBody.tinted(j.inkMuted),
          ),
        ),
      );
    }

    final fragmentList = fragments.asData?.value ?? const <JournalFragment>[];

    return QScreen(
      canvasColor: j.desk,
      child: QMeasure(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            q.space.base,
            context.gutter,
            q.space.emptiness,
          ),
          children: [
            Row(
              children: [
                QIconButton(
                  glyph: QuietGlyph.chevronLeft,
                  onPressed: () => context.pop(),
                  semanticLabel: 'Back',
                ),
                const Spacer(),
                QIconButton(
                  glyph: QuietGlyph.ellipsis,
                  onPressed: () => _showActions(
                    context,
                    ref,
                    model,
                    fragmentList,
                  ),
                  semanticLabel: 'Memory actions',
                ),
              ],
            ),
            SizedBox(height: q.space.xl),
            Text(
              _formatDate(date),
              textScaler: context.structuralTextScaler,
              style: q.text.archiveMeta.tinted(j.inkMuted),
            ),
            SizedBox(height: q.space.sm),
            Text(
              model.title,
              textScaler: context.nameTextScaler,
              style: q.text.voiceLg.tinted(j.ink),
            ),
            if (model.mood != null) ...[
              SizedBox(height: q.space.sm),
              Text(
                model.mood!.displayName.toUpperCase(),
                textScaler: context.structuralTextScaler,
                style: q.text.archiveLabel.tinted(j.inkMuted),
              ),
            ],
            if (fragmentList.isEmpty && model.body.isNotEmpty) ...[
              SizedBox(height: q.space.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  model.body,
                  style: q.text.archiveBodyLarge.tinted(j.ink),
                ),
              ),
            ],
            for (final fragment in fragmentList) ...[
              SizedBox(height: q.space.xl),
              _FragmentReader(fragment: fragment),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showActions(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
    List<JournalFragment> fragments,
  ) async {
    final choice = await showQChoiceSheet(
      context: context,
      title: entry.title,
      choices: const [
        QChoice('Edit'),
        QChoice('Delete', destructive: true),
      ],
    );
    if (choice == null || !context.mounted) return;
    if (choice == 0) {
      final updated = await openJournalMemoryEditor(
        context: context,
        date: entry.localDate,
        position: entry.position,
        existing: entry,
        existingFragments: fragments,
      );
      if (updated != null) QuietHaptics.commit();
      return;
    }
    if (choice == 1) {
      final confirm = await showQChoiceSheet(
        context: context,
        title: 'Delete this memory?',
        choices: const [
          QChoice('Keep it'),
          QChoice('Delete', destructive: true),
        ],
      );
      if (confirm != 1 || !context.mounted) return;
      await ref.read(journalRepositoryProvider).softDeleteEntry(entry.id);
      QuietHaptics.commit();
      if (context.mounted) context.pop();
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

class _FragmentReader extends ConsumerWidget {
  const _FragmentReader({required this.fragment});

  final JournalFragment fragment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final j = q.journal;

    switch (fragment.kind) {
      case JournalFragmentKind.writing:
        final text = fragment.textBody?.trim() ?? '';
        if (text.isEmpty) return const SizedBox.shrink();
        return Semantics(
          label: 'Writing fragment',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(text, style: q.text.archiveBodyLarge.tinted(j.ink)),
          ),
        );
      case JournalFragmentKind.list:
        final items = fragment.listItems;
        if (items.isEmpty) return const SizedBox.shrink();
        return Semantics(
          label: 'List fragment',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items) ...[
                  Text(
                    '•  $item',
                    style: q.text.archiveBodyLarge.tinted(j.ink),
                  ),
                  SizedBox(height: q.space.xs),
                ],
              ],
            ),
          ),
        );
      case JournalFragmentKind.photograph:
        final photoId = fragment.photoId;
        if (photoId == null || photoId.isEmpty) {
          return const SizedBox.shrink();
        }
        final image = ref.watch(journalPhotoProvider(photoId)).asData?.value;
        if (image == null) return const SizedBox.shrink();
        return Semantics(
          label: 'Photograph fragment',
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: QJournalPhotoPrint(
                caption: fragment.caption,
                child: Image(image: image, fit: BoxFit.cover),
              ),
            ),
          ),
        );
      case JournalFragmentKind.audio:
        final path = fragment.audioRelPath;
        if (path == null || path.isEmpty || !JournalAudioModule.enabled) {
          return Text(
            'Audio',
            style: q.text.archiveBody.tinted(j.inkMuted),
          );
        }
        return JournalAudioPlayback(
          relativePath: path,
          durationMs: fragment.audioDurationMs,
          caption: fragment.caption,
        );
    }
  }
}
