# Single Task Execution Prompt

```text
Read AGENTS.md first.

Then read:

- docs/product-brief.md
- docs/architecture.md
- docs/contracts.md
- docs/protected-paths.md
- docs/system-flows.md
- docs/implementation-map.md
- docs/test-strategy.md
- docs/status.md
- docs/bugs.md
- .tasks/[TASK-FILE].md

Implement exactly this task and nothing outside its scope.

After implementation:

- Add or update relevant tests
- Run relevant verification commands
- Fix failures caused by this task
- Update docs/status.md
- Update docs/implementation-map.md if files changed
- Update docs/system-flows.md if flows changed
- Update docs/contracts.md only if explicitly allowed
- Update docs/bugs.md if bugs were found or fixed

Stop if:

- The task requires a product decision
- The task requires changing a public contract
- The task requires touching protected paths without permission
- The task requires a major dependency
- The task conflicts with existing docs
- The task cannot be verified

Final response must include:

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
```
