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

## Theme

How the app looks is decided in one place. [PLAN-PHASE-2.md](PLAN-PHASE-2.md) has the palette and the reasons behind it.

- **One source of style.** Screen files never contain a literal color, corner radius, spacing number or shape. They use `Theme` and the shared components.
- `Shared/Theme/` holds `Theme` (colors, spacing, radii, icon sizes, opacities), `AdaptiveColor` (a light and a dark value that follows the color scheme) and `RGBColor` (plain numbers, so contrast can be unit tested). Categories and statuses get their color from `RequestCategory+Color` and `RequestStatus+Color`.
- `Shared/Components/` holds the building blocks: `CategoryIcon`, `StatusBadge`, `TagBadge`, `PrimaryButtonStyle`, `SecondaryButtonStyle`, `MessageView`, `SectionHeader`, `InlineMessage`, `ErrorBanner` and a few list helpers. They take plain values, never a view model, and each has a light and dark preview.
- A colored element is the color as foreground on a 14% tint of itself. Only the one primary button on a screen is a solid fill.
- Backgrounds and plain text use the system's colors (`.primary`, `.secondary`, list backgrounds), so dark mode and Increase Contrast work without extra code.
- `ThemeTests` checks that every palette color reaches a 4.5:1 contrast ratio on its own tint, in both modes. A new color goes into `Theme.Colors.palette` so the test covers it.
- The app icon is drawn by `scripts/make-app-icon.swift`. Run it again if the brand color changes.

## Project file

`project.yml` (XcodeGen) is the source of truth. `Favorly.xcodeproj` is generated and git-ignored.

## Tests

- Package tests use Swift Testing and run on macOS with `swift test`, without a Simulator. View model tests run against the real mocks from `FavorlyData` with no artificial delay.
- The `Favorly` scheme runs the same package tests plus the UI tests on an iOS Simulator.
- UI tests find elements by `accessibilityIdentifier` and subclass `UITestCase`, which launches the app with `-uiTesting`.
