# Slice 012: Required Control Surface And Geodesic Shell

## Goal

Make the reusable native kit include the viewport control surface by default and use the imported Fey 3V geodesic shell as the default physical speaker anchor surface.

## Depends On

```text
Slice 011: VU Meter Plumbing And Settings Tray
```

## Protected Path Touch

Allowed:

```text
Sources/OrbitalViewRender/
Tests/OrbitalViewRenderTests/
Sources/OrbitalViewSwiftUI/
Tests/OrbitalViewSwiftUITests/
```

## Acceptance Criteria

- `OrbitalView` includes a native reusable control surface for Plan, Elevation, Isometric, Export PNG, speaker shape, speaker size, fog density, speaker numbers, and hidden lines.
- Native display settings are separate from meter/VU visual settings.
- The default Wavefield/Fey scene adapter uses an imported Fey geodesic shell and node anchors.
- Renderer draw inputs resolve node anchors to shell node positions.
- Meter updates and VU setting updates still do not rebuild static speaker geometry.
- Docs record that future kit integrations must include the control surface and imported geodesic shell path.

## Required Checks

```text
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test
```

