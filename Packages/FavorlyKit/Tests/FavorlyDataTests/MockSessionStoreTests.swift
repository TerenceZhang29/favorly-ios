import FavorlyCore
import FavorlyData
import Testing

@MainActor
struct MockSessionStoreTests {
    @Test func startsAsAlexWithAllDemoUsersAvailable() {
        let session = MockSessionStore()
        #expect(session.currentUser == DemoUsers.alex)
        #expect(session.availableUsers == DemoUsers.all)
    }

    @Test func switchUserChangesTheCurrentUser() {
        let session = MockSessionStore()
        session.switchUser(to: DemoUsers.bea.id)
        #expect(session.currentUser == DemoUsers.bea)
    }

    @Test func switchingToAnUnknownUserIsIgnored() {
        let session = MockSessionStore()
        session.switchUser(to: UserID(rawValue: "user-nobody"))
        #expect(session.currentUser == DemoUsers.alex)
    }
}
