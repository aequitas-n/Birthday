import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';

/// Shell framing Today, Kin, and Journal with primary bottom navigation.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final selected = switch (navigationShell.currentIndex) {
      0 => PrimaryDestination.today,
      1 => PrimaryDestination.kin,
      _ => PrimaryDestination.journal,
    };

    return Column(
      children: [
        Expanded(child: navigationShell),
        QPrimaryNav(
          selected: selected,
          onSelected: (destination) {
            navigationShell.goBranch(switch (destination) {
              PrimaryDestination.today => 0,
              PrimaryDestination.kin => 1,
              PrimaryDestination.journal => 2,
            });
          },
        ),
      ],
    );
  }
}
