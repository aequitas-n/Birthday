import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/place_picker_sheet.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/fields/q_date_field.dart';
import 'package:kin/design/components/fields/q_field.dart';
import 'package:kin/design/components/rows/q_section_title.dart';
import 'package:kin/design/components/rows/q_setting_row.dart';
import 'package:kin/design/components/sheets/q_choice_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet.dart';
import 'package:kin/design/components/sheets/q_sheet_route.dart';
import 'package:kin/design/feedback/quiet_haptics.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/person.dart';
import 'package:kin/features/person_editor/application/person_editor_notifier.dart';

/// How the birthday sheet finishes.
///
/// The sheet itself never opens a profile. Callers choose a mode, read the
/// returned [Person], and decide what happens next.
enum BirthdayCreationMode {
  /// Birthdays page: persist and done.
  birthdayOnly,

  /// People → Create New Birthday: persist, return the person, and let the
  /// launcher continue into the profile sheet.
  birthdayThenProfile,
}

Future<Person?> showAddPersonSheet(
  BuildContext context,
  WidgetRef ref, {
  BirthdayCreationMode mode = BirthdayCreationMode.birthdayOnly,
}) async {
  ref.read(personEditorProvider.notifier).reset();
  return showQSheet<Person>(
    context: context,
    builder: (context) => AddPersonSheet(mode: mode),
  );
}

/// One birthday sheet. Two completion paths, chosen by [mode].
///
/// The fields never change. Only the primary/secondary labels and what the
/// launcher does with the returned [Person] change. The sheet does not open
/// a profile — that stays the caller's job.
class AddPersonSheet extends ConsumerStatefulWidget {
  const AddPersonSheet({
    this.mode = BirthdayCreationMode.birthdayOnly,
    super.key,
  });

  final BirthdayCreationMode mode;

  @override
  ConsumerState<AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends ConsumerState<AddPersonSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _dayController;
  late final TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(personEditorProvider);
    _nameController = TextEditingController(text: state.name);
    _dayController = TextEditingController(text: state.birthDay);
    _yearController = TextEditingController(text: state.birthYear);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final state = ref.watch(personEditorProvider);
    final notifier = ref.read(personEditorProvider.notifier);

    final continuesToProfile =
        widget.mode == BirthdayCreationMode.birthdayThenProfile;

    return QSheet(
      title: 'Add a birthday',
      bottom: QBottomActions(
        children: [
          QButton.tertiary(
            // Birthday-only can leave unfinished; profile creation is mid-flow
            // and Cancel says so without implying something was discarded
            // after a save that never happened.
            label: continuesToProfile ? 'Cancel' : 'Not now',
            onPressed: () {
              notifier.reset();
              Navigator.of(context).pop();
            },
          ),
          QButton.primary(
            // Next is honest: the birthday is persisted, but the intent that
            // brought the user here is not finished until the profile exists.
            label: continuesToProfile ? 'Next' : 'Save',
            loading: state.isSaving,
            onPressed: () async {
              final saved = await notifier.save();
              if (saved == null || !context.mounted) return;
              QuietHaptics.commit();
              Navigator.of(context).pop(saved);
            },
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name, birthday, and where they are. That is enough.',
              style: q.text.bodyLg.tinted(q.color.textSecondary),
            ),
            SizedBox(height: q.space.xl),
            QField(
              controller: _nameController,
              label: 'Name',
              placeholder: 'Who are you adding?',
              autofocus: true,
              textInputAction: TextInputAction.next,
              onChanged: notifier.setName,
              error: state.nameError,
            ),
            QDateField(
              dayController: _dayController,
              yearController: _yearController,
              monthLabel: state.birthMonth == null
                  ? null
                  : _monthNames[state.birthMonth! - 1],
              onMonthPressed: () => _showMonthPicker(
                context: context,
                onSelected: notifier.setBirthMonth,
                selectedMonth: state.birthMonth,
              ),
              onDayChanged: notifier.setBirthDay,
              onYearChanged: notifier.setBirthYear,
              error: state.birthdayError,
              helper: 'The year is optional.',
            ),
            const QSectionTitle(
              'Where they live',
              support: 'So the day arrives at the right time for them.',
            ),
            QSettingRow(
              label: state.location?.city ?? 'Choose a city',
              subtitle: state.location == null
                  ? (state.locationError ??
                        'Tap to search — required for reminders.')
                  : state.location!.label,
              showChevron: true,
              onTap: () async {
                final city = await showPlacePickerSheet(context: context);
                if (city == null || !context.mounted) return;
                notifier.setLocation(city);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showMonthPicker({
  required BuildContext context,
  required ValueChanged<int> onSelected,
  int? selectedMonth,
}) async {
  final index = await showQChoiceSheet(
    context: context,
    title: 'Month',
    choices: [for (final month in _monthNames) QChoice(month)],
    selectedIndex: selectedMonth == null ? null : selectedMonth - 1,
  );
  if (index != null) onSelected(index + 1);
}

const _monthNames = <String>[
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
