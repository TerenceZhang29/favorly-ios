# Architecture

A short summary of the layers and rules. [PLAN.md](PLAN.md) has the full detail.

## Layers

```
App target (Favorly)  ──►  FavorlyFeatures  ──►  FavorlyCore
        │                                           ▲
        └──────────────►  FavorlyData  ─────────────┘
```

| Module | Holds | May import |
| --- | --- | --- |
| `FavorlyCore` | Models, service protocols, errors, business rules | Foundation only |
| `FavorlyData` | In-memory mock services and seed data | `FavorlyCore` |
| `FavorlyFeatures` | SwiftUI screens and `@Observable` view models | `FavorlyCore`, SwiftUI |
| App target | `@main`, and the choice of concrete services | all three |

The three modules are library targets of one local package, `Packages/FavorlyKit`.

## Rules

- `FavorlyFeatures` never imports `FavorlyData`. Views get services only through `AppEnvironment`.
- The App target is the only place that picks concrete implementations.
- A real backend arrives as a new sibling of `FavorlyData`, not as edits to it.
- One type per file; the file name matches the type; `public` only for what other modules need.
- No third-party runtime dependencies without a note in [PROGRESS.md](PROGRESS.md).

## Project file

`project.yml` (XcodeGen) is the source of truth. `Favorly.xcodeproj` is generated and git-ignored.

## Tests

- Package tests use Swift Testing and run on macOS with `swift test`, without a Simulator.
- The `Favorly` scheme runs the same package tests plus the UI tests on an iOS Simulator.
