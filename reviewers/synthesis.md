# Review Synthesis

Combine specialty reviewer results into one report.

Do:

- Deduplicate
- Drop ungrounded claims
- Promote repeated findings
- Resolve contradictions
- Assign severity
- Separate safe autofixes from manual decisions

Severity:

```text
P0 blocker
P1 should fix
P2 nice to fix
P3 advisory
```

Output:

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
