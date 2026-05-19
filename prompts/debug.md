# Debug Prompt

```text
Use the debug skill.

Read AGENTS.md, docs/status.md, docs/bugs.md, docs/protected-paths.md, and the relevant task or slice.

Investigate the failure without making broad unrelated changes.

Goal:

- Identify root cause
- Explain why it happened
- Fix the smallest reasonable scope
- Add or update regression test
- Run relevant checks
- Update docs/status.md
- Update docs/bugs.md

Do not refactor unrelated code.
Do not touch protected paths unless explicitly allowed.

Return:

1. Root cause
2. Fix made
3. Files changed
4. Regression test added or updated
5. Commands run and results
6. Bug list update
7. Protected paths touched
8. Remaining risks
```
