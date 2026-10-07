# Favorly iOS

Favorly is a hyperlocal iOS app that lets neighbors post small help requests and pick them up. This repo holds the Phase 1 prototype: SwiftUI, fake data and a fake location, run in the iOS Simulator.

The plan is in [docs/PLAN.md](docs/PLAN.md), the layering rules in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and the current status in [docs/PROGRESS.md](docs/PROGRESS.md).

## Prerequisites

- A Mac with the latest stable Xcode and at least one iOS Simulator runtime
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

Pick an iPhone simulator and press Run.

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

## Lint and format

```bash
swiftlint --strict
swiftformat --lint .   # drop --lint to apply the fixes
```
