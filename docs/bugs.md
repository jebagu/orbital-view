# Bug List

## Open Bugs

```text
none
```

## Fixed Bugs

```text
2026-05-21: Cube VU speakers in the SceneKit review app appeared as solid purple cubes and showed an unintended cubical halo. Fixed by removing the separate halo SCNBox child nodes and driving the actual six SCNBox cube faces with a retained 9x9 pixelated face texture cache, while preserving material-only meter updates and avoiding overlay face planes.
```

## Deferred Suspicions

```text
none
```
