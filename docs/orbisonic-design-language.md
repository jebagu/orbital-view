# Orbisonic Design Language For Orbital View Kit

Status: active UI guideline

## Purpose

Orbital View Kit uses the Orbisonic design language as the guideline for future production UI, review surfaces, and visual telemetry work.

This is a shell, layout, palette, meter, and information-hierarchy guideline. It is not permission to import Orbisonic product semantics, playback behavior, routing behavior, source models, or app-specific control flows into Orbital View Kit.

## Source References

Read these files before changing Orbital View UI, review surfaces, visible diagnostics, tuning trays, palette behavior, or visual meter treatment:

```text
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-ui-language.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-palette-brief.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/Orbisonic Design System Kit/design-system.md
```

The design-language workspace root is:

```text
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language
```

## Applies To

- `OrbitalViewSwiftUI` production host wrapper UI
- `OrbitalViewReview` review/demo surface
- `OrbitalViewViewer` review executable
- future mockups that are intended to influence native UI work
- future host integration UI notes for Wavefield, Orbisonic, Splat, or other realtime-family apps

It does not apply to pure data validation in `OrbitalViewCore`, host-owned realtime behavior, audio routing, playback, MIDI/OSC parsing, or raw livestream packet handling.

## Required Review Criteria

Future UI and review-surface changes must check:

- strict grid alignment for panels, rows, labels, buttons, meters, and repeated tiles
- no page-level scrolling in active workflow tabs or panels
- title-only panel and tray headers
- compact primary status UI that answers what is selected, what is happening, whether it is safe or ready, or what can be done next
- diagnostics trays for raw evidence, logs, UIDs, file paths, device names, sample rates, and support detail
- no global animation timeline for static shell chrome

Diagnostics and support inspection may scroll when their job is raw evidence review. Primary operator workflows should reduce density, split panels, paginate, or collapse advanced material instead of adding scroll views.

## Palette And Meter Continuity

Preserve the current Orbital View review palette inventory unless a future explicit UI task revises it:

```text
Purple
Flamingo
Green
B&W
Daft Punk Bow
Rack Mint
Rack Pink
Rack Blue
Ember Console
Graphite
Flamingo Green
Dusty Rose
```

`Daft Punk Bow` remains the canonical rainbow VU palette in this kit. It is the visible successor to older `Tech Rainbow` / `techRainbow` naming. Existing migration behavior from `techRainbow` to `daftPunkBow` must be preserved.

Daft Punk Bow is display-only color/material behavior. It must not affect audio, routing, physical channel identity, object identity, meter values, speaker geometry, or host realtime timing.

## Verification Rule

When changing the review executable or a visible UI surface, verify the visible result against the Orbisonic design-language source files above instead of inventing one-off local layout rules.

For docs-only design-language work, source review plus existing build/test coverage is sufficient. Manual visual review is required when a slice changes visible UI behavior, layout, palette rendering, or review executable controls.

