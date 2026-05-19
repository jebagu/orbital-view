---
name: visual-mockup
description: Create a quick disposable HTML/CSS/JS mockup in mockups/[feature-name] before Swift implementation when Jeremy wants to see the UI, interaction, or audio control surface first.
---

# Visual Mockup Skill

## Purpose

Show what a Swift app feature might look and feel like before writing Swift code.

## Use When

- A feature has meaningful UI
- Jeremy says "show me what it looks like"
- Swift implementation would take too long to preview
- A control surface, timeline, meter, waveform, or flow needs visual iteration
- The product direction is still uncertain

## Do Not Use When

- The feature is backend-only
- The UI is trivial
- The feature is already visually obvious
- The mockup would take longer than writing Swift

## Rules

- Do not write Swift.
- Do not change app source code.
- Do not implement real persistence.
- Do not implement real audio processing.
- Do not implement production business logic.
- Use fake data.
- Keep the mockup lightweight.
- Make it easy to preview in a browser or Codex Canvas.
- Treat the mockup as disposable.

## Create

```text
mockups/[feature-name]/index.html
mockups/[feature-name]/notes.md
```

## The Mockup Should Show

- Main layout
- Primary user flow
- Important controls
- Important visual states
- Empty state
- Active state
- Error or warning state if useful
- Audio-specific controls, meters, waveform, or timeline if relevant

## notes.md Should Explain

1. What the mockup demonstrates
2. What is intentionally fake
3. Product questions Jeremy should decide
4. What Swift implementation would need later

## Final Response

Return:

```text
Mockup created:
What it demonstrates:
What is fake:
Product questions:
Recommended next step:
```
