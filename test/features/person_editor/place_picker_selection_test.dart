import 'package:flutter/material.dart' show MaterialApp, Scaffold;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/core/id.dart';
import 'package:kin/data/timezone/city_dataset.dart';
import 'package:kin/data/timezone/device_timezone.dart';
import 'package:kin/design/theme/material_shim.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/features/person_editor/application/person_editor_notifier.dart';
import 'package:kin/features/person_editor/presentation/add_person_sheet.dart';
import 'package:kin/notifications/application/notification_coordinator.dart';

import '../../support/quiet_test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadQuietFonts);

  testWidgets('Where they live shows the city after location is set', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late WidgetRef hostRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          idGeneratorProvider.overrideWithValue(
            const _FixedIdGenerator('draft-city'),
          ),
          deviceTimezoneSourceProvider.overrideWithValue(
            const DeviceTimezoneSource(fixedIanaName: 'Asia/Kolkata'),
          ),
        ],
        child: MaterialApp(
          theme: buildMaterialShim(const QuietTheme.dark()),
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                hostRef = ref;
                return const AddPersonSheet();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a city'), findsOneWidget);
    expect(find.textContaining('Tap to search'), findsOneWidget);

    hostRef
        .read(personEditorProvider.notifier)
        .setLocation(cityDataset.firstWhere((city) => city.city == 'Chennai'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a city'), findsNothing);
    expect(find.text('Chennai'), findsOneWidget);
    expect(find.text('Chennai, Tamil Nadu, India'), findsOneWidget);
  });
}

class _FixedIdGenerator extends IdGenerator {
  const _FixedIdGenerator(this.value);

  final String value;

  @override
  String next() => value;
}
