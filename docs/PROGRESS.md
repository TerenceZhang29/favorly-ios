# Progress

Updated by every coding session. Read this after `docs/PLAN.md` and continue from the first unchecked item.

**Current phase:** Phase 1 complete (`v0.1.0-prototype`)
**Next task:** Merge the phase pull requests into `main`, then run the demo script in the README by hand once. Phase 2 has no plan yet; see "What later phases will plug in" in `docs/PLAN.md`

## Phase checklist

- [x] **1A.** Repo scaffold and empty app
- [x] **1B.** Core domain (models, protocols, rules, distance)
- [x] **1C.** Mock data layer (repository, location, session, seed data)
- [x] **1D.** App environment and navigation shell (tabs, Dev Settings)
- [x] **1E.** Browse nearby + request detail + pick up (Flow 2)
- [x] **1F.** Post request + My Activity (Flow 1)
- [x] **1G.** Hardening, UI test, docs, tag `v0.1.0-prototype`

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
- 2026-10-07 · 1D · `SessionStore` and `LocationSettings` now also require `Sendable` · `AppEnvironment` must be `Sendable` to be an environment default and to be captured by view-model tasks; `@MainActor` classes already are, so conformers need no change
- 2026-10-07 · 1D · The environment value uses SwiftUI's `@Entry` macro (`EnvironmentValues.appEnvironment`), where the plan says `EnvironmentKey` · `@Entry` generates the same key; SwiftFormat rewrites a hand-written key to it
- 2026-10-07 · 1D · `AppEnvironment.preview()` is built from small read-only stubs inside Features (`PreviewRequestRepository`, `PreviewLocationProvider`, `PreviewSessionStore`, `PreviewLocationSettings`) · Features cannot import Data, and previews and the environment default still need something to run on
- 2026-10-07 · 1D · A view with no injected environment gets `AppEnvironment.sharedPreview` through `MainActor.assumeIsolated` · the default must be produced from a nonisolated context; SwiftUI reads environment values on the main actor. The app always injects `AppEnvironment.demo()`
- 2026-10-07 · 1D · `FavorlyFeaturesTests` depends on `FavorlyData` · the plan calls for view model tests against the mocks; only the Features sources are barred from importing Data
- 2026-10-07 · 1D · Dev Settings lists users and locations as rows of buttons with a checkmark, not `Picker`s · each row gets a stable `accessibilityIdentifier` the UI tests can tap
- 2026-10-07 · 1D · No Dev Settings view model · the screen only forwards taps to the session, location settings and repository, and holds no logic to test; `DevSettingsUITests` covers it end to end
- 2026-10-07 · 1D · "Reset demo data" restores requests only, not the current user or location · the plan lists it under data controls
- 2026-10-07 · 1D · The debug line reads "Alex @ Cornell Tech, Roosevelt Island", using the full location label, where the plan's example shows "Alex @ Cornell Tech" · the label is the plan's own preset name
- 2026-10-07 · 1E · View models take the `AppEnvironment` in `init`; `RootView` reads it from the SwiftUI environment and passes it down · a view model has to exist before the view body runs, so it cannot read `@Environment` itself
- 2026-10-07 · 1E · Location and radius changes reload through `.task(id: viewModel.reloadKey)` in the view; repository writes reload through `viewModel.observeChanges()` · the plan says the view model "observes" both; this keeps the view model free of observation plumbing and easy to test
- 2026-10-07 · 1E · A list already on screen stays visible while it reloads; only the first load and a retry after an error show the spinner · avoids a flicker on every radius tap and every write
- 2026-10-07 · 1E · Nearby keeps the debug line ("Alex @ Cornell Tech, Roosevelt Island") as its location header, and shows a count ("7 requests") above the list · on one laptop the demo needs to show who is signed in; the count makes radius changes obvious and gives UI tests something stable to read
- 2026-10-07 · 1E · The detail status row reads "Claimed by Bea" while claimed, with a separate Helper row for claimed and completed requests · matches the demo script's wording
- 2026-10-07 · 1E · Only Pick up asks for confirmation; Cancel request and Mark completed act at once · the plan asks for a dialog before Pick up only
- 2026-10-07 · 1E · When an action fails, the detail screen shows the message and reloads the request · after `alreadyClaimed` the user should see who claimed it
- 2026-10-07 · 1E · Added `BrowseAndPickUpUITests` (Flow 2, own request has no Pick up, empty and error states) · the plan checks Flow 2 by hand; an agent cannot, so the flow is automated
- 2026-10-07 · 1F · `RootView` owns the tab selection and the just-posted request ID; `PostRequestView` reports a post through an `onPosted` closure · switching tabs and highlighting are navigation concerns, so the Post view model stays unaware of other tabs
- 2026-10-07 · 1F · The new request is highlighted in My Activity (tinted row and a "New" badge) until the user leaves that tab · the plan says "highlight" without saying for how long
- 2026-10-07 · 1F · The Post form's category defaults to Other · none of the five is an obvious default, and the demo picks Ingredient explicitly
- 2026-10-07 · 1F · The title message appears only once the user has typed something; the Post button is disabled either way · an empty form should not open with an error
- 2026-10-07 · 1F · My Activity rows show the status ("Claimed by Bea"), plus "Posted by Dana" for requests picked up from someone else · the plan lists "status and helper" for My requests and nothing for Picked up by me
- 2026-10-07 · 1F · `statusText(for:)` moved to a `SessionStore` extension shared by Request Detail and My Activity · both screens need the same "Claimed by Bea" wording
- 2026-10-07 · 1F · Added `PostAndGetPickedUpUITests` (Flow 1 end to end, and the two empty states) · the plan checks Flow 1 by hand; 1G turns this into `DemoFlowUITests`
- 2026-10-07 · 1G · `-uiTesting` only sets the mock delay to zero · the plan also says it "resets data", but data is in memory and every launch already starts from the seed
- 2026-10-07 · 1G · `DemoFlowUITests` runs the whole seven-step demo script, which contains Flow 1; it replaces 1F's `PostAndGetPickedUpUITests` · one test that mirrors the README script is easier to keep in step with it
- 2026-10-07 · 1G · UI tests share a `UITestCase` base class (launch, lookup by identifier, wait, scroll-then-tap) · removes the duplicated helpers noted in 1F
- 2026-10-07 · 1G · List rows speak one sentence to VoiceOver ("Need 2 eggs for a cake, Ingredient, less than 0.1 miles away, posted 12 minutes ago by Chen"); detail rows read as label plus value · the default reading split each row into fragments and read "<" literally. Added `DistanceFormatter.spokenMiles` in Core for this
- 2026-10-07 · 1G · Detail rows stack the value under the label at accessibility text sizes, and row icons scale with the text · side-by-side text was cramped at large sizes
- 2026-10-07 · 1G · Dev Settings rows use primary text color, not the button tint · every row looked like a link
- 2026-10-07 · 1G · `ScreenshotUITests` regenerates the README screenshots and is skipped unless `TEST_RUNNER_SCREENSHOT_DIR` is set · an agent cannot tap through the Simulator by hand to capture them
- 2026-10-07 · 1G · Tag `v0.1.0-prototype` points at the tip of `phase/1g-hardening`, because the phase pull requests were not merged yet · if the pull requests are squash-merged, move the tag to the resulting commit on `main`
- 2026-10-07 · 1A · Tab bar buttons are found by label in UI tests (`app.tabBars.buttons["Nearby"]`) · SwiftUI does not reliably pass a tab item's `accessibilityIdentifier` to the tab bar button

## Known issues

- Not yet checked by a person: the demo script has only been run by `DemoFlowUITests`, and VoiceOver labels were set in code and read back through UI tests, not listened to with VoiceOver on.
- The segmented radius and activity pickers do not grow with Dynamic Type. That is how the system control behaves; everything else was checked at the `accessibility-large` text size.
- The optional GitHub Actions CI from 1A is still not set up.
- The UI test suite takes a little over three minutes, mostly app launches and typing.
- If a UI test fails, `xcodebuild` can sit for several minutes collecting diagnostics before it exits.
- `xcodebuild` prints `appintentsmetadataprocessor ... Metadata extraction skipped` warnings. They come from an Xcode build tool, not the Swift compiler, and need no action.

## Open questions

- 1B through 1G were each branched from the previous phase branch because the earlier pull requests were not merged yet. Merge them in order, or merge the latest alone, which contains the earlier ones.
- The plan's 1A says "first commit pushed to `main`", while `CLAUDE.md` says one branch per phase. Resolved as: the pre-existing docs were committed straight to `main`, and the 1A work is on `phase/1a-scaffold` for a pull request.

## Session log

Newest first, one line per session: `YYYY-MM-DD · phase · what was done · next step`.

- 2026-10-07 · 1G · `-uiTesting` flag, `DemoFlowUITests`, accessibility pass, README with demo script and screenshots, architecture notes; a fresh clone generates, lints and passes `swift test` and `xcodebuild test`; tagged `v0.1.0-prototype` · merge the pull requests, run the demo by hand
- 2026-10-07 · 1F · `PostRequestViewModel`, `PostRequestView`, `ActivityViewModel`, `ActivityView`, `ActivityRow`, `ActivitySegment`, post-then-highlight navigation; 56 Features tests and Flow 1 UI tests; `swift test` and `xcodebuild test` pass · start 1G on `phase/1g-hardening`
- 2026-10-07 · 1E · `NearbyViewModel`, `NearbyView`, `RequestRow`, `RadiusOption`, `RequestDetailViewModel`, `RequestDetailView`, shared display helpers; 38 Features tests and Flow 2 UI tests; `swift test` and `xcodebuild test` pass · start 1F on `phase/1f-post-activity`
- 2026-10-07 · 1D · `AppEnvironment` with preview stubs and environment value, `AppEnvironment.demo()` in the App target, four tabs each in a `NavigationStack`, working Dev Settings, `DevSettingsUITests`; `swift test` and `xcodebuild test` pass · start 1E on `phase/1e-nearby-detail`
- 2026-10-07 · 1C · Seed fixtures (`LocationPresets`, `DemoUsers`, `DemoRequests`), `MockRequestRepository`, `MockLocationProvider`, `MockLocationSettings`, `MockSessionStore` with 40 tests; `swift test` and `xcodebuild test` pass · start 1D on `phase/1d-app-shell`
- 2026-10-07 · 1B · Models, service protocols, `FavorlyError`, `RequestRules`, `DraftValidator`, `Distance`, `DistanceFormatter` in `FavorlyCore` with 28 tests; Core imports only Foundation; `swift test` and `xcodebuild test` pass · start 1C on `phase/1c-mock-data`
- 2026-10-07 · 1A · Package with three library and three test targets, `project.yml`, app with four empty tabs, launch UI test, lint/format configs, README, ARCHITECTURE; `swift test` and `xcodebuild test` (iPhone 17, iOS 27.0) pass · start 1B on `phase/1b-core-domain`
