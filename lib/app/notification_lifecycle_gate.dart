import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kin/app/app_providers.dart';
import 'package:kin/app/router.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapNotifications());
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

  Future<void> _bootstrapNotifications() async {
    final coordinator = ref.read(notificationCoordinatorProvider);
    await coordinator.initialize();
    final launchRequest = await coordinator.consumeLaunchRequest();
    await coordinator.synchronizeStartup();
    ref
      ..invalidate(notificationStatusProvider)
      ..invalidate(notificationDebugSnapshotProvider);
    _bootstrapped = true;
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
    GoRouter.of(
      context,
    ).pushNamed(AppRoute.person.name, pathParameters: {'id': request.personId});
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
