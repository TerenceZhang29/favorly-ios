@testable import FavorlyFeatures
import Testing

@Test func rootHasFourTabsInDemoOrder() {
    #expect(RootTab.allCases == [.nearby, .post, .activity, .devSettings])
}

@Test func rootTabsHaveDistinctTitlesAndIcons() {
    #expect(Set(RootTab.allCases.map(\.title)).count == RootTab.allCases.count)
    #expect(Set(RootTab.allCases.map(\.systemImage)).count == RootTab.allCases.count)
}
