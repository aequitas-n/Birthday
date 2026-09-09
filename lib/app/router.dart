import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/app_shell.dart';
import 'package:kin/features/gallery/presentation/gallery_screen.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/journal/presentation/journal_day_screen.dart';
import 'package:kin/features/journal/presentation/journal_entry_screen.dart';
import 'package:kin/features/journal/presentation/journal_home_screen.dart';
import 'package:kin/features/person/presentation/person_screen.dart';
import 'package:kin/features/reminders/presentation/reminder_planner_screen.dart';
import 'package:kin/features/settings/presentation/notification_debug_screen.dart';
import 'package:kin/features/settings/presentation/settings_screen.dart';
import 'package:kin/features/today/presentation/today_screen.dart';
import 'package:kin/features/welcome/presentation/welcome_screen.dart';

enum AppRoute {
  welcome('/welcome'),
  today('/'),
  kin('/kin'),
  journal('/journal'),
  journalDay('/journal/:date'),
  journalEntry('/journal/:date/:entryId'),
  person('/person/:id'),
  reminders('/reminders'),
  settings('/settings'),
  gallery('/gallery'),
  debugNotifications('/debug/notifications')
  ;

  const AppRoute(this.path);

  final String path;
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _todayShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'todayShell',
);
final _kinShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'kinShell');
final _journalShellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'journalShell',
);

final routerProvider = Provider<GoRouter>((ref) {
  final initialSettings = ref.watch(initialAppSettingsProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialSettings.onboardingCompletedAt == null
        ? AppRoute.welcome.path
        : AppRoute.today.path,
    routes: [
      GoRoute(
        path: AppRoute.welcome.path,
        name: AppRoute.welcome.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage<void>(child: WelcomeScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _todayShellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.today.path,
                name: AppRoute.today.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: TodayScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _kinShellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.kin.path,
                name: AppRoute.kin.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _journalShellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoute.journal.path,
                name: AppRoute.journal.name,
                pageBuilder: (context, state) => const NoTransitionPage<void>(
                  child: JournalHomeScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.journalDay.path,
        name: AppRoute.journalDay.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _quietPushPage(
          key: state.pageKey,
          child: JournalDayScreen(
            dateKey: state.pathParameters['date'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoute.journalEntry.path,
        name: AppRoute.journalEntry.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _quietPushPage(
          key: state.pageKey,
          child: JournalEntryScreen(
            dateKey: state.pathParameters['date'] ?? '',
            entryId: state.pathParameters['entryId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoute.person.path,
        name: AppRoute.person.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _quietPushPage(
          key: state.pageKey,
          child: PersonScreen(personId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoute.reminders.path,
        name: AppRoute.reminders.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _quietPushPage(
          key: state.pageKey,
          child: const ReminderPlannerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) =>
            _quietPushPage(key: state.pageKey, child: const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoute.gallery.path,
        name: AppRoute.gallery.name,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GalleryScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoute.debugNotifications.path,
          name: AppRoute.debugNotifications.name,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) => _quietPushPage(
            key: state.pageKey,
            child: const NotificationDebugScreen(),
          ),
        ),
    ],
  );
});

CustomTransitionPage<void> _quietPushPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incoming = CurvedAnimation(
        parent: animation,
        curve: const Cubic(0, 0, 0, 1),
        reverseCurve: const Cubic(0.3, 0, 1, 1),
      );

      return FadeTransition(
        opacity: incoming,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(incoming),
          child: child,
        ),
      );
    },
  );
}
