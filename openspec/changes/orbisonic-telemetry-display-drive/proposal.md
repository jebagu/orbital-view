# Change Proposal: Orbisonic Telemetry Display Drive

## Why

Orbisonic can publish healthy VU-style display levels while raw RMS remains numerically low. The review viewport currently drives its main live telemetry speaker visuals from raw RMS, so a real Orbisonic test track can fail to reach the tops of Cube VU, Pixel Jets, and Cell Jets meters even when the host has already computed a full-scale display value.

## What Changes

- Add a display-drive path that uses Orbisonic telemetry `vuNormalized` only when an explicit VU-normalized-valid record flag is set, otherwise falling back to raw `rms`.
- Keep raw `rms`, raw `peak`, and `clip` as unmodified telemetry facts.
- Let Cube VU scalar calculation accept an optional display-drive input without breaking existing callers.
- Show display drive separately in review diagnostics so operators can distinguish raw RMS/peak from visual meter drive.

## What Does Not Change

- `Input Calibration` remains bounded and is now capped at `8x`.
- Structurally present but untrusted zero-filled `vuNormalized` / `vuDbFS` slots do not override raw RMS.
- Full visual meter scale does not imply clipping unless `clip` or true peak state says so.
- Orbital View does not change audio gain, source trim, Dante gain, routing, channel order, or host tap ownership.

## Impacted Specs

```text
openspec/changes/orbisonic-telemetry-display-drive/specs/orbital-view-telemetry-ingress/spec.md
openspec/changes/orbisonic-telemetry-display-drive/specs/orbital-view-review-surface/spec.md
```

## Impacted Docs

```text
docs/contracts.md
docs/implementation-map.md
docs/system-flows.md
docs/test-strategy.md
docs/status.md
```

## Risk

```text
medium
```

Risk is medium because the change touches the protected review surface and user-visible meter behavior, even though it does not touch host audio paths.

## Specialty Review Required

```text
yes
```

Required review areas:

```text
audio
protected-path
reliability
```
