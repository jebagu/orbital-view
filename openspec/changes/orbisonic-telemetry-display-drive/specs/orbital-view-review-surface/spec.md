# orbital-view-review-surface Specification Delta

## Purpose

Define review-surface diagnostics and visual behavior for VU-normalized live telemetry reach.

## Requirements

### Requirement: Raw Diagnostics With Display Drive

The review surface SHALL show raw RMS and raw peak separately from VU/display drive.

#### Scenario: Explicit VU display reaches full scale while raw RMS is low

- GIVEN live telemetry for one channel has `rms: 0.10`, `peak: 0.40`, `vuNormalized: 1.0`, and the VU-normalized-valid record flag
- WHEN the review surface computes speaker meter diagnostics
- THEN diagnostics report raw RMS as `0.10`
- AND diagnostics report raw peak as `0.40`
- AND diagnostics report display drive as full scale
- AND Cube VU, Pixel Jets, and Cell Jets can render full visual scale for that channel

#### Scenario: Untrusted zero-filled VU slot does not suppress raw RMS

- GIVEN live telemetry for one channel has `rms: 0.25`, `peak: 0.40`, `vuNormalized: 0`, and no VU-normalized-valid record flag
- WHEN the review surface computes speaker meter diagnostics
- THEN diagnostics report raw RMS as `0.25`
- AND diagnostics report display drive as `0.25`
- AND Cube VU, Pixel Jets, and Cell Jets can still move for that channel

### Requirement: Channel Identity Remains Stable

The review surface SHALL keep live telemetry keyed by physical channel ID when adding display-drive behavior.

#### Scenario: Telemetry has separate raw and display values

- GIVEN two channels publish different raw RMS, peak, and VU-normalized values
- WHEN the review surface projects speakers and selects a diagnostic channel
- THEN channel identity is preserved by channel ID
- AND display-drive behavior must not reorder or merge physical speakers
