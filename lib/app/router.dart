import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/features/gallery/presentation/gallery_screen.dart';
import 'package:kin/features/home/presentation/home_screen.dart';
import 'package:kin/features/person/presentation/person_screen.dart';
import 'package:kin/features/settings/presentation/notification_debug_screen.dart';
import 'package:kin/features/settings/presentation/settings_screen.dart';
import 'package:kin/features/welcome/presentation/welcome_screen.dart';

enum AppRoute {
  welcome('/welcome'),
  home('/'),
  person('/person/:id'),
  settings('/settings'),
  gallery('/gallery'),
  debugNotifications('/debug/notifications')
  ;

  const AppRoute(this.path);

  final String path;
}

final routerProvider = Provider<GoRouter>((ref) {
  final initialSettings = ref.watch(initialAppSettingsProvider);

  return GoRouter(
    initialLocation: initialSettings.onboardingCompletedAt == null
        ? AppRoute.welcome.path
        : AppRoute.home.path,
    routes: [
      GoRoute(
        path: AppRoute.welcome.path,
        name: AppRoute.welcome.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage<void>(child: WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        pageBuilder: (context, state) =>
            const NoTransitionPage<void>(child: HomeScreen()),
      ),
      GoRoute(
        path: AppRoute.person.path,
        name: AppRoute.person.name,
        pageBuilder: (context, state) => _quietPushPage(
          key: state.pageKey,
          child: PersonScreen(personId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        pageBuilder: (context, state) =>
            _quietPushPage(key: state.pageKey, child: const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoute.gallery.path,
        name: AppRoute.gallery.name,
        builder: (context, state) => const GalleryScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoute.debugNotifications.path,
          name: AppRoute.debugNotifications.name,
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
