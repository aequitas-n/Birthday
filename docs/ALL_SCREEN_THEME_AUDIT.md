# Theme coverage across the app

Reference: **Vintage Diary**, with the same feature widgets and sample data checked under refreshed **Neon Arcade**, **Retro Postcard**, **Sunday Comics**, **Botanical Sketchbook**, **Seaside Watercolor**, and **Midnight Storybook**.

Open [the screen review](../artwork/screens/index.html) to browse the real Flutter captures by theme, or compare the same view across all seven. There are **336 captures: 48 views for each of the seven themes**. These are captures of the production widgets with deterministic sample data, bundled fonts, and reduced motion; they are not concept mockups.

## Coverage

| Area | Screens, sections, and overlays reviewed |
| --- | --- |
| Today | Populated journal preview, first-memory invitation, birthdays, coming up, reminders, primary navigation |
| Kin | Birthdays tab and birthday tags; People tab, search, populated and empty profile cards; profile creation chooser and existing-birthday picker |
| Person | Identity, Moments collection, photo review, Notes, favorites, gifts, plans, and empty sections |
| Profile | Existing profile and new profile sheets, photo controls, name/nickname, relationships, and scrolled memory sections |
| Journal | Month calendar and markers; populated and empty days; card deck; readable compact layout; day mood picker |
| Memory | Reading writing/list fragments; new and existing editors; fragment chooser; memory mood picker; audio recording sheet |
| Notes | Standard note editor, active gift editor with Mark as given, custom category fields, important-date fields, kind selector, and confirmation sheet |
| Reminders | Populated/empty planner, week navigation, date strip, reminder editor, hour/minute and AM/PM controls |
| Settings | Appearance, privacy, reminders, permissions, timezone picker, lower settings, version, notification inspector |
| Onboarding | All three panels and their navigation |
| Design gallery | Active theme identity, typography, color, cards, chips, buttons, glyphs, avatars, rows, fields, loading/surfaces, sheets, empty states, back navigation |
| Keyboard and scaling | Birthday and reminder sheets with keyboard insets; 320 × 640 at 160% text across the same screens; scrolled lower sections |

All 11 application routes in `lib/app/router.dart` are included. Modal routes and sheets opened by the public feature flows are also exercised. Android's camera, photo library, permission prompts, and keyboard are OS-owned interfaces; the Flutter views around them use the selected theme.

## Corrections from this audit

- Shared sheets, writing wells, journal paper, generic cards, and Person's Moments/Notes plates now use the active illustration direction, beyond merely inheriting its colors.
- Full photo review now uses the selected theme's canvas.
- The reminder week strip adapts to narrow layouts and uses the theme's calendar paper.
- Large text and short screens receive scrollable day-memory and person-detail layouts, preserving readable text rather than squeezing a fixed deck/header.
- People card prompts flex within their available width.
- Sheet actions wrap and allow the gift editor's existing third action; the previous two-action assertion caused a debug crash when editing an active gift.
- The existing-birthday picker scrolls as the list grows.
- Welcome panels scroll with large text and include each theme's ambient illustration.
- The design gallery reports the active theme, has a back button, and wraps its surface samples.
- The loading arc and field caret honor reduced motion. Journal fragment mood washes resolve the current brightness.

## Reproduce

```sh
flutter test --no-pub test/design/all_screens_theme_audit_test.dart \
  --dart-define=EXPORT_THEME_AUDIT=true
flutter test --no-pub --exclude-tags golden
flutter analyze lib --no-pub --no-fatal-infos
dart run tool/check_architecture.dart
```

The audit asserts that the rendered backgrounds, surface painters, and animated illustration widgets belong to the selected theme. Both normal and compact layouts must render without Flutter exceptions. It also opens actual modal routes, checks keyboard layouts, and scrolls the longer sections. Platform-dependent golden baselines are separate from this render audit.

Validation: **333 non-golden regression tests pass**, including the complete 14-case theme/viewport matrix. The architecture guard passes across 210 source files. The full-project strict analyzer passes with no findings.

The typography pass assigns a distinct heading/journal pair to every illustrated theme and uses shared DM Sans / DM Mono functional UI. All 336 captures were regenerated with the bundled fonts loaded. See [the typography specification](THEME_TYPOGRAPHY.md).
