# Codex Plan Audit Prompt

```text
Read AGENTS.md and all files in docs/.

Do not write code.

Audit the project plan for:

- Missing requirements
- Unclear module boundaries
- Missing contracts
- Contradictory instructions
- Untestable tasks
- Bad task ordering
- Missing test strategy
- Missing protected path definitions
- Missing audio constraints
- Missing stopping conditions
- Places where implementation would likely drift from docs

Return:

1. Issues found
2. Recommended doc changes
3. Recommended task or work-package changes
4. Protected path concerns
5. Audio-specific concerns
6. Questions that block implementation
7. Questions that can be treated as assumptions
```
