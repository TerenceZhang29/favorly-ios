import FavorlyCore
import FavorlyData
@testable import FavorlyFeatures
import Testing

struct AvatarColorTests {
    @Test func avatarColorsComeFromTheColorfulPaletteEntries() {
        #expect(Theme.Colors.avatars.allSatisfy { Theme.Colors.palette.contains($0) })
        #expect(!Theme.Colors.avatars.contains(Theme.Colors.neutral))
        #expect(!Theme.Colors.avatars.contains(Theme.Colors.statusCancelled))
    }

    @Test func theFourDemoUsersGetFourDifferentColors() {
        let colors = DemoUsers.all.map(\.id.avatarColor)
        #expect(Set(colors).count == 4)
    }

    @Test func aUsersColorDependsOnlyOnTheirID() {
        #expect(UserID(rawValue: "user-bea").avatarColor == DemoUsers.bea.id.avatarColor)
        #expect(DemoUsers.alex.id.avatarColor == Theme.Colors.categoryCar)
        #expect(DemoUsers.bea.id.avatarColor == Theme.Colors.categoryMoving)
        #expect(DemoUsers.chen.id.avatarColor == Theme.Colors.categoryIngredient)
        #expect(DemoUsers.dana.id.avatarColor == Theme.Colors.categoryErrand)
        #expect(UserID(rawValue: "").avatarColor == Theme.Colors.brand)
    }

    @Test func avatarSizeMatchesThePlan() {
        #expect(Theme.IconSize.avatar == 64)
    }
}
