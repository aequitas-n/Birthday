import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/components/surfaces/q_illustrated_surface.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/domain/models/local_calendar_date.dart';
import 'package:kin/features/home/application/home_providers.dart';
import 'package:kin/features/journal/application/journal_providers.dart';
import 'package:kin/features/reminders/application/reminder_providers.dart';
import 'package:kin/features/today/application/today_providers.dart';
import 'package:kin/features/today/presentation/today_screen.dart';

import '../support/quiet_test_app.dart';

// Also produces reviewable PNGs from the actual Flutter components:
// flutter test test/design/illustrated_theme_preview_test.dart \
//   --dart-define=EXPORT_THEME_ART=true
const _export = bool.fromEnvironment('EXPORT_THEME_ART');

Future<void> _save(WidgetTester tester, GlobalKey key, String filename) async {
  if (!_export) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(filename);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(loadQuietFonts);
  for (final theme in ProductThemes.all.where((theme) => theme.art != null)) {
    testWidgets(
      '${theme.label} renders its complete daily scene and surface set',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              journalTodayProvider.overrideWithValue(
                const LocalCalendarDate(year: 2026, month: 11, day: 14),
              ),
              journalEntriesProvider.overrideWith(
                (ref, key) => Stream.value(const []),
              ),
              todayActiveRemindersProvider.overrideWithValue(const []),
              todayUpcomingProvider.overrideWithValue(const []),
              todayBirthdayProvider.overrideWithValue(const []),
              peopleStreamProvider.overrideWith(
                (ref) => Stream.value(const []),
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: buildMaterialShim(theme.quiet, appTheme: theme),
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(390, 844),
                  disableAnimations: true,
                ),
                child: RepaintBoundary(
                  key: key,
                  child: QThemeCanvas(
                    child: QuietShellBackdropScope(
                      child: Column(
                        children: [
                          const Expanded(child: TodayScreen()),
                          QPrimaryNav(
                            selected: PrimaryDestination.today,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.pumpQuietImages(const Duration(milliseconds: 250));
        expect(find.text('Add memory'), findsOneWidget);
        expect(find.text(theme.art!.invitation), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _save(tester, key, 'artwork/previews/${theme.art!.folder}.png');

        for (final kind in IllustratedSurfaceKind.values) {
          final surfaceKey = GlobalKey();
          final size = switch (kind) {
            IllustratedSurfaceKind.navigation => const Size(360, 64),
            IllustratedSurfaceKind.search => const Size(360, 56),
            IllustratedSurfaceKind.tag => const Size(360, 100),
            IllustratedSurfaceKind.profile => const Size(300, 440),
            IllustratedSurfaceKind.calendar => const Size(360, 340),
            IllustratedSurfaceKind.card => const Size(360, 280),
          };
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: RepaintBoundary(
                  key: surfaceKey,
                  child: SizedBox.fromSize(
                    size: size,
                    child: QIllustratedSurface(
                      art: theme.art,
                      kind: kind,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          await _save(
            tester,
            surfaceKey,
            'artwork/surfaces/${theme.art!.folder}/${kind.name}.png',
          );
        }
      },
    );
  }
}
