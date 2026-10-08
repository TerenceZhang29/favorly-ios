import FavorlyCore
@testable import FavorlyFeatures
import SwiftUI
import Testing

struct ThemeTests {
    /// Spelled out because macOS has an old system type with the same name.
    private typealias RGBColor = FavorlyFeatures.RGBColor

    /// WCAG AA for normal-size text.
    private let minimumContrast = 4.5

    /// The surfaces a colored element sits on: the system grouped background and the plain one.
    private func backgrounds(for colorScheme: ColorScheme) -> [RGBColor] {
        colorScheme == .dark
            ? [RGBColor(hex: 0x1C1C1E), RGBColor(hex: 0x000000)]
            : [RGBColor(hex: 0xF2F2F7), RGBColor(hex: 0xFFFFFF)]
    }

    @Test(arguments: Theme.Colors.palette, [ColorScheme.light, .dark])
    func everyPaletteColorIsReadableOnItsOwnTint(color: AdaptiveColor, colorScheme: ColorScheme) {
        let foreground = color.rgb(for: colorScheme)
        for background in backgrounds(for: colorScheme) {
            let tint = foreground.blended(over: background, opacity: Theme.tintOpacity)
            #expect(foreground.contrastRatio(with: tint) >= minimumContrast)
        }
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func primaryButtonLabelIsReadableOnTheBrandColor(colorScheme: ColorScheme) {
        let label = Theme.Colors.onBrand.rgb(for: colorScheme)
        let fill = Theme.Colors.brand.rgb(for: colorScheme)
        #expect(label.contrastRatio(with: fill) >= minimumContrast)
    }

    @Test func primaryButtonLabelIsWhiteInLightModeAndBlackInDarkMode() {
        #expect(Theme.Colors.onBrand == AdaptiveColor(light: 0xFFFFFF, dark: 0x000000))
    }

    @Test func adaptiveColorPicksTheValueForTheColorScheme() {
        let color = AdaptiveColor(light: 0x0A6B67, dark: 0x4FD1C5)
        #expect(color.rgb(for: .light) == RGBColor(hex: 0x0A6B67))
        #expect(color.rgb(for: .dark) == RGBColor(hex: 0x4FD1C5))
    }

    @Test func everyCategoryMapsToItsColor() {
        #expect(RequestCategory.allCases.map(\.color) == [
            Theme.Colors.categoryIngredient,
            Theme.Colors.categoryMoving,
            Theme.Colors.categoryCar,
            Theme.Colors.categoryErrand,
            Theme.Colors.neutral,
        ])
        #expect(Set(RequestCategory.allCases.map(\.color)).count == RequestCategory.allCases.count)
    }

    @Test func everyStatusMapsToItsColor() {
        #expect(RequestStatus.open.color == Theme.Colors.brand)
        #expect(RequestStatus.claimed.color == Theme.Colors.statusClaimed)
        #expect(RequestStatus.completed.color == Theme.Colors.neutral)
        #expect(RequestStatus.cancelled.color == Theme.Colors.statusCancelled)
    }

    @Test func spacingAndRadiusMatchThePlan() {
        #expect(Theme.Spacing.small == 4)
        #expect(Theme.Spacing.medium == 8)
        #expect(Theme.Spacing.large == 12)
        #expect(Theme.Spacing.xLarge == 16)
        #expect(Theme.Spacing.section == 24)
        #expect(Theme.Radius.badge == 6)
        #expect(Theme.Radius.tile == 10)
        #expect(Theme.Radius.button == 12)
        #expect(Theme.tintOpacity == 0.14)
    }
}
