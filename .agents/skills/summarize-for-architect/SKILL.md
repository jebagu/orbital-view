---
name: summarize-for-architect
description: Use when a worker needs to report back to the high-level Architect Chat without polluting it with raw diffs, logs, or review dumps.
---

# Summarize for Architect Skill

## Purpose

Compress implementation noise into high-level project state.

## Include

- What changed
- Why it matters
- Files changed, grouped by purpose
- Tests run
- Bug list impact
- Protected paths touched
- Risks
- Decisions needed
- Recommended next action

## Exclude

- Raw diffs
- Giant logs
- Long stack traces
- Repeated reviewer findings
- Low-level implementation chatter

## Output

```text
Architect Summary:
Project impact:
Files changed:
Tests:
Bugs:
Protected paths:
Risks:
Decision needed:
Recommended next action:
```
