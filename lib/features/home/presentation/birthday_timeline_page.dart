import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/rows/q_person_row.dart';
import 'package:kin/design/components/surfaces/q_hairline.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

/// Below this many people the timeline is one list. Grouping only appears when
/// there is enough of a year left to need chapters.
const _groupThreshold = 6;

/// Birthday timeline — the "when" mode.
class BirthdayTimelinePage extends ConsumerWidget {
  const BirthdayTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleStreamProvider);

    if (people.isLoading) {
      return const SizedBox.shrink();
    }
    if ((people.asData?.value ?? const []).isEmpty) {
      return _TimelineEmptyState(
        onAdd: () => showAddPersonFlow(context, ref),
      );
    }
    return const _HomeTimeline();
  }
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return QEmptyState(
      headline: 'No one here yet.',
      support: "Everyone you'd hate to forget.",
      action: QButton.primary(label: 'Add someone', onPressed: onAdd),
    );
  }
}

class _HomeTimeline extends ConsumerWidget {
  const _HomeTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(homeGroupsProvider);
    final total = groups.fold<int>(
      0,
      (sum, group) => sum + group.entries.length,
    );
    // Few people: one continuous list. Sections only earn their keep when the
    // year is long enough that "who is next" needs chapters.
    final showSections = total >= _groupThreshold && groups.length > 1;
    final indent = personRowHairlineIndent(context);

    return _EntranceFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSections)
            for (final group in groups) ...[
              _TimelineSectionTitle(
                group.section.label,
                isFirst: group == groups.first,
              ),
              ..._rowsFor(context, group.entries, indent),
            ]
          else
            ..._rowsFor(
              context,
              [
                for (final group in groups) ...group.entries,
              ],
              indent,
            ),
        ],
      ),
    );
  }

  List<Widget> _rowsFor(
    BuildContext context,
    List<HomeEntry> entries,
    double indent,
  ) {
    return [
      for (var index = 0; index < entries.length; index++) ...[
        _TimelinePersonRow(entry: entries[index]),
        if (index < entries.length - 1) QHairline(indent: indent),
      ],
    ];
  }
}

/// A section title that sits on the rows beneath it, not in an ocean of air.
class _TimelineSectionTitle extends StatelessWidget {
  const _TimelineSectionTitle(this.title, {required this.isFirst});

  final String title;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? q.space.xs : q.space.xl,
        bottom: q.space.sm,
      ),
      child: Text(
        title,
        textScaler: context.nameTextScaler,
        style: q.text.sectionTitle.tinted(q.color.textPrimary),
      ),
    );
  }
}

class _TimelinePersonRow extends ConsumerWidget {
  const _TimelinePersonRow({required this.entry});

  final HomeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(personPhotoProvider(entry.profile?.photoId));

    return QPersonRow(
      displayName: entry.person.displayName,
      seed: entry.person.id,
      daysUntil: entry.daysUntil,
      turningAge: entry.turningAge,
      nextBirthdayLine: entry.nextBirthdayLine,
      countdownText: entry.countdownText,
      photo: photo.asData?.value,
      heroTag: 'person-${entry.person.id}',
      onTap: () => context.pushNamed(
        AppRoute.person.name,
        pathParameters: {'id': entry.person.id},
      ),
    );
  }
}

class _EntranceFrame extends StatefulWidget {
  const _EntranceFrame({required this.child});

  final Widget child;

  @override
  State<_EntranceFrame> createState() => _EntranceFrameState();
}

class _EntranceFrameState extends State<_EntranceFrame> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMotion = QuietMotion.of(context);
    final tokens = context.quiet.motion;

    return AnimatedOpacity(
      duration: tokens.base,
      curve: resolvedMotion.enter,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: resolvedMotion.move(tokens.base),
        curve: resolvedMotion.enter,
        offset: _visible
            ? Offset.zero
            : resolvedMotion.offset(const Offset(0, 0.02)),
        child: widget.child,
      ),
    );
  }
}
