---
name: specialty-review
description: Use after risky changes involving audio, protected paths, performance, reliability, architecture, or large multi-slice work. Produces a synthesized review, not raw reviewer dumps.
---

# Specialty Review Skill

## Purpose

Review risky work using specialized lenses.

## Use When

- Audio behavior changed
- Protected paths were touched
- Performance-sensitive code changed
- Reliability-sensitive code changed
- Architecture changed
- A large work package is ready for merge
- Multiple slices interact in a risky way

## Reviewers

Use relevant reviewers:

```text
performance
reliability
architecture
audio
protected-path
```

## Process

1. Identify the diff or slice under review.
2. Read `docs/review-policy.md`.
3. Read `docs/protected-paths.md`.
4. Read relevant contracts.
5. Run specialty reviewers.
6. Synthesize findings.
7. Deduplicate.
8. Assign severity.
9. Recommend next action.

## Severity

```text
P0: blocker
P1: should fix before accept
P2: nice to fix
P3: advisory
```

## Output

Return:

```text
P0 blockers:
P1 should-fix:
P2 nice-to-fix:
Safe autofixes:
Manual decisions needed:
Audio concerns:
Protected path concerns:
Recommended next action:
```
