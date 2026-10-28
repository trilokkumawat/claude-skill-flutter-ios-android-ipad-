# Platform conventions

Match each platform where users notice the difference; share everything else. Keep platform
checks in one place (an adaptive widget or a small platform abstraction), never scattered through
screens.

| Behaviour | iOS / iPadOS | Android | Flutter approach |
|---|---|---|---|
| Back navigation | Edge swipe back; back button top-left | System back gesture or button; predictive back | `PopScope` for confirmation; let the router handle pops; never block system back without a reason |
| Scrolling | Bouncing overscroll | Stretch or glow overscroll | Platform default `ScrollPhysics`; do not force one |
| Dialogs | Alert style with centred actions | Material dialog | `showAdaptiveDialog`, `AlertDialog.adaptive` |
| Switches, sliders, spinners | Cupertino look | Material look | `Switch.adaptive`, `Slider.adaptive`, `CircularProgressIndicator.adaptive` |
| Date and time pickers | Wheel / inline | Material pickers | Choose per platform in the adaptive layer |
| Action menus | Action sheet, context menu | Bottom sheet, menu | Bottom sheet on phones; popover or menu on iPad and large windows |
| App bar title | Centred | Start-aligned | Theme default per platform |
| Haptics | Light, selective | Light, selective | `HapticFeedback` for meaningful moments only; never on scroll or timer ticks |
| Share | Share sheet | Share sheet | One share abstraction |
| Text selection and keyboard toolbar | Native style | Native style | Default `TextField`; `TextInputAction` set per field |
| Permissions | Purpose string in the system prompt | Rationale before the prompt; permanently-denied path to Settings | Pre-prompt explanation on both; graceful denial |
| Edge-to-edge | Safe areas | Edge-to-edge with transparent bars | Annotate system-bar styles per screen background |

## iPad

- Use the space: list-detail, sidebars, and multi-column layouts on expanded widths.
- Support pointer hover and hardware-keyboard shortcuts where natural.
- Present popovers and centred dialogs instead of full-height sheets on large windows.
- Respect multitasking widths; never assume full screen.

## Android large screens and foldables

- Resizable activities; no forced orientation without reason.
- Avoid the hinge; adapt between folded and unfolded postures.

## When to diverge

Diverge only where the platform convention affects usability (navigation, dialogs, pickers,
permissions). Brand surfaces, content layout, and design tokens stay the same on both platforms.
