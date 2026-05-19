---
name: debug
description: Use when something breaks and Codex should find root cause, fix the smallest safe scope, add regression coverage, and update the bug list.
---

# Debug Skill

## Purpose

Find and fix the smallest reasonable root cause.

## Process

1. Read `AGENTS.md`.
2. Read `docs/status.md`.
3. Read `docs/bugs.md`.
4. Read relevant task/work-package docs.
5. Reproduce or explain why reproduction is impossible.
6. Identify root cause.
7. Fix the smallest safe scope.
8. Add or update a regression test.
9. Run relevant checks.
10. Update `docs/bugs.md` and `docs/status.md`.

## Rules

- Do not refactor unrelated code.
- Do not touch protected paths unless explicitly allowed.
- Do not hide unresolved bugs.
- If the bug involves audio behavior, document verification limits.

## Final Response

Return:

```text
Root cause:
Fix made:
Files changed:
Regression test:
Commands run:
Bug list update:
Protected paths touched:
Remaining risks:
```
