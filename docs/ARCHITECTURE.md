# Architecture

A short summary of the layers and rules. [PLAN.md](PLAN.md) has the full detail, and [PROGRESS.md](PROGRESS.md) logs every place the code departs from it.

## Layers

```
App target (Favorly)  ──►  FavorlyFeatures  ──►  FavorlyCore
        │                                           ▲
        └──────────────►  FavorlyData  ─────────────┘
```

| Module | Holds | May import |
| --- | --- | --- |
| `FavorlyCore` | Models, service protocols, errors, business rules | Foundation only |
| `FavorlyData` | In-memory mock services and seed data | `FavorlyCore`, system frameworks |
| `FavorlyFeatures` | SwiftUI screens and `@Observable` view models | `FavorlyCore`, SwiftUI |
| App target | `@main`, and the choice of concrete services | all three |

The three modules are library targets of one local package, `Packages/FavorlyKit`.

## Rules

- `FavorlyFeatures` never imports `FavorlyData`. Views get services only through `AppEnvironment`.
- The App target is the only place that picks concrete implementations (`AppEnvironment.demo()`).
- A real backend arrives as a new sibling of `FavorlyData`, not as edits to it.
- One type per file; the file name matches the type; `public` only for what other modules need.
- No third-party runtime dependencies without a note in [PROGRESS.md](PROGRESS.md).

## How a screen is put together

- `AppEnvironment` holds the four services: `RequestRepository`, `LocationProvider`, `SessionStore` and `LocationSettings`. All four are protocols in Core.
- `RootView` reads the environment once and hands it to each screen's initializer. The screen creates its view model from it.
- View models are `@MainActor @Observable` classes. They expose a `state` enum and async methods such as `load()`, and hold no SwiftUI types.
- Screens refresh in two ways. `observeChanges()` reloads after any repository write. A `reloadKey` on the view model, used with `.task(id:)`, reloads when the user, location or radius changes.
- Business rules live in Core (`RequestRules`, `DraftValidator`, `Distance`). The repository enforces them; view models use the same rules to decide which buttons to show.
- Other users see only a location label and a rounded distance, never coordinates.

## Project file

`project.yml` (XcodeGen) is the source of truth. `Favorly.xcodeproj` is generated and git-ignored.

## Tests

- Package tests use Swift Testing and run on macOS with `swift test`, without a Simulator. View model tests run against the real mocks from `FavorlyData` with no artificial delay.
- The `Favorly` scheme runs the same package tests plus the UI tests on an iOS Simulator.
- UI tests find elements by `accessibilityIdentifier` and subclass `UITestCase`, which launches the app with `-uiTesting`.
