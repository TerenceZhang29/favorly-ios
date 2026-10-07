# Favorly iOS prototype

Favorly is a hyperlocal iOS app that lets neighbors post small help requests and pick them up. This repo holds the Phase 1 prototype: SwiftUI, fake data and a fake location, run in the iOS Simulator.

## Start of every session

1. Read `docs/PLAN.md`. It is the source of truth for scope, architecture, interfaces and acceptance criteria.
2. Read `docs/PROGRESS.md` and continue from the first unchecked phase or task.
3. If the plan is ambiguous or seems wrong, write the question in `docs/PROGRESS.md` under "Open questions" and pick the most reasonable option. Don't silently diverge from the plan.

## How to work

- Do one phase (1A → 1G) per session, on a branch named `phase/<id>-<short-name>` (e.g. `phase/1b-core-domain`).
- Commit in small steps using Conventional Commits (`feat(core): request status rules`).
- Implement the types and protocols in the plan's "Domain model" section as written. If you must change one, record why in `docs/PROGRESS.md`.
- Every new rule, repository method or view model ships with tests in the same phase.

## Architecture rules (do not break)

- Dependencies: `FavorlyFeatures → FavorlyCore` and `FavorlyData → FavorlyCore`. The App target imports both.
- `FavorlyCore` imports only Foundation.
- `FavorlyFeatures` never imports `FavorlyData`. Views get services only through `AppEnvironment`.
- One type per file; the file name matches the type; `public` only for what other modules need.
- No third-party runtime dependencies without a note in `docs/PROGRESS.md`.
- Keep the UI plain system SwiftUI. Add an `accessibilityIdentifier` to every interactive element.

## Project file

- `project.yml` (XcodeGen) is the source of truth. Never hand-edit `Favorly.xcodeproj`; it is git-ignored.
- After changing `project.yml`, run `xcodegen generate`.

## Commands

```bash
xcodegen generate
swift test --package-path Packages/FavorlyKit
xcrun simctl list devices available
xcodebuild test -project Favorly.xcodeproj -scheme Favorly \
  -destination 'platform=iOS Simulator,name=<available iPhone>'
```

## Before ending a phase

1. `swift test` passes, and `xcodebuild test` passes once the app target exists (1A onward).
2. No compiler warnings under Swift 6 strict concurrency; SwiftLint is clean.
3. The phase's "Done when" criteria in `docs/PLAN.md` are met.
4. `docs/PROGRESS.md` is updated: tick tasks, log decisions and known issues, and name the next task.
5. Commit and push the branch; summarize the changes for the PR description.
