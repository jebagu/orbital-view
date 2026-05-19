# Task [ID]: [Task Name]

## Status

```text
pending
```

## Goal

[Plain-English goal]

## Background

[Context from product brief, architecture, contracts, OpenSpec, or previous work]

## Relevant Docs

Read these before starting:

```text
AGENTS.md
docs/product-brief.md
docs/architecture.md
docs/contracts.md
docs/protected-paths.md
docs/system-flows.md
docs/implementation-map.md
docs/test-strategy.md
docs/status.md
docs/bugs.md
```

If relevant, also read:

```text
openspec/changes/[change-id]/
work-packages/[package]/MV.md
```

## Scope

Implement:

- [Item]
- [Item]

Update:

- [Doc]
- [Doc]

Add tests for:

- [Behavior]
- [Behavior]

## Out of Scope

Do not:

- [Thing]
- [Thing]

## Contract References

```text
docs/contracts.md#[module-name]
```

## Protected Path Check

This task:

```text
does / does not
```

touch a protected path.

If yes, permitted protected paths:

```text
[path or none]
```

## Expected Files

Likely files to create or modify:

```text
[path]
[path]
```

This list is guidance, not permission to make unrelated changes.

## Acceptance Criteria

This task is complete when:

- [Criterion]
- [Criterion]
- Relevant tests pass or blocker is documented
- Relevant docs are updated
- `docs/status.md` is updated
- `docs/bugs.md` is updated if relevant

## Verification Commands

Run commands that exist in this project.

```text
[command]
[command]
```

If a command does not exist, document that instead of inventing one.

## Stopping Conditions

Stop and report instead of continuing if:

- The task requires changing a public contract
- The task requires touching a protected path not explicitly allowed
- The task requires a major new dependency
- The task conflicts with existing docs
- The task touches unrelated subsystems
- Tests fail for reasons outside this task
- Required behavior is ambiguous
- Audio behavior cannot be verified when required
- The work cannot be verified

## Required Final Summary

Return:

1. What changed
2. Files changed
3. Tests added or updated
4. Commands run and results
5. Documentation updated
6. Bugs found or fixed
7. Protected paths touched
8. Assumptions
9. Risks or blockers
10. Recommended next task
