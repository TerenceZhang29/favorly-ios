# Favorly iOS Prototype — Phase 2 Implementation Plan: UI refresh

Oct 7, 2026 · Team 402

## Overview

Phase 1 delivered a working prototype with deliberately plain visuals. Phase 2 makes it look good. The app keeps the same screens, the same flows and the same behavior; only how things look changes.

**Goal:** a minimal, clean, friendly UI with a small, consistent set of colors.

**In scope:** a small theme (colors, spacing, shapes), a handful of shared visual components, restyling of all five screens, dark mode, an app icon and accent color, refreshed screenshots.

**Out of scope:** new features, new screens, changed wording, changed navigation, new kinds of controls (the category picker stays a menu, the radius picker stays segmented), maps, images or illustrations, custom fonts, custom animations, iPad layouts, anything in the "later phases" table of [PLAN.md](PLAN.md).

**Definition of done:** every screen uses the theme, in light and dark mode and at accessibility text sizes; all Phase 1 tests pass without edits to what they assert; the diff for the phase touches no file in `FavorlyCore`, `FavorlyData` or any view model; the team has looked at the screenshots and approved them.

[PLAN.md](PLAN.md) still governs architecture, the domain model and behavior. This file governs how the app looks. Where the two disagree about looks (for example "keep the UI plain"), this file wins.

## Preparation work (you, before coding starts)

None of this blocks a start; the defaults below are used unless changed in `docs/PROGRESS.md`.

- [ ] Confirm or replace the brand color (default: teal, see *Color palette*)
- [ ] Say if there is an app you want this to feel like; otherwise the reference is Apple's own apps (Reminders, Health): lots of white space, one accent color, color used for meaning
- [ ] Agree who approves the look at the review gate after 2B

## Design principles

1. **System first.** Keep `List`, `Form`, `NavigationStack`, SF Symbols and the system font. Style them; do not replace them. This keeps Dynamic Type, VoiceOver, dark mode and pull to refresh working for free.
2. **One accent, color for meaning.** The brand color marks what the user can act on. Other colors appear only on category icons and status badges, and each always means the same thing.
3. **Color is never the only signal.** Every colored element also has text or an icon, so the app reads the same in grayscale and with VoiceOver.
4. **Hierarchy through weight and space, not decoration.** Titles are heavier, supporting text is smaller and gray, rows have room to breathe. No gradients, shadows or borders beyond what the system draws.
5. **One source of style.** Screens never contain a literal color, corner radius or spacing number. They use `Theme` and the shared components.

## Functionality guardrails (do not break)

These are what "functionality unchanged" means in practice. Each is checked at the end of every sub-phase.

- No changes under `Sources/FavorlyCore`, `Sources/FavorlyData`, or to any `*ViewModel.swift`. Check with `git diff --stat main -- <paths>`; it must be empty.
- No changes to the 125 package tests, other than adding new ones.
- Every `accessibilityIdentifier` keeps its exact name and stays on an element of the same kind (a button stays a button).
- Every visible string and every VoiceOver label stays the same. UI tests compare them exactly, for example `"Need a cup of rice, Ingredient, Open, new"` and `"7 requests"`.
- Controls keep their type and interaction: menu picker for category, segmented picker for radius and activity segment, confirmation dialog before Pick up, pull to refresh on Nearby.
- `LaunchUITests`, `DevSettingsUITests`, `BrowseAndPickUpUITests` and `DemoFlowUITests` pass with no edits. Only `ScreenshotUITests` changes, to capture more screens and appearances.
- If a visual change cannot be made without breaking one of these, do not make it. Write it under "Open questions" in `docs/PROGRESS.md` instead.

## Theme

All theme code lives in `Sources/FavorlyFeatures/Shared/Theme/`, one type per file, internal to the module.

### Color palette

Colors are defined in code as a light and a dark hex value, so they can be unit tested for contrast and need no asset catalog inside the package.

| Token | Used for | Light | Dark |
| --- | --- | --- | --- |
| `brand` | Tint: buttons, links, selected tab, "New" and "Yours" badges, distance | `#0A6B67` | `#4FD1C5` |
| `categoryIngredient` | Ingredient icon | `#286E2C` | `#6FCF7A` |
| `categoryMoving` | Moving help icon | `#4B4FC4` | `#9FA3FF` |
| `categoryCar` | Car help icon | `#195EB6` | `#6FB1FF` |
| `categoryErrand` | Errand icon | `#AB2D5E` | `#FF8FB3` |
| `neutral` | Other icon, Completed status | `#5A616C` | `#A9B0BC` |
| `statusOpen` | Open status | same as `brand` | same as `brand` |
| `statusClaimed` | Claimed status | `#974B00` | `#FFB357` |
| `statusCancelled` | Cancelled status, destructive actions, error text | `#B42424` | `#FF8A80` |

These values were checked by calculation when the plan was written: each reaches at least 4.6:1 as text on its own tint, in both modes. They have not been seen on a screen yet. If one looks wrong at the review gate, change it, keep the contrast test in 2A passing, and record the change in `docs/PROGRESS.md`.

Backgrounds and plain text use the system's own colors (`Color.primary`, `.secondary`, grouped list backgrounds), so they follow light and dark mode without any work.

**How a color is applied.** A colored element is the color as foreground on a soft tint of the same color (14% opacity). Solid fills with white text are used only for the one primary button on a screen.

### Types

| Type | What it is |
| --- | --- |
| `RGBColor` | Three `Double` components parsed from a hex integer, with `relativeLuminance` and `contrastRatio(with:)`. Plain value, no SwiftUI, so tests can use it |
| `AdaptiveColor` | A `ShapeStyle` holding a light and a dark `RGBColor`; `resolve(in:)` picks one from `environment.colorScheme` |
| `Theme` | An enum namespace: `Theme.Colors` (the tokens above), `Theme.Spacing` (`small` 4, `medium` 8, `large` 12, `xLarge` 16, `section` 24), `Theme.Radius` (`badge` 6, `tile` 10, `button` 12), `Theme.tintOpacity` (0.14) |
| `RequestCategory+Color` | `var color: AdaptiveColor` for each category |
| `RequestStatus+Color` | `var color: AdaptiveColor` for each status |

### Shared components

| Component | Replaces | Look |
| --- | --- | --- |
| `CategoryIcon` | The bare SF Symbol in rows | Symbol in the category color on a rounded square tinted with that color; size scales with Dynamic Type |
| `StatusBadge` | Plain status text where a status is shown on its own | Small capsule: status color text on its tint. Takes the text to show, so "Claimed by Bea" still reads in full |
| `TagBadge` | The plain "Yours" and "New" text | Same capsule in the brand color |
| `PrimaryButtonStyle` | Default text buttons for the main action | Full width, filled with the brand color, white semibold label, dimmed when disabled |
| `SecondaryButtonStyle` | Default text buttons for other actions | Full width, tinted background, colored label; takes a color so Cancel request can be red |
| `MessageView` | Bare `Text` for empty and error states | Centered SF Symbol, message, optional Retry button |
| `FactRow` (existing) | — | Gains an optional leading SF Symbol; keeps its stacking at accessibility sizes |

Components take plain values (strings, colors, a symbol name), never a view model, and each has a `#Preview` showing light and dark.

### App-level touches

- `RootView` applies `.tint(Theme.Colors.brand)`.
- `App/Resources/Assets.xcassets/AccentColor.colorset` gets the same two brand values, so system dialogs and the launch transition match.
- An app icon: a white `hand.raised` style glyph on the brand color, 1024×1024, generated by a small script kept in `scripts/` so it can be redrawn. Skip, and note it in `docs/PROGRESS.md`, if it cannot be generated reliably.
- `MARKETING_VERSION` in `project.yml` becomes `0.2.0`.

## Screen by screen

Layouts keep their order and content. The table lists only what changes.

| Screen | Changes |
| --- | --- |
| **Nearby** | Location line gets a `mappin.and.ellipse` icon and sits above the radius picker with more space. Rows: `CategoryIcon`, title in semibold, distance in the brand color followed by name and time in gray, "Yours" as a `TagBadge`, more vertical padding. Count header in a slightly larger, darker style. Empty and error states use `MessageView` (`tray` and `wifi.exclamationmark` symbols). Loading spinner centered with space around it |
| **Request Detail** | Header: `CategoryIcon` (large), title in `title2` bold, `StatusBadge` underneath, details text below with comfortable line spacing. Facts keep their rows and gain leading symbols (`tag`, `mappin`, `ruler`, `person`, `checkmark.seal`, `hands.sparkles`). Actions move out of plain list rows into full-width buttons: Pick up and Mark completed use `PrimaryButtonStyle`, Cancel request uses `SecondaryButtonStyle` in red. The action error becomes a red-tinted banner row with a warning symbol |
| **Post** | Section headers in sentence case with clearer spacing. Validation messages get a small warning symbol and the theme red. Location row shows the pin in the brand color. Post request uses `PrimaryButtonStyle` and sits in its own clear section; its disabled look must be obviously inactive |
| **My Activity** | Rows: `CategoryIcon`, title in semibold, status as a `StatusBadge`, "Posted by Dana" in gray beside it, "New" as a `TagBadge`. The highlighted new row keeps a brand-tinted background. Empty states use `MessageView` (`square.and.pencil` for My requests, `hand.thumbsup` for Picked up by me) |
| **Dev Settings** | Stays the plainest screen. Checkmarks in the brand color, a "Prototype only" note styled as a gray footer, Reset demo data as a red `SecondaryButtonStyle` button |
| **Tab bar and navigation** | Brand tint on the selected tab; large navigation titles on the four root screens, inline on Request Detail |

Row views keep `accessibilityElement(children: .ignore)` with their current spoken label, so adding badges and icons does not change what VoiceOver reads or what UI tests see.

## Implementation phases

Four sequential phases, each sized for one agent session. Each ends with green tests, an updated `docs/PROGRESS.md` including the commit map, and a build that can be demoed.

No pull requests. Work on a branch `phase/<id>-<short-name>`; when the phase is done, fast-forward `main` to it, push `main`, and delete the branch.

### 2A. Theme and shared components

- [ ] Before changing anything, extend `ScreenshotUITests` to capture all five screens plus the Nearby empty state, each in light and dark, and save the Phase 1 look to `docs/screenshots/phase-1/` as the "before" set
- [ ] `RGBColor`, `AdaptiveColor`, `Theme`, `RequestCategory+Color`, `RequestStatus+Color`
- [ ] `CategoryIcon`, `StatusBadge`, `TagBadge`, `PrimaryButtonStyle`, `SecondaryButtonStyle`, `MessageView`, each with a light and dark `#Preview`; optional symbol on `FactRow`
- [ ] Brand tint on `RootView`; `AccentColor` asset filled in
- [ ] Tests in `FavorlyFeaturesTests`: hex parsing; contrast ratio against two known pairs (black on white is 21:1); every palette color, as text on its own 14% tint over the system grouped background (`#F2F2F7` light, `#1C1C1E` dark) and over plain white and black, reaches 4.5:1; white on `brand` (light) and black on `brand` (dark) reach 4.5:1 for the primary button; every category and status maps to a color

**Done when:** `swift test` and `xcodebuild test` pass; the app looks the same as before except for the tint; the "before" screenshots are committed.

### 2B. Nearby and Request Detail

- [ ] `RequestRow` and `NearbyView` restyled as in *Screen by screen*
- [ ] `RequestDetailView` header, facts with symbols, full-width action buttons, error banner
- [ ] Capture screenshots in light, dark and at `accessibility-large`, and check each one by eye for clipping, truncation and overlap
- [ ] Guardrail checks: the four behavior UI test classes pass unedited; the Core, Data and view model diff is empty

**Done when:** Flow 2 from [PLAN.md](PLAN.md) works by hand and through `BrowseAndPickUpUITests`, and the new screenshots are in `docs/screenshots/`.

**Review gate.** Stop here and show the team the Nearby and Request Detail screenshots next to the Phase 1 ones. Palette or component changes requested now are edits to `Theme` and the shared components only. Record the outcome in `docs/PROGRESS.md` before starting 2C.

### 2C. Post, My Activity and Dev Settings

- [ ] `PostRequestView` restyled: headers, validation messages, location row, primary button
- [ ] `ActivityRow` and `ActivityView` restyled: icon, status badge, "New" badge, highlighted row, empty states
- [ ] `DevSettingsView` touches
- [ ] Screenshots in light, dark and at `accessibility-large`, checked by eye
- [ ] Guardrail checks as in 2B

**Done when:** the full demo script in the README works by hand and through `DemoFlowUITests`, and no screen still uses Phase 1 styling.

### 2D. Polish, icon, docs

- [ ] Consistency pass: search `FavorlyFeatures` for literal colors (`.red`, `.blue`, `Color(`), corner radii and padding numbers outside `Shared/Theme/`, and replace them with theme values
- [ ] Accessibility pass: every screen at the largest accessibility text size, with Increase Contrast on, and with Reduce Transparency on; VoiceOver labels unchanged
- [ ] App icon and `MARKETING_VERSION` `0.2.0`
- [ ] README: new screenshots (light), one dark-mode screenshot, link to this plan; `docs/ARCHITECTURE.md`: a short "Theme" section stating the one-source-of-style rule
- [ ] SwiftLint and SwiftFormat clean; no compiler warnings
- [ ] Tag `v0.2.0-ui`

**Done when:** the *Definition of done* in the Overview is met on a fresh clone.

## Testing and review

- **Automated.** The Phase 1 suite is the regression net for behavior: 125 package tests and the UI tests, unedited. New package tests cover the theme's math and mappings. Nothing tests how a screen looks pixel by pixel; snapshot testing would need a third-party library and is not worth it at this size.
- **By eye.** `ScreenshotUITests` produces the same set of images every time, so before and after can be compared side by side. The agent checks each image after each phase; the team approves at the review gate and at the end.
- **By hand.** The demo script in the README, run once in light mode and once in dark mode at the end of 2C.

## Conventions for coding agents

Everything in [PLAN.md](PLAN.md)'s conventions and in `CLAUDE.md` still applies, with these changes for Phase 2:

- "Keep the UI plain" becomes "style only through `Theme` and the shared components". A literal color or size in a screen file is a defect.
- New components are views with no logic, so they need previews, not tests. Anything with logic (`RGBColor`, the color mappings) needs tests in the same phase.
- No third-party dependencies, no custom fonts, no image assets other than the app icon.
- When a look is a judgment call, pick the plainer option and note it in `docs/PROGRESS.md`.
