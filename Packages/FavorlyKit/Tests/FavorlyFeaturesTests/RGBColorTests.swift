@testable import FavorlyFeatures
import Testing

struct RGBColorTests {
    private let black = RGBColor(hex: 0x000000)
    private let white = RGBColor(hex: 0xFFFFFF)

    @Test func hexIsSplitIntoRedGreenAndBlue() {
        let color = RGBColor(hex: 0x0A6B67)
        #expect(color == RGBColor(red: 10.0 / 255, green: 107.0 / 255, blue: 103.0 / 255))
        #expect(white == RGBColor(red: 1, green: 1, blue: 1))
        #expect(black == RGBColor(red: 0, green: 0, blue: 0))
    }

    @Test func luminanceRunsFromBlackToWhite() {
        #expect(black.relativeLuminance == 0)
        #expect(abs(white.relativeLuminance - 1) < 0.0001)
        #expect(abs(RGBColor(hex: 0xFF0000).relativeLuminance - 0.2126) < 0.0001)
    }

    @Test func contrastRatioMatchesKnownPairs() {
        #expect(abs(black.contrastRatio(with: white) - 21) < 0.001)
        // #767676 is the well-known lightest gray that passes 4.5:1 on white.
        #expect(abs(RGBColor(hex: 0x767676).contrastRatio(with: white) - 4.54) < 0.01)
    }

    @Test func contrastRatioIgnoresOrderAndIsOneForEqualColors() {
        #expect(white.contrastRatio(with: black) == black.contrastRatio(with: white))
        #expect(white.contrastRatio(with: white) == 1)
    }

    @Test func blendingMixesTowardTheBackground() {
        #expect(black.blended(over: white, opacity: 1) == black)
        #expect(black.blended(over: white, opacity: 0) == white)
        #expect(black.blended(over: white, opacity: 0.5) == RGBColor(red: 0.5, green: 0.5, blue: 0.5))
    }
}
