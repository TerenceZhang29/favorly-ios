# Progress

Updated by every coding session. Read this after `docs/PLAN.md` and continue from the first unchecked item.

**Current phase:** 1D. App environment and navigation shell
**Next task:** Add `AppEnvironment` and its SwiftUI `EnvironmentKey` to `FavorlyFeatures/Environment/`, then `AppEnvironment.demo()` in the App target

## Phase checklist

- [x] **1A.** Repo scaffold and empty app
- [x] **1B.** Core domain (models, protocols, rules, distance)
- [x] **1C.** Mock data layer (repository, location, session, seed data)
- [ ] **1D.** App environment and navigation shell (tabs, Dev Settings)
- [ ] **1E.** Browse nearby + request detail + pick up (Flow 2)
- [ ] **1F.** Post request + My Activity (Flow 1)
- [ ] **1G.** Hardening, UI test, docs, tag `v0.1.0-prototype`

## Confirmed decisions

Defaults from the plan's Preparation section. Change here if the team decides otherwise.

- Bundle identifier: `edu.cornelltech.team402.favorly`
- Minimum iOS: 17
- Default fake location: Cornell Tech, Roosevelt Island (40.7553, -73.9562)
- Categories: Ingredient, Moving help, Car help, Errand, Other
- Units: miles in the UI, meters internally

## Decisions made during implementation

Add entries as `YYYY-MM-DD · phase · decision · reason`.

- 2026-10-07 · 1A · The `Favorly` scheme's test action lists the three package test targets and `FavorlyUITests` directly, with no `.xctestplan` file · a test plan file refers to project targets by generated IDs, which would be hand-maintained against a git-ignored project; the scheme runs the same tests
- 2026-10-07 · 1A · Optional GitHub Actions CI left out · it could not be verified from this machine, and the hosted runner's Xcode and simulator names are unknown; add it once someone can watch a run
- 2026-10-07 · 1A · `FavorlyCoreModule` and `FavorlyDataModule` are placeholder types so the targets compile and have one trivial test each · delete them in 1B and 1C when real types land
- 2026-10-07 · 1A · Only folders that hold a file exist so far (`Root/` in Features) · git does not track empty folders; each later phase creates the plan's folders as it fills them
- 2026-10-07 · 1A · SwiftFormat rule `wrapPropertyBodies` disabled · the plan's own code uses one-line computed properties (`var id: RequestID { request.id }`)
- 2026-10-07 · 1A · SwiftLint `trailing_comma` set to mandatory · otherwise it conflicts with SwiftFormat, which adds trailing commas
- 2026-10-07 · 1A · UI test target has `LaunchUITests` (app shows four tabs) · the target needs a source file; `DemoFlowUITests` arrives in 1G
- 2026-10-07 · 1B · Every public model has an explicit `public init`; `HelpRequest`'s defaults `helperID` and `claimedAt` to `nil` and `status` to `.open` · Swift's memberwise initializers are internal, so other modules could not build the types otherwise
- 2026-10-07 · 1B · `DraftValidator.validate(_:)` returns the draft with title and details trimmed (`@discardableResult`), where the plan shows no return value · the repository must store the trimmed title, and this keeps the trimming in one place
- 2026-10-07 · 1B · Details are trimmed before the 500-character check, like the title · the plan only says "0–500 characters"; trailing whitespace should not use up the limit
- 2026-10-07 · 1B · `validateClaim` checks "own request" before status, so a requester claiming their own already-claimed request gets `cannotClaimOwnRequest` · the plan does not order the two checks
- 2026-10-07 · 1B · `DistanceFormatter.miles` shows "< 0.1 mi" for anything under 0.1 mi, including 0.05–0.1 mi that would round up to "0.1 mi" · the plan's wording allows either; this one never overstates a short distance
- 2026-10-07 · 1B · Added `Distance.metersPerMile`, `Distance.meters(fromMiles:)`, `DraftValidator.titleLengthRange` and `DraftValidator.maxDetailsLength` · the UI needs the same constants for the radius picker and form hints
- 2026-10-07 · 1B · SwiftLint `identifier_name` allows `to` · the plan names the parameter in `canTransition(from:to:)`
- 2026-10-07 · 1C · `LocationSettings` is a `@MainActor` protocol in Core, with `LocationPreset` as a Core model; the `@Observable` class is `MockLocationSettings` in Data · the plan puts `LocationSettings` in Data but has `AppEnvironment` (Features) hold it, and Features must not import Data. This mirrors `SessionStore` / `MockSessionStore`
- 2026-10-07 · 1C · Seed data is `DemoRequests.all(now:)`, a function, where the plan writes `DemoRequests.all` · timestamps are relative to launch time, and tests need a fixed clock
- 2026-10-07 · 1C · `MockRequestRepository.init` takes `seed`, `artificialDelay` and `now` closures/values, all defaulted · tests run with zero delay and a fixed clock; 1G's `-uiTesting` launch argument will pass zero delay
- 2026-10-07 · 1C · `reset()` skips the artificial delay and emits on `changes()` · it is a dev-settings action, and open screens must refresh after it
- 2026-10-07 · 1C · `requests(claimedBy:)` returns every request whose helper is the user, whatever its status, newest claim first · "Picked up by me" should keep showing completed and cancelled pick-ups
- 2026-10-07 · 1C · `changes()` streams buffer one pending signal · the signal has no payload, so a slow subscriber needs only one refresh
- 2026-10-07 · 1C · `FavorlyData` imports `os` (for `OSAllocatedUnfairLock` in `ChangeBroadcaster`) and `Observation` · `changes()` is not `async`, so the actor needs a lock-protected subscriber list; both are system frameworks
- 2026-10-07 · 1C · Seed has 12 requests: from Cornell Tech, 3 open within 0.25 mi, 7 within 1 mi, 8 within 3 mi · matches the plan's "about 8" for the demo and makes each radius step visibly change the list
- 2026-10-07 · 1A · Tab bar buttons are found by label in UI tests (`app.tabBars.buttons["Nearby"]`) · SwiftUI does not reliably pass a tab item's `accessibilityIdentifier` to the tab bar button

## Known issues

- `xcodebuild` prints `appintentsmetadataprocessor ... Metadata extraction skipped` warnings. They come from an Xcode build tool, not the Swift compiler, and need no action.

## Open questions

- 1B and 1C were each branched from the previous phase branch because the earlier pull requests were not merged yet. Merge them in order, or merge the latest alone, which contains the earlier ones.
- The plan's 1A says "first commit pushed to `main`", while `CLAUDE.md` says one branch per phase. Resolved as: the pre-existing docs were committed straight to `main`, and the 1A work is on `phase/1a-scaffold` for a pull request.

## Session log

Newest first, one line per session: `YYYY-MM-DD · phase · what was done · next step`.

- 2026-10-07 · 1C · Seed fixtures (`LocationPresets`, `DemoUsers`, `DemoRequests`), `MockRequestRepository`, `MockLocationProvider`, `MockLocationSettings`, `MockSessionStore` with 40 tests; `swift test` and `xcodebuild test` pass · start 1D on `phase/1d-app-shell`
- 2026-10-07 · 1B · Models, service protocols, `FavorlyError`, `RequestRules`, `DraftValidator`, `Distance`, `DistanceFormatter` in `FavorlyCore` with 28 tests; Core imports only Foundation; `swift test` and `xcodebuild test` pass · start 1C on `phase/1c-mock-data`
- 2026-10-07 · 1A · Package with three library and three test targets, `project.yml`, app with four empty tabs, launch UI test, lint/format configs, README, ARCHITECTURE; `swift test` and `xcodebuild test` (iPhone 17, iOS 27.0) pass · start 1B on `phase/1b-core-domain`
