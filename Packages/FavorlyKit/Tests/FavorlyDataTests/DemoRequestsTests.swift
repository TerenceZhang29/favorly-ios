import FavorlyCore
import FavorlyData
import Foundation
import Testing

struct DemoRequestsTests {
    let now = Date(timeIntervalSince1970: 1_000_000)
    var requests: [HelpRequest] { DemoRequests.all(now: now) }

    private func miles(_ request: HelpRequest) -> Double {
        Distance.meters(from: LocationPresets.cornellTech.location.point, to: request.location.point)
            / Distance.metersPerMile
    }

    @Test func seedHasTwelveRequestsWithStableUniqueIDs() {
        #expect(requests.count == 12)
        #expect(Set(requests.map(\.id)).count == 12)
        #expect(requests.map(\.id) == DemoRequests.all(now: now.addingTimeInterval(3600)).map(\.id))
    }

    @Test func noneBelongToAlexAndEveryRequesterIsADemoUser() {
        let demoUserIDs = Set(DemoUsers.all.map(\.id))
        #expect(requests.allSatisfy { $0.requesterID != DemoUsers.alex.id })
        #expect(requests.allSatisfy { demoUserIDs.contains($0.requesterID) })
    }

    @Test func everyCategoryIsCovered() {
        #expect(Set(requests.map(\.category)) == Set(RequestCategory.allCases))
    }

    @Test func mostAreOpenWithOneClaimedAndOneCompleted() {
        #expect(requests.count(where: { $0.status == .open }) == 10)
        #expect(requests.count(where: { $0.status == .claimed }) == 1)
        #expect(requests.count(where: { $0.status == .completed }) == 1)
        #expect(requests.allSatisfy { ($0.status == .open) == ($0.helperID == nil) })
        #expect(requests.allSatisfy { ($0.helperID == nil) == ($0.claimedAt == nil) })
    }

    @Test func distancesFromCornellTechAreSpreadAsPlanned() {
        #expect(requests.count(where: { miles($0) <= 0.5 }) == 6)
        #expect(requests.count(where: { miles($0) > 0.5 && miles($0) <= 1.5 }) == 3)
        #expect(requests.count(where: { miles($0) > 3 }) == 3)
    }

    @Test func timestampsAreInThePastRelativeToNow() {
        #expect(requests.allSatisfy { $0.createdAt < now })
        #expect(requests.allSatisfy { ($0.claimedAt ?? now) > $0.createdAt })
    }
}
