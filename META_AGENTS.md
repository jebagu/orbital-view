# META_AGENTS.md

## Purpose

This file defines how Jeremy, the Architect Chat, and Codex should start and manage a larger Swift/audio project.

The goal is to make projects:

- Modular
- Understandable without reading source code
- Easy to resume
- Easy to troubleshoot
- Testable slice by slice
- Safe around protected audio paths
- Structured so Codex can execute bounded tasks without wandering

Do not start by asking Codex to build the whole app.

Do not begin implementation until the project has:

```text
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
```

For nontrivial changes, also use:

```text
openspec/
work-packages/
.tasks/
```

---

# 1. Roles

## Jeremy

Jeremy is the product owner and final decision maker.

Jeremy should be able to understand the project from docs, summaries, diagrams, mockups, status, and bug lists without reading source code.

## Architect Chat

Architect Chat is the clean, high-level project brain.

Architect Chat owns:

- Product direction
- Architecture decisions
- Work packages
- Slice queue
- Bug list
- Protected paths
- Open questions
- Agent delegation
- Final high-level acceptance

Architect Chat does not:

- Write code
- Inspect huge diffs
- Run detailed code review
- Debug logs line by line
- Let implementation noise pollute its context

Architect Chat may spawn:

- Brainstorm agents
- HTML mockup agents
- Codex implementation agents
- Specialty reviewer agents
- Debug agents
- Documentation refresh agents

Architect Chat receives:

- Short summaries
- Decision options
- Slice status
- Risks
- Bug updates
- Synthesized review reports
- Recommended next actions

## Codex

Codex is the implementation worker.

Codex receives bounded tasks or slices, implements them, runs checks, updates docs, summarizes, and stops.

Codex must not be asked to build the whole app.

---

# 2. Operating Principles

## 2.1 Plan before code

For difficult or ambiguous work, use Codex built-in Plan mode. Do not create a custom plan skill unless the built-in flow proves insufficient.

## 2.2 Specs before meaningful changes

Use OpenSpec for nontrivial changes. OpenSpec is the change-spec layer, not the whole process.

Use OpenSpec when changing:

- behavior
- architecture
- audio pipeline
- protected paths
- persistence
- public contracts
- multi-module flows

Skip OpenSpec for tiny changes and disposable mockups.

## 2.3 Show it before Swift

When the UI or interaction is uncertain, create a disposable HTML/CSS/JS mockup before writing Swift.

Mockups live in:

```text
mockups/[feature-name]/
```

Mockups are visual decision tools. They are not implementation scaffolding.

## 2.4 Contracts before implementation

Every major module must have a contract before Codex implements it.

Contracts define:

- Responsibility
- Non-responsibilities
- Inputs
- Outputs
- Errors
- Side effects
- Dependencies
- Forbidden dependencies
- Tests
- Audio/performance constraints when relevant

## 2.5 Small slices beat large prompts

A slice should be small enough that Codex can:

- Understand it
- Implement it
- Test it
- Update docs
- Summarize it
- Stop cleanly

## 2.6 Protect the audio path

If a path is protected, Codex may inspect it but must not modify it unless the task or work package explicitly allows it.

If Codex accidentally needs to touch a protected path:

```text
Stop.
Report.
Wait for Architect decision.
```

## 2.7 Documentation is part of implementation

A task is not complete unless relevant docs are updated.

At minimum, Codex updates:

```text
docs/status.md
```

When relevant, Codex also updates:

```text
docs/implementation-map.md
docs/system-flows.md
docs/contracts.md
docs/test-strategy.md
docs/bugs.md
docs/protected-paths.md
```

---

# 3. Default New Project Sequence

1. Create `[Project Name] - Architect` chat.
2. Fill product brief.
3. Fill architecture.
4. Define protected paths.
5. Define module contracts.
6. Define test strategy.
7. Create `AGENTS.md`.
8. Initialize OpenSpec if this is a real project.
9. Create initial `.tasks/` files or a work package.
10. Run Codex plan audit.
11. Revise docs.
12. Implement one bounded task or slice at a time.

---

# 4. Big Work Package Rule

Use a work package when the feature is too big for one task.

A work package may have:

```text
5 slices
10 slices
50 slices
```

Before it starts, Architect decides:

```text
main tree or new worktree
```

Default:

```text
large work package = new worktree
tiny task = current tree
```

Architect babysits the package until it is merged, canceled, or decomposed.

---

# 5. Review Rule

Normal changes use built-in Codex review.

Special changes use specialty review.

Specialty review is required when the change touches:

- Audio behavior
- Protected paths
- Performance-sensitive logic
- Reliability-sensitive logic
- Architecture
- Large multi-slice changes

Specialty reviewers:

```text
performance
reliability
architecture
audio
protected-path
```

One synthesis pass combines the results.

Do not send Jeremy raw multi-agent dumps.

---

# 6. Quality Bar

The project is ready for implementation only when:

- Jeremy can understand it without reading code
- Codex can execute the next slice without guessing
- Module boundaries are clear
- Protected paths are named
- Audio constraints are documented
- Tests are specified
- Stopping conditions are explicit
- The status doc explains current state
- The bug list exists
