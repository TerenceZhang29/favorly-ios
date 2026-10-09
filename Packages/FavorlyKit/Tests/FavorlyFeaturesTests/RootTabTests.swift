@testable import FavorlyFeatures
import Testing

@Test func rootHasFiveTabsInDemoOrder() {
    #expect(RootTab.allCases == [.nearby, .post, .activity, .profile, .devSettings])
    #expect(RootTab.profile.title == "Profile")
    #expect(RootTab.profile.systemImage == "person.crop.circle")
}

@Test func rootTabsHaveDistinctTitlesAndIcons() {
    #expect(Set(RootTab.allCases.map(\.title)).count == RootTab.allCases.count)
    #expect(Set(RootTab.allCases.map(\.systemImage)).count == RootTab.allCases.count)
}
