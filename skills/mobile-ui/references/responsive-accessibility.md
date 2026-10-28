# Responsive layout and accessibility

## Window classes (by available width, in logical pixels)

| Class | Width | Typical layout | Navigation |
|---|---|---|---|
| Compact | < 600 | Single pane | Bottom navigation bar |
| Medium | 600–839 | Single pane with wider gutters, or list-detail in landscape | Navigation rail |
| Expanded | 840–1199 | List-detail, two panes | Navigation rail or extended rail |
| Large / extra large | ≥ 1200 | Two or three panes, capped content width | Extended rail or sidebar |

Use the window's available width (`MediaQuery.sizeOf(context).width` or `LayoutBuilder`
constraints), never the device model. An iPad in narrow Split View or Slide Over is a compact
window; a phone in landscape stays on phone metrics unless the width says otherwise.

## Layout rules

- Cap reading width on large windows (around 840 for content, 480 for forms) and centre it.
- Lists become list-detail on expanded widths; keep selection state when the window resizes.
- Grids derive column count from width (`SliverGridDelegateWithMaxCrossAxisExtent`).
- No fixed heights on containers that hold text.
- Foldables: avoid placing content across a hinge (`MediaQuery.displayFeaturesOf(context)`).

## Insets, keyboard, orientation

- Edge-to-edge: content may draw under system bars; apply `SafeArea` or padding where the layout
  needs it (usually scroll content and bottom action bars), not around every screen.
- Keyboard: `MediaQuery.viewInsetsOf(context).bottom`; forms scroll; the focused field and the
  primary action stay visible; a sheet's primary action is never covered.
- Notch, Dynamic Island, home indicator, gesture navigation, and 3-button navigation all leave
  interactive content reachable.
- Orientation changes and window resizes keep state (controllers and scroll positions survive).

## iPad specifics

- Support the multitasking widths (Split View, Slide Over, Stage Manager) unless full-screen is
  justified; test at narrow and full widths.
- Hardware keyboard: logical focus traversal, `Shortcuts` / `CallbackShortcuts` for frequent
  actions, Escape closes dialogs.
- Pointer: hover states where they help; large-screen menus and popovers instead of full-screen
  sheets where natural.

## Accessibility

- Labels: every interactive element has a meaningful label (`Semantics(label:)`, `tooltip`,
  `semanticLabel`); decorative images are excluded (`excludeFromSemantics: true`).
- Merge related content into one node (`MergeSemantics`) so a card reads as one item; use
  `Semantics(container: true, button: true)` for custom tappable areas.
- Touch targets: at least 48 × 48 dp; 44 × 44 pt is Apple's minimum.
- Text scaling: layouts hold at 200%; use `TextScaler` from `MediaQuery`; never clamp scaling to
  1.0 globally.
- Contrast: WCAG AA (4.5:1 text, 3:1 large text and essential non-text UI) in both themes.
- Never colour alone: pair status colour with an icon, label, or shape.
- Reduced motion: honour `MediaQuery.disableAnimationsOf(context)`; no information only in motion.
- Announce important changes (`SemanticsService.announce`) when focus does not move to them.
- Verify with TalkBack and VoiceOver on devices for core flows; widget tests cover the rest.

## Test recipe

```dart
Future<void> pumpAtSize(
  WidgetTester tester,
  Widget app, {
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(app);
  await tester.pump();
  expect(tester.takeException(), isNull); // no overflow or layout errors
}
```

Representative sizes: `Size(360, 640)` small phone · `Size(430, 932)` large phone ·
`Size(744, 1133)` small iPad portrait · `Size(1366, 1024)` large iPad landscape ·
`Size(375, 1024)` iPad split view.

Accessibility matchers:

```dart
final handle = tester.ensureSemantics();
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
await expectLater(tester, meetsGuideline(textContrastGuideline));
handle.dispose();
```

If the project's test harness already wraps sizes, themes, and text scale, use it instead.
