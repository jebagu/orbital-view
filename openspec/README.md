# OpenSpec Layer

OpenSpec is the behavioral spec and change-management layer.

This project uses the openspec.dev workflow for future audio-facing and architecture-facing changes. For Orbital View Kit, that includes realtime-family boundaries, telemetry ingress, host integration, review-surface behavior, protected renderer/UI paths, and any change that could affect callback reachability, routing, meter source-of-truth, overload behavior, or performance gates.

It does not replace:

```text
Architect Chat
docs/
.tasks/
work-packages/
AGENTS.md
```

It adds a clean way to capture what behavior is changing before Codex writes code.

## Use OpenSpec For

- New features
- Behavioral changes
- Architecture changes
- Audio pipeline changes
- Protected path changes
- Multi-module changes
- Refactors with user-visible or architecture impact

## Skip OpenSpec For

- Typos
- Tiny copy changes
- One-file bugs
- Simple test additions
- Disposable HTML mockups

## Setup

After the repo exists:

```text
npm install -g @fission-ai/openspec@latest
openspec init
```

Recommended environment:

```text
OPENSPEC_TELEMETRY=0
DO_NOT_TRACK=1
```

## Typical Flow

```text
/opsx:propose "[feature or change]"
review proposal.md
review design.md
review tasks.md
review specs/
convert risky/multi-module tasks into .tasks or work-package slices
Codex implements one task/slice
tests pass
docs update
archive only after specs/docs/code are synchronized
```

## Division of Responsibility

```text
docs/product-brief.md       product source of truth
docs/architecture.md        architecture source of truth
docs/contracts.md           module interface source of truth
docs/protected-paths.md     protected subsystem source of truth
docs/status.md              project control panel
docs/bugs.md                bug ledger
openspec/specs/             current behavioral requirements
openspec/changes/           proposed behavioral changes
.tasks/                     bounded Codex execution
work-packages/              large multi-slice efforts
```
