# Favorly iOS

Favorly is a hyperlocal iOS app that lets neighbors post small help requests and pick them up. This repo holds the Phase 1 prototype: SwiftUI, fake data and a fake location, run in the iOS Simulator.

| Nearby | Request detail | My Activity |
| --- | --- | --- |
| ![Nearby list with a radius picker](docs/screenshots/nearby.png) | ![Request detail after a pick up](docs/screenshots/request-detail.png) | ![My Activity showing a claimed request](docs/screenshots/my-activity.png) |

The Phase 1 plan is in [docs/PLAN.md](docs/PLAN.md), the Phase 2 (UI refresh) plan in [docs/PLAN-PHASE-2.md](docs/PLAN-PHASE-2.md), the layering rules in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and the status and decision log in [docs/PROGRESS.md](docs/PROGRESS.md).

## Prerequisites

- A Mac with the latest stable Xcode and at least one iOS Simulator runtime (iOS 17 or later)
- Command-line builds pointed at Xcode: `sudo xcode-select -s /Applications/Xcode.app`
- Homebrew tools: `brew install xcodegen swiftlint swiftformat`

## Setup

The Xcode project is generated from `project.yml` and is not checked in.

```bash
git clone git@github.com:TerenceZhang29/favorly-ios.git
cd favorly-ios
xcodegen generate
```

Run `xcodegen generate` again after any change to `project.yml`.

## Run

```bash
open Favorly.xcodeproj
```

Pick an iPhone simulator and press Run. All data is in memory and resets on every launch.

## Test

```bash
# fast logic tests, no Simulator
swift test --package-path Packages/FavorlyKit

# list simulators, then pick an available iPhone name
xcrun simctl list devices available

# build and run all tests on a simulator
xcodebuild test -project Favorly.xcodeproj -scheme Favorly \
  -destination 'platform=iOS Simulator,name=<iPhone model from the list>'
```

The second command runs the package tests again on iOS, plus the UI tests. `DemoFlowUITests` walks through the demo script below. UI tests launch the app with `-uiTesting`, which removes the 300 ms delay the mock data layer adds to mimic a network.

## Lint and format

```bash
swiftlint --strict
swiftformat --lint .   # drop --lint to apply the fixes
```

## Demo script

One person plays both sides by switching users in the Dev Settings tab. It takes about five minutes.

1. Launch the app. Dev Settings shows *Alex @ Cornell Tech, Roosevelt Island*.
2. Nearby: 7 open requests within 1 mi, closest first. Change the radius to 0.25 mi (3 requests), then to 3 mi (8 requests), then back to 1 mi.
3. Post tab: title "Need a cup of rice", category Ingredient, location tagged at Cornell Tech. Tap Post request. My Activity opens and shows it as *Open*.
4. Dev Settings: switch to Bea. Nearby: Alex's rice request is at the top at "< 0.1 mi".
5. Open it, tap Pick up and confirm. The status becomes *Claimed by Bea*. It leaves Nearby and appears in My Activity under *Picked up by me*.
6. Dev Settings: switch back to Alex. My Activity shows the rice request as *Claimed by Bea*. Open it and tap Mark completed.
7. Dev Settings: choose Ithaca, NY. Nearby shows "No requests within 1 mi". Tap Reset demo data to finish.

## Updating the screenshots

`ScreenshotUITests` is skipped unless it is given a folder to write to:

```bash
TEST_RUNNER_SCREENSHOT_DIR=/tmp/favorly-shots xcodebuild test \
  -project Favorly.xcodeproj -scheme Favorly \
  -destination 'platform=iOS Simulator,name=<iPhone model>' \
  -only-testing:FavorlyUITests/ScreenshotUITests
```

Copy the images you want into `docs/screenshots/`.
