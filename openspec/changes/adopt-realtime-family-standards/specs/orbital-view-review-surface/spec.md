# orbital-view-review-surface Specification Delta

## Purpose

Define review-surface rules for local file playback, impulse meters, local livestream test generators, diagnostics, themes, and Orbisonic design-language UI while preserving production host contracts.

## Standards Impact Summary

```text
Touches realtime: no production realtime code; review sources are visual harness inputs only.
Touches routing: no; review surfaces must not decide production routing.
Meter source-of-truth: review-only local file, impulse, fake, or livestream inputs are test/display sources only; production truth remains host-owned measured meters.
Callback reachability: review surfaces must not be called from host audio callbacks.
Overload policy: review surfaces may reduce fidelity, throttle, or drop visual frames before affecting audio behavior.
Performance gates: review slices must prove visual stress behavior does not rebuild static geometry on meter-only updates and does not imply production audio correctness.
```

## Requirements

### Requirement: Review Sources Are Non-Production

The system SHALL label local file playback, impulse test modes, fake meters, and local livestream generators as review/test harness sources unless a future OpenSpec change defines a production host contract.

#### Scenario: Local audio file drives visual meters

- GIVEN the review app loads a local audio file
- WHEN it converts the file to mono RMS/peak visual samples
- THEN that behavior is labeled review local audio, remains review-only, and must not replace production `SpeakerMeterFrame` truth

#### Scenario: Local livestream generator is used

- GIVEN a local livestream test generator emits test layout or meter frames
- WHEN Orbital View Kit visualizes those frames
- THEN the frames are labeled local livestream test generator and treated as host-prepared test snapshots, not Orbital View Kit-owned audio

### Requirement: Orbisonic Design-Language Continuity

The system SHALL use the Orbisonic design language directory as the visual guideline for future review-surface and host-UI work.

Required references:

```text
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-ui-language.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/orbisonic-palette-brief.md
/Users/jeremyguillory/Documents/vibecode projects/orbisonic design language/Orbisonic Design System Kit/design-system.md
```

#### Scenario: Review surface UI changes

- GIVEN a future slice changes review-surface controls, palettes, layout, or diagnostics
- WHEN the UI is implemented
- THEN the result should preserve the Orbisonic design language while keeping diagnostics and source-test controls clearly separated from production host contracts
- AND the result should preserve strict grid alignment, no page-level active-workflow scrolling, title-only panel headers, compact status primary UI, diagnostics for raw evidence, and no global animation timeline for static shell chrome

#### Scenario: Palette behavior is changed

- GIVEN a future slice changes palette rendering, VU treatment, or theme controls
- WHEN the UI is implemented
- THEN existing Orbital View palette names and Daft Punk Bow behavior remain preserved unless the slice explicitly updates those source-level contracts
- AND Daft Punk Bow remains display-only color/material behavior that does not affect audio, routing, physical speaker channel identity, object identity, meter values, or host realtime timing
