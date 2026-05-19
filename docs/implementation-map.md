# Implementation Map

## Purpose

This file maps project behavior to files and folders so the current system can be understood without reading every document.

## Top-Level Structure

```text
docs/                         Active project documentation
.tasks/                       Bounded Codex execution tasks
work-packages/orbital-view-kit/ Initial OrbitalViewKit work package
openspec/                     Behavioral change/spec templates
mockups/                      Disposable visual mockups
.agents/skills/               Local project skills
.codex/agents/                Local reviewer agent configs
reviewers/                    Human-readable review checklists
prompts/                      Reusable project prompts
```

Swift source directories are now present for `OrbitalViewCore`.

## Feature Map

### OrbitalViewCore Foundation

Purpose:

```text
Pure data contracts and validation for spherical speaker viewport scenes.
```

Implementation locations:

```text
Package.swift
Sources/OrbitalViewCore/
Tests/OrbitalViewCoreTests/
```

Related docs:

```text
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/test-strategy.md
work-packages/orbital-view-kit/MV.md
.tasks/001-orbital-view-core-foundation.md
```

### Future Wavefield Adapter

Purpose:

```text
Convert Wavefield speaker layout and meter structures into OrbitalViewCore scene and meter contracts.
```

Planned location:

```text
to be decided after inspecting the actual Wavefield package
```

### Future Renderer

Purpose:

```text
Render validated OrbitalViewCore scenes as a native 3D viewport.
```

Planned locations:

```text
Sources/OrbitalViewRender/
Sources/OrbitalViewSwiftUI/
```

## Test Map

```text
unit direction validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
speaker validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
shell reference validation -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
meter channel identity -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
camera center-lock presets -> Tests/OrbitalViewCoreTests/OrbitalViewCoreTests.swift
Wavefield layout adaptation -> downstream adapter tests, if implemented
```

## Last Updated

2026-05-19 OrbitalViewCore foundation
