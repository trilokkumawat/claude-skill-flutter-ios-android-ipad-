# Design system

## Discover what exists first

```bash
grep -rnE "ThemeData\(|ColorScheme\.|ThemeExtension<|TextTheme\(" lib
grep -rnE "Color\(0x|Colors\.[a-z]+[^.]|fontSize:|EdgeInsets\.(all|symmetric|only)\([0-9]" lib | head -50
```

The first shows the theme and any tokens; the second shows literals that should become tokens.
Extend the existing system — do not create a parallel one.

## Token architecture

1. **Palette** — raw values (`#2E7D32`), private to the design-system folder.
2. **Semantic roles** — what a colour or size means (`accent`, `textSecondary`, `danger`,
   `cardSurface`, `spaceM`), defined for light and dark. Screens use only these.
3. **Component tokens** — where a component needs its own (`buttonHeightLarge`,
   `navDockHeight`), defined in terms of semantic roles.

Name tokens by role, never by hue (`danger`, not `red`), except user-chosen swatches.

## Token categories

| Category | Typical content |
|---|---|
| Colour roles | canvas, surface, raised surface, inset surface, border, divider; text primary, secondary, muted, disabled; accent and on-accent, pressed accent, accent tint; success, warning, info, danger with container and on-container pairs; focus ring; skeleton base and highlight; scrim |
| Typography | display, page title, headline, title, body, body strong, label, caption, plus feature styles (metric, timer); sizes per window class if they differ |
| Spacing | 4-point scale: 4, 8, 12, 16, 20, 24, 32, 40, 48 |
| Radius | small, medium, large, extra large, pill |
| Elevation and strokes | a few elevation levels; hairline and emphasis stroke widths |
| Icon sizes | 16, 20, 24, 32 |
| Motion | durations (instant, fast, normal, slow) with matching curves |
| Layout | screen gutters, section gaps, card padding, input height, content max widths — per window class |
| Component sizes | button heights, list row heights, avatar sizes, minimum touch target |

## Light and dark

- Define every colour role for both themes. Dark is designed per token, not computed by inversion
  or blanket opacity.
- Keep the surface ladder distinguishable in dark (canvas → card → inset → selected).
- Check each foreground/background pair you add: 4.5:1 for text, 3:1 for large text and
  essential non-text UI, in both themes. When a brand colour fails, add a paired foreground token
  rather than shipping the failing pair.

## Encoding in Flutter

```dart
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.canvas, required this.textPrimary, required this.accent});

  final Color canvas;
  final Color textPrimary;
  final Color accent;

  static const light = AppColors(canvas: AppPalette.white, textPrimary: AppPalette.grey900, accent: AppPalette.green700);
  static const dark = AppColors(canvas: AppPalette.grey950, textPrimary: AppPalette.white, accent: AppPalette.green300);

  @override
  AppColors copyWith({Color? canvas, Color? textPrimary, Color? accent}) => AppColors(
        canvas: canvas ?? this.canvas,
        textPrimary: textPrimary ?? this.textPrimary,
        accent: accent ?? this.accent,
      );

  @override
  AppColors lerp(AppColors? other, double t) => other == null
      ? this
      : AppColors(
          canvas: Color.lerp(canvas, other.canvas, t)!,
          textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
          accent: Color.lerp(accent, other.accent, t)!,
        );
}

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
```

Seed the Material `ColorScheme` from the same palette so Material widgets match, and map the
typography roles onto `TextTheme` for Material widgets.

## Components

- Inventory shared components before creating one; one component per concept (one primary
  button, one text field, one sheet frame, one empty state).
- API: data and callbacks only; variants as enums, not booleans that multiply; sensible defaults.
- States a component may model: idle, pressed, focused, selected, loading, success, error,
  disabled, expanded, collapsed, dragging.
- Document shared components: purpose, usage, states, accessibility, platform differences,
  motion, performance notes.

## Enforcement

No colour, font size, spacing, radius, elevation, or duration literal outside the design-system
folder. A grep like the one above, run in CI or review, should print nothing outside that folder.

## From a design reference

- Translate the reference's values into tokens once; screens consume tokens.
- Mockup presentation chrome (decorative backdrops, device frames) is not app UI.
- State whether a screen is a visual approximation of the reference or was validated with a
  pixel or golden comparison.
