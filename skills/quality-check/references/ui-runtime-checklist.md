# Runtime and UI checklist — categories 11 and 12

## 11. Performance, lifecycle, memory

Static checks (report as Verified with `file:line`):

- `build()` is pure: no network calls, database reads, heavy parsing, sorting large lists, or
  object churn that could be cached.
- Every `AnimationController`, `TextEditingController`, `ScrollController`, `FocusNode`,
  `StreamSubscription`, `Timer`, and listener created by a widget is disposed or cancelled.
- After `await`, `context.mounted` (or `mounted`) is checked before using `BuildContext`.
- Rebuild scope: `const` constructors; selective watching (`select`, `BlocSelector`,
  `Selector`); ticking state (timers, progress) kept low in the tree, never rebuilding a screen
  each second.
- Lists use builders (`ListView.builder`, slivers) with stable keys; long lists paginate.
- Images sized for display (`cacheWidth` / `cacheHeight`, resized assets), cached when remote.
- Heavy work (large JSON, image processing) off the UI isolate (`compute`, `Isolate.run`).
- No heavy blur, large shadows, or `Opacity` over large subtrees in scrolling lists.
- App lifecycle handled (`AppLifecycleListener` / `WidgetsBindingObserver`): pause work and
  persist state in background; resume cleanly.
- Startup: no blocking network call before the first frame without a visible state.

Profiling claims (jank, memory, startup time) require a profile-mode run
(`flutter run --profile`, DevTools). If none ran, list them under "not checked".

## 12. Accessibility and responsive UI

Accessibility:

- Interactive elements have meaningful labels (`Semantics`, `tooltip`, `semanticLabel`);
  decorative images excluded (`excludeFromSemantics`, `ExcludeSemantics`).
- Touch targets at least 48 × 48 dp (Android) / 44 × 44 pt (iOS).
- Text scales to 200% without clipping or overflow; no fixed-height text containers.
- Contrast meets WCAG AA: 4.5:1 for text, 3:1 for large text and essential UI marks.
- State is never conveyed by colour alone.
- Reduced motion honoured (`MediaQuery.disableAnimationsOf`); no information only in an
  animation.
- Logical focus and reading order; custom controls expose role and state.
- Widget-test matchers: `meetsGuideline(androidTapTargetGuideline)`,
  `meetsGuideline(iOSTapTargetGuideline)`, `meetsGuideline(labeledTapTargetGuideline)`,
  `meetsGuideline(textContrastGuideline)`.

Responsive:

- Layout adapts by available width (`MediaQuery.sizeOf`, `LayoutBuilder`), not by device type.
- Representative sizes: small phone (~360 × 640), large phone (~430 × 932), iPad portrait and
  landscape, iPad split-screen widths, foldable postures where targeted.
- Navigation adapts at width breakpoints (bottom bar → rail → extended rail or sidebar).
- Safe areas, notches, Dynamic Island, home indicator, gesture navigation handled where the
  layout needs it.
- Keyboard never covers the primary action or the focused field (`viewInsets`).
- Orientation changes and window resizing keep state.
- Content width capped on large screens for readability.

Visual comparison against a design is reported as an approximation unless a golden test or a
pixel comparison actually ran.
