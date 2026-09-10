import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/person_editor_launcher.dart';
import 'package:kin/app/router.dart';
import 'package:kin/design/components/buttons/q_button.dart';
import 'package:kin/design/components/feedback/q_empty_state.dart';
import 'package:kin/design/components/feedback/q_pane_loading.dart';
import 'package:kin/design/components/rows/q_birthday_strip.dart';
import 'package:kin/design/motion/quiet_motion.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/person/application/person_detail_providers.dart';

/// Birthday timeline — hanging paper tags, one strip per person.
class BirthdayTimelinePage extends ConsumerWidget {
  const BirthdayTimelinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleStreamProvider);

    if (people.isLoading) {
      return const QPaneLoading(minHeight: 200);
    }
    if ((people.asData?.value ?? const []).isEmpty) {
      return Center(
        child: _TimelineEmptyState(
          onAdd: () => showAddPersonFlow(context, ref),
        ),
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

  static const _months = [
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = context.quiet;
    final groups = ref.watch(homeGroupsProvider);
    // Preserve proximity ordering (today → later), then chapter by calendar month.
    final entries = [
      for (final group in groups) ...group.entries,
    ];
    final chapters = _monthChapters(entries);

    return _EntranceFrame(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: q.space.section),
        itemCount: chapters.length,
        itemBuilder: (context, chapterIndex) {
          final chapter = chapters[chapterIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MonthHeading(
                title: chapter.$1,
                isFirst: chapterIndex == 0,
              ),
              QBirthdayStripChain(
                children: [
                  for (final entry in chapter.$2)
                    _TimelineStrip(entry: entry),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Consecutive month chapters while keeping global days-until order.
  List<(String, List<HomeEntry>)> _monthChapters(List<HomeEntry> entries) {
    if (entries.isEmpty) return const [];
    final chapters = <(String, List<HomeEntry>)>[];
    String? currentLabel;
    var bucket = <HomeEntry>[];

    for (final entry in entries) {
      final label = _months[entry.nextBirthday.month - 1].toUpperCase();
      if (currentLabel == null) {
        currentLabel = label;
        bucket = [entry];
        continue;
      }
      if (label == currentLabel) {
        bucket.add(entry);
        continue;
      }
      chapters.add((currentLabel, bucket));
      currentLabel = label;
      bucket = [entry];
    }
    if (currentLabel != null && bucket.isNotEmpty) {
      chapters.add((currentLabel, bucket));
    }
    return chapters;
  }
}

class _MonthHeading extends StatelessWidget {
  const _MonthHeading({required this.title, required this.isFirst});

  final String title;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final rule = q.color.textTertiary.withValues(alpha: 0.45);

    // Vintage: no bottom gap — first strip chain hangs from this rule.
    // Default: small lead so paper cards clear the divider.
    final hang = context.appTheme.assets.chrome.birthdayStrip != null;
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? q.space.sm : q.space.xl,
        bottom: hang ? 0 : q.space.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: rule)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: q.space.md),
            child: Text(
              title,
              textScaler: context.structuralTextScaler,
              style: q.inked(
                q.text.decorativeLabel,
                tone: QuietInkTone.secondary,
              ),
            ),
          ),
          Expanded(child: Container(height: 1, color: rule)),
        ],
      ),
    );
  }
}

class _TimelineStrip extends ConsumerWidget {
  const _TimelineStrip({required this.entry});

  final HomeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(personPhotoProvider(entry.profile?.photoId));

    return QBirthdayStrip(
      displayName: entry.person.displayName,
      seed: entry.person.id,
      daysUntil: entry.daysUntil,
      dateLabel: entry.birthdayDateLabel,
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
