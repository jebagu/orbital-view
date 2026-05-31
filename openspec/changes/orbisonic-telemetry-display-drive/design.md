# Design: Orbisonic Telemetry Display Drive

## Technical Approach

Expose `displayDrive` as a convenience value on decoded Orbisonic telemetry meter levels. The value returns `vuNormalized` only when the record carries an explicit VU-normalized-valid flag; absent or structurally present but untrusted VU slots fall back to raw `rms`.

Carry that value through the review viewport meter sample and projected speaker model. Cube VU, Pixel Jets, and Cell Jets scalar calculation uses display drive for calibrated/display/hot visual intensity while palette and diagnostics can still reference raw peak and raw RMS.

## Architecture Notes

The display-drive value is display intent, not a new meter source of truth. Existing `SpeakerMeterLevel`, telemetry decoding, channel identity, DVS state, and provider selection semantics remain unchanged.

The core scalar initializer receives a source-compatible optional parameter so existing raw-RMS callers retain current behavior.

## Audio Notes

This change does not alter audible gain, routing, output channel order, source selection, Dante configuration, or host tap-point ownership. `Input Calibration` remains display-only and is bounded at `8x`. `clip` continues to mean raw peak/clip state and must not be inferred from visual full scale.

Orbisonic should publish its existing VU display level into the current `vuNormalized` field, publish the corresponding display dB value in `vuDbFS` when available, and set the explicit VU-normalized-valid record flag only when those fields carry intentional display data. Current Orbisonic records that zero-fill the extended slots without setting the flag remain raw-RMS driven.

## Protected Path Notes

The protected review surface is touched because live telemetry visual intensity and diagnostics are user-visible review behavior. The change is limited to display preparation and SceneKit/SwiftUI review rendering, not downstream audio or production host paths.

## Alternatives Considered

### Rely Only On Higher Input Calibration

Pros:

- Simple control-level change.

Cons:

- Makes all low-level telemetry more sensitive.
- Does not distinguish raw signal facts from host-provided display intent.
- Does not fix the display-source mismatch by itself.

### Use Validity-Aware VU-Normalized Display Drive

Pros:

- Lets Orbisonic publish the intended visual meter level.
- Preserves raw RMS, peak, and clip as diagnostics.
- Keeps channel identity unchanged and keeps calibration bounded.
- Preserves real silence because valid `vuNormalized: 0` is accepted only when the explicit validity flag is set.

Cons:

- Requires Orbisonic to set a validity flag before Orbital View trusts `vuNormalized`.
- Requires explicit diagnostics so operators understand why display drive can differ from raw RMS.

## Decision

Use validity-aware VU-normalized display drive for visual reach and keep `Input Calibration` bounded at `8x`.

## Risks

- End-to-end live VU-intent behavior still depends on Orbisonic publishing `vuNormalized` and its validity flag correctly.
- Review diagnostics must remain explicit enough that full display scale is not mistaken for raw clipping.
