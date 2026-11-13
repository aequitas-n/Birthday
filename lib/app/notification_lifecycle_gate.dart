import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/phase5_diag.dart';
import 'package:kin/app/router.dart';
import 'package:kin/domain/models/notification_plan.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';
import 'package:kin/notifications/notification_service.dart';

class NotificationLifecycleGate extends ConsumerStatefulWidget {
  const NotificationLifecycleGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationLifecycleGate> createState() =>
      _NotificationLifecycleGateState();
}

class _NotificationLifecycleGateState
    extends ConsumerState<NotificationLifecycleGate>
    with WidgetsBindingObserver {
  StreamSubscription<NotificationLaunchRequest>? _launchSubscription;
  var _integrationEnabled = false;
  var _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    final notificationService = ref.read(notificationServiceProvider);
    if (notificationService is NoopNotificationService) {
      return;
    }
    _integrationEnabled = true;
    WidgetsBinding.instance.addObserver(this);
    _launchSubscription = ref
        .read(notificationCoordinatorProvider)
        .launchRequests
        .listen(_openLaunchRequest);
    // Cold-start initialize + synchronizeStartup already ran on the white
    // bootstrap canvas (see bootstrap.dart). After first paint, only consume
    // launch deep-links and arm resume refresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_finishNotificationBootstrap());
    });
  }

  @override
  void dispose() {
    if (_integrationEnabled) {
      WidgetsBinding.instance.removeObserver(this);
    }
    unawaited(_launchSubscription?.cancel());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_integrationEnabled &&
        state == AppLifecycleState.resumed &&
        _bootstrapped) {
      unawaited(_refreshNotifications());
    }
  }

  Future<void> _finishNotificationBootstrap() async {
    Phase5Diag.mark('notifBootstrap_begin');
    final coordinator = ref.read(notificationCoordinatorProvider);
    final launchRequest = await coordinator.consumeLaunchRequest();
    ref
      ..invalidate(notificationStatusProvider)
      ..invalidate(notificationDebugSnapshotProvider);
    _bootstrapped = true;
    Phase5Diag.mark('notifBootstrap_end');
    if (!mounted || launchRequest == null) {
      return;
    }
    _openLaunchRequest(launchRequest);
  }

  Future<void> _refreshNotifications() async {
    await ref.read(notificationCoordinatorProvider).synchronize();
    ref
      ..invalidate(notificationStatusProvider)
      ..invalidate(notificationDebugSnapshotProvider);
  }

  void _openLaunchRequest(NotificationLaunchRequest request) {
    if (!mounted) return;
    final router = GoRouter.of(context);
    if (request.source == NotificationPlanSource.personal ||
        (request.personId == null || request.personId!.isEmpty)) {
      router.pushNamed(AppRoute.reminders.name);
      return;
    }
    router.pushNamed(
      AppRoute.person.name,
      pathParameters: {'id': request.personId!},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
