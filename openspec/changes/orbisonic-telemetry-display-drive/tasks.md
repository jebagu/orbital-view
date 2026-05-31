# Tasks: Orbisonic Telemetry Display Drive

## Implementation Checklist

- [x] 1. Add the OpenSpec change package before implementation.
- [x] 2. Add source-compatible core scalar `displayDrive` support.
- [x] 3. Expose telemetry level `displayDrive` as validity-aware `vuNormalized` with raw-RMS fallback.
- [x] 4. Drive review Cube VU, Pixel Jets, and Cell Jets intensity from display drive while preserving raw diagnostics.
- [x] 5. Add core, telemetry, and review regression tests.
- [x] 6. Update project docs and status.
- [x] 7. Run build, tests, launch verification, and specialty review.

## Convert to Work Package?

```text
no
```

This is a bounded display-behavior fix with a protected-path note, not a multi-slice package.
