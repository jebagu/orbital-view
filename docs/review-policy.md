# Review Policy

## Default Rule

Normal code changes use built-in Codex review.

Specialty review is reserved for special stuff.

## Use Specialty Review When

- Audio behavior changes
- A protected path is touched
- Performance-sensitive code changes
- Reliability-sensitive code changes
- Architecture changes
- A large work package reaches a merge point
- Multiple slices interact in a risky way

## Specialty Reviewers

```text
performance
reliability
architecture
audio
protected-path
```

Optional later:

```text
UX/accessibility
```

Not default:

```text
security
adversarial
```

Reason:

```text
These projects are local apps. Security and adversarial review become important only if the app adds networking, plugins, licensing, auto-update behavior, private-file access beyond normal local use, or external services.
```

## Synthesis Rule

Do not send Jeremy raw reviewer dumps.

The synthesis should return:

```text
P0 blockers
P1 should-fix
P2 nice-to-fix
Safe autofixes
Manual decisions needed
Protected path concerns
Audio concerns
Recommended next action
```
