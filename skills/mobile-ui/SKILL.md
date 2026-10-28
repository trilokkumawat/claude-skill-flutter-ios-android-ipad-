---
name: mobile-ui
description: Build or refine premium Flutter UI for Android phones, iPhones, and iPads on a consistent design system — tokens, reusable components, screens with loading, empty, error, offline, disabled, and success states, adaptive layouts, safe areas and keyboard, accessibility, dark mode, reduced motion, and platform conventions — with business logic kept out of widgets. Use when creating or changing a screen, component, theme, or design system, matching a design reference, or reviewing a screen's UI.
argument-hint: "[design-system | screen | component | refine | review] [name or path]"
---

# Mobile UI

Load the `mobile-standards` skill first (in the plugin: `flutter-mobile-kit:mobile-standards`).
References for this skill are in `${CLAUDE_SKILL_DIR}/references/`.

Arguments: `$ARGUMENTS` — a mode and a target. Modes: `design-system` (create or extend tokens and
theme), `screen` (new screen), `component` (shared or feature widget), `refine` (improve an
existing screen within its structure), `review` (report only — no edits). Without a mode, infer
it from the request and say which you chose.

**Scope discipline:** change only the screen, component, or tokens requested. Do not restyle
unrelated screens or alter architecture, routing, or state ownership during a focused UI change —
list such needs as follow-ups.

## Before writing UI code

1. **Requirements and flow.** Read the screen's entry in `docs/product/app-flow.md` (or the
   project's equivalent): purpose, entry and exit, actions, data, states, auth. If it is missing,
   derive a draft from the request and the code and confirm it.
2. **Existing UI.** Read the theme, design-system folder, shared widgets, and two or three
   comparable screens. Reuse before creating. Inspect any supplied screenshot, design export, or
   link.
3. **Tokens.** Confirm the colour, typography, spacing, radius, elevation, motion, and component
   tokens the work needs ([design-system.md](references/design-system.md)). Missing tokens are
   added to the design system, never written as literals in a screen.
4. **Screen spec.** Write the structure and state variants before code:

   ```
   Screen <ID> <name> — <purpose>
   Entry / exit: <routes, deep links, results returned>
   Layout: compact | medium | expanded regions; content max width
   Components: reused <list> · new <list> (shared or feature-local)
   States: initial · loading · success · empty · error · offline · disabled · submitting · done
   State owner: <existing provider / bloc / notifier> · intents: <list>
   Accessibility: labels, focus order, announcements, minimum targets
   Platform differences: <iOS / Android / iPad specifics>
   ```

   For a new screen or a design-system change, present the spec and wait for approval when the
   user or the invoking workflow requires it.
5. **Boundaries.** Widgets render state and dispatch intents. Data comes from the project's
   existing state owner and repository; navigation goes through the project's router. No API
   calls, storage access, business rules, or route decisions inside widgets.

## Requirements

- Responsive Android phone, iPhone, and iPad layouts when targeted
  ([responsive-accessibility.md](references/responsive-accessibility.md)).
- Safe areas, insets, keyboard, orientation, window resizing, split screen.
- Accessible semantics, screen readers, 200% text scaling, WCAG AA contrast, 48 dp / 44 pt targets.
- Every state the screen can reach ([screen-states.md](references/screen-states.md)).
- Light and dark themes when the app supports them; reduced motion respected.
- Platform-appropriate behaviour and navigation
  ([platform-conventions.md](references/platform-conventions.md)).
- Reusable, composable widgets; no duplicated components; no unnecessary fixed dimensions.

## Flutter implementation

- Theme: `ThemeData(useMaterial3: true)` with a `ColorScheme` and a `ThemeExtension` for app
  tokens, read through a `BuildContext` extension. Follow the project's existing approach if it
  has one.
- Components take data and callbacks only — never a repository, API client, or use case.
  `const` constructors wherever possible. Document purpose, states, accessibility, platform
  differences, motion, and performance notes on shared components.
- Placement: used by one feature → that feature's presentation folder; used by two or more →
  the shared widgets layer; carries gestures, animation, or haptics → the project's interactive
  layer if it has one.
- Layout by available width (`MediaQuery.sizeOf`, `LayoutBuilder`), not by device model.
- Platform checks isolated in one place (`Theme.of(context).platform` or an abstraction); prefer
  `.adaptive` constructors where Flutter offers them.
- Motion from tokens; implicit animations first; any `AnimationController` disposed; degrade to a
  fade or a cut when `MediaQuery.disableAnimationsOf(context)` is true.

## Verification

Widget tests in the project's existing test files where they exist:

- Each state renders (loading, empty, error, offline, success, disabled).
- Callbacks fire; forms validate; sheets and dialogs open and close.
- No overflow at a small phone, a large phone, and iPad portrait and landscape, at 1.0 and 2.0
  text scale, in light and dark (recipe in `responsive-accessibility.md`).
- Accessibility guideline matchers pass for tap targets, labels, and contrast.

Then run the project's gate (format → analyze → relevant tests). A comparison with a design
reference is reported as **visual approximation** unless a golden test or pixel comparison ran.

Report: files changed, components reused and added, tokens added, sizes and text scales tested,
commands with results, and anything not verified (for example "not checked on a physical iPad").
