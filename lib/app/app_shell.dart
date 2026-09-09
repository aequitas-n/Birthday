import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';

/// Shell framing Today, Kin, and Journal with primary bottom navigation.
///
/// Root tabs use **parent back-target semantics**, not a visit stack. Switching
/// Kin ↔ Journal repeatedly does not accumulate back entries — back always
/// unwinds: internal child route → parent module → Today → exit.
///
/// Kin's Birthdays/People modes are local home-screen state and never appear
/// here. Child routes (person, journal day, …) live on the root navigator and
/// pop before this shell back-target is consulted.
class AppShell extends StatefulWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  /// Where the Journal tab returns on system back (0 Today or 1 Kin).
  int _journalBackTarget = 0;

  /// True while [StatefulNavigationShell.goBranch] is driven by our own
  /// navigation write (select or back).
  var _mutatingBranch = false;

  StatefulNavigationShell get _shell => widget.navigationShell;

  PrimaryDestination get _selected => switch (_shell.currentIndex) {
    0 => PrimaryDestination.today,
    1 => PrimaryDestination.kin,
    _ => PrimaryDestination.journal,
  };

  int _indexFor(PrimaryDestination destination) => switch (destination) {
    PrimaryDestination.today => 0,
    PrimaryDestination.kin => 1,
    PrimaryDestination.journal => 2,
  };

  /// Test seam — module index the Journal tab will return to on back.
  @visibleForTesting
  int get debugJournalBackTarget => _journalBackTarget;

  /// Test seam — active shell branch (0 Today, 1 Kin, 2 Journal).
  @visibleForTesting
  int get debugActiveModule => _shell.currentIndex;

  /// Legacy test seam — encodes [debugActiveModule] and [debugJournalBackTarget].
  @visibleForTesting
  List<int> get debugModuleHistory => [
    _shell.currentIndex,
    if (_shell.currentIndex == 2) _journalBackTarget,
  ];

  void _selectModule(PrimaryDestination destination) {
    final newIndex = _indexFor(destination);
    final oldIndex = _shell.currentIndex;
    if (newIndex == oldIndex) return;

    if (newIndex == 2) {
      // Journal always backs to whichever module we came from.
      _journalBackTarget = oldIndex;
    }

    _goBranch(newIndex);
  }

  void _goBranch(int index) {
    _mutatingBranch = true;
    _shell.goBranch(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mutatingBranch = false;
    });
  }

  /// System back from a root tab. Returns false when Today should exit the app.
  bool _handleRootBack() {
    final current = _shell.currentIndex;
    if (current == 0) return false;

    final target = switch (current) {
      1 => 0, // Kin → Today
      2 => _journalBackTarget, // Journal → Kin or Today
      _ => 0,
    };

    _goBranch(target);
    return true;
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mutatingBranch) return;

    // External navigation (e.g. Today "See all" → goNamed(kin)).
    final index = _shell.currentIndex;
    final oldIndex = oldWidget.navigationShell.currentIndex;
    if (index != oldIndex && index == 2) {
      _journalBackTarget = oldIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onToday = _shell.currentIndex == 0;

    return PopScope(
      canPop: onToday,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleRootBack();
      },
      child: Column(
        children: [
          Expanded(child: _shell),
          QPrimaryNav(
            selected: _selected,
            onSelected: _selectModule,
          ),
        ],
      ),
    );
  }
}
