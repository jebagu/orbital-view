# Project File Tree

```text
AGENTS.md
README.md
START_HERE.md
FILE_TREE.md
META_AGENTS.md
.env.example
.gitignore
Package.swift

docs/
  architect-control.md
  product-brief.md
  architecture.md
  contracts.md
  protected-paths.md
  renderer-test-harness.md
  system-flows.md
  implementation-map.md
  test-strategy.md
  status.md
  bugs.md
  review-policy.md
  decisions/
    0001-initial-architecture.md
    0002-renderer-backend.md

.tasks/
  000-project-bootstrap.md
  001-orbital-view-core-foundation.md
  002-wavefield-layout-json-adapter.md
  003-wavefield-meter-frame-adapter.md
  004-orbital-viewport-visual-mockup.md
  005-renderer-backend-decision.md
  006-orbital-view-render-target-seam.md
  007-orbital-view-swiftui-wrapper-skeleton.md
  008-renderer-test-harness-plan.md
  009-offscreen-renderer-smoke-test.md
  010-renderer-invariant-tests.md
  _template-task.md

Sources/
  OrbitalViewCore/
  OrbitalViewRender/
    OrbitalViewMetalDrawPipeline.swift
    OrbitalViewMetalRenderer.swift
    OrbitalViewRendering.swift
    OrbitalViewRenderState.swift
  OrbitalViewSwiftUI/
  OrbitalViewWavefield/

Tests/
  OrbitalViewCoreTests/
  OrbitalViewRenderTests/
  OrbitalViewSwiftUITests/
  OrbitalViewWavefieldTests/

work-packages/
  orbital-view-kit/
    MV.md
    orbital-view-kit-codex-work-package.md
    slices/
      001-orbital-view-core-foundation.md
      002-wavefield-layout-json-adapter.md
      003-wavefield-meter-frame-adapter.md
      004-orbital-viewport-visual-mockup.md
      005-renderer-backend-decision.md
      006-orbital-view-render-target-seam.md
      007-orbital-view-swiftui-wrapper-skeleton.md
      008-renderer-test-harness-plan.md
      009-offscreen-renderer-smoke-test.md
      010-renderer-invariant-tests.md
  _template/
    MV.md
    slices/
    reviews/

openspec/
  README.md
  specs/
  changes/

mockups/
  README.md
  orbital-view-viewport/
    index.html
    notes.md
  _template/

.agents/
  skills/

.codex/
  config.toml
  agents/

reviewers/
prompts/
```

Downstream app integration source remains intentionally absent until later tasks create it.
