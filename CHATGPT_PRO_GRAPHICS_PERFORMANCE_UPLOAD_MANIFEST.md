# ChatGPT Pro Graphics Performance Upload Manifest

## Archive

```text
OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip
```

## Purpose

This archive is a curated upload bundle for ChatGPT Pro. It contains enough current Orbital View Kit context for ChatGPT Pro to write an implementation-ready prompt for improving graphical performance.

The archive is not a full repository dump. It excludes build products, Git metadata, old zip artifacts, app bundles, package installers, and broad generated icon batches.

## Performance Targets In This Bundle

```text
Active viewport / interaction target: 120 FPS
Meter display target: 30 FPS
```

Current implementation reality:

```text
Current review app and production settings mostly center around 60 FPS active motion.
Current public performance settings validate active FPS as 30 or 60.
Current meter-only / inspector cadences are generally lower than 30 FPS.
The bundle is meant to help plan the path from current behavior to the 120 FPS / 30 FPS target.
```

## Included First-Read Files

```text
CHATGPT_PRO_GRAPHICS_PERFORMANCE_GUIDE.md
CHATGPT_PRO_GRAPHICS_PERFORMANCE_UPLOAD_MANIFEST.md
README.md
START_HERE.md
AGENTS.md
Package.swift
```

## Included Documentation

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
docs/protected-paths.md
docs/renderer-test-harness.md
docs/visual-telemetry-stress-gates.md
docs/realtime-family-compliance-audit.md
docs/orbisonic-design-language.md
docs/integrations/
docs/decisions/
openspec/changes/adopt-realtime-family-standards/
work-packages/orbital-view-kit/MV.md
work-packages/orbital-view-kit/orbital-view-kit-codex-work-package.md
work-packages/orbital-view-kit/realtime-family-adoption-work-package.md
work-packages/orbital-view-kit/slices/
reviewers/performance.md
reviewers/architecture.md
reviewers/reliability.md
reviewers/protected-path.md
```

## Included Source

```text
Sources/OrbitalViewCore/
Sources/OrbitalViewWavefield/
Sources/OrbitalViewSpatGRIS/
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
Sources/OrbitalViewReview/
Sources/OrbitalViewViewer/
Sources/OrbitalViewViewerSupport/
```

The important performance files are:

```text
Sources/OrbitalViewReview/OrbitalViewportMockup.swift
Sources/OrbitalViewRender/OrbitalViewMetalDrawPipeline.swift
Sources/OrbitalViewRender/OrbitalViewMetalRenderer.swift
Sources/OrbitalViewRender/OrbitalViewRenderState.swift
Sources/OrbitalViewSwiftUI/OrbitalViewMetalView.swift
Sources/OrbitalViewCore/OrbitalViewPerformanceSettings.swift
Sources/OrbitalViewViewerSupport/OrbitalViewVisualTelemetryStressScene.swift
```

## Included Tests

```text
Tests/OrbitalViewCoreTests/
Tests/OrbitalViewWavefieldTests/
Tests/OrbitalViewSpatGRISTests/
Tests/OrbitalViewRenderTests/
Tests/OrbitalViewSwiftUITests/
Tests/OrbitalViewViewerTests/
```

## Included Visual References

```text
mockups/orbital-view-viewport/
mockups/README.md
docs/media/orbital-view-vu-1.0/
fey sphere - domelab-configuration.json
```

These are visual references and review evidence. They should not be treated as browser runtime code to port into production.

## Explicit Exclusions

```text
.git/
.build/
.swiftpm/
OrbitalViewKit-chatgpt-pro-architecture-context.zip
OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip
dist/
*.app
*.pkg
*.app.zip
```

The archive intentionally excludes broad generated `dist/` batches. The visual media under `docs/media/orbital-view-vu-1.0/` is included because it is relevant to graphical performance and visual quality.

## Verification Commands

After creating the archive, verify:

```text
unzip -t OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip
zipinfo -1 OrbitalViewKit-chatgpt-pro-graphics-performance-context-2026-05-29.zip
git diff --check
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

## Notes For ChatGPT Pro

Start with `CHATGPT_PRO_GRAPHICS_PERFORMANCE_GUIDE.md`.

The correct deliverable is a coding-agent prompt for graphical performance work. Do not propose audio changes, route changes, WebView replacement, a new standalone app, or downstream host integration work unless the repository docs explicitly ask for that in a future task.
