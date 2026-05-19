---
name: execute-task
description: Use when Codex should implement exactly one bounded task or work-package slice and then stop.
---

# Execute Task Skill

## Purpose

Implement one task or slice without scope drift.

## Required Input

One of:

```text
.tasks/[task].md
work-packages/[package]/slices/[slice].md
```

## Process

1. Read `AGENTS.md`.
2. Read the task or slice.
3. Read referenced docs.
4. Check protected paths.
5. Implement only the requested scope.
6. Add or update relevant tests.
7. Run relevant checks.
8. Update docs.
9. Update bug list if relevant.
10. Stop.

## Stop If

- Protected path change is not explicitly allowed
- Public contract must change
- Major dependency is required
- Task is ambiguous
- Audio behavior cannot be verified when required
- Tests fail outside the task scope

## Final Response

Use the final response format in `AGENTS.md`.
