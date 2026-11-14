import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/feedback/q_pressable.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/theme/product_themes.dart';

import '../support/quiet_test_app.dart';

void main() {
  setUpAll(loadQuietFonts);
  for (final theme in ProductThemes.all) {
    testWidgets(
      '${theme.label}: navigation respects the home indicator and touch targets',
      (tester) async {
        PrimaryDestination? selected;
        await tester.pumpQuiet(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(bottom: 34),
              viewPadding: EdgeInsets.only(bottom: 34),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: QPrimaryNav(
                selected: PrimaryDestination.today,
                onSelected: (value) => selected = value,
              ),
            ),
          ),
          theme: theme.quiet,
          appTheme: theme,
        );
        final size = tester.getSize(find.byType(QPrimaryNav));
        expect(size.width, 390);
        expect(size.height, lessThan(130));
        for (final destination in PrimaryDestination.values) {
          final hit = find.byWidgetPredicate(
            (widget) =>
                widget is QPressable &&
                widget.semanticLabel == destination.label,
          );
          final target = tester.getRect(hit);
          expect(
            target.width,
            greaterThanOrEqualTo(theme.quiet.layout.minTouchTarget),
          );
          expect(
            target.height,
            greaterThanOrEqualTo(theme.quiet.layout.minTouchTarget),
          );
          expect(target.bottom, lessThanOrEqualTo(810));
          await tester.tap(find.text(destination.label));
          expect(selected, destination);
        }
        expect(find.byType(Image), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
