# Protected Path Reviewer

Read:

```text
docs/protected-paths.md
AGENTS.md
active task or slice
```

Check:

- Did the diff touch protected paths?
- Was that explicitly allowed?
- Were invariants preserved?
- Was specialty review triggered?
- Were docs updated?
- Were tests or manual verification specified?

Output:

```text
Result: clear / concerns / blocker
Protected path touched:
Invariant risk:
Required next action:
```
