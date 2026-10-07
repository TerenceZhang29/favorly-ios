import FavorlyCore
import FavorlyData
import Testing

struct DemoUsersTests {
    @Test func fourUsersWithThePlannedIDs() {
        #expect(DemoUsers.all.map(\.displayName) == ["Alex", "Bea", "Chen", "Dana"])
        #expect(DemoUsers.all.map(\.id.rawValue) == ["user-alex", "user-bea", "user-chen", "user-dana"])
    }
}
