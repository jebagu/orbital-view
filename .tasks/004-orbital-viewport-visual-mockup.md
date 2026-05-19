# Task 004: Orbital Viewport Visual Mockup

## Status

```text
complete
```

## Goal

Create a disposable HTML/CSS/JS visual mockup for the OrbitalViewKit spherical monitor viewport before Swift renderer implementation.

## Scope

Implemented:

- Static browser mockup under `mockups/orbital-view-viewport/`.
- Canvas-rendered spherical speaker viewport with fake Fey-style speaker positions.
- Camera preset buttons, reset, projection toggle, structure/speaker/label/cutaway toggles.
- Fake meter animation mapped to glow, ring intensity, and color.
- Speaker selection inspector and speaker level list.

Out of scope:

- Swift, SwiftUI, MetalKit, or renderer source.
- Real audio, real meters, persistence, or production business logic.
- DomeLab code import.

## Protected Path Check

This task:

```text
does not touch protected downstream paths
```

## Verification

```text
node -e 'const fs=require("fs"); const html=fs.readFileSync("mockups/orbital-view-viewport/index.html","utf8"); const scripts=[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m=>m[1]).join("\n"); new Function(scripts); console.log("inline JS parses");'
```

The mockup is static HTML, so the verification command extracts and parses its inline JavaScript.
