import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/profile_launcher.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/features/home/application/gallery_providers.dart';

/// What the user picked from the profile-creation chooser.
enum _ProfileCreationStart {
  linkExisting,
  createNew,
}

/// Opens the profile-creation chooser — never jumps straight into the editor.
///
/// The chooser only returns a choice. Continuation always runs against the
/// caller's context, never the sheet's: popping the chooser unmounts its
/// context, and using that for the next sheet is why birthday→profile used
/// to stop after Save.
Future<void> showProfileCreationChooser({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final choice = await showQSheet<_ProfileCreationStart>(
    context: context,
    builder: (context) => const _ProfileCreationChooserSheet(),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _ProfileCreationStart.linkExisting:
      await showLinkExistingBirthdayPicker(context: context, ref: ref);
    case _ProfileCreationStart.createNew:
      await showCreateBirthdayThenProfileFlow(context: context, ref: ref);
  }
}

Future<void> showLinkExistingBirthdayPicker({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final person = await showQSheet<Person>(
    context: context,
    builder: (context) => const _LinkExistingBirthdaySheet(),
  );
  if (person == null || !context.mounted) return;
  await showProfileFlow(context: context, ref: ref, person: person);
}

/// Birthday sheet in continue-to-profile mode, then the real profile sheet.
///
/// The birthday is persisted inside the sheet before it returns. No draft IDs:
/// the [Person] that opens the profile is the one in the database.
Future<void> showCreateBirthdayThenProfileFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final saved = await showAddPersonFlow(
    context,
    ref,
    mode: BirthdayCreationMode.birthdayThenProfile,
  );
  if (saved == null || !context.mounted) return;
  await showProfileFlow(context: context, ref: ref, person: saved);
}

class _ProfileCreationChooserSheet extends StatelessWidget {
  const _ProfileCreationChooserSheet();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return QSheet(
      title: 'How would you like to begin?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Link someone you already remember by date, '
            'or start fresh with a new birthday.',
            style: q.text.body.tinted(context.controlInkSecondary),
          ),
          SizedBox(height: q.space.xl),
          QButton.primary(
            label: 'Link Existing Birthday',
            onPressed: () => Navigator.of(context).pop(
              _ProfileCreationStart.linkExisting,
            ),
          ),
          SizedBox(height: q.space.sm),
          QButton(
            label: 'Create New Birthday',
            onPressed: () => Navigator.of(context).pop(
              _ProfileCreationStart.createNew,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkExistingBirthdaySheet extends ConsumerWidget {
  const _LinkExistingBirthdaySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final unlinked = ref.watch(unlinkedBirthdaysProvider);

    return QSheet(
      title: 'Link Existing Birthday',
      child: unlinked.isEmpty
          ? Text(
              'Every birthday already has a relationship profile.',
              style: q.text.body.tinted(context.controlInkSecondary),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, person) in unlinked.indexed) ...[
                    QSettingRow(
                      label: person.displayName,
                      subtitle: _birthdayLabel(person),
                      onTap: () => Navigator.of(context).pop(person),
                    ),
                    if (index < unlinked.length - 1) const QHairline(),
                  ],
                ],
              ),
            ),
    );
  }

  String _birthdayLabel(Person person) {
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
    final birthday = person.birthday;
    final month = months[birthday.month - 1];
    if (birthday.year == null) {
      return '${birthday.day} $month';
    }
    return '${birthday.day} $month ${birthday.year}';
  }
}
