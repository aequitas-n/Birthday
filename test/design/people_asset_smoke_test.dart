import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/fields/q_people_search_strip.dart';
import 'package:kin/design/components/surfaces/q_screen.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/tokens/vintage_diary_tokens.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);

  testWidgets('People-style MaterialApp still loads Vintage search + bg', (tester) async {
    const theme = QuietTheme.light();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view..physicalSize = const Size(390, 844)..devicePixelRatio = 1;
    addTearDown(() {
      tester.view..resetPhysicalSize()..resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMaterialShim(theme),
        home: const QScreen(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: QPeopleSearchStrip(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final paths = collectAssetImagePaths(tester);
    print('paths=$paths');
    expect(paths, contains(VintageDiaryAssets.background));
    expect(paths, contains(VintageDiaryAssets.search));
  });
}
