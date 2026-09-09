import 'dart:io';

import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';

/// The three concrete themes, for tests that sweep across all of them.
const quietThemes = <String, QuietTheme>{
  'light': QuietTheme.light(),
  'dark': QuietTheme.dark(),
  'amoled': QuietTheme.amoled(),
};

/// The text scales every component must survive.
///
/// 1.0 is the baseline; 1.3 is where structural chrome hits its clamp and the
/// person row restacks.
const quietTextScales = <String, double>{'1.0x': 1, '1.3x': 1.3};

/// Loads the bundled variable fonts into the test binding.
///
/// Without this, every golden renders in the test placeholder font and the
/// typography — which is the whole design — is invisible.
Future<void> loadQuietFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final family in const {
    'Fraunces': 'assets/fonts/Fraunces-Variable.ttf',
    'CourierPrime': 'assets/fonts/CourierPrime-Regular.ttf',
    'Caveat': 'assets/fonts/Caveat-Variable.ttf',
  }.entries) {
    final bytes = File(family.value).readAsBytesSync();
    await (FontLoader(
      family.key,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}

/// Wraps a widget in everything it needs: a provider scope, the Material shim
/// carrying [QuietTheme], and a fixed text scale.
class QuietTestApp extends StatelessWidget {
  const QuietTestApp({
    required this.child,
    this.theme = const QuietTheme.light(),
    this.textScale = 1.0,
    this.devicePixelRatio = 1.0,
    super.key,
  });

  final Widget child;
  final QuietTheme theme;
  final double textScale;
  final double devicePixelRatio;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildMaterialShim(theme),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              devicePixelRatio: devicePixelRatio,
            ),
            child: ColoredBox(
              color: theme.color.canvas,
              child: DefaultTextStyle(
                style: theme.text.body.tinted(theme.color.textPrimary),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension QuietPump on WidgetTester {
  /// Pumps [child] inside a [QuietTestApp] at a fixed surface size.
  Future<void> pumpQuiet(
    Widget child, {
    QuietTheme theme = const QuietTheme.light(),
    double textScale = 1.0,
    Size surfaceSize = const Size(390, 844),
  }) async {
    await binding.setSurfaceSize(surfaceSize);
    view
      ..physicalSize = surfaceSize
      ..devicePixelRatio = 1.0;
    addTearDown(() {
      view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });

    await pumpWidget(
      QuietTestApp(theme: theme, textScale: textScale, child: child),
    );
    await pumpAndSettle();
  }
}
