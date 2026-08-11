import 'package:flutter/widgets.dart';
import 'package:kin/design/components/fields/q_note_kind_picker.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/domain/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How detail kinds are grouped in the add/edit sheet.
enum DetailKindSection {
  favorites('Favorites'),
  gift('Gift'),
  plan('Plan'),
  note('Note')
  ;

  const DetailKindSection(this.title);

  final String title;

  static const defaultOrder = <DetailKindSection>[
    DetailKindSection.favorites,
    DetailKindSection.gift,
    DetailKindSection.plan,
    DetailKindSection.note,
  ];

  static DetailKindSection? tryParse(String raw) {
    for (final section in values) {
      if (section.name == raw) return section;
    }
    return null;
  }

  List<NoteKind> get kinds {
    return switch (this) {
      DetailKindSection.favorites => _favoriteKindsSorted,
      DetailKindSection.gift => const [NoteKind.giftIdea],
      DetailKindSection.plan => const [NoteKind.plan],
      DetailKindSection.note => const [
        NoteKind.free,
        NoteKind.importantDate,
        NoteKind.custom,
      ],
    };
  }

  static DetailKindSection? forKind(NoteKind kind) {
    if (kind == NoteKind.photo) return null;
    for (final section in values) {
      if (section.kinds.contains(kind)) return section;
    }
    return DetailKindSection.note;
  }
}

/// Groups text details into Favorites / Gift / Plan / Note, in [order].
///
/// Empty sections are omitted. Favorites within a section sort A–Z by kind label.
List<(DetailKindSection section, List<Note> notes)> groupNotesByDetailSection(
  Iterable<Note> notes, {
  List<DetailKindSection> order = DetailKindSection.defaultOrder,
}) {
  final textNotes = notes
      .where((n) => !n.isPhotoMemory)
      .toList(growable: false);
  final grouped = <(DetailKindSection, List<Note>)>[];

  for (final section in order) {
    final inSection = textNotes
        .where((n) => section.kinds.contains(n.kind))
        .toList();
    if (section == DetailKindSection.favorites) {
      inSection.sort(
        (a, b) => _labelForKind(a.kind).toLowerCase().compareTo(
          _labelForKind(b.kind).toLowerCase(),
        ),
      );
    }
    if (inSection.isNotEmpty) {
      grouped.add((section, inSection));
    }
  }

  return grouped;
}

/// Favorite kinds A–Z by their display label.
final List<NoteKind> _favoriteKindsSorted = () {
  const kinds = <NoteKind>[
    NoteKind.flower,
    NoteKind.colour,
    NoteKind.food,
    NoteKind.dessert,
    NoteKind.drink,
    NoteKind.movie,
    NoteKind.music,
    NoteKind.restaurant,
    NoteKind.place,
  ];
  final sorted = [...kinds]
    ..sort(
      (a, b) => _labelForKind(a).toLowerCase().compareTo(
        _labelForKind(b).toLowerCase(),
      ),
    );
  return List<NoteKind>.unmodifiable(sorted);
}();

String _labelForKind(NoteKind kind) {
  return switch (kind) {
    NoteKind.flower => 'Favorite flower',
    NoteKind.colour => 'Favorite color',
    NoteKind.food => 'Favorite food',
    NoteKind.dessert => 'Favorite dessert',
    NoteKind.drink => 'Favorite drink',
    NoteKind.movie => 'Favorite movie',
    NoteKind.music => 'Favorite music',
    NoteKind.restaurant => 'Favorite restaurant',
    NoteKind.place => 'Favorite place',
    NoteKind.giftIdea => 'Gift idea',
    NoteKind.plan => 'Plan',
    NoteKind.importantDate => 'Important date',
    NoteKind.free => 'Note',
    NoteKind.custom => 'Something else',
    NoteKind.photo => 'Photo',
  };
}

const _sectionOrderPrefsKey = 'detail_kind_section_order';

Future<List<DetailKindSection>> loadDetailKindSectionOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList(_sectionOrderPrefsKey);
  if (raw == null || raw.isEmpty) {
    return List<DetailKindSection>.from(DetailKindSection.defaultOrder);
  }
  final parsed = <DetailKindSection>[];
  for (final name in raw) {
    final section = DetailKindSection.tryParse(name);
    if (section != null && !parsed.contains(section)) {
      parsed.add(section);
    }
  }
  for (final section in DetailKindSection.defaultOrder) {
    if (!parsed.contains(section)) parsed.add(section);
  }
  return parsed;
}

Future<void> saveDetailKindSectionOrder(List<DetailKindSection> order) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    _sectionOrderPrefsKey,
    order.map((section) => section.name).toList(growable: false),
  );
}

/// Kind chips grouped into Favorites / Gift / Plan / Note.
///
/// Lives inside the sheet's own scroll view — no nested list (ReorderableListView
/// inside a sheet was crashing with `_owner != null` / duplicate GlobalKeys).
/// Long-press a section title and drop it on another to reorder.
class DetailKindPicker extends StatefulWidget {
  const DetailKindPicker({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final NoteKind selected;
  final ValueChanged<NoteKind> onSelected;

  @override
  State<DetailKindPicker> createState() => _DetailKindPickerState();
}

class _DetailKindPickerState extends State<DetailKindPicker> {
  List<DetailKindSection> _order = List<DetailKindSection>.from(
    DetailKindSection.defaultOrder,
  );
  DetailKindSection? _dragging;
  DetailKindSection? _hovering;

  @override
  void initState() {
    super.initState();
    _restoreOrder();
  }

  Future<void> _restoreOrder() async {
    final order = await loadDetailKindSectionOrder();
    if (!mounted) return;
    setState(() => _order = order);
  }

  Future<void> _moveSection(
    DetailKindSection from,
    DetailKindSection to,
  ) async {
    if (from == to) return;
    final oldIndex = _order.indexOf(from);
    final newIndex = _order.indexOf(to);
    if (oldIndex < 0 || newIndex < 0) return;
    setState(() {
      final section = _order.removeAt(oldIndex);
      _order.insert(newIndex, section);
      _dragging = null;
      _hovering = null;
    });
    await saveDetailKindSectionOrder(_order);
  }

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _order.length; index++) ...[
          if (index > 0) SizedBox(height: q.space.lg),
          _SectionBlock(
            section: _order[index],
            selected: widget.selected,
            highlighted:
                _hovering == _order[index] && _dragging != _order[index],
            dimmed: _dragging == _order[index],
            onSelected: widget.onSelected,
            onDragStarted: () => setState(() => _dragging = _order[index]),
            onDragEnded: () => setState(() {
              _dragging = null;
              _hovering = null;
            }),
            onHover: (section) => setState(() => _hovering = section),
            onAccept: (from) => _moveSection(from, _order[index]),
          ),
        ],
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
    required this.selected,
    required this.highlighted,
    required this.dimmed,
    required this.onSelected,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onHover,
    required this.onAccept,
  });

  final DetailKindSection section;
  final NoteKind selected;
  final bool highlighted;
  final bool dimmed;
  final ValueChanged<NoteKind> onSelected;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<DetailKindSection?> onHover;
  final ValueChanged<DetailKindSection> onAccept;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;

    return DragTarget<DetailKindSection>(
      onWillAcceptWithDetails: (details) {
        onHover(section);
        return details.data != section;
      },
      onLeave: (_) => onHover(null),
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        return Opacity(
          opacity: dimmed ? 0.35 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: highlighted ? q.color.accent : q.color.canvas,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: q.space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LongPressDraggable<DetailKindSection>(
                    data: section,
                    onDragStarted: onDragStarted,
                    onDragEnd: (_) => onDragEnded(),
                    onDraggableCanceled: (_, _) => onDragEnded(),
                    feedback: DecoratedBox(
                      decoration: BoxDecoration(
                        color: q.color.raised,
                        borderRadius: BorderRadius.circular(q.radius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: q.color.scrim,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: q.space.md,
                          vertical: q.space.sm,
                        ),
                        child: Text(
                          section.title.toUpperCase(),
                          style: q.text.eyebrow.tinted(q.color.accent),
                        ),
                      ),
                    ),
                    childWhenDragging: _SectionHeader(title: section.title),
                    child: _SectionHeader(title: section.title),
                  ),
                  SizedBox(height: q.space.sm),
                  QPillGroup(
                    options: [
                      for (final kind in section.kinds) _labelForKind(kind),
                    ],
                    selected: section.kinds.contains(selected)
                        ? _labelForKind(selected)
                        : null,
                    onSelected: (label) {
                      final kind = section.kinds.firstWhere(
                        (entry) => _labelForKind(entry) == label,
                      );
                      onSelected(kind);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: q.space.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              textScaler: context.structuralTextScaler,
              style: q.text.eyebrow.tinted(q.color.textTertiary),
            ),
          ),
          Text(
            '≡',
            style: q.text.metadata.tinted(q.color.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Display label for a note kind — shared with the editor sheet.
String detailKindLabel(NoteKind kind) => _labelForKind(kind);

/// Subtitle under a note in a sectioned list.
///
/// Favorite kinds omit the label — the subtype header above the cluster
/// already says "Favorite flower". Plan / gift omit too (section header).
/// Free notes only show a remembered when-line when set.
String? noteRowSubtitle(Note note) {
  switch (note.kind) {
    case NoteKind.plan:
    case NoteKind.giftIdea:
    case NoteKind.photo:
    case NoteKind.flower:
    case NoteKind.colour:
    case NoteKind.food:
    case NoteKind.dessert:
    case NoteKind.drink:
    case NoteKind.movie:
    case NoteKind.music:
    case NoteKind.restaurant:
    case NoteKind.place:
      return null;
    case NoteKind.free:
      return note.rememberedWhenDisplay;
    case NoteKind.importantDate:
      return 'Important date';
    case NoteKind.custom:
      final custom = note.label?.trim();
      if (custom == null || custom.isEmpty) return null;
      return custom;
  }
}

/// Expands a section's notes into rows with an optional subtype header.
///
/// Favorites already sort by kind, so contiguous flowers share one
/// "Favorite flower" header. Other sections never emit kind headers.
Iterable<(String? kindHeader, Note note)> notesWithKindHeaders(
  DetailKindSection section,
  List<Note> notes,
) sync* {
  NoteKind? previous;
  for (final note in notes) {
    String? header;
    if (section == DetailKindSection.favorites && note.kind != previous) {
      header = detailKindLabel(note.kind);
    }
    previous = note.kind;
    yield (header, note);
  }
}

/// Secondary line under a note value in a sectioned list.
///
/// Returns `null` when the section header already says what the kind is
/// (Plan, Gift, bare Note). Favorites keep specific labels ("Favorite flower").
/// Free notes keep only a remembered-when line when present.
String? noteListSubtitle(Note note) {
  return switch (note.kind) {
    NoteKind.plan || NoteKind.giftIdea || NoteKind.photo => null,
    NoteKind.free => note.rememberedWhenDisplay,
    NoteKind.custom => () {
      final custom = note.label?.trim();
      if (custom != null && custom.isNotEmpty) return custom;
      return _labelForKind(NoteKind.custom);
    }(),
    NoteKind.importantDate ||
    NoteKind.flower ||
    NoteKind.colour ||
    NoteKind.food ||
    NoteKind.dessert ||
    NoteKind.drink ||
    NoteKind.movie ||
    NoteKind.music ||
    NoteKind.restaurant ||
    NoteKind.place => _labelForKind(note.kind),
  };
}
