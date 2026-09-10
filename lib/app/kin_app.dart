import 'package:flutter/material.dart' show MaterialApp, ThemeMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/app/desktop/desktop_phone_shell.dart';
import 'package:kin/app/desktop/phone_shell_frame.dart';
import 'package:kin/app/notification_lifecycle_gate.dart';
import 'package:kin/app/router.dart';
import 'package:kin/app/theme_controller.dart';
import 'package:kin/design/theme/material_shim.dart';

/// The application root.
///
/// [MaterialApp] appears here and nowhere else. It is present only to supply
/// the framework plumbing that Kin's own widgets rely on — routing, overlays,
/// text selection — with a theme that is a thin shim over QuietTheme.
class KinApp extends ConsumerWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themePreferenceProvider);
    final router = ref.watch(routerProvider);
    final definition = preference.definition;
    final quiet = definition.quiet;

    return MaterialApp.router(
      title: 'Kin',
      debugShowCheckedModeBanner: false,
      theme: buildMaterialShim(quiet, appTheme: definition),
      themeMode: ThemeMode.light,
      // A theme change animates over `base` rather than snapping, which is
      // free once QuietTheme.lerp is correct.
      themeAnimationDuration: quiet.motion.base,
      themeAnimationCurve: quiet.motion.standard,
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final gated = NotificationLifecycleGate(
          child: child ?? const SizedBox.shrink(),
        );
        final content = MediaQuery(
          data: media.copyWith(platformBrightness: Brightness.light),
          child: gated,
        );
        if (!wantsDesktopPhoneShell) {
          return content;
        }
        return DesktopPhoneShell(child: content);
      },
    );
  }
}
