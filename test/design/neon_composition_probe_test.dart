import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/design/components/navigation/q_primary_nav.dart';
import 'package:kin/design/components/surfaces/q_theme_surfaces.dart';
import 'package:kin/design/theme/product_themes.dart';
import 'package:kin/design/theme/quiet_theme.dart';
import 'package:kin/design/theme/quiet_theme_x.dart';
import 'package:kin/design/tokens/vintage_portrait_geometry.dart';

import '../support/quiet_test_app.dart';

/// Smoke layout checks for Neon Arcade composition (no golden dependency).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadQuietFonts);

  for (final size in const [
    Size(320, 720),
    Size(390, 844),
    Size(430, 932),
  ]) {
    testWidgets('Neon Today composition survives ${size.width.toInt()}w', (
      tester,
    ) async {
      await tester.pumpQuiet(
        const _NeonTodayProbe(),
        theme: const QuietTheme.neonArcade(),
        appTheme: ProductThemes.neonArcade,
        surfaceSize: size,
      );
      await tester.pumpQuietImages();
      expect(tester.takeException(), isNull);
      expect(find.text("Today's journal"), findsOneWidget);
      expect(find.text('Nothing written yet.'), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
    });
  }

  testWidgets('Neon People plate uses theme aspect and light paper ink', (
    tester,
  ) async {
    await tester.pumpQuiet(
      const _NeonPeopleProbe(),
      theme: const QuietTheme.neonArcade(),
      appTheme: ProductThemes.neonArcade,
      surfaceSize: const Size(390, 844),
    );
    await tester.pumpQuietImages();
    expect(tester.takeException(), isNull);
    expect(find.text('Alex Rivera'), findsOneWidget);

    final layout = ProductThemes.neonArcade.assets.layout.profileCard!;
    expect(layout.aspectRatio, closeTo(941 / 1672, 0.001));
    expect(layout.clipPlateCorners, isFalse);
    expect(
      ProductThemes.neonArcade.assets.layout.galleryCardWidthFraction,
      1.0,
    );
  });
}

class _NeonTodayProbe extends StatelessWidget {
  const _NeonTodayProbe();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    return Stack(
      fit: StackFit.expand,
      children: [
        const QuietThemeBackdrop(includeScrim: false),
        Column(
          children: [
            Expanded(
              child: QThemeCanvas(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: q.space.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: q.space.lg),
                        Text(
                          "Today's journal",
                          style: q.inked(q.text.sectionTitle),
                        ),
                        SizedBox(height: q.space.sectionLead),
                        QJournalCardSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '10',
                                style: q.inked(
                                  q.text.editorialBody,
                                  surface: QuietSurfaceKind.paper,
                                ),
                              ),
                              Text(
                                'September',
                                style: q.inked(
                                  q.text.decorativeLabel,
                                  surface: QuietSurfaceKind.paper,
                                  tone: QuietInkTone.secondary,
                                ),
                              ),
                              SizedBox(height: q.space.md),
                              Text(
                                'Nothing written yet.',
                                style: q.inked(
                                  q.text.journalPrompt,
                                  surface: QuietSurfaceKind.paper,
                                ),
                              ),
                              SizedBox(height: q.space.xs),
                              Text(
                                'What do you want to remember?',
                                style: q.inked(
                                  q.text.journalWriting,
                                  surface: QuietSurfaceKind.paper,
                                  tone: QuietInkTone.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            QPrimaryNav(
              selected: PrimaryDestination.today,
              onSelected: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}

class _NeonPeopleProbe extends StatelessWidget {
  const _NeonPeopleProbe();

  @override
  Widget build(BuildContext context) {
    final q = context.quiet;
    final layout = context.appTheme.assets.layout;
    return Stack(
      fit: StackFit.expand,
      children: [
        const QuietThemeBackdrop(includeScrim: false),
        Column(
          children: [
            Expanded(
              child: QThemeCanvas(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = VintagePortraitLayout.fitIn(
                      maxWidth: constraints.maxWidth - q.space.lg * 2,
                      maxHeight: constraints.maxHeight * 0.75,
                      widthFraction: layout.galleryCardWidthFraction ??
                          q.layout.galleryCardWidthFraction,
                      aspectRatio: layout.profileCard?.aspectRatio ??
                          ProfileCardGeometry.aspectRatio,
                    );
                    final asset = context.appTheme.assets.chrome.profileCard!;
                    final photo = layout.profileCard;
                    return Center(
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(asset, fit: BoxFit.cover),
                            Positioned(
                              left: size.width * (photo?.photoLeft ?? 0.14),
                              right: size.width *
                                  (1 - (photo?.photoRight ?? 0.86)),
                              top: size.height * (photo?.photoTop ?? 0.11),
                              bottom: size.height *
                                  (1 - (photo?.photoBottom ?? 0.66)),
                              child: const ColoredBox(color: Color(0xFF334455)),
                            ),
                            Positioned(
                              left: size.width * (photo?.textLeft ?? 0.1),
                              right: size.width *
                                  (1 - (photo?.textRight ?? 0.9)),
                              bottom:
                                  size.height * (photo?.textBottom ?? 0.055),
                              child: Text(
                                'Alex Rivera',
                                textAlign: TextAlign.center,
                                style: q.inked(
                                  q.text.personName,
                                  surface: QuietSurfaceKind.paper,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            QPrimaryNav(
              selected: PrimaryDestination.kin,
              onSelected: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}
