import FavorlyCore
import FavorlyData
@testable import FavorlyFeatures
import SwiftUI
import Testing

@MainActor
struct AppEnvironmentTests {
    private func makeEnvironment() -> AppEnvironment {
        let locationSettings = MockLocationSettings()
        let repository = MockRequestRepository(artificialDelay: .zero)
        return AppEnvironment(
            repository: repository,
            kindness: repository,
            reviews: repository,
            chat: repository,
            locationProvider: MockLocationProvider(settings: locationSettings),
            session: MockSessionStore(),
            locationSettings: locationSettings
        )
    }

    @Test func debugSummaryNamesTheUserAndLocation() {
        #expect(makeEnvironment().debugSummary == "Alex @ Cornell Tech, Roosevelt Island")
    }

    @Test func debugSummaryFollowsUserAndLocationChanges() {
        let environment = makeEnvironment()
        environment.session.switchUser(to: DemoUsers.bea.id)
        environment.locationSettings.selectedPreset = LocationPresets.ithaca
        #expect(environment.debugSummary == "Bea @ Ithaca, NY")
    }

    @Test func locationProviderFollowsTheSharedLocationSettings() async throws {
        let environment = makeEnvironment()
        environment.locationSettings.selectedPreset = LocationPresets.midtownEast
        #expect(try await environment.locationProvider.currentLocation() == LocationPresets.midtownEast.location)

        environment.locationSettings.simulatesError = true
        await #expect(throws: FavorlyError.locationUnavailable) {
            try await environment.locationProvider.currentLocation()
        }
    }

    @Test func previewEnvironmentIsSelfConsistent() async throws {
        let environment = AppEnvironment.preview()
        #expect(environment.session.availableUsers.contains(environment.session.currentUser))
        #expect(environment.locationSettings.presets.contains(environment.locationSettings.selectedPreset))

        let here = try await environment.locationProvider.currentLocation()
        #expect(here == environment.locationSettings.selectedPreset.location)
        #expect(try await !environment.repository.nearby(around: here.point, radiusMeters: 1000).isEmpty)
    }

    @Test func environmentValuesDefaultToThePreviewEnvironment() {
        let environment = EnvironmentValues().appEnvironment
        #expect(environment.debugSummary == AppEnvironment.preview().debugSummary)
    }

    @Test func previewSessionSwitchesBetweenItsUsers() throws {
        let session = AppEnvironment.preview().session
        let other = try #require(session.availableUsers.first { $0 != session.currentUser })
        session.switchUser(to: other.id)
        #expect(session.currentUser == other)
    }

    @Test func previewRepositoryIsReadOnly() async throws {
        let environment = AppEnvironment.preview()
        let user = environment.session.currentUser.id
        let here = try await environment.locationProvider.currentLocation()
        let first = try #require(try await environment.repository.nearby(around: here.point, radiusMeters: 1000).first)

        #expect(try await environment.repository.request(id: first.id) == first.request)
        await #expect(throws: FavorlyError.notAllowed) {
            try await environment.repository.claim(first.id, by: user)
        }
        await #expect(throws: FavorlyError.notAllowed) {
            try await environment.repository.create(
                NewRequestDraft(title: "Need rice", details: "", category: .other, location: here),
                by: user
            )
        }
    }
}
